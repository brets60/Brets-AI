import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class BretaApiService {
  // Configurable Supabase Endpoint & Anon Key
  static String supabaseUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://demo.supabase.co');
  static String supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'demo-key');
  static String? userAuthToken;

  /// Fetches the multi-metric assessment history for the trend chart
  static Future<List<AssessmentPoint>> getAssessmentHistory() async {
    // If Supabase is configured with valid token, fetch from Supabase
    if (userAuthToken != null && !supabaseUrl.contains('demo.supabase.co')) {
      try {
        final res = await http.get(
          Uri.parse('$supabaseUrl/rest/v1/learning_progress?order=practice_date.asc'),
          headers: {
            'apikey': supabaseAnonKey,
            'Authorization': 'Bearer $userAuthToken',
          },
        );
        if (res.statusCode == 200) {
          final List data = jsonDecode(res.body);
          if (data.isNotEmpty) {
            return data.map((row) {
              return AssessmentPoint(
                dateLabel: row['practice_date'].toString().substring(5), // MM-DD
                fluency: (row['fluency_score'] as num).toDouble(),
                grammar: (row['grammar_score'] as num).toDouble(),
                pronunciation: (row['pronunciation_score'] as num).toDouble(),
                vocabulary: (row['vocabulary_score'] as num).toDouble(),
                overall: (row['overall_score'] as num).toDouble(),
              );
            }).toList();
          }
        }
      } catch (_) {
        // Fall back to seed baseline
      }
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

  /// Requests a short-lived ephemeral session token from the Edge Function
  static Future<Map<String, dynamic>> requestGeminiLiveToken() async {
    if (userAuthToken != null && !supabaseUrl.contains('demo.supabase.co')) {
      try {
        final res = await http.post(
          Uri.parse('$supabaseUrl/functions/v1/gemini-live-token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userAuthToken',
          },
        );
        if (res.statusCode == 200) {
          return jsonDecode(res.body);
        }
      } catch (_) {}
    }

    // Fallback simulation for offline testing
    return {
      'sessionId': 'session_${DateTime.now().millisecondsSinceEpoch}',
      'model': 'models/gemini-2.0-flash-exp',
      'voicePersona': 'Puck',
      'remainingMinutes': 15,
      'token': 'emp_demo_token',
    };
  }

  /// Sends a sentence to the Smart Grammar Coach Edge Function
  static Future<FeedbackItem> analyzeSentenceWithCoach(String sentence) async {
    if (userAuthToken != null && !supabaseUrl.contains('demo.supabase.co')) {
      try {
        final res = await http.post(
          Uri.parse('$supabaseUrl/functions/v1/grammar-coach'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userAuthToken',
          },
          body: jsonEncode({'sentence': sentence}),
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return FeedbackItem(
            id: data['id'] ?? 'corr_${DateTime.now().millisecondsSinceEpoch}',
            userAnswer: data['userAnswer'] ?? sentence,
            suggestions: data['suggestions'] ?? '',
            correctedSentence: data['correctedSentence'] ?? sentence,
            errorWords: List<String>.from(data['errorWords'] ?? []),
            category: data['category'] ?? 'General Grammar',
            originalMistakeNote: 'Identified by Gemini Smart Coach',
          );
        }
      } catch (_) {}
    }

    // High quality offline fallback (matching Image 4)
    return FeedbackItem(
      id: 'mock_1',
      userAnswer: sentence,
      suggestions:
          'In your sentence, remember that completed actions in the past require simple past verbs ("swam", "ate") rather than present base forms ("swim", "eat").',
      correctedSentence: sentence.replaceAll('swim', 'swam').replaceAll('eat', 'ate'),
      errorWords: ['swam', 'ate'],
      category: 'Past Simple Irregular Verbs',
      originalMistakeNote: 'Verb tense consistency',
    );
  }
}
