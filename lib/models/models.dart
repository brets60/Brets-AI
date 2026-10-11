class FeedbackItem {
  final String id;
  final String userAnswer;
  final String suggestions;
  final String correctedSentence;
  final List<String> errorWords; // Words to highlight in red badge
  final String category;
  final String originalMistakeNote;
  bool isPracticed;

  FeedbackItem({
    required this.id,
    required this.userAnswer,
    required this.suggestions,
    required this.correctedSentence,
    required this.errorWords,
    required this.category,
    required this.originalMistakeNote,
    this.isPracticed = false,
  });
}

class AssessmentPoint {
  final String dateLabel;
  final double fluency;
  final double grammar;
  final double pronunciation;
  final double vocabulary;
  final double overall;

  AssessmentPoint({
    required this.dateLabel,
    required this.fluency,
    required this.grammar,
    required this.pronunciation,
    required this.vocabulary,
    required this.overall,
  });
}

class PracticeScenario {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'General', 'Interview', 'Business'
  final String dateTag;
  final String iconType;

  PracticeScenario({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.dateTag,
    required this.iconType,
  });
}
