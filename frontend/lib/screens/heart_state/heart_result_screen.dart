import 'package:flutter/material.dart';
import 'package:qalbcare/models/heart_state_model.dart';
import 'package:qalbcare/services/firestore_service.dart';
import 'package:qalbcare/utils/constants.dart';
import 'package:qalbcare/utils/helpers.dart';
import 'package:qalbcare/screens/heart_state/heart_journey_screen.dart';
import 'package:qalbcare/widgets/islamic_loading_indicator.dart';

class HeartResultScreen extends StatefulWidget {
  final HeartState heartState;

  final List<HeartState> history;

  const HeartResultScreen({super.key, required this.heartState, required this.history});

  @override
State<HeartResultScreen> createState() => _HeartResultScreenState();
}

class _HeartResultScreenState extends State<HeartResultScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<HeartState> _historyRecords = [];
  int _selectedHistoryDays = 7;

  @override
  void initState() {
    super.initState();
    _historyRecords = widget.history;
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select History Range', 
            style: TextStyle(color: AppColors.primaryGreen)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('1 Day'),
                onTap: () {
                  Navigator.of(context).pop();
                  _fetchHistory(1);
                },
              ),
              ListTile(
                title: const Text('3 Days'),
                onTap: () {
                  Navigator.of(context).pop();
                  _fetchHistory(3);
                },
              ),
              ListTile(
                title: const Text('7 Days'),
                onTap: () {
                  Navigator.of(context).pop();
                  _fetchHistory(7);
                },
              ),
              ListTile(
                title: const Text('30 Days'),
                onTap: () {
                  Navigator.of(context).pop();
                  _fetchHistory(30);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchHistory(int days) async {
    setState(() {
      _selectedHistoryDays = days;
    });

    try {
      final records = await _firestoreService.getQalbStateHistory(lastDays: days);
      setState(() {
        _historyRecords = records;
      });

      if (mounted) {
        _showHistorySheet();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Heart State History ($_selectedHistoryDays days)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _historyRecords.isEmpty
                    ? const Center(
                        child: Text(
                          'No history records found for this period.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _historyRecords.length,
                        itemBuilder: (context, index) {
                          final record = _historyRecords[index];
                          final date = DateTime.parse(record.date);
                          final dateStr = '${date.day}/${date.month}/${date.year}';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getHeartIcon(record.healthPercentage),
                                color: Helpers.getProgressColor(record.healthPercentage),
                                size: 30,
                              ),
                              title: Text(
                                'Heart Assessment: $dateStr',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Health: ${record.healthPercentage.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'Journey Day: ${record.day}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: IslamicLoadingIndicator(
                                      size: 25.0,
                                      message: null,
                                      showQuote: false,
                                      primaryColor: Helpers.getProgressColor(record.healthPercentage),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context); // Close history sheet
                                _showHistoryDetailDialog(record);
                              },
                            )
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryDetailDialog(HeartState record) {
    final date = DateTime.parse(record.date);
    final dateStr = '${date.day}/${date.month}/${date.year}';
    final color = Helpers.getProgressColor(record.healthPercentage);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _getHeartIcon(record.healthPercentage),
                color: color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Heart State - $dateStr',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health percentage with progress indicator
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: IslamicLoadingIndicator(
                                size: 60.0,
                                message: null,
                                showQuote: false,
                                primaryColor: color,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getHeartIcon(record.healthPercentage),
                                  size: 30,
                                  color: color,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${record.healthPercentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Helpers.getHeartStateMessage(record.healthPercentage),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Journey information
                _buildDetailRow('Journey Day', '${record.day}'),
                _buildDetailRow('Assessment Date', dateStr),
                _buildDetailRow('Health Score', '${record.healthPercentage.toStringAsFixed(1)}%'),
                
                const SizedBox(height: 16),
                
                // Recommended deeds section
                if (record.recommendedDeeds.isNotEmpty) ...[
                  const Text(
                    'Recommended Deeds:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...record.recommendedDeeds.map((deed) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.primaryGreen)),
                        Expanded(
                          child: Text(
                            deed,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                const SizedBox(height: 16),
                
                // Completed deeds section
                if (record.completedDeeds.isNotEmpty) ...[
                  const Text(
                    'Completed Deeds:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...record.completedDeeds.map((deed) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            deed,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.primaryGreen),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getHeartIcon(double percentage) {
    if (percentage >= 80) {
      return Icons.favorite;
    } else if (percentage >= 60) {
      return Icons.favorite_border;
    } else if (percentage >= 40) {
      return Icons.heart_broken;
    } else {
      return Icons.heart_broken_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.heartState.healthPercentage;
    final message = Helpers.getHeartStateMessage(percentage);
    final color = Helpers.getProgressColor(percentage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart State Result'),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.history,
              color: Colors.white,
            ),
            onPressed: () => _showHistoryDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Your Heart State',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 30),
              HeartStateIndicator(
                percentage: percentage,
                color: color,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getDetailedMessage(percentage),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 30),
              // Display history
              if (widget.history.isNotEmpty) _buildHistorySection(),
              const SizedBox(height: 30),
              _buildActionButtons(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _getDetailedMessage(double percentage) {
    if (percentage >= 90) {
      return 'Your heart is illuminated with faith. Continue to nurture it with good deeds and remembrance of Allah.';
    } else if (percentage >= 70) {
      return 'Your heart shows strong signs of faith. Keep strengthening it with consistent acts of worship and reflection.';
    } else if (percentage >= 50) {
      return 'Your heart has potential for growth. Increase your good deeds and reduce heedlessness to strengthen your faith.';
    } else if (percentage >= 30) {
      return 'Your heart needs attention. Increase your prayers, Quran recitation, and remembrance of Allah to revive it.';
    } else {
      return 'Your heart is yearning for revival. Begin a journey of healing through consistent worship, repentance, and good deeds.';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    // Check if the 7-day journey is complete
    final bool journeyComplete = widget.heartState.day > 7;

    if (journeyComplete) {
      // Show different actions for completed journey
      return Column(
        children: [
          const Text(
            'Congratulations! You have completed your 7-day heart healing journey.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Reset and start new journey
              _startNewJourney(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start New Journey',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }

    // Normal actions for ongoing or starting journey
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigate to journey screen if the user wants to improve their heart
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    HeartJourneyScreen(heartState: widget.heartState),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.heartState.healthPercentage < 50
                ? Colors.red
                : AppColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.heartState.day == 1
                ? (widget.heartState.healthPercentage < 50
                    ? 'Heal My Heart'
                    : 'Start Journey')
                : 'Continue Journey',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Go back to previous screen
          },
          child: const Text(
            'Maybe Later',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Heart State History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.history.map((state) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text(
                  Helpers.formatDate(state.date),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(width: 10),
                const Expanded(
                    child: SizedBox(
                      width: 180,
                      height: 20,
                      child: IslamicLoadingIndicator(
                        size: 20.0,
                        message: null,
                        showQuote: false,
                      ),
                    ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${state.healthPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _startNewJourney(BuildContext context) async {
    // Reset the journey to day 1 with new tasks
    final day1Tasks = HeartHealingJourney.dailyTasks[1] ?? [];

    final newHeartState = HeartState(
      date: DateTime.now().toString().split(' ')[0],
      answers: widget.heartState.answers,
      healthPercentage: widget.heartState.healthPercentage,
      day: 1,
      recommendedDeeds: day1Tasks,
      completedDeeds: [],
    );

    // Save the new heart state
    final firestoreService = FirestoreService();
    await firestoreService.saveQalbState(newHeartState);

    // Navigate to journey screen
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HeartJourneyScreen(heartState: newHeartState),
        ),
      );
    }
  }
}

class HeartStateIndicator extends StatelessWidget {
  final double percentage;
  final Color color;

  const HeartStateIndicator({
    super.key,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[100],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 180,
          height: 180,
          child: IslamicLoadingIndicator(
            size: 120.0,
            message: null,
            showQuote: false,
            primaryColor: color,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getHeartIcon(percentage),
              size: 60,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getHeartIcon(double percentage) {
    if (percentage >= 80) {
      return Icons.favorite;
    } else if (percentage >= 60) {
      return Icons.favorite_border;
    } else if (percentage >= 40) {
      return Icons.heart_broken;
    } else {
      return Icons.heart_broken_outlined;
    }
  }
}
