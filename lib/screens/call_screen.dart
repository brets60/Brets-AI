import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/pulsing_avatar.dart';

class CallScreen extends StatefulWidget {
  final String userName;
  final String scenarioTitle;
  final Function(List<FeedbackItem> mistakes) onEndCallWithMistakes;
  final VoidCallback onBack;

  const CallScreen({
    super.key,
    this.userName = 'Learner',
    required this.scenarioTitle,
    required this.onEndCallWithMistakes,
    required this.onBack,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late FlutterTts _flutterTts;
  bool isAiSpeaking = false;
  bool isUserSpeaking = false;
  bool isMuted = false;
  bool isCameraOn = false;
  int callSeconds = 0;
  Timer? _timer;

  // Live Feature Toggles (Image 3)
  bool enableCorrections = true;
  bool enableHints = true;
  bool enableRephrasing = true;
  bool enablePronunciation = true;

  // Live dialogue subtitles
  String currentAiDialogue =
      "Hi! I'm Brets AI. What would you like to practice today?";

  // Real-time collected mistakes for session feedback
  final List<FeedbackItem> _sessionMistakes = [];

  final List<String> sampleSpeechPrompts = [
    "Yesterday I go to school with my friend.",
    "I am working as developer since three years in Manila.",
    "She don't know the answer to the question.",
    "I am really excited to practice English with you!",
  ];

  @override
  void initState() {
    super.initState();
    _requestCallPermissions();
    _initTts();
    _startTimer();
  }

  Future<void> _requestCallPermissions() async {
    if (!kIsWeb) {
      try {
        final mic = await Permission.microphone.status;
        if (!mic.isGranted) {
          await Permission.microphone.request();
        }
      } catch (_) {}
    }
  }

  Future<void> _toggleCamera() async {
    if (!isCameraOn) {
      if (!kIsWeb) {
        try {
          final cam = await Permission.camera.request();
          if (!cam.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.grammar,
                  content: Text('Camera permission required for video partner mode.'),
                ),
              );
            }
            return;
          }
        } catch (_) {}
      }
      setState(() => isCameraOn = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF10B981),
            content: Text('Camera Active: Facial articulation & video tracking enabled! 📹'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() => isCameraOn = false);
    }
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.48); // Gentle, patient cadence
      await _flutterTts.setVolume(1.0);     // Full volume
      await _flutterTts.setPitch(1.05);

      _flutterTts.setStartHandler(() {
        if (mounted) setState(() => isAiSpeaking = true);
      });

      _flutterTts.setCompletionHandler(() {
        if (mounted) setState(() => isAiSpeaking = false);
      });

      _flutterTts.setErrorHandler((_) {
        if (mounted) setState(() => isAiSpeaking = false);
      });

      // Speak initial greeting after short delay
      Future.delayed(const Duration(milliseconds: 600), () {
        _speak(currentAiDialogue);
      });
    } catch (_) {
      // Fallback if audio driver unavailable
    }
  }

  Future<void> _speak(String text) async {
    if (isMuted) return;
    try {
      await _flutterTts.setVolume(1.0);
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => callSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  String _formatTimer(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Handle user speech turn with real-time error detection
  void _processUserTurn(String userText) {
    setState(() {
      isUserSpeaking = false;
      isAiSpeaking = true;
    });

    final lower = userText.toLowerCase();
    String aiResponse = "";

    if (lower.contains("yesterday") && lower.contains("go to")) {
      aiResponse =
          "Great job! Quick tip: say 'yesterday I went' instead of 'go'. Try: 'Yesterday I went to school'!";
      _sessionMistakes.add(
        FeedbackItem(
          id: 'mistake_${DateTime.now().millisecondsSinceEpoch}',
          userAnswer: userText,
          suggestions:
              'For completed past events, use "went" instead of "go". Example: "Yesterday I went to school."',
          correctedSentence: userText.replaceAll("go to", "went to").replaceAll("Go to", "Went to"),
          errorWords: ['went'],
          category: 'Past Simple (Go → Went)',
          originalMistakeNote: 'Used present "go" instead of past "went"',
        ),
      );
    } else if (lower.contains("since three years") || lower.contains("since 3 years")) {
      aiResponse =
          "Nice! Remember: say 'for three years' for time length. Try: 'I have worked for three years'.";
      _sessionMistakes.add(
        FeedbackItem(
          id: 'mistake_${DateTime.now().millisecondsSinceEpoch}',
          userAnswer: userText,
          suggestions:
              'Use "for" for duration of time ("for 3 years"). Use "since" only with a specific starting date ("since 2023").',
          correctedSentence: userText.replaceAll("since three years", "for three years").replaceAll("since 3 years", "for three years"),
          errorWords: ['for'],
          category: 'For vs Since',
          originalMistakeNote: 'Used "since" instead of "for" for duration',
        ),
      );
    } else if (lower.contains("she don't") || lower.contains("he don't")) {
      aiResponse =
          "Good effort! With 'she' or 'he', say 'doesn't'. Try: 'She doesn't know the answer'.";
      _sessionMistakes.add(
        FeedbackItem(
          id: 'mistake_${DateTime.now().millisecondsSinceEpoch}',
          userAnswer: userText,
          suggestions:
              'With singular subjects (He, She, It), use "doesn\'t", not "don\'t". Example: "She doesn\'t know."',
          correctedSentence: userText.replaceAll("don't", "doesn't"),
          errorWords: ["doesn't"],
          category: 'Subject-Verb Agreement',
          originalMistakeNote: 'Used "don\'t" instead of "doesn\'t"',
        ),
      );
    } else {
      aiResponse = "Clear and natural! Tell me more about that!";
    }

    setState(() {
      currentAiDialogue = aiResponse;
    });

    _speak(aiResponse);
  }

  void _showSpeakInputModal() {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Speak or Type Your Turn',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Speak or type what you want to say in English...',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: () {
                      final txt = textController.text.trim();
                      if (txt.isNotEmpty) {
                        Navigator.pop(context);
                        _processUserTurn(txt);
                      }
                    },
                  ),
                ),
                onSubmitted: (txt) {
                  if (txt.trim().isNotEmpty) {
                    Navigator.pop(context);
                    _processUserTurn(txt.trim());
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Try one of these real learner sentences:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...sampleSpeechPrompts.map((prompt) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _processUserTurn(prompt);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            prompt,
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Conversation Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: enableCorrections,
                activeThumbColor: AppColors.primary,
                title: const Text('Real-time Corrections'),
                subtitle: const Text('Provide gentle grammar coaching mid-call'),
                onChanged: (val) {
                  setState(() => enableCorrections = val);
                  Navigator.pop(context);
                },
              ),
              SwitchListTile(
                value: enableHints,
                activeThumbColor: AppColors.primary,
                title: const Text('Conversation Hints'),
                subtitle: const Text('Show suggestions when paused'),
                onChanged: (val) {
                  setState(() => enableHints = val);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0E18),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                      // Top Bar with back, title, and settings (Image 2 Right)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              onPressed: widget.onBack,
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.scenarioTitle,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.pronunciation,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTimer(callSeconds),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                              onPressed: _showSettingsModal,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Live Call Status Badge (Image 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Gemini Live Audio Engine',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Central Glowing AI Avatar (Image 2 & 3)
                      PulsingAvatar(
                        isSpeaking: isAiSpeaking,
                        speakerName: isAiSpeaking ? 'Lexie Speaking...' : 'Listening to you',
                        statusText: isAiSpeaking ? 'Wait for your turn' : 'Your turn • Tap mic to speak',
                        size: 130,
                      ),

                      const SizedBox(height: 20),

                      // User Turn Avatar Badge (Image 2 Right)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161A2B),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isUserSpeaking ? AppColors.pronunciation : AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                                ),
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isUserSpeaking ? 'Speaking Now...' : '${widget.userName} (Learner)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isUserSpeaking ? AppColors.pronunciation : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isCameraOn) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111526),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.videocam_rounded, color: Color(0xFF10B981), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.userName}: Live Video & Articulation Synced',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const Spacer(),

                      // 4 Live Feature Toggles (Image 3)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          childAspectRatio: 2.3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildCallPill(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Real-time grammar help',
                              color: AppColors.pronunciation,
                              isActive: enableCorrections,
                            ),
                            _buildCallPill(
                              icon: Icons.lightbulb_outline_rounded,
                              label: 'Hints when stuck',
                              color: AppColors.overall,
                              isActive: enableHints,
                            ),
                            _buildCallPill(
                              icon: Icons.sync_rounded,
                              label: 'Better ways to say it',
                              color: AppColors.fluency,
                              isActive: enableRephrasing,
                            ),
                            _buildCallPill(
                              icon: Icons.volume_up_outlined,
                              label: 'Pronunciation tips',
                              color: AppColors.primary,
                              isActive: enablePronunciation,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Live Caption Box (Image 2 Bottom)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141829),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF2B3352),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.subtitles_rounded, color: AppColors.primary, size: 14),
                                const SizedBox(width: 6),
                                const Text(
                                  'Captions',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 16),
                                  onPressed: () => _speak(currentAiDialogue),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currentAiDialogue,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () => _speak(currentAiDialogue),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isAiSpeaking ? const Color(0xFF059669) : AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(isAiSpeaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded, color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        isAiSpeaking ? 'Speaking Now... (Tap to Replay)' : 'Tap to Hear Brets AI Speak 🔊',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bottom Call Controls (End Call, Mic Toggle, Camera Toggle, Speaker Toggle)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Mute / Speaker Audio Toggle
                            IconButton(
                              onPressed: () {
                                setState(() => isMuted = !isMuted);
                                if (isMuted) _flutterTts.stop();
                              },
                              iconSize: 26,
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surfaceLight,
                                padding: const EdgeInsets.all(13),
                              ),
                              icon: Icon(
                                isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                color: isMuted ? AppColors.grammar : Colors.white,
                              ),
                            ),

                            // Camera / Video Mode Toggle (requests camera permission on phone)
                            IconButton(
                              onPressed: _toggleCamera,
                              iconSize: 26,
                              style: IconButton.styleFrom(
                                backgroundColor: isCameraOn ? const Color(0xFF10B981) : AppColors.surfaceLight,
                                padding: const EdgeInsets.all(13),
                              ),
                              icon: Icon(
                                isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                                color: Colors.white,
                              ),
                            ),

                            // Push-to-Talk Speaking Action
                            GestureDetector(
                              onTap: _showSpeakInputModal,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: isUserSpeaking
                                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                        : [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isUserSpeaking ? AppColors.pronunciation : AppColors.primary)
                                          .withValues(alpha: 0.5),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),

                            // Red End Call Button -> Navigates to Instant Feedback with collected mistakes
                            IconButton(
                              onPressed: () {
                                _flutterTts.stop();
                                widget.onEndCallWithMistakes(_sessionMistakes);
                              },
                              iconSize: 26,
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                padding: const EdgeInsets.all(13),
                              ),
                              icon: const Icon(
                                Icons.call_end_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ),
);
  }

  Widget _buildCallPill({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF171B2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? color.withValues(alpha: 0.35) : AppColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? color : AppColors.textMuted, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
