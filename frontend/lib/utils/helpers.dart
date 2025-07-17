import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qalbcare/utils/constants.dart';

class Helpers {
  // Format date for display
  static String formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }

  // Get motivational message based on percentage
  static String getMotivationalMessage(double percentage) {
    if (percentage >= 90) {
      return 'Excellent! Keep up the great spiritual journey!';
    } else if (percentage >= 70) {
      return 'Well done! You\'re making wonderful progress.';
    } else if (percentage >= 50) {
      return 'Good effort! Tomorrow is another opportunity to grow.';
    } else {
      return 'Every step counts. May Allah guide your journey.';
    }
  }

  // Get heart state message based on percentage
  static String getHeartStateMessage(double percentage) {
    if (percentage >= 90) {
      return 'MashaAllah! Your heart is alive and vibrant with faith.';
    } else if (percentage >= 70) {
      return 'Your heart is on the path of healing and growth.';
    } else if (percentage >= 50) {
      return 'Your heart shows signs of life but needs consistent care.';
    } else if (percentage >= 30) {
      return 'Your heart is struggling and needs immediate attention.';
    } else {
      return 'Your heart is in a state of heedlessness. It\'s time to revive it with faith and good deeds.';
    }
  }

  // Get color based on percentage
  static Color getProgressColor(double percentage) {
    if (percentage >= 80) {
      return AppColors.primaryGreen;
    } else if (percentage >= 60) {
      return const Color(0xFF0A7D65);
    } else if (percentage >= 40) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }

  // Generate random Islamic deeds for heart healing
  static List<String> generateRandomDeeds(int count) {
    final random = Random();
    final allDeeds = IslamicDeeds.heartHealingDeeds;
    final selectedDeeds = <String>[];

    // Ensure we don't try to select more deeds than available
    count = min(count, allDeeds.length);

    while (selectedDeeds.length < count) {
      final deed = allDeeds[random.nextInt(allDeeds.length)];
      if (!selectedDeeds.contains(deed)) {
        selectedDeeds.add(deed);
      }
    }

    return selectedDeeds;
  }

  // Generate random Islamic deeds specifically for heart healing
  static List<String> generateRandomIslamicDeeds(int count) {
    return generateRandomDeeds(count); // Reuse the existing method
  }
}
