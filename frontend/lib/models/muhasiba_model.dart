import 'package:flutter/material.dart';

class MuhasibaQuestion {
  final String question;
  final String id;
  final IconData icon;

  MuhasibaQuestion({
    required this.question,
    required this.id,
    required this.icon,
  });
}

class DailyRecord {
  final String date;
  final Map<String, bool> answers;
  final double progressPercentage;

  DailyRecord({
    required this.date,
    required this.answers,
    required this.progressPercentage,
  });

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      date: json['date'],
      answers: Map<String, bool>.from(json['answers']),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'answers': answers,
        'progressPercentage': progressPercentage,
      };
}