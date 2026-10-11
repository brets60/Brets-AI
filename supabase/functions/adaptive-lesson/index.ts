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

    // 1. Fetch user's weakest mistake patterns
    const { data: weakPatterns } = await supabaseClient
      .from("user_mistake_patterns")
      .select("category, mistake_count, mastery_percentage")
      .eq("user_id", user.id)
      .order("mastery_percentage", { ascending: true })
      .limit(3);

    const targetTopics = weakPatterns?.map((p) => p.category).join(", ") || "General Past Tense and Prepositions";

    const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
    if (!GEMINI_API_KEY) {
      return new Response(JSON.stringify({ error: "GEMINI_API_KEY not configured" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Synthesize an adaptive practice prompt with Gemini
    const prompt = `Synthesize a personalized 5-minute English speaking scenario for a student who struggles with: ${targetTopics}.
Provide:
1. "scenarioTitle": Catchy scenario title (e.g. "Sharing a Past Weekend Trip", "Reporting a Bug in a Standup").
2. "goalDescription": Specific practice goal.
3. "openingPrompt": What the AI speaking partner will say first to prompt the user to use the target grammatical form.
4. "targetVocabulary": Array of 3 helpful phrases.

Return ONLY valid JSON matching this schema:
{
  "scenarioTitle": "string",
  "goalDescription": "string",
  "openingPrompt": "string",
  "targetVocabulary": ["phrase1", "phrase2", "phrase3"]
}`;

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`;
    const geminiResp = await fetch(geminiUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { responseMimeType: "application/json" },
      }),
    });

    const geminiData = await geminiResp.json();
    const rawText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text;
    const lesson = JSON.parse(rawText || "{}");

    return new Response(JSON.stringify(lesson), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
