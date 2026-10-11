import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class InstantFeedbackCard extends StatefulWidget {
  final FeedbackItem item;
  final VoidCallback? onPracticed;

  const InstantFeedbackCard({
    super.key,
    required this.item,
    this.onPracticed,
  });

  @override
  State<InstantFeedbackCard> createState() => _InstantFeedbackCardState();
}

class _InstantFeedbackCardState extends State<InstantFeedbackCard> {
  bool isPracticeMode = false;
  final TextEditingController _inputController = TextEditingController();
  bool? isCorrectSubmission;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _verifySentence() {
    final text = _inputController.text.trim().toLowerCase();
    // Check if both corrected words are present
    final hasAllCorrections = widget.item.errorWords.every(
      (word) => text.contains(word.toLowerCase()),
    );

    setState(() {
      isCorrectSubmission = hasAllCorrections;
      if (hasAllCorrections) {
        widget.item.isPracticed = true;
        widget.onPracticed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. YOUR ANSWER (Green Tag)
        _buildSectionCard(
          badgeLabel: 'What You Said:',
          badgeIcon: Icons.chat_bubble_rounded,
          badgeColor: const Color(0xFF00C88C), // Vibrant Green
          content: widget.item.userAnswer,
        ),

        const SizedBox(height: 18),

        // 2. SUGGESTIONS (Purple Tag)
        _buildSectionCard(
          badgeLabel: 'Easy Explanation:',
          badgeIcon: Icons.lightbulb_rounded,
          badgeColor: const Color(0xFF8B5CF6), // Purple
          content: widget.item.suggestions,
        ),

        const SizedBox(height: 18),

        // 3. CORRECTIONS (Red Tag with inline red pill badges)
        _buildCorrectionsCard(
          badgeLabel: 'Correct Sentence:',
          badgeIcon: Icons.check_circle_rounded,
          badgeColor: const Color(0xFF10B981), // Friendly Green/Emerald
          sentence: widget.item.correctedSentence,
          highlightWords: widget.item.errorWords,
        ),

        const SizedBox(height: 24),

        // Interactive "Try Again" action
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF161A2B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.item.isPracticed
                  ? AppColors.pronunciation.withValues(alpha: 0.6)
                  : AppColors.primaryGlow,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          widget.item.isPracticed
                              ? Icons.check_circle_rounded
                              : Icons.refresh_rounded,
                          color: widget.item.isPracticed
                              ? AppColors.pronunciation
                              : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.item.isPracticed
                                ? 'Awesome! Mastered 🎉'
                                : 'Practice this sentence',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!widget.item.isPracticed && !isPracticeMode)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() => isPracticeMode = true);
                      },
                      child: const Text('Try Now'),
                    ),
                ],
              ),
              if (isPracticeMode && !widget.item.isPracticed) ...[
                const SizedBox(height: 14),
                const Text(
                  'Say or type the sentence using the corrected past tense words:',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _inputController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. Last summer I went to the beach... we swam...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                      onPressed: _verifySentence,
                    ),
                  ),
                  onSubmitted: (_) => _verifySentence(),
                ),
                if (isCorrectSubmission == false) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Almost! Make sure to include "swam" and "ate". Give it another try!',
                    style: TextStyle(color: AppColors.grammar, fontSize: 13),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String badgeLabel,
    required IconData badgeIcon,
    required Color badgeColor,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF262C3E), // Dark slate gray card from Image 4
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badgeIcon, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Content Bubble
          Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.55,
                color: Color(0xFFE2E8F0),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionsCard({
    required String badgeLabel,
    required IconData badgeIcon,
    required Color badgeColor,
    required String sentence,
    required List<String> highlightWords,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF262C3E),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badgeIcon, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Sentence with highlighted red badge pills
          Padding(
            padding: const EdgeInsets.all(18),
            child: _buildHighlightedSpans(sentence, highlightWords),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedSpans(String text, List<String> words) {
    final tokens = text.split(' ');
    final spans = <InlineSpan>[];

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final cleanToken = token.replaceAll(RegExp(r'[^\w\s]'), '');
      final isErrorMatch = words.any(
        (w) => w.toLowerCase() == cleanToken.toLowerCase(),
      );

      if (isErrorMatch) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE05353), // Red badge highlight from Image 4
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                token,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$token ',
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: Color(0xFFE2E8F0),
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }
}
