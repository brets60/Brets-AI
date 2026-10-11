import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/correction_card.dart';

class FeedbackScreen extends StatefulWidget {
  final VoidCallback onViewProgress;
  final List<FeedbackItem>? sessionMistakes;

  const FeedbackScreen({
    super.key,
    required this.onViewProgress,
    this.sessionMistakes,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int currentMistakeIndex = 0;

  late List<FeedbackItem> feedbackItems;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(covariant FeedbackScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionMistakes != widget.sessionMistakes) {
      _loadItems();
    }
  }

  void _loadItems() {
    if (widget.sessionMistakes != null && widget.sessionMistakes!.isNotEmpty) {
      feedbackItems = List.from(widget.sessionMistakes!);
    } else {
      feedbackItems = [
        FeedbackItem(
          id: '1',
          userAnswer:
              'Last summer I went to the beach with my family. It was amazing, we swim in the sea and eat a lot of ice cream.',
          suggestions:
              'For past events, use the past tense: say "we swam" and "we ate" instead of "swim" and "eat".',
          correctedSentence:
              'Last summer I went to the beach with my family. It was amazing, we swam in the sea and ate a lot of ice cream.',
          errorWords: ['swam', 'ate'],
          category: 'Past Simple (Irregular Verbs)',
          originalMistakeNote: 'Used present simple (swim, eat) instead of simple past (swam, ate).',
        ),
        FeedbackItem(
          id: '2',
          userAnswer:
              'I am working as developer since three years in Manila.',
          suggestions:
              'Use "for" for time duration ("for three years"). Use "have been working" for actions continuing until now.',
          correctedSentence:
              'I have been working as a developer for three years in Manila.',
          errorWords: ['have', 'been', 'working', 'for'],
          category: 'Present Perfect Continuous',
          originalMistakeNote: 'Confused "since" with duration "for", missed continuous auxiliary.',
        ),
      ];
    }
    currentMistakeIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = feedbackItems[currentMistakeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E17),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Title matching Image 4
              Center(
                child: Column(
                  children: const [
                    Text(
                      'Get Instant',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00E699), // Lime green accent from Image 4
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Mistake Navigator Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: List.generate(feedbackItems.length, (idx) {
                    final isSel = idx == currentMistakeIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => currentMistakeIndex = idx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Mistake ${idx + 1}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                color: isSel ? Colors.white : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 14),

              // Category Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.vocabulary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.vocabulary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      currentItem.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.vocabulary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // The 3-Tier Feedback Card Component (Image 4)
              InstantFeedbackCard(
                item: currentItem,
                onPracticed: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF059669),
                      content: Text('Great job! Sentence added to your Mastery Bank!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Action button to View Updated Scores
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
                onPressed: widget.onViewProgress,
                icon: const Icon(Icons.insights_rounded, color: AppColors.overall),
                label: const Text(
                  'View Progress & Historical Scores',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}
