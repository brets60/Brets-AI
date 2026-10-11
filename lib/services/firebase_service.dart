import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class FirebaseService {
  static const String projectId = 'breta-ai-demo';
  static String? userAuthToken;
  static const String currentUserId = 'ross_demo';

  /// Initialize Firebase service
  static Future<void> initialize() async {
    // REST initialized
  }

  /// Fetch assessment history for the trend chart (Image 5)
  static Future<List<AssessmentPoint>> getAssessmentHistory() async {
    if (userAuthToken != null) {
      try {
        final url = Uri.parse(
          'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/learning_progress',
        );
        final res = await http.get(url, headers: {'Authorization': 'Bearer $userAuthToken'});
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final docs = data['documents'] as List?;
          if (docs != null && docs.isNotEmpty) {
            return docs.map((doc) {
              final fields = doc['fields'] as Map<String, dynamic>;
              final dateStr = fields['practiceDate']?['stringValue'] ?? 'Sep 1';
              return AssessmentPoint(
                dateLabel: dateStr.length >= 10 ? dateStr.substring(5) : dateStr,
                fluency: (fields['fluencyScore']?['doubleValue'] ?? 0.0).toDouble(),
                grammar: (fields['grammarScore']?['doubleValue'] ?? 0.0).toDouble(),
                pronunciation: (fields['pronunciationScore']?['doubleValue'] ?? 0.0).toDouble(),
                vocabulary: (fields['vocabularyScore']?['doubleValue'] ?? 0.0).toDouble(),
                overall: (fields['overallScore']?['doubleValue'] ?? 0.0).toDouble(),
              );
            }).toList();
          }
        }
      } catch (_) {}
    }

    // Default Seed Baseline matching Image 5
    return [
      AssessmentPoint(dateLabel: 'Sep 1', overall: 63, fluency: 30, grammar: 40, pronunciation: 90, vocabulary: 92),
      AssessmentPoint(dateLabel: 'Sep 8', overall: 66, fluency: 35, grammar: 45, pronunciation: 95, vocabulary: 88),
      AssessmentPoint(dateLabel: 'Sep 15', overall: 66, fluency: 40, grammar: 50, pronunciation: 85, vocabulary: 90),
      AssessmentPoint(dateLabel: 'Sep 22', overall: 72, fluency: 45, grammar: 55, pronunciation: 92, vocabulary: 95),
      AssessmentPoint(dateLabel: 'Sep 29', overall: 76, fluency: 50, grammar: 60, pronunciation: 98, vocabulary: 97),
      AssessmentPoint(dateLabel: 'Oct 6', overall: 77.5, fluency: 55, grammar: 65, pronunciation: 96, vocabulary: 94),
      AssessmentPoint(dateLabel: 'Oct 13', overall: 78.5, fluency: 60, grammar: 70, pronunciation: 93, vocabulary: 91),
    ];
  }

  /// Fetch feedback corrections (Image 4)
  static Future<List<FeedbackItem>> getCorrections() async {
    return [
      FeedbackItem(
        id: '1',
        userAnswer:
            'Last summer I went to the beach with my family. It was amazing, we swim in the sea and eat a lot of ice cream.',
        suggestions:
            'In your response, there are several verb tense errors. In the sentences "we swim in the sea" and "we eat a lot of ice cream", past tense should be used: "we swam" and "we ate". These errors relate to verb tenses and the correct usage of past forms.',
        correctedSentence:
            'Last summer I went to the beach with my family. It was amazing, we swam in the sea and ate a lot of ice cream.',
        errorWords: ['swam', 'ate'],
        category: 'Past Simple Irregular Verbs',
        originalMistakeNote: 'Verb tense consistency in past narrative',
        isPracticed: true,
      ),
      FeedbackItem(
        id: '2',
        userAnswer: 'I am working as developer since three years in Manila.',
        suggestions:
            'When describing an action that started in the past and continues into the present, use the Present Perfect Continuous ("have been working") with "for" instead of "since" for durations.',
        correctedSentence:
            'I have been working as a developer for three years in Manila.',
        errorWords: ['have', 'been', 'working', 'for'],
        category: 'Present Perfect Continuous',
        originalMistakeNote: 'Duration preposition error',
        isPracticed: false,
      ),
    ];
  }

  /// Mark correction as practiced
  static Future<void> markPracticed(String correctionId) async {
    // Marks locally
  }
}
