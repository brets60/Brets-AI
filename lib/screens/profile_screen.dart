import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/permission_dialog.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String authProvider;
  final VoidCallback onSignOut;

  const ProfileScreen({
    super.key,
    this.userName = 'Learner',
    this.userEmail = 'learner@example.com',
    this.authProvider = '',
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E17),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // User Card Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                        ),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 38),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: authProvider == 'google'
                                      ? const Color(0xFFEA4335).withValues(alpha: 0.15)
                                      : authProvider == 'facebook'
                                          ? const Color(0xFF1877F2).withValues(alpha: 0.15)
                                          : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      authProvider == 'google'
                                          ? Icons.g_mobiledata_rounded
                                          : authProvider == 'facebook'
                                              ? Icons.facebook_rounded
                                              : Icons.mail_rounded,
                                      size: 14,
                                      color: authProvider == 'google'
                                          ? const Color(0xFFEA4335)
                                          : authProvider == 'facebook'
                                              ? const Color(0xFF1877F2)
                                              : Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      authProvider == 'google'
                                          ? 'Google Login'
                                          : authProvider == 'facebook'
                                              ? 'Facebook Login'
                                              : 'Email Login',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: authProvider == 'google'
                                            ? const Color(0xFFEA4335)
                                            : authProvider == 'facebook'
                                                ? const Color(0xFF1877F2)
                                                : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Freemium / Subscription Banner (₱199/mo Philippines test price from plan)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E1065), Color(0xFF1E1B4B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Brets AI Pro Member',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '₱199/mo',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Unlimited Gemini Live speaking sessions, intelligent memory bank, and personalized roleplay simulations.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Personal Mistake Memory Bank
              const Text(
                'Mistakes Brets AI is Helping You Fix',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Brets AI tracks your practice words so you can build confidence quickly.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 14),

              _buildMemoryItem('Past Tense Verbs (e.g. went, ate)', '78% Mastered', 0.78, AppColors.pronunciation),
              _buildMemoryItem('Time Prepositions (for vs since)', '62% Mastered', 0.62, AppColors.overall),
              _buildMemoryItem('Subject Matching (doesn\'t vs don\'t)', '85% Mastered', 0.85, AppColors.fluency),

              const SizedBox(height: 24),

              // Settings Options
              const Text(
                'Preferences & Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              _buildSettingsTile(
                Icons.security_rounded,
                'App Device Permissions',
                'Microphone, Camera & Audio Access (Granted)',
                onTap: () {
                  PermissionSheet.show(context, onGranted: () {});
                },
              ),
              _buildSettingsTile(Icons.language_rounded, 'Native Language', 'Filipino / Tagalog'),
              _buildSettingsTile(Icons.record_voice_over_rounded, 'Coach Voice Persona', 'Lexie (Encouraging)'),
              _buildSettingsTile(Icons.speed_rounded, 'Speaking Pace', 'Normal (1.0x)'),
              _buildSettingsTile(Icons.privacy_tip_outlined, 'Privacy & Stored Transcripts', 'Encrypted with User RLS'),

              const SizedBox(height: 24),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: onSignOut,
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Log Out of Brets AI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Official Brets AI Brand Footer
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/brets_logo.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Brets AI • v1.0.0',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Your English Speaking Partner',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  static Widget _buildMemoryItem(String title, String status, double progress, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSettingsTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
