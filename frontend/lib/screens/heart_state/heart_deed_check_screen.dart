import 'package:flutter/material.dart';
import 'package:qalbcare/models/heart_state_model.dart';
import 'package:qalbcare/services/firestore_service.dart';
import 'package:qalbcare/utils/constants.dart';
import 'package:qalbcare/widgets/islamic_loading_indicator.dart';

class HeartDeedCheckScreen extends StatefulWidget {
  final HeartState heartState;

  const HeartDeedCheckScreen({super.key, required this.heartState});

  @override
  State<HeartDeedCheckScreen> createState() => _HeartDeedCheckScreenState();
}

class _HeartDeedCheckScreenState extends State<HeartDeedCheckScreen> {
  late HeartState _heartState;
  final List<bool> _checkedDeeds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _heartState = widget.heartState;
    // Initialize all deeds as unchecked
    _checkedDeeds.addAll(
        List.generate(_heartState.recommendedDeeds.length, (_) => false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Your Deeds'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: _isLoading
          ? LoadingStates.savingData()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildDeedsList(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 48,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 16),
            const Text(
              'Mark the deeds you have completed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Day ${_heartState.day} of your heart healing journey',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeedsList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Recommended Deeds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _heartState.recommendedDeeds.length,
              (index) => _buildDeedCheckItem(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeedCheckItem(int index) {
    return CheckboxListTile(
      title: Text(
        _heartState.recommendedDeeds[index],
        style: TextStyle(
          fontSize: 16,
          fontWeight:
              _checkedDeeds[index] ? FontWeight.bold : FontWeight.normal,
          color: _checkedDeeds[index] ? AppColors.primaryGreen : Colors.black87,
        ),
      ),
      value: _checkedDeeds[index],
      activeColor: AppColors.primaryGreen,
      checkColor: Colors.white,
      onChanged: (bool? value) {
        setState(() {
          _checkedDeeds[index] = value ?? false;
        });
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      controlAffinity: ListTileControlAffinity.leading,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _updateHeartState,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> _updateHeartState() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate how many deeds were completed
      final completedCount = _checkedDeeds.where((checked) => checked).length;
      final totalDeeds = _heartState.recommendedDeeds.length;

      // Add completed deeds to the list
      final List<String> newCompletedDeeds = [];
      for (int i = 0; i < _checkedDeeds.length; i++) {
        if (_checkedDeeds[i]) {
          newCompletedDeeds.add(_heartState.recommendedDeeds[i]);
        }
      }

      // Update heart health percentage based on completed deeds
      double healthIncrease = 0;
      if (totalDeeds > 0) {
        healthIncrease =
            (completedCount / totalDeeds) * 10; // Max 10% increase per day
      }

      // Only advance to next day if at least some deeds were completed
      final shouldAdvanceDay = completedCount > 0;
      final nextDay = shouldAdvanceDay ? _heartState.day + 1 : _heartState.day;
      
      List<String> nextDayTasks;
      if (shouldAdvanceDay && nextDay <= 7) {
        // Get tasks for the next day
        nextDayTasks = HeartHealingJourney.dailyTasks[nextDay]?.cast<String>() ?? [];
      } else if (!shouldAdvanceDay) {
        // Keep current day's tasks if no deeds completed
        nextDayTasks = _heartState.recommendedDeeds;
      } else {
        // Journey complete
        nextDayTasks = [];
      }

      // Create updated heart state
      final updatedHeartState = HeartState(
        date: DateTime.now().toString().split(' ')[0], // Use date format
        answers: _heartState.answers, // Keep existing answers
        healthPercentage: _heartState.healthPercentage + healthIncrease,
        day: nextDay, // Only advance if deeds completed
        recommendedDeeds: nextDayTasks,
        completedDeeds: [..._heartState.completedDeeds, ...newCompletedDeeds],
      );

      // Save updated heart state to Firestore
      await FirestoreService().saveQalbState(updatedHeartState);

      // Show success message first
      if (!mounted) return;

      // Show completion dialog immediately
      if (nextDay > 7) {
        _showJourneyCompletionDialog(updatedHeartState);
      } else {
        _showNextDayTasksDialog(updatedHeartState, nextDay);
      }
    } catch (e) {
      // Show error message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showJourneyCompletionDialog(HeartState updatedState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Journey Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Congratulations! You have completed your 7-day heart healing journey.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Your heart health is now at ${updatedState.healthPercentage.toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to main screen
              },
              child: const Text('Continue'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  void _showNextDayTasksDialog(HeartState updatedState, int nextDay) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Day $nextDay Tasks Ready!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryGreen,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Great progress! Here are your tasks for tomorrow:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...updatedState.recommendedDeeds.take(3).map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.arrow_right,
                          color: AppColors.primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
              if (updatedState.recommendedDeeds.length > 3)
                const Text(
                  '...and more tasks await you!',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to journey screen
              },
              child: const Text('Continue Journey'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
