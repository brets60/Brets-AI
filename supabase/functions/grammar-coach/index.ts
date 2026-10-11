import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      }
    );

    const {
      data: { user },
      error: authError,
    } = await supabaseClient.auth.getUser();

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { sentence, conversationId } = await req.json();

    if (!sentence || typeof sentence !== "string") {
      return new Response(JSON.stringify({ error: "Missing 'sentence' in request" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Get user profile for native language & target level
    const { data: profile } = await supabaseClient
      .from("profiles")
      .select("english_level, native_language")
      .eq("id", user.id)
      .single();

    const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
    if (!GEMINI_API_KEY) {
      return new Response(JSON.stringify({ error: "GEMINI_API_KEY not configured" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Call Gemini 1.5/2.0 Flash for structured grammar correction
    const prompt = `You are the Breta AI Smart Grammar Coach for an English learner (${profile?.english_level ?? "B1"}).
User Spoken Sentence: "${sentence}"
User Native Language: ${profile?.native_language ?? "Tagalog/English"}

Analyze the sentence. If there are mistakes, provide:
1. "correctedSentence": The natural English sentence with grammatical errors fixed.
2. "suggestions": A friendly, clear explanation of the grammar mistake in simple English (mentioning the exact rule).
3. "errorWords": An array of words in the correctedSentence that were modified or added to fix the error (these will be highlighted with red badges in the UI).
4. "category": Concise grammatical category (e.g. "Past Simple Irregular Verbs", "Prepositions of Place", "Subject-Verb Agreement", "Articles").

Return ONLY valid JSON matching this structure:
{
  "correctedSentence": "string",
  "suggestions": "string",
  "errorWords": ["word1", "word2"],
  "category": "string"
}`;

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`;
    const geminiResp = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          responseMimeType: "application/json",
        },
      }),
    });

    const geminiData = await geminiResp.json();
    const rawText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text;
    const parsed = JSON.parse(rawText || "{}");

    // Save correction in Supabase
    const { data: savedCorrection, error: insertError } = await supabaseClient
      .from("corrections")
      .insert({
        user_id: user.id,
        original_text: sentence,
        corrected_text: parsed.correctedSentence || sentence,
        explanation: parsed.suggestions || "Looks good!",
        error_words: parsed.errorWords || [],
        category: parsed.category || "General Grammar",
      })
      .select()
      .single();

    if (insertError) {
      console.error("Failed to save correction:", insertError);
    }

    // Update Mistake Memory Bank
    if (parsed.category) {
      await supabaseClient.rpc("record_user_mistake", {
        p_user_id: user.id,
        p_category: parsed.category,
      }).catch(() => {});
    }

    return new Response(
      JSON.stringify({
        id: savedCorrection?.id || crypto.randomUUID(),
        userAnswer: sentence,
        suggestions: parsed.suggestions,
        correctedSentence: parsed.correctedSentence,
        errorWords: parsed.errorWords,
        category: parsed.category,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
