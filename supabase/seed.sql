-- ============================================================================
-- BRETA AI — DEMO SEED DATA
-- Pre-populates Ross's account matching the mockup screens and charts
-- ============================================================================

DO $$
DECLARE
    demo_user_id UUID := 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
    conv_id UUID := 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22';
    msg_user_id UUID := 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a33';
BEGIN
    -- 1. Insert Profile
    INSERT INTO public.profiles (
        id, display_name, english_level, native_language, learning_goal, daily_goal_minutes, streak_days
    ) VALUES (
        demo_user_id, 'Ross', 'B2', 'Tagalog', 'Tech Job Interview Fluency', 15, 7
    ) ON CONFLICT (id) DO UPDATE SET
        display_name = EXCLUDED.display_name,
        english_level = EXCLUDED.english_level;

    -- 2. Insert Conversation
    INSERT INTO public.conversations (
        id, user_id, scenario, mode, started_at, ended_at, duration_seconds
    ) VALUES (
        conv_id, demo_user_id, 'Talk about anything', 'learning',
        now() - INTERVAL '15 minutes', now(), 900
    ) ON CONFLICT (id) DO NOTHING;

    -- 3. Insert Messages
    INSERT INTO public.conversation_messages (
        id, conversation_id, speaker, transcript, created_at
    ) VALUES
    (
        gen_random_uuid(), conv_id, 'ai',
        'Great to meet you! How can I assist your English today? We can talk about anything you like!',
        now() - INTERVAL '14 minutes'
    ),
    (
        msg_user_id, conv_id, 'user',
        'Last summer I went to the beach with my family. It was amazing, we swim in the sea and eat a lot of ice cream.',
        now() - INTERVAL '13 minutes'
    ),
    (
        gen_random_uuid(), conv_id, 'ai',
        'That sounds like a fun trip! You used past tense nicely with "went", but remember that for swim and eat in the past, we say "swam" and "ate".',
        now() - INTERVAL '12 minutes'
    ) ON CONFLICT (id) DO NOTHING;

    -- 4. Insert Corrections (matching Image 4)
    INSERT INTO public.corrections (
        id, user_id, message_id, original_text, corrected_text, explanation, error_words, category, is_practiced
    ) VALUES (
        gen_random_uuid(),
        demo_user_id,
        msg_user_id,
        'Last summer I went to the beach with my family. It was amazing, we swim in the sea and eat a lot of ice cream.',
        'Last summer I went to the beach with my family. It was amazing, we swam in the sea and ate a lot of ice cream.',
        'In your response, there are several verb tense errors. In the sentences "we swim in the sea" and "we eat a lot of ice cream", past tense should be used: "we swam" and "we ate". These errors relate to verb tenses and the correct usage of past forms.',
        ARRAY['swam', 'ate'],
        'Past Simple Irregular Verbs',
        true
    ),
    (
        gen_random_uuid(),
        demo_user_id,
        NULL,
        'I am working as developer since three years in Manila.',
        'I have been working as a developer for three years in Manila.',
        'When describing an ongoing duration from the past to present, use Present Perfect Continuous ("have been working") with "for" instead of "since".',
        ARRAY['have', 'been', 'working', 'for'],
        'Present Perfect Continuous',
        false
    );

    -- 5. Insert Learning Progress Assessment Points (matching Image 5 curve)
    INSERT INTO public.learning_progress (
        user_id, practice_date, minutes_practiced, words_learned, overall_score, fluency_score, grammar_score, pronunciation_score, vocabulary_score
    ) VALUES
    (demo_user_id, '2026-09-01'::DATE, 20, 15, 63.0, 30.0, 40.0, 90.0, 92.0),
    (demo_user_id, '2026-09-08'::DATE, 25, 20, 66.0, 35.0, 45.0, 95.0, 88.0),
    (demo_user_id, '2026-09-15'::DATE, 15, 12, 66.0, 40.0, 50.0, 85.0, 90.0),
    (demo_user_id, '2026-09-22'::DATE, 30, 25, 72.0, 45.0, 55.0, 92.0, 95.0),
    (demo_user_id, '2026-09-29'::DATE, 20, 18, 76.0, 50.0, 60.0, 98.0, 97.0),
    (demo_user_id, '2026-10-06'::DATE, 25, 22, 77.5, 55.0, 65.0, 96.0, 94.0),
    (demo_user_id, '2026-10-13'::DATE, 35, 30, 78.5, 60.0, 70.0, 93.0, 91.0)
    ON CONFLICT (user_id, practice_date) DO NOTHING;

    -- 6. Insert Mistake Memory Patterns
    INSERT INTO public.user_mistake_patterns (
        user_id, category, mistake_count, retry_success_count
    ) VALUES
    (demo_user_id, 'Past Simple Irregular Verbs', 14, 11),
    (demo_user_id, 'Prepositions of Time & Place', 8, 5),
    (demo_user_id, 'Subject-Verb Agreement', 20, 17)
    ON CONFLICT (user_id, category) DO NOTHING;

    -- 7. Insert Subscription (Philippines test tier: ₱199/month)
    INSERT INTO public.subscriptions (
        user_id, plan, status, provider, price_cents, currency, current_period_end
    ) VALUES (
        demo_user_id, 'premium', 'active', 'google_play', 19900, 'PHP', now() + INTERVAL '30 days'
    );

END $$;
