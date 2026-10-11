#!/usr/bin/env python3
"""
Breta AI — WebSocket Bridge for Gemini Live API
Enables Flutter and Web applications to connect via WebSocket for bidirectional
audio conversations with interruption handling.
"""

import os
import sys
import json
import asyncio
import argparse
from typing import Optional

try:
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
except Exception:
    pass

try:
    import websockets
    from websockets.server import WebSocketServerProtocol
except ImportError:
    print("[ERROR] websockets not installed. Run: pip install websockets")
    exit(1)

try:
    from google import genai
    from google.genai import types
except ImportError:
    genai = None

SYSTEM_INSTRUCTION = """You are Breta AI, a friendly and patient English-speaking coach.
Help learners speak English naturally, confidently, and correctly.
When the learner makes a meaningful grammar mistake, acknowledge their meaning first and give a brief correction.
Keep responses concise (1-3 sentences) so the learner speaks most of the time."""

class GeminiLiveBridge:
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.environ.get("GEMINI_API_KEY")
        self.client = genai.Client(api_key=self.api_key, http_options={"api_version": "v1alpha"}) if (genai and self.api_key) else None

    async def handle_client(self, websocket: WebSocketServerProtocol):
        client_id = id(websocket)
        print(f"[+] Client connected: {client_id}")

        # Send welcome/ready message
        await websocket.send(json.dumps({
            "type": "ready",
            "voice": "Puck",
            "model": "models/gemini-2.0-flash-exp",
            "live_ready": bool(self.client),
        }))

        try:
            async for raw_msg in websocket:
                data = json.loads(raw_msg)
                msg_type = data.get("type")

                if msg_type == "user_message":
                    user_text = data.get("text", "")
                    print(f"[{client_id}] User said: {user_text}")

                    # If API key is available and client initialized
                    if self.client:
                        await self._stream_gemini_turn(websocket, user_text)
                    else:
                        # Smart simulated pedagogical response
                        await self._simulate_coach_turn(websocket, user_text)

                elif msg_type == "interrupt":
                    print(f"[{client_id}] Client triggered interruption")
                    await websocket.send(json.dumps({
                        "type": "interrupted",
                        "status": "halted_previous_turn"
                    }))

        except websockets.exceptions.ConnectionClosed:
            print(f"[-] Client disconnected: {client_id}")
        except Exception as e:
            print(f"[!] Error handling client {client_id}: {e}")

    async def _stream_gemini_turn(self, websocket, user_text: str):
        config = types.LiveConnectConfig(
            response_modalities=[types.LiveModality.AUDIO],
            speech_config=types.SpeechConfig(
                voice_config=types.VoiceConfig(
                    prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name="Puck")
                )
            ),
            system_instruction=types.Content(parts=[types.Part.from_text(text=SYSTEM_INSTRUCTION)]),
        )

        try:
            async with self.client.aio.live.connect(model="models/gemini-2.0-flash-exp", config=config) as session:
                await session.send(input=user_text, end_of_turn=True)

                async for response in session.receive():
                    server_content = response.server_content
                    if server_content is not None:
                        if server_content.interrupted:
                            await websocket.send(json.dumps({"type": "interrupted"}))
                            break

                        model_turn = server_content.model_turn
                        if model_turn is not None:
                            for part in model_turn.parts:
                                if part.text:
                                    await websocket.send(json.dumps({"type": "caption", "text": part.text}))
                                if part.inline_data:
                                    # Send audio chunk
                                    await websocket.send(json.dumps({
                                        "type": "audio_chunk",
                                        "data": part.inline_data.data.decode("utf-8") if isinstance(part.inline_data.data, bytes) else str(part.inline_data.data),
                                    }))

                        if server_content.turn_complete:
                            await websocket.send(json.dumps({"type": "turn_complete"}))
                            break
        except Exception as err:
            await websocket.send(json.dumps({"type": "error", "message": str(err)}))

    async def _simulate_coach_turn(self, websocket, user_text: str):
        await asyncio.sleep(0.35) # Latency simulation

        correction = ""
        reply = "I understand you perfectly! Tell me more about that."
        lower = user_text.lower()

        if "yesterday i go" in lower:
            correction = "Notice that for yesterday, we say 'went' instead of 'go'."
            reply = f"That's great! {correction} How was the rest of your day?"
        elif "since three years" in lower or "for three years" in lower:
            correction = "For a duration of time, use 'for three years' with 'have been working'."
            reply = f"Awesome career! {correction} What projects do you work on?"

        # Stream caption
        await websocket.send(json.dumps({"type": "caption", "text": reply}))
        await asyncio.sleep(0.1)
        await websocket.send(json.dumps({
            "type": "turn_complete",
            "correction_detected": bool(correction),
            "correction": correction,
        }))

async def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8080)
    parser.add_argument("--api-key", default=None)
    args = parser.parse_args()

    bridge = GeminiLiveBridge(api_key=args.api_key)
    print(f"[*] Starting Breta AI Gemini Live Bridge on ws://localhost:{args.port}/ws/live")
    print(f"[*] Ready for client voice connections.")

    async with websockets.serve(bridge.handle_client, "0.0.0.0", args.port):
        await asyncio.Future() # run forever

if __name__ == "__main__":
    asyncio.run(main())
