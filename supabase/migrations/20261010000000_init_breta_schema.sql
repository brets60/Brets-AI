-- ============================================================================
-- BRETA AI — SUPABASE POSTGRESQL SCHEMA INITIALIZATION
-- Multi-tier AI speaking partner, grammar coach, and progress tracking
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ----------------------------------------------------------------------------
-- 1. PROFILES TABLE
-- Extends Supabase auth.users with learner preferences & CEFR levels
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL DEFAULT 'Learner',
    avatar_url TEXT,
    english_level TEXT NOT NULL DEFAULT 'B1' CHECK (english_level IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')),
    native_language TEXT NOT NULL DEFAULT 'Tagalog',
    learning_goal TEXT NOT NULL DEFAULT 'Job Interview Fluency',
    daily_goal_minutes INT NOT NULL DEFAULT 15,
    streak_days INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Trigger to auto-create profile on Supabase auth signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Learner'),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ----------------------------------------------------------------------------
-- 2. CONVERSATIONS TABLE
-- One record per AI voice conversation session
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    scenario TEXT NOT NULL DEFAULT 'Talk about anything',
    mode TEXT NOT NULL DEFAULT 'learning' CHECK (mode IN ('learning', 'conversation', 'roleplay', 'interview')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    ended_at TIMESTAMPTZ,
    duration_seconds INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON public.conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_created_at ON public.conversations(created_at DESC);

-- ----------------------------------------------------------------------------
-- 3. CONVERSATION MESSAGES TABLE
-- Chronological user and AI transcript turns
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.conversation_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    speaker TEXT NOT NULL CHECK (speaker IN ('user', 'ai')),
    transcript TEXT NOT NULL,
    audio_duration_ms INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON public.conversation_messages(conversation_id);

-- ----------------------------------------------------------------------------
-- 4. CORRECTIONS TABLE
-- Smart Grammar Coach 3-tier feedback records
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.corrections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    message_id UUID REFERENCES public.conversation_messages(id) ON DELETE SET NULL,
    original_text TEXT NOT NULL,
    corrected_text TEXT NOT NULL,
    explanation TEXT NOT NULL,
    error_words TEXT[] NOT NULL DEFAULT '{}',
    category TEXT NOT NULL DEFAULT 'General Grammar',
    is_practiced BOOLEAN NOT NULL DEFAULT FALSE,
    practiced_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_corrections_user_id ON public.corrections(user_id);
CREATE INDEX IF NOT EXISTS idx_corrections_category ON public.corrections(category);

-- ----------------------------------------------------------------------------
-- 5. LEARNING PROGRESS TABLE
-- Daily performance and historical scores for the 5 competency curves
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.learning_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    practice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    minutes_practiced INT NOT NULL DEFAULT 0,
    words_learned INT NOT NULL DEFAULT 0,
    overall_score NUMERIC(5, 2) NOT NULL DEFAULT 0.0 CHECK (overall_score BETWEEN 0 AND 100),
    fluency_score NUMERIC(5, 2) NOT NULL DEFAULT 0.0 CHECK (fluency_score BETWEEN 0 AND 100),
    grammar_score NUMERIC(5, 2) NOT NULL DEFAULT 0.0 CHECK (grammar_score BETWEEN 0 AND 100),
    pronunciation_score NUMERIC(5, 2) NOT NULL DEFAULT 0.0 CHECK (pronunciation_score BETWEEN 0 AND 100),
    vocabulary_score NUMERIC(5, 2) NOT NULL DEFAULT 0.0 CHECK (vocabulary_score BETWEEN 0 AND 100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, practice_date)
);

CREATE INDEX IF NOT EXISTS idx_learning_progress_user_date ON public.learning_progress(user_id, practice_date DESC);

-- ----------------------------------------------------------------------------
-- 6. USER MISTAKE PATTERNS TABLE
-- Persistent Learning Memory Bank
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_mistake_patterns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    mistake_count INT NOT NULL DEFAULT 1,
    retry_success_count INT NOT NULL DEFAULT 0,
    mastery_percentage NUMERIC(5, 2) GENERATED ALWAYS AS (
        CASE WHEN mistake_count = 0 THEN 100.0
             ELSE LEAST(100.0, ROUND((retry_success_count::numeric / mistake_count::numeric) * 100.0, 2))
        END
    ) STORED,
    last_seen_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    UNIQUE(user_id, category)
);

CREATE INDEX IF NOT EXISTS idx_mistake_patterns_user ON public.user_mistake_patterns(user_id);

-- ----------------------------------------------------------------------------
-- 7. SUBSCRIPTIONS TABLE
-- Payment status (Freemium: Free, Premium ₱199/mo, Pro)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    plan TEXT NOT NULL DEFAULT 'free' CHECK (plan IN ('free', 'premium', 'pro', 'team')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'canceled', 'expired', 'past_due')),
    provider TEXT NOT NULL DEFAULT 'google_play' CHECK (provider IN ('google_play', 'apple_iap', 'stripe', 'manual')),
    price_cents INT NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'PHP',
    current_period_start TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    current_period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);

-- ----------------------------------------------------------------------------
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Strict user isolation: users can only read and write their own data
-- ----------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.corrections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_mistake_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Profiles: users manage their own record
CREATE POLICY "Users can view own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- Conversations
CREATE POLICY "Users can view own conversations"
    ON public.conversations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations"
    ON public.conversations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own conversations"
    ON public.conversations FOR UPDATE
    USING (auth.uid() = user_id);

-- Messages
CREATE POLICY "Users can view own conversation messages"
    ON public.conversation_messages FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM public.conversations c
        WHERE c.id = conversation_messages.conversation_id AND c.user_id = auth.uid()
    ));

CREATE POLICY "Users can insert messages into own conversation"
    ON public.conversation_messages FOR INSERT
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.conversations c
        WHERE c.id = conversation_messages.conversation_id AND c.user_id = auth.uid()
    ));

-- Corrections
CREATE POLICY "Users can view own corrections"
    ON public.corrections FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own corrections"
    ON public.corrections FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own corrections"
    ON public.corrections FOR UPDATE
    USING (auth.uid() = user_id);

-- Learning Progress
CREATE POLICY "Users can view own learning progress"
    ON public.learning_progress FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert/update own learning progress"
    ON public.learning_progress FOR ALL
    USING (auth.uid() = user_id);

-- Mistake Patterns
CREATE POLICY "Users can view own mistake patterns"
    ON public.user_mistake_patterns FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own mistake patterns"
    ON public.user_mistake_patterns FOR ALL
    USING (auth.uid() = user_id);

-- Subscriptions
CREATE POLICY "Users can view own subscription"
    ON public.subscriptions FOR SELECT
    USING (auth.uid() = user_id);
