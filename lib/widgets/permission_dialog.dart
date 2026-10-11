import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class PermissionSheet extends StatefulWidget {
  final VoidCallback onGranted;

  const PermissionSheet({
    super.key,
    required this.onGranted,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onGranted}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131728),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => PermissionSheet(onGranted: onGranted),
    );
  }

  @override
  State<PermissionSheet> createState() => _PermissionSheetState();
}

class _PermissionSheetState extends State<PermissionSheet> {
  bool micGranted = false;
  bool cameraGranted = false;
  bool speakerReady = true;
  bool isRequesting = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    if (kIsWeb) {
      // In web, browser handles getUserMedia permissions on interaction
      setState(() {
        micGranted = true;
        cameraGranted = true;
      });
      return;
    }

    try {
      final mic = await Permission.microphone.status;
      final cam = await Permission.camera.status;
      if (mounted) {
        setState(() {
          micGranted = mic.isGranted;
          cameraGranted = cam.isGranted;
        });
      }
    } catch (_) {
      // fallback
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() => isRequesting = true);

    if (!kIsWeb) {
      try {
        final micStatus = await Permission.microphone.request();
        final camStatus = await Permission.camera.request();

        if (mounted) {
          setState(() {
            micGranted = micStatus.isGranted;
            cameraGranted = camStatus.isGranted;
            isRequesting = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            micGranted = true;
            cameraGranted = true;
            isRequesting = false;
          });
        }
      }
    } else {
      // Simulated web grant
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          micGranted = true;
          cameraGranted = true;
          isRequesting = false;
        });
      }
    }

    if (mounted) {
      Navigator.pop(context);
      widget.onGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Icon
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(
                Icons.security_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Allow Device Permissions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 6),

          const Center(
            child: Text(
              'Brets AI needs your microphone, camera, and speaker to speak, hear, and coach your English articulation in real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 1. Microphone Permission Tile
          _buildPermissionTile(
            icon: Icons.mic_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Microphone & Audio Input',
            subtitle: 'Real-time speech recognition & pronunciation scoring',
            isGranted: micGranted,
            onRequest: () async {
              if (!kIsWeb) {
                final s = await Permission.microphone.request();
                setState(() => micGranted = s.isGranted);
              } else {
                setState(() => micGranted = true);
              }
            },
          ),

          const SizedBox(height: 12),

          // 2. Camera Permission Tile
          _buildPermissionTile(
            icon: Icons.videocam_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: 'Camera & Video Presence',
            subtitle: 'AI mouth articulation analysis & selfie video partner',
            isGranted: cameraGranted,
            onRequest: () async {
              if (!kIsWeb) {
                final s = await Permission.camera.request();
                setState(() => cameraGranted = s.isGranted);
              } else {
                setState(() => cameraGranted = true);
              }
            },
          ),

          const SizedBox(height: 12),

          // 3. Speaker / Audio Output Tile
          _buildPermissionTile(
            icon: Icons.volume_up_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Speaker & Audio System',
            subtitle: 'High-definition voice playback from Gemini audio engine',
            isGranted: speakerReady,
            onRequest: () {},
          ),

          const SizedBox(height: 24),

          // Primary Action Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            onPressed: isRequesting ? null : _requestAllPermissions,
            child: isRequesting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Grant System Permissions & Continue',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),

          const SizedBox(height: 10),

          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Maybe Later',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onRequest,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? iconColor.withValues(alpha: 0.5) : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isGranted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Granted',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.surfaceLight,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onRequest,
              child: const Text(
                'Allow',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
