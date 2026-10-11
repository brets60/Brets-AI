import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_chart.dart';

class ProgressScreen extends StatelessWidget {
  final VoidCallback onBackToHome;

  const ProgressScreen({
    super.key,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    // Assessment points strictly modeled after the trends in Image 5
    final assessmentPoints = [
      AssessmentPoint(
        dateLabel: 'Sep 1',
        overall: 63,
        fluency: 30,
        grammar: 40,
        pronunciation: 90,
        vocabulary: 92,
      ),
      AssessmentPoint(
        dateLabel: 'Sep 8',
        overall: 66,
        fluency: 35,
        grammar: 45,
        pronunciation: 95,
        vocabulary: 88,
      ),
      AssessmentPoint(
        dateLabel: 'Sep 15',
        overall: 66,
        fluency: 40,
        grammar: 50,
        pronunciation: 85,
        vocabulary: 90,
      ),
      AssessmentPoint(
        dateLabel: 'Sep 22',
        overall: 72,
        fluency: 45,
        grammar: 55,
        pronunciation: 92,
        vocabulary: 95,
      ),
      AssessmentPoint(
        dateLabel: 'Sep 29',
        overall: 76,
        fluency: 50,
        grammar: 60,
        pronunciation: 98,
        vocabulary: 97,
      ),
      AssessmentPoint(
        dateLabel: 'Oct 6',
        overall: 77.5,
        fluency: 55,
        grammar: 65,
        pronunciation: 96,
        vocabulary: 94,
      ),
      AssessmentPoint(
        dateLabel: 'Oct 13',
        overall: 78.5,
        fluency: 60,
        grammar: 70,
        pronunciation: 93,
        vocabulary: 91,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E17),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Header matching Image 5
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: onBackToHome,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Your Progress',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  'This is your assessment history. You can view your progress and scores over time.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // The Chart Component (recreating Image 5)
              ProgressAssessmentChart(points: assessmentPoints),

              const SizedBox(height: 24),

              // Summary Stats Row
              Row(
                children: [
                  _buildStatBadge(
                    icon: Icons.timer_outlined,
                    value: '145m',
                    label: 'Spoken Time',
                    color: AppColors.fluency,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBadge(
                    icon: Icons.check_circle_outline_rounded,
                    value: '36',
                    label: 'Rules Mastered',
                    color: AppColors.pronunciation,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBadge(
                    icon: Icons.local_fire_department_rounded,
                    value: '7 Days',
                    label: 'Streak',
                    color: AppColors.streakOrange,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Competency Breakdown Cards
              const Text(
                'Skill Competency Breakdown',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),

              _buildCompetencyRow('Fluency & Speed', 60, AppColors.fluency, '115 WPM • Low Hesitation'),
              _buildCompetencyRow('Grammar Accuracy', 70, AppColors.grammar, 'Past & Perfect Tenses Practiced'),
              _buildCompetencyRow('Pronunciation', 93, AppColors.pronunciation, 'Clear Phonetics & Intonation'),
              _buildCompetencyRow('Vocabulary Range', 91, AppColors.vocabulary, 'CEFR Level: Upper B2'),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  static Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCompetencyRow(String title, double score, Color color, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Text(
                '${score.toInt()}%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100.0,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
