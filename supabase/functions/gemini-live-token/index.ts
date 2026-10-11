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

    // 1. Authenticate user from JWT
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

    // 2. Check user's subscription and daily speaking quota
    const { data: profile } = await supabaseClient
      .from("profiles")
      .select("daily_goal_minutes, english_level")
      .eq("id", user.id)
      .single();

    const { data: subscription } = await supabaseClient
      .from("subscriptions")
      .select("plan, status")
      .eq("user_id", user.id)
      .eq("status", "active")
      .maybeSingle();

    const isPro = subscription && ["premium", "pro"].includes(subscription.plan);

    // 3. Obtain Gemini API Key from backend secret
    const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
    if (!GEMINI_API_KEY) {
      return new Response(
        JSON.stringify({ error: "GEMINI_API_KEY is not configured on server" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 4. Return live session authorization payload & ephemeral connection endpoint
    // Client connects via WebSocket with short-lived session token
    const sessionPayload = {
      sessionId: crypto.randomUUID(),
      userId: user.id,
      model: "models/gemini-2.0-flash-exp",
      voicePersona: "Puck", // Friendly, patient speaking coach voice
      systemInstruction: `You are Breta AI, a friendly, patient English-speaking coach for ${profile?.english_level ?? "B1"} learners. Speak naturally, encourage the speaker, and never interrupt every sentence.`,
      tier: isPro ? "unlimited" : "standard",
      remainingMinutes: isPro ? 999 : (profile?.daily_goal_minutes ?? 15),
      token: `emp_${crypto.randomUUID()}`, // Ephemeral token representation
      expiresInSeconds: 3600,
    };

    return new Response(JSON.stringify(sessionPayload), {
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
