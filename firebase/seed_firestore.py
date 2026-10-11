#!/usr/bin/env python3
"""
Breta AI — Firestore Demo Data Seeder
Populates Firestore with Ross's profile, assessment points (Sep 1 - Oct 13),
and correction cards matching the reference UI mockups.
"""

import json

DEMO_DATA = {
    "users": {
        "ross_demo": {
            "displayName": "Ross",
            "englishLevel": "B2",
            "nativeLanguage": "Tagalog",
            "learningGoal": "Tech Job Interview Fluency",
            "dailyGoalMinutes": 15,
            "streakDays": 7,
            "createdAt": "2026-09-01T00:00:00Z"
        }
    },
    "learning_progress": [
        {"userId": "ross_demo", "practiceDate": "2026-09-01", "overallScore": 63, "fluencyScore": 30, "grammarScore": 40, "pronunciationScore": 90, "vocabularyScore": 92},
        {"userId": "ross_demo", "practiceDate": "2026-09-08", "overallScore": 66, "fluencyScore": 35, "grammarScore": 45, "pronunciationScore": 95, "vocabularyScore": 88},
        {"userId": "ross_demo", "practiceDate": "2026-09-15", "overallScore": 66, "fluencyScore": 40, "grammarScore": 50, "pronunciationScore": 85, "vocabularyScore": 90},
        {"userId": "ross_demo", "practiceDate": "2026-09-22", "overallScore": 72, "fluencyScore": 45, "grammarScore": 55, "pronunciationScore": 92, "vocabularyScore": 95},
        {"userId": "ross_demo", "practiceDate": "2026-09-29", "overallScore": 76, "fluencyScore": 50, "grammarScore": 60, "pronunciationScore": 98, "vocabularyScore": 97},
        {"userId": "ross_demo", "practiceDate": "2026-10-06", "overallScore": 77.5, "fluencyScore": 55, "grammarScore": 65, "pronunciationScore": 96, "vocabularyScore": 94},
        {"userId": "ross_demo", "practiceDate": "2026-10-13", "overallScore": 78.5, "fluencyScore": 60, "grammarScore": 70, "pronunciationScore": 93, "vocabularyScore": 91}
    ],
    "corrections": [
        {
            "userId": "ross_demo",
            "userAnswer": "Last summer I went to the beach with my family. It was amazing, we swim in the sea and eat a lot of ice cream.",
            "suggestions": "In your response, there are several verb tense errors. In the sentences 'we swim in the sea' and 'we eat a lot of ice cream', past tense should be used: 'we swam' and 'we ate'. These errors relate to verb tenses and the correct usage of past forms.",
            "correctedSentence": "Last summer I went to the beach with my family. It was amazing, we swam in the sea and ate a lot of ice cream.",
            "errorWords": ["swam", "ate"],
            "category": "Past Simple Irregular Verbs",
            "isPracticed": True
        },
        {
            "userId": "ross_demo",
            "userAnswer": "I am working as developer since three years in Manila.",
            "suggestions": "When describing an action that started in the past and continues into the present, use the Present Perfect Continuous ('have been working') with 'for' instead of 'since' for durations.",
            "correctedSentence": "I have been working as a developer for three years in Manila.",
            "errorWords": ["have", "been", "working", "for"],
            "category": "Present Perfect Continuous",
            "isPracticed": False
        }
    ],
    "mistake_patterns": [
        {"userId": "ross_demo", "category": "Past Simple Irregular Verbs", "mistakeCount": 14, "retrySuccessCount": 11, "masteryPercentage": 78.5},
        {"userId": "ross_demo", "category": "Prepositions of Time & Place", "mistakeCount": 8, "retrySuccessCount": 5, "masteryPercentage": 62.5},
        {"userId": "ross_demo", "category": "Subject-Verb Agreement", "mistakeCount": 20, "retrySuccessCount": 17, "masteryPercentage": 85.0}
    ],
    "subscriptions": {
        "ross_demo": {
            "userId": "ross_demo",
            "plan": "premium",
            "pricePHP": 199.00,
            "status": "active",
            "provider": "google_play"
        }
    }
}

def export_seed_json():
    with open("firestore_seed.json", "w") as f:
        json.dump(DEMO_DATA, f, indent=2)
    print("[✓] Generated firestore_seed.json successfully.")
    print("    You can import this directly into Firebase Console or Firestore Emulator!")

if __name__ == "__main__":
    export_seed_json()
