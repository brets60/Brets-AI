# Breta AI — Supabase Backend & Database Setup

This directory contains the production database schema, seed data, and Edge Functions for **Breta AI**.

---

## 🗄️ Database Architecture

The schema is organized across 7 core tables with strict **Row Level Security (RLS)**:

1. **`profiles`**: Extends Supabase `auth.users` with learner preferences, CEFR level (`A1`–`C2`), native language, and daily goal streak.
2. **`conversations`**: Tracks speaking sessions, scenarios (`Talk about anything`, `Job Interview`), modes (`learning` vs `conversation`), and duration.
3. **`conversation_messages`**: Real-time transcript turns (`user` vs `ai`).
4. **`corrections`**: 3-tier feedback cards storing `original_text`, `corrected_text`, `suggestions`, and `error_words[]`.
5. **`learning_progress`**: Daily performance and historical scores for the 5 competency curves (Overall, Fluency, Grammar, Pronunciation, Vocabulary).
6. **`user_mistake_patterns`**: The **Personal Learning Memory Bank** tracking recurring bottlenecks and mastery percentages.
7. **`subscriptions`**: Freemium tier management (Free, Premium `₱199/mo`, Pro).

---

## ⚡ Supabase Edge Functions (Deno / TypeScript)

### 1. `gemini-live-token`
* **Purpose:** Safely issues ephemeral credentials/tokens for client-to-server Gemini Live WebSocket sessions.
* **Security:** Client app never holds the secret `GEMINI_API_KEY`. Enforces daily speaking quotas and active subscriptions.

### 2. `grammar-coach`
* **Purpose:** Smart Grammar Coach workflow.
* **Model:** Calls Gemini with structured JSON output to extract corrections, pedagogical explanations, and exact words to highlight in red badges.
* Automatically records mistakes in the `user_mistake_patterns` memory bank.

### 3. `adaptive-lesson`
* **Purpose:** Retrieves the learner's recurring mistake patterns and synthesizes a tailored micro-scenario targeting their weakest grammatical areas.

---

## 🚀 Deployment Instructions

### 1. Prerequisites
Install the [Supabase CLI](https://supabase.com/docs/guides/cli):
```bash
npm install -g supabase
```

### 2. Initialize & Link Project
```bash
supabase login
supabase link --project-ref your-project-ref
```

### 3. Push Database Schema & Seed Data
```bash
# Push SQL migrations:
supabase db push

# (Optional) Seed demo records matching Ross & the mockups:
supabase db execute --file supabase/seed.sql
```

### 4. Deploy Edge Functions
Set your Gemini API key in Supabase secrets:
```bash
supabase secrets set GEMINI_API_KEY="your-gemini-api-key"
```

Deploy the functions:
```bash
supabase functions deploy gemini-live-token
supabase functions deploy grammar-coach
supabase functions deploy adaptive-lesson
```

---

## 🔒 Security Best Practices Implemented
- **No Client Keys:** Privileged Gemini API keys reside exclusively in Supabase Edge Functions.
- **Row Level Security (RLS):** All 7 tables have RLS enabled with `auth.uid() = user_id` policies.
- **Cascading Deletions:** User account deletion cleanly cascades across all child learning history.
