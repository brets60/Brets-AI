import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PulsingAvatar extends StatefulWidget {
  final bool isSpeaking;
  final String speakerName;
  final String statusText;
  final double size;

  const PulsingAvatar({
    super.key,
    required this.isSpeaking,
    this.speakerName = 'Lexie Speaking',
    this.statusText = 'Wait for your turn',
    this.size = 140,
  });

  @override
  State<PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = widget.isSpeaking ? _scaleAnimation.value : 1.0;
        final glowOpacity = widget.isSpeaking ? _glowAnimation.value : 0.2;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Avatar Circle
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ambient Glow Aura
                Container(
                  width: widget.size * 1.55 * scale,
                  height: widget.size * 1.55 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: glowOpacity * 0.7),
                        AppColors.fluency.withValues(alpha: glowOpacity * 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Intermediate Ring
                Container(
                  width: widget.size * 1.25,
                  height: widget.size * 1.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: glowOpacity * 0.6),
                      width: 2,
                    ),
                  ),
                ),
                // Inner Avatar Orb
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFF4C1D95),
                        Color(0xFF1E1B4B),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: glowOpacity),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: widget.size * 0.78,
                      height: widget.size * 0.78,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF111425),
                      ),
                      padding: EdgeInsets.all(widget.size * 0.12),
                      child: Image.asset(
                        'assets/images/brets_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.record_voice_over_rounded,
                          color: Colors.white,
                          size: widget.size * 0.44,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Speaker Name Badge
            Text(
              widget.speakerName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            // Status text
            Text(
              widget.statusText,
              style: TextStyle(
                fontSize: 13,
                color: widget.isSpeaking
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}
