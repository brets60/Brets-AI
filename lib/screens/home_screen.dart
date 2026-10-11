import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/permission_dialog.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final Function(int tabIndex) onNavigate;
  final Function(String scenarioTitle) onStartCall;

  const HomeScreen({
    super.key,
    this.userName = 'Learner',
    required this.onNavigate,
    required this.onStartCall,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'General';
  final List<String> categories = ['General', 'Interview', 'Business'];

  final List<PracticeScenario> scenarios = [
    PracticeScenario(
      id: '1',
      title: 'Talk about anything',
      subtitle: 'Free-flowing conversational English',
      category: 'General',
      dateTag: '20 Jun 2026',
      iconType: 'chat',
    ),
    PracticeScenario(
      id: '2',
      title: 'Vocabulary Boost',
      subtitle: 'Learn 10 high-impact workplace idioms',
      category: 'General',
      dateTag: 'Daily Boost',
      iconType: 'book',
    ),
    PracticeScenario(
      id: '3',
      title: 'Tech Job Interview Simulation',
      subtitle: 'Tell me about a time you solved a conflict',
      category: 'Interview',
      dateTag: 'Popular',
      iconType: 'work',
    ),
    PracticeScenario(
      id: '4',
      title: 'Presenting a Project Update',
      subtitle: 'Confident stakeholder communication',
      category: 'Business',
      dateTag: 'Advanced',
      iconType: 'presentation',
    ),
  ];

  Future<void> _handleStartCallWithPermission(String scenario) async {
    if (!kIsWeb) {
      try {
        final mic = await Permission.microphone.status;
        final cam = await Permission.camera.status;
        if (!mic.isGranted || !cam.isGranted) {
          if (mounted) {
            PermissionSheet.show(context, onGranted: () {
              widget.onStartCall(scenario);
            });
            return;
          }
        }
      } catch (_) {}
    }
    widget.onStartCall(scenario);
  }

  @override
  Widget build(BuildContext context) {
    final filteredScenarios = scenarios
        .where((s) => s.category == selectedCategory || selectedCategory == 'General')
        .toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 640;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Top Bar: User Profile + Streak + History (Image 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 2),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                            ),
                          ),
                          child: const Icon(Icons.face_retouching_natural_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${widget.userName}! 👋',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Ready to practice?',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Streak Flame Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF333B58)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF7A00), size: 18),
                            SizedBox(width: 4),
                            Text(
                              '1',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      // History Button
                      IconButton(
                        onPressed: () => widget.onNavigate(3), // Go to progress
                        icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search Bar with Mic Icon (Image 2)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search_rounded, color: AppColors.textMuted),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search lessons, topics or exercises',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.mic_none_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Daily Goal Card (Image 2)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Daily Goal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Complete 3 exercises',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        // 1/3 circular indicator badge
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 3),
                            color: AppColors.surfaceLight,
                          ),
                          child: const Center(
                            child: Text(
                              '1/3',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 3 Category Action Buttons: Speaking, Grammar, Vocabulary
                    Row(
                      children: [
                        Expanded(
                          child: _buildGoalCategoryButton(
                            label: 'Speaking',
                            icon: Icons.mic_rounded,
                            iconBgColor: AppColors.fluency,
                            onTap: () => _handleStartCallWithPermission('Talk about anything'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGoalCategoryButton(
                            label: 'Grammar',
                            icon: Icons.menu_book_rounded,
                            iconBgColor: AppColors.vocabulary,
                            onTap: () => widget.onNavigate(2), // Go to Feedback / Grammar
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildGoalCategoryButton(
                            label: 'Vocabulary',
                            icon: Icons.lightbulb_rounded,
                            iconBgColor: AppColors.pronunciation,
                            onTap: () => widget.onNavigate(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Category Selector Tabs: General, Interview, Business (Image 2)
              Row(
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 2.5,
                            width: isSelected ? 32 : 0,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // Scenario Cards (Image 2)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 3 : 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: isTablet ? 1.02 : 0.88,
                ),
                itemCount: filteredScenarios.length,
                itemBuilder: (context, index) {
                  final scenario = filteredScenarios[index];
                  return _buildScenarioCard(scenario);
                },
              ),

              const SizedBox(height: 20),

              // Big "Start Live Speaking" Action Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _handleStartCallWithPermission('Talk about anything'),
                  icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white),
                  label: const Text(
                    'Start Live Speaking Room',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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

  Widget _buildGoalCategoryButton({
    required String label,
    required IconData icon,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconBgColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioCard(PracticeScenario scenario) {
    return InkWell(
      onTap: () => _handleStartCallWithPermission(scenario.title),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    scenario.iconType == 'book'
                        ? Icons.menu_book_rounded
                        : scenario.iconType == 'work'
                            ? Icons.business_center_rounded
                            : Icons.forum_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    scenario.dateTag,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scenario.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
