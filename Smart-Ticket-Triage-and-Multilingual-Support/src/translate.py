"""Detects a ticket's language, translates it to English, and translates replies back.

Technical terms in glossary.tsv are kept unchanged using Translator's dynamic dictionary.

Usage:
    python src/translate.py "Angikwazi ukungena ku-Outlook"
"""
import os
import re
import sys
import uuid
from pathlib import Path

import requests
from dotenv import load_dotenv

load_dotenv()

ENDPOINT = "https://api.cognitive.microsofttranslator.com"
GLOSSARY = Path(__file__).with_name("glossary.tsv")


def _headers() -> dict:
    return {
        "Ocp-Apim-Subscription-Key": os.environ["TRANSLATOR_KEY"],
        "Ocp-Apim-Subscription-Region": os.environ["TRANSLATOR_REGION"],
        "Content-Type": "application/json",
        "X-ClientTraceId": str(uuid.uuid4()),
    }


def load_terms() -> list[str]:
    if not GLOSSARY.exists():
        return []
    terms = [line.split("\t")[0].strip() for line in GLOSSARY.read_text(encoding="utf-8").splitlines() if line.strip()]
    return sorted(terms, key=len, reverse=True)  # longest first so "Microsoft Authenticator" wins over "Authenticator"


def protect_terms(text: str) -> str:
    for term in load_terms():
        pattern = re.compile(rf"(?<![\w-]){re.escape(term)}(?![\w-])")
        text = pattern.sub(f'<mstrans:dictionary translation="{term}">{term}</mstrans:dictionary>', text)
    return text


def translate(text: str, to_lang: str, from_lang: str | None = None) -> tuple[str, str]:
    """Returns (detected_or_source_language, translated_text)."""
    params = {"api-version": "3.0", "to": to_lang}
    if from_lang:
        params["from"] = from_lang
    response = requests.post(
        f"{ENDPOINT}/translate",
        params=params,
        headers=_headers(),
        json=[{"text": protect_terms(text)}],
        timeout=15,
    )
    response.raise_for_status()
    data = response.json()[0]
    detected = data.get("detectedLanguage", {}).get("language", from_lang or "en")
    return detected, data["translations"][0]["text"]


def to_english(text: str) -> tuple[str, str]:
    lang, english = translate(text, "en")
    return lang, (text if lang == "en" else english)


def reply_in(lang: str, reply_english: str) -> str:
    if lang == "en":
        return reply_english
    return translate(reply_english, lang, "en")[1]


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit('Usage: python src/translate.py "ticket text"')
    lang, english = to_english(sys.argv[1])
    print(f"Detected language: {lang}")
    print(f"English: {english}")
    reply = "Please restart Outlook and sign in again with Microsoft Authenticator."
    print(f"Reply ({lang}): {reply_in(lang, reply)}")
