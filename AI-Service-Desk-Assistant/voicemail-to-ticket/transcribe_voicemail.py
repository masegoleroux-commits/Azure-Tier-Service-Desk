"""Turns a voicemail recording into a structured service desk ticket.

1. Azure AI Speech transcribes the .wav file (South African English).
2. Azure OpenAI extracts ticket fields as JSON.
3. The result is printed and saved to ../sample-output/<file>.json.

Usage:
    python transcribe_voicemail.py samples/vm01.wav
"""
import json
import os
import sys
import threading
from pathlib import Path

import azure.cognitiveservices.speech as speechsdk
from dotenv import load_dotenv
from openai import AzureOpenAI

load_dotenv()

CATEGORIES = ["Password", "Email", "Hardware", "Network", "Access", "Software"]

SYSTEM_PROMPT = f"""You turn service desk voicemail transcripts into tickets.
Return only JSON with these keys:
  caller_name: string or null
  callback_number: string or null
  device: string or null
  category: one of {CATEGORIES}
  priority: one of P1, P2, P3, P4
     P1 = many users or a key system down
     P2 = one user fully blocked, or a team affected
     P3 = user can work with a workaround
     P4 = request or minor issue
  summary: one short sentence
  needs_callback: true or false
Use null when something is not stated. Do not invent details.
Never include passwords or codes even if the caller says them."""


def transcribe(path: str) -> str:
    """Continuous recognition so longer voicemails are not cut off after the first sentence."""
    config = speechsdk.SpeechConfig(subscription=os.environ["SPEECH_KEY"], region=os.environ["SPEECH_REGION"])
    config.speech_recognition_language = "en-ZA"
    audio = speechsdk.audio.AudioConfig(filename=path)
    recognizer = speechsdk.SpeechRecognizer(speech_config=config, audio_config=audio)

    parts: list[str] = []
    finished = threading.Event()

    def on_recognized(evt):
        if evt.result.reason == speechsdk.ResultReason.RecognizedSpeech:
            parts.append(evt.result.text)

    def on_canceled(evt):
        details = evt.cancellation_details
        if details.reason == speechsdk.CancellationReason.Error:
            print(f"Speech error: {details.error_details}", file=sys.stderr)
        finished.set()

    recognizer.recognized.connect(on_recognized)
    recognizer.session_stopped.connect(lambda evt: finished.set())
    recognizer.canceled.connect(on_canceled)

    recognizer.start_continuous_recognition()
    finished.wait(timeout=300)
    recognizer.stop_continuous_recognition()
    return " ".join(parts).strip()


def to_ticket(transcript: str) -> dict:
    client = AzureOpenAI(
        azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],
        api_key=os.environ["AZURE_OPENAI_KEY"],
        api_version=os.getenv("AZURE_OPENAI_API_VERSION", "2024-10-21"),
    )
    response = client.chat.completions.create(
        model=os.environ["AZURE_OPENAI_DEPLOYMENT"],
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": transcript},
        ],
        response_format={"type": "json_object"},
        temperature=0,
    )
    ticket = json.loads(response.choices[0].message.content)
    if ticket.get("category") not in CATEGORIES:
        ticket["category"] = "Software"
        ticket["review_note"] = "Category was not recognised; please check."
    return ticket


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit("Usage: python transcribe_voicemail.py <file.wav>")
    wav = Path(sys.argv[1])
    if not wav.exists():
        sys.exit(f"File not found: {wav}")

    transcript = transcribe(str(wav))
    if not transcript:
        sys.exit("No speech recognised. Check the file is 16 kHz mono WAV and the Speech key and region are correct.")

    ticket = to_ticket(transcript)
    ticket["source_file"] = wav.name
    ticket["transcript"] = transcript

    out_dir = Path(__file__).resolve().parent.parent / "sample-output"
    out_dir.mkdir(exist_ok=True)
    out_file = out_dir / f"{wav.stem}.json"
    out_file.write_text(json.dumps(ticket, indent=2), encoding="utf-8")

    print(json.dumps(ticket, indent=2))
    print(f"\nSaved to {out_file}")


if __name__ == "__main__":
    main()
