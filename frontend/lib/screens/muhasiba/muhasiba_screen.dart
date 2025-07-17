import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:qalbcare/models/muhasiba_model.dart';
import 'package:qalbcare/screens/muhasiba/muhasiba_result_screen.dart';
import 'package:qalbcare/services/firestore_service.dart';
import 'package:qalbcare/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qalbcare/widgets/islamic_loading_indicator.dart';
import 'package:qalbcare/services/notification_service.dart';

class MuhasibaScreen extends StatefulWidget {
  const MuhasibaScreen({super.key});

  @override
  State<MuhasibaScreen> createState() => _MuhasibaScreenState();
}

// Custom painter for diagonal lines pattern
class DiagonalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

  // Draw diagonal lines from top-left corner extending further (45 degree angle)
    double spacing = 10.0; // Spacing between lines
    // Extend the lines to cover more area, reaching toward the icon
    for (double i = 0; i <= size.width * 1.2; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(0, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DiagonalLinesPainter oldDelegate) => false;
}

class _MuhasibaScreenState extends State<MuhasibaScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final CardSwiperController _cardController = CardSwiperController();
  bool _isLoading = true;
  bool _isCheckingCompletion = true;
  

  final List<MuhasibaQuestion> _questions = [
    MuhasibaQuestion(
        question: "Did you offer all five prayers today?",
        id: "prayer",
        icon: Icons.mosque),
    MuhasibaQuestion(
        question: "Did you recite the Quran today?",
        id: "quran",
        icon: Icons.book),
    MuhasibaQuestion(
        question: "Did you recite Durood at least 100 times today?",
        id: "durood",
        icon: Icons.auto_stories),
    MuhasibaQuestion(
        question:
            "Did you avoid anger in a situation where you could have gotten angry?",
        id: "anger",
        icon: Icons.sentiment_satisfied_alt),
    MuhasibaQuestion(
        question: "Did you help someone today?",
        id: "help",
        icon: Icons.volunteer_activism),
    MuhasibaQuestion(
        question: "Did you speak the truth in all situations today?",
        id: "truth",
        icon: Icons.verified),
    MuhasibaQuestion(
        question: "Did you refrain from backbiting or gossiping today?",
        id: "backbiting",
        icon: Icons.mic_off),
    MuhasibaQuestion(
        question: "Did you maintain good relations with your family today?",
        id: "family",
        icon: Icons.groups),
    MuhasibaQuestion(
        question: "Did you lower your gaze and guard your modesty today?",
        id: "modesty",
        icon: Icons.visibility_off),
    MuhasibaQuestion(
        question: "Did you seek forgiveness (Istighfar) today?",
        id: "istighfar",
        icon: Icons.healing),
  ];

  final Map<String, bool> _answers = {};
  bool _isCompletingAssessment = false;


  Future<void> _checkTodayCompletion() async {
    setState(() {
      _isCheckingCompletion = true;
      _isLoading = true;
    });

    try {
      // Check shared preferences first for daily completion
      final prefs = await SharedPreferences.getInstance();
      final today = NotificationService.formatDate(DateTime.now());
      final lastCompletionDate = prefs.getString('muhasiba_last_completion_date');
      
      if (lastCompletionDate == today) {
        // User already completed today's assessment based on shared preferences
        
        // Fetch today's results to display
        final todayRecords = await _firestoreService.getMuhasibaResults(lastDays: 1);
        if (todayRecords.isNotEmpty && mounted) {
          final todayRecord = todayRecords.first;
          
          // Navigate to results screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MuhasibaResultScreen(
                answers: todayRecord.answers,
                progressPercentage: todayRecord.progressPercentage,
                questions: _questions,
              ),
            ),
          );
        }
      } else {
        // User hasn't completed today's assessment
        setState(() {
          _isCheckingCompletion = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isCheckingCompletion = false;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking today\'s completion: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSwipe(String questionId, bool answer) {
    setState(() {
      _answers[questionId] = answer;
    });
    
    // If this was the last question, finish immediately
    if (_answers.length >= _questions.length) {
      _onFinish();
    }
  }

  void _onFinish() async {
    if (_isCompletingAssessment) return; // Prevent multiple calls
    
    setState(() {
      _isCompletingAssessment = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final answered = _answers.length;
      final correct = _answers.values.where((a) => a).length;
      final percentage = answered > 0 ? (correct / answered) * 100.0 : 0.0;

      final today = NotificationService.formatDate(DateTime.now());
      final newRecord = DailyRecord(
        date: today,
        answers: _answers,
        progressPercentage: percentage,
      );

      await _firestoreService.saveMuhasibaResult(newRecord);
      await _firestoreService.addMuhasibaPoints();
      
      // Save completion date in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('muhasiba_last_submit', today);
      await prefs.setString('muhasiba_last_completion_date', today);

      setState(() {
        _isCompletingAssessment = false;
      });

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MuhasibaResultScreen(
            answers: _answers,
            progressPercentage: percentage,
            questions: _questions,
          ),
        ),
      );
      }
    } catch (e) {
      setState(() {
        _isCompletingAssessment = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking completion
    if (_isCheckingCompletion) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Muhasiba',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          color: const Color(0xFFF8F9FA),
          child: LoadingStates.general('Checking today\'s completion...'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Muhasiba',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Daily Self-Assessment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_answers.length} of ${_questions.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                // Progress Bar
                LinearProgressIndicator(
                  value: _answers.length / _questions.length,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.primaryGreen,
                  minHeight: 8,
                ),
              ],
            ),
          ),
          // Card Swiper
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA), // A very light grey background
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: (_isLoading || _isCompletingAssessment)
                  ? _isCompletingAssessment
                      ? LoadingStates.processingMuhasiba()
                      : LoadingStates.general('Loading muhasiba...')
                  : CardSwiper(
                      controller: _cardController,
                      cardsCount: _questions.length,
                      onSwipe: _handleSwipe,
      padding: const EdgeInsets.symmetric(horizontal: 24),
                      numberOfCardsDisplayed: 1,
                      backCardOffset: const Offset(0, 15),
                      scale: 0.95,
                      cardBuilder: (context, index, percentThresholdX,
                          percentThresholdY) {
                        return _buildMuhasibaCard(_questions[index]);
                      },
                    ),
            ),
          ),
          // Bottom Instructions
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInstructionItem(
                  icon: Icons.swipe_left_outlined,
                  color: Colors.red.shade600,
                  label: 'Swipe Left for No',
                ),
                _buildInstructionItem(
                  icon: Icons.swipe_right_outlined,
                  color: Colors.green.shade700,
                  label: 'Swipe Right for Yes',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuhasibaCard(MuhasibaQuestion question) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Diagonal lines pattern extending further on the card
          Positioned(
            left: 0,
            top: 0,
            width: 200, // Increased width to extend lines further
            height: 200, // Increased height to extend lines further
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
              ),
              child: CustomPaint(
                painter: DiagonalLinesPainter(),
              ),
            ),
          ),
          Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top instruction banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, size: 18, color: Color(0xFF2E7D5E)),
                  SizedBox(width: 8),
                  Text(
                    'Swipe Right for Yes, Left for No',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            // Family icon circle like in reference
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(question.icon, size: 50, color: Colors.white),
              ),
            ),
            // Question text in container box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  bool _handleSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final isYes = direction == CardSwiperDirection.right;
    _onSwipe(_questions[previousIndex].id, isYes);
    return true;
  }


  Widget _buildInstructionItem({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
  
// Check Muhasiba completion and schedule reminder
  void _checkAndScheduleReminder() {
    NotificationService.checkAndScheduleMuhasibaReminder();
  }

  @override
  void initState() {
    super.initState();
    _checkTodayCompletion();
    _checkAndScheduleReminder();
  }
}
