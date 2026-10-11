# Breta AI — Firebase & Cloud Firestore Architecture

Breta AI uses **Google Cloud Firestore** as its database, with **Firebase Authentication**, **Cloud Functions**, and **Firebase Security Rules**.

---

## 🧭 Where to See Your Database on Firebase

1. Go to the **[Firebase Console](https://console.firebase.google.com)**.
2. Select your Breta AI project (or create one by clicking **"Add project"**).
3. On the left navigation menu, click **Build** $\rightarrow$ **Firestore Database**:
   - Here you will see your collections and documents in a real-time visual interface!

---

## 🗂️ Firestore Collections Structure

| Collection | Description | Document Fields |
| :--- | :--- | :--- |
| **`users`** | Learner profiles & CEFR level | `displayName`, `englishLevel`, `nativeLanguage`, `learningGoal`, `dailyGoalMinutes`, `streakDays` |
| **`conversations`** | Voice speaking sessions | `userId`, `scenario`, `mode`, `durationSeconds`, `startedAt` |
| **`conversations/{id}/messages`** | Speech transcripts subcollection | `speaker` ('user'/'ai'), `transcript`, `createdAt` |
| **`corrections`** | 3-tier feedback cards (Image 4) | `userId`, `userAnswer`, `suggestions`, `correctedSentence`, `errorWords[]`, `category`, `isPracticed` |
| **`learning_progress`** | Historical scores for 5 competency curves (Image 5) | `userId`, `practiceDate`, `overallScore`, `fluencyScore`, `grammarScore`, `pronunciationScore`, `vocabularyScore` |
| **`mistake_patterns`** | Personal Learning Memory Bank | `userId`, `category`, `mistakeCount`, `retrySuccessCount`, `masteryPercentage` |
| **`subscriptions`** | Freemium access (₱199/month Pro) | `userId`, `plan`, `pricePHP`, `status`, `expiresAt` |

---

## 🔐 Security Rules (`firestore.rules`)
All documents enforce strict user ownership:
```javascript
function isOwner(userId) {
  return request.auth != null && request.auth.uid == userId;
}
```
Users can only read and write their own speaking sessions, corrections, and progress records.

---

## ⚡ Firebase Cloud Functions (`functions/index.js`)

1. **`getGeminiLiveToken`**: Generates short-lived session tokens for client-to-server Gemini Live voice streaming without exposing API keys.
2. **`analyzeGrammarMistake`**: Smart Grammar Coach endpoint calling Gemini with structured JSON extraction, writing corrections directly to Firestore.
3. **`getAdaptiveLesson`**: Synthesizes custom speaking scenarios based on the user's highest mistake frequency in Firestore.

---

## 🚀 How to Connect Your Firebase Project to Flutter

### 1. Install the Firebase CLI & FlutterFire CLI
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

### 2. Configure Flutter with 1 Command
Run from the project root:
```bash
flutterfire configure
```
This automatically registers your Android, iOS, and Web apps with Firebase and generates `lib/firebase_options.dart`.

### 3. Deploy Security Rules & Cloud Functions
```bash
cd firebase
firebase deploy --only firestore:rules,firestore:indexes,functions
```

### 4. (Optional) Populate Demo Seed Data
```bash
python firebase/seed_firestore.py
```
This exports `firestore_seed.json` with Ross's profile, the Sep 1 to Oct 13 assessment curve data, and sample correction cards ready to import into Firebase Console!
