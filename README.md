# Brets AI — English Speaking Partner

**Your Personal AI English-Speaking Partner**  
*“Speak first, learn from your mistakes, and speak better next time.”*

🌐 **Live 24/7 Web Application**: [https://web-one-coral-10.vercel.app](https://web-one-coral-10.vercel.app)

---

## 📱 Implemented UI Screens & Features

This application is built with Flutter and deployed across Mobile (Android/iOS) and Web:

1. **Home Dashboard (`HomeScreen`)**
   - Daily Goal tracker (`1/3` badge), Speaking Streak (`🔥 1`), Category Hub (**General**, **Interview**, **Business**), and Scenario Cards (`Talk about anything`, `Vocabulary Boost`, `Job Interview`).
   - Quick launch for live speaking sessions with automatic microphone/camera permission checks.

2. **AI Live Speaking Room (`CallScreen`)**
   - Central animated pulsing glowing AI coach avatar (`PulsingAvatar`) with dynamic soundwave aura and custom Brets AI logo mark.
   - User turn badge (`Speaking Now...` / `Your Turn`).
   - 4 Live Feature Toggles:
     - `✓ Real-time corrections`
     - `💡 Hints when stuck`
     - `🔄 Native rephrasing`
     - `🔊 Pronunciation feedback`
     - Live dialogue caption banner.
     - Call duration timer, mute toggle, push-to-talk mic, and end-session red button that automatically triggers session feedback.

3. **Instant Learning Feedback (`FeedbackScreen`)**
   - Matching **Image 4**:
     - 🟩 **Your Answer:** Verbatim speech transcription.
     - 🟪 **Suggestions:** Pedagogical grammar explanation.
     - 🟥 **Corrections:** Corrected sentence with error tokens highlighted in red pill badges (`swam`, `ate`).
     - Interactive **"Try Now" Practice Field**: Allows users to retry the sentence with instant validation.

4. **Progress & Assessment History (`ProgressScreen`)**
   - Matching **Image 5**:
     - Custom high-fidelity multi-line assessment chart (`ProgressAssessmentChart`) plotting historical dates (`Sep 1` to `Oct 13`) against 0–100 scores:
       - 🟠 **Overall**
       - 🔵 **Fluency**
       - 🔴 **Grammar**
       - 🟢 **Pronunciation**
       - 🟣 **Vocabulary**
     - Detailed skill competency progress bars.

5. **Learner Profile & Memory Bank (`ProfileScreen`)**
   - Learner goals, Philippine market freemium plan (`₱199/mo`), and persistent mistake memory bank.

---

## 🚀 How to Run the App

### Option 1: Instant Browser Preview (Recommended)
Double-click `run-web.bat` in the project root, or run:
```bash
python -m http.server 5050 --directory build/web
```
Then visit `http://localhost:5050` in Chrome or Edge.

### Option 2: Live Development Mode
```bash
# Run in Chrome with hot reload:
flutter run -d chrome

# Run as native Windows desktop app:
flutter run -d windows

# Run on connected Android phone/emulator:
flutter run -d android
```

---

## 🛠️ Project Structure

```
lib/
├── main.dart                   # Bottom navigation shell & routing
├── theme/
│   └── app_theme.dart          # Dark-mode color palette & typography
├── models/
│   └── models.dart             # Feedback, assessment points, and scenarios
├── widgets/
│   ├── pulsing_avatar.dart     # Concentric animated glowing AI avatar
│   ├── progress_chart.dart     # CustomPainter multi-line chart (Image 5)
│   └── correction_card.dart    # 3-tier feedback card (Image 4)
└── screens/
    ├── home_screen.dart        # Dashboard (Image 2 Left)
    ├── call_screen.dart        # AI Voice Room (Image 2 Right & 3)
    ├── feedback_screen.dart    # Instant Review (Image 4)
    ├── progress_screen.dart    # Historical Trends (Image 5)
    └── profile_screen.dart     # Profile & Mistake Memory
```
