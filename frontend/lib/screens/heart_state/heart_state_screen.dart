import 'package:flutter/material.dart';
import 'package:qalbcare/models/heart_state_model.dart';
import 'package:qalbcare/services/firestore_service.dart';
import 'package:qalbcare/utils/constants.dart';
import 'package:qalbcare/screens/heart_state/heart_question_card.dart';
import 'package:qalbcare/screens/heart_state/heart_result_screen.dart';
import 'package:qalbcare/screens/heart_state/heart_journey_screen.dart';
import 'package:qalbcare/widgets/islamic_loading_indicator.dart';

class HeartStateScreen extends StatefulWidget {
  const HeartStateScreen({super.key});

  @override
  State<HeartStateScreen> createState() => _HeartStateScreenState();
}

class _HeartStateScreenState extends State<HeartStateScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  
  // Filter dropdown options
  final Map<String, int?> _filterOptions = {
    'Last 1 Day': 1,
    'Last 7 Days': 7,
    'Last 30 Days': 30,
    'All Time': null,
  };
  final String _selectedFilter = 'Last 7 Days';
  
  bool _isLoading = true;
  HeartState? _heartState;
  List<HeartState> _heartStateHistory = [];
  bool _showInitialDialog = false;
  int _currentQuestionIndex = 0;
  final Map<String, int> _answers = {};

  @override
  void initState() {
    super.initState();
    _loadHeartState();
  }

  Future<void> _loadHeartState() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load heart state history with current filter
      final filterDays = _filterOptions[_selectedFilter];
      _heartStateHistory = await _firestoreService.getQalbStateHistory(lastDays: filterDays);
      
      final heartState = await _firestoreService.getLatestQalbState();
      
      // Check if we need to show the initial dialog
      bool showDialog = false;

      if (heartState == null) {
        // First time user
        showDialog = true;
      } else {
        // Check if 7-day journey is complete and it's been more than 7 days
        final lastStateDate = DateTime.parse(heartState.date);
        final daysSinceLastState = DateTime.now().difference(lastStateDate).inDays;
        
        if (heartState.day > 7 && daysSinceLastState >= 7) {
          // Journey complete and 7 days passed, allow new assessment
          showDialog = true;
        } else if (heartState.day > 7) {
          // Journey complete but less than 7 days, show result
          showDialog = false;
        } else {
          // Journey in progress, check if user missed days
          if (daysSinceLastState > 1) {
            // User missed days, auto-advance to current day
            final newDay = (heartState.day + daysSinceLastState).clamp(1, 8);
            final newTasks = newDay <= 7 ? HeartHealingJourney.dailyTasks[newDay] ?? [] : [];
            
            final updatedHeartState = HeartState(
              date: DateTime.now().toString().split(' ')[0],
              answers: heartState.answers,
              healthPercentage: heartState.healthPercentage,
              day: newDay,
              recommendedDeeds: newTasks.cast<String>(),
              completedDeeds: heartState.completedDeeds,
            );
            
            await _firestoreService.saveQalbState(updatedHeartState);
            setState(() {
              _heartState = updatedHeartState;
            });
          } else {
            setState(() {
              _heartState = heartState;
            });
          }
          showDialog = false;
        }
      }

      setState(() {
        _isLoading = false;
        _showInitialDialog = showDialog;
      });

      if (_showInitialDialog) {
        // Use a post-frame callback to show dialog after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showHeartStateDialog();
        });
      } else if (_heartState != null) {
        // Navigate to appropriate screen based on heart state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_heartState!.day <= 7 && _heartState!.recommendedDeeds.isNotEmpty) {
            // We're in the middle of a journey
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    HeartJourneyScreen(heartState: _heartState!),
              ),
            );
          } else {
            // Show the result screen with history
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HeartResultScreen(
                  heartState: _heartState!,
                  history: _heartStateHistory,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading heart state: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showHeartStateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Heart State Check',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        content: const Text(
          'Would you like to check the state of your heart - whether it\'s alive or in need of revival?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startHeartAssessment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _startHeartAssessment() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
    });
  }

  void _answerQuestion(String id, int answerIndex) {
    setState(() {
      _answers[id] = answerIndex;

      if (_currentQuestionIndex < HeartQuestions.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _finishAssessment();
      }
    });
  }

  Future<void> _finishAssessment() async {
    // Calculate heart health percentage
    double totalCorrect = 0;
    for (final entry in _answers.entries) {
      final question = HeartQuestions.questions.firstWhere(
        (q) => q['id'] == entry.key,
        orElse: () => {'correctOptionIndex': 0},
      );

      // Give partial credit based on how close the answer is to correct
      final correctIndex = question['correctOptionIndex'] as int;
      final userIndex = entry.value;
      final distance = (correctIndex - userIndex).abs();

      // Calculate score (3 = perfect, 2 = close, 1 = far, 0 = opposite)
      final score = 3 - distance;
      totalCorrect += score / 3; // Convert to 0-1 scale
    }

    final percentage = (totalCorrect / _answers.length) * 100;

    // Get day 1 tasks from the new 7-day healing journey
    final day1Tasks = HeartHealingJourney.dailyTasks[1] ?? [];

    // Create new heart state
    final today = DateTime.now().toString().split(' ')[0];
    final newHeartState = HeartState(
      date: today,
      answers: _answers,
      healthPercentage: percentage,
      day: 1, // Start of journey
      recommendedDeeds: day1Tasks,
      completedDeeds: [],
    );

    // Save heart state to Firestore
    try {
      await _firestoreService.saveQalbState(newHeartState);
      
      // Award gem points for completing qalb state assessment
      await _firestoreService.addQalbStatePoints();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Heart state assessment completed! +50 gem points earned!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }

      // Navigate to result screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HeartResultScreen(
              heartState: newHeartState,
              history: _heartStateHistory,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving heart state: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Heart State'),
          backgroundColor: AppColors.primaryGreen,
        ),
        backgroundColor: AppColors.background,
        body: LoadingStates.analyzingHeartState(),
      );
    }

    // If we're showing questions
    if (_answers.isEmpty ||
        _currentQuestionIndex < HeartQuestions.questions.length) {
      final questions = HeartQuestions.questions;
      final currentQuestion = questions[_currentQuestionIndex];

      return Scaffold(
        appBar: AppBar(
          title: const Text('Heart Assessment'),
          backgroundColor: AppColors.primaryGreen,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex) / questions.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
            Expanded(
              child: HeartQuestionCard(
                question: currentQuestion['question'] as String,
                options: List<String>.from(currentQuestion['options']),
                onAnswer: (index) {
                  _answerQuestion(currentQuestion['id'] as String, index);
                },
              ),
            ),
          ],
        ),
      );
    }

    // This should not happen, but just in case
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart State'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _startHeartAssessment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
          ),
          child: const Text('Start Assessment'),
        ),
      ),
    );
  }
}
