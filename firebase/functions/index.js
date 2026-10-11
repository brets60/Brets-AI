const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// ----------------------------------------------------------------------
// 1. getGeminiLiveToken: Ephemeral session credentials for live voice
// ----------------------------------------------------------------------
exports.getGeminiLiveToken = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated with Firebase.");
  }

  const userId = request.auth.uid;
  const userDoc = await db.collection("users").doc(userId).get();
  const userData = userDoc.exists ? userDoc.data() : { englishLevel: "B1", dailyGoalMinutes: 15 };

  const subDoc = await db.collection("subscriptions").doc(userId).get();
  const isPro = subDoc.exists && ["premium", "pro"].includes(subDoc.data()?.plan);

  const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
  if (!GEMINI_API_KEY) {
    throw new HttpsError("failed-precondition", "GEMINI_API_KEY is not configured in Firebase secrets.");
  }

  return {
    sessionId: `live_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`,
    userId: userId,
    model: "models/gemini-2.0-flash-exp",
    voicePersona: "Puck",
    systemInstruction: `You are Breta AI, a friendly, patient English-speaking coach for ${userData.englishLevel} learners. Speak naturally, encourage the speaker, and never interrupt every sentence.`,
    tier: isPro ? "unlimited" : "standard",
    remainingMinutes: isPro ? 999 : (userData.dailyGoalMinutes || 15),
    token: `emp_fb_${Date.now()}`,
    expiresInSeconds: 3600,
  };
});

// ----------------------------------------------------------------------
// 2. analyzeGrammarMistake: Smart Grammar Coach (Image 4 feedback)
// ----------------------------------------------------------------------
exports.analyzeGrammarMistake = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const { sentence } = request.data;
  if (!sentence || typeof sentence !== "string") {
    throw new HttpsError("invalid-argument", "Missing 'sentence' argument.");
  }

  const userId = request.auth.uid;
  const userDoc = await db.collection("users").doc(userId).get();
  const userData = userDoc.exists ? userDoc.data() : { englishLevel: "B1", nativeLanguage: "Tagalog" };

  const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
  if (!GEMINI_API_KEY) {
    throw new HttpsError("failed-precondition", "GEMINI_API_KEY not configured.");
  }

  const prompt = `You are Breta AI Smart Grammar Coach for an English learner (${userData.englishLevel}).
User Spoken Sentence: "${sentence}"
User Native Language: ${userData.nativeLanguage}

Analyze the sentence for grammatical errors.
Return ONLY valid JSON matching this schema:
{
  "correctedSentence": "string",
  "suggestions": "string (clear, encouraging pedagogical explanation)",
  "errorWords": ["word1", "word2"],
  "category": "string (concise grammar category)"
}`;

  const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`;
  const response = await fetch(geminiUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { responseMimeType: "application/json" },
    }),
  });

  const jsonResult = await response.json();
  const rawText = jsonResult.candidates?.[0]?.content?.parts?.[0]?.text;
  const parsed = JSON.parse(rawText || "{}");

  // Save into Firestore corrections collection
  const correctionRef = await db.collection("corrections").add({
    userId: userId,
    userAnswer: sentence,
    correctedSentence: parsed.correctedSentence || sentence,
    suggestions: parsed.suggestions || "Well done!",
    errorWords: parsed.errorWords || [],
    category: parsed.category || "General Grammar",
    isPracticed: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Update Mistake Memory Bank
  if (parsed.category) {
    const patternRef = db.collection("mistake_patterns").doc(`${userId}_${parsed.category.replace(/[\/\s]/g, "_")}`);
    await patternRef.set(
      {
        userId: userId,
        category: parsed.category,
        mistakeCount: admin.firestore.FieldValue.increment(1),
        lastSeenAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  }

  return {
    id: correctionRef.id,
    userAnswer: sentence,
    suggestions: parsed.suggestions,
    correctedSentence: parsed.correctedSentence,
    errorWords: parsed.errorWords || [],
    category: parsed.category || "General Grammar",
  };
});

// ----------------------------------------------------------------------
// 3. getAdaptiveLesson: Synthesizes scenario based on Firestore memory
// ----------------------------------------------------------------------
exports.getAdaptiveLesson = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "User must be authenticated.");
  }

  const userId = request.auth.uid;
  const patternsSnapshot = await db
    .collection("mistake_patterns")
    .where("userId", "==", userId)
    .orderBy("mistakeCount", "desc")
    .limit(3)
    .get();

  const weakTopics = patternsSnapshot.docs.map((doc) => doc.data().category).join(", ") || "Past Simple and Prepositions";
  const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

  if (!GEMINI_API_KEY) {
    throw new HttpsError("failed-precondition", "GEMINI_API_KEY not configured.");
  }

  const prompt = `Synthesize a 5-minute English speaking scenario for a student who repeatedly struggles with: ${weakTopics}.
Return ONLY valid JSON:
{
  "scenarioTitle": "string",
  "goalDescription": "string",
  "openingPrompt": "string",
  "targetVocabulary": ["phrase1", "phrase2", "phrase3"]
}`;

  const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`;
  const response = await fetch(geminiUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: { responseMimeType: "application/json" },
    }),
  });

  const jsonResult = await response.json();
  const rawText = jsonResult.candidates?.[0]?.content?.parts?.[0]?.text;
  return JSON.parse(rawText || "{}");
});
