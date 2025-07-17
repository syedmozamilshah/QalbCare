class HeartQuestion {
  final String question;
  final String id;
  final List<String> options;
  final int correctOptionIndex;

  HeartQuestion({
    required this.question,
    required this.id,
    required this.options,
    required this.correctOptionIndex,
  });
}

class HeartState {
  final String date;
  final Map<String, int> answers; // questionId -> selectedOptionIndex
  final double healthPercentage;
  final int day; // Day in the 7-day journey (1-7)
  final List<String> recommendedDeeds;
  final List<String> completedDeeds;

  HeartState({
    required this.date,
    required this.answers,
    required this.healthPercentage,
    required this.day,
    required this.recommendedDeeds,
    required this.completedDeeds,
  });

  factory HeartState.fromJson(Map<String, dynamic> json) {
    return HeartState(
      date: json['date'],
      answers: Map<String, int>.from(json['answers']),
      healthPercentage: (json['healthPercentage'] as num).toDouble(),
      day: json['day'],
      recommendedDeeds: List<String>.from(json['recommendedDeeds']),
      completedDeeds: List<String>.from(json['completedDeeds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'answers': answers,
        'healthPercentage': healthPercentage,
        'day': day,
        'recommendedDeeds': recommendedDeeds,
        'completedDeeds': completedDeeds,
      };
}