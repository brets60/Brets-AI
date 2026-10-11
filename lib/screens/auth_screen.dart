import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  final Function(String name, String email, String provider) onAuthSuccess;

  const AuthScreen({
    super.key,
    required this.onAuthSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginMode = false; // Registration mode by default
  bool isPasswordVisible = false;
  bool isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String selectedLevel = 'B1';
  final List<String> levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showGoogleLoginModal() {
    final gNameController = TextEditingController();
    final gEmailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141829),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Google Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.g_mobiledata_rounded, color: Color(0xFFEA4335), size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Connect your Google account to Brets AI',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Inputs for User's Own Google Account
                    _buildTextField(
                      controller: gNameController,
                      hint: 'Your Name or Nickname',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: gEmailController,
                      hint: 'Your Google Email (e.g. yourname@gmail.com)',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 18),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1F2937),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        final rawName = gNameController.text.trim();
                        final rawEmail = gEmailController.text.trim();
                        final name = rawName.isNotEmpty ? rawName : (rawEmail.contains('@') ? rawEmail.split('@')[0] : 'Learner');
                        final email = rawEmail.isNotEmpty ? rawEmail : 'learner@gmail.com';
                        Navigator.pop(modalContext);
                        widget.onAuthSuccess(name, email, 'google');
                      },
                      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                      label: const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),

                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        '🔒 Brets AI only uses your name to personalize English practice.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFacebookLoginModal() {
    final fbNameController = TextEditingController();
    final fbEmailController = TextEditingController();
    final fbPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141829),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Meta Facebook Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1877F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.facebook_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Log in with Facebook',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Connect your real Facebook profile to Brets AI',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),                    _buildTextField(
                      controller: fbNameController,
                      hint: 'Your Facebook Name or Nickname',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: fbEmailController,
                      hint: 'Facebook Email or Mobile Number',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: fbPasswordController,
                      hint: 'Password (Optional)',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      isPasswordVisible: false,
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        final rawName = fbNameController.text.trim();
                        final rawEmail = fbEmailController.text.trim();
                        final name = rawName.isNotEmpty ? rawName : 'Learner';
                        final email = rawEmail.isNotEmpty ? rawEmail : 'facebook.user@brets.ai';
                        Navigator.pop(modalContext);
                        widget.onAuthSuccess(name, email, 'facebook');
                      },
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      label: const Text('Log in with Facebook', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        '🔒 We respect your privacy. No unwanted posts will be made to Facebook.',

                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleEmailSubmit() {
    final email = _emailController.text.trim();
    final name = isLoginMode ? 'Learner' : _nameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.grammar,
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.grammar,
          content: Text('Password must be at least 6 characters.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => isLoading = false);
        widget.onAuthSuccess(
          name.isNotEmpty ? name : 'Learner',
          email,
          'email',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E17),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // Official Brets AI Brand App Logo
                Center(
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.asset(
                        'assets/images/brets_app_icon.png',
                        width: 86,
                        height: 86,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00F2FE), Color(0xFF7C3AED)],
                            ),
                          ),
                          child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 44),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title & Tagline
                const Center(
                  child: Text(
                    'Brets AI',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Your Personal AI English-Speaking Partner',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Social Login Buttons (Google / Gmail & Facebook)
                _buildSocialButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  iconColor: const Color(0xFFEA4335),
                  bgColor: Colors.white,
                  textColor: const Color(0xFF1F2937),
                  onTap: _showGoogleLoginModal,
                ),

                const SizedBox(height: 12),

                _buildSocialButton(
                  label: 'Continue with Facebook',
                  icon: Icons.facebook_rounded,
                  iconColor: Colors.white,
                  bgColor: const Color(0xFF1877F2), // Meta Facebook Blue
                  textColor: Colors.white,
                  onTap: _showFacebookLoginModal,
                ),

                const SizedBox(height: 22),

                // Divider "OR EMAIL"
                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: AppColors.cardBorder)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'OR CONTINUE WITH EMAIL',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: AppColors.cardBorder)),
                  ],
                ),

                const SizedBox(height: 20),

                // Toggle Tab: Sign In vs Register
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isLoginMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isLoginMode ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  fontWeight: isLoginMode ? FontWeight.bold : FontWeight.w500,
                                  color: isLoginMode ? Colors.white : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isLoginMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !isLoginMode ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontWeight: !isLoginMode ? FontWeight.bold : FontWeight.w500,
                                  color: !isLoginMode ? Colors.white : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Name field (if Register mode)
                if (!isLoginMode) ...[
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Your Full Name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  // CEFR Level Picker
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Starting English Level:',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ),
                        DropdownButton<String>(
                          value: selectedLevel,
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          underline: const SizedBox(),
                          items: levels.map((lvl) {
                            return DropdownMenuItem(value: lvl, child: Text(lvl));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedLevel = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  hint: 'Email address',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 12),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  hint: 'Password (min. 6 characters)',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  isPasswordVisible: isPasswordVisible,
                  onToggleVisibility: () {
                    setState(() => isPasswordVisible = !isPasswordVisible);
                  },
                ),

                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isLoading ? null : _handleEmailSubmit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isLoginMode ? 'Sign In to Brets AI' : 'Complete Registration & Start',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 16),

                // Switch between Register and Sign In prompt
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => isLoginMode = !isLoginMode),
                    child: Text(
                      isLoginMode
                          ? "New learner? Register here →"
                          : "Already registered? Sign In here →",
                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Notice
                const Center(
                  child: Text(
                    '🔒 Registration required to track speaking progress & AI memory.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
