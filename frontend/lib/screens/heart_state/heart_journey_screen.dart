import 'package:flutter/material.dart';
import 'package:qalbcare/models/heart_state_model.dart';
import 'package:qalbcare/services/storage_service.dart';
import 'package:qalbcare/utils/constants.dart';
import 'package:qalbcare/utils/helpers.dart';
import 'package:qalbcare/screens/heart_state/heart_deed_check_screen.dart';

class HeartJourneyScreen extends StatefulWidget {
  final HeartState heartState;

  const HeartJourneyScreen({super.key, required this.heartState});

  @override
  State<HeartJourneyScreen> createState() => _HeartJourneyScreenState();
}

class _HeartJourneyScreenState extends State<HeartJourneyScreen> {
  late HeartState _heartState;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _heartState = widget.heartState;
    _loadHeartState();
  }

  Future<void> _loadHeartState() async {
    final savedHeartState = await _storageService.getHeartState();
    if (savedHeartState != null) {
      setState(() {
        _heartState = savedHeartState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Healing Journey'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJourneyHeader(),
              const SizedBox(height: 24),
              _buildJourneyProgress(),
              const SizedBox(height: 24),
              _buildRecommendedDeeds(),
              const SizedBox(height: 24),
              if (_heartState.completedDeeds.isNotEmpty) _buildCompletedDeeds(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  HeartDeedCheckScreen(heartState: _heartState),
            ),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.check),
        label: const Text('Check Deeds'),
      ),
    );
  }

  Widget _buildJourneyHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getHeartIcon(_heartState.healthPercentage),
                  size: 40,
                  color: Helpers.getProgressColor(_heartState.healthPercentage),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    HeartHealingJourney.getDayTitle(_heartState.day),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              HeartHealingJourney.getDayDescription(_heartState.day),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Heart Health: ${_heartState.healthPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Helpers.getProgressColor(_heartState.healthPercentage),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Helpers.getHeartStateMessage(_heartState.healthPercentage),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Helpers.getProgressColor(_heartState.healthPercentage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyProgress() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your 7-Day Journey',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final day = index + 1;
                final isCurrentDay = day == _heartState.day;
                final isCompletedDay = day < _heartState.day;

                return Flexible(
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrentDay
                          ? AppColors.primaryGreen
                          : isCompletedDay
                              ? Colors.green[100]
                              : Colors.grey[200],
                      border: Border.all(
                        color: isCurrentDay
                            ? AppColors.primaryGreen
                            : isCompletedDay
                                ? Colors.green
                                : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color: isCurrentDay
                              ? Colors.white
                              : isCompletedDay
                                  ? Colors.green
                                  : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _heartState.day / 7,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedDeeds() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended Deeds for Today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            ..._heartState.recommendedDeeds.map((deed) => _buildDeedItem(deed)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedDeeds() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completed Deeds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            ..._heartState.completedDeeds
                .map((deed) => _buildDeedItem(deed, isCompleted: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeedItem(String deed, {bool isCompleted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              deed,
              style: TextStyle(
                fontSize: 16,
                color: isCompleted ? Colors.green : Colors.black87,
                fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
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
}
