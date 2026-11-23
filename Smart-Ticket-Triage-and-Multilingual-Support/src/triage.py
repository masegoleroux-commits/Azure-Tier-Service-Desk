"""Redacts personal data, classifies the ticket and suggests a priority.

Usage:
    python src/triage.py "Outlook keeps crashing, this is urgent, call me on 000 000 0000"
"""
import json
import os
import sys

from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential
from dotenv import load_dotenv

load_dotenv()

URGENT_WORDS = ("urgent", "asap", "everyone", "all users", "whole team", "down", "month-end", "payroll", "can't work")
LOW_CONFIDENCE = 0.6

_client = None


def client() -> TextAnalyticsClient:
    global _client
    if _client is None:
        _client = TextAnalyticsClient(
            os.environ["LANGUAGE_ENDPOINT"], AzureKeyCredential(os.environ["LANGUAGE_KEY"])
        )
    return _client


def redact(text: str) -> tuple[str, list[str]]:
    result = client().recognize_pii_entities([text], language="en")[0]
    if result.is_error:
        raise RuntimeError(result.error)
    return result.redacted_text, sorted({e.category for e in result.entities})


def classify(text: str) -> tuple[str, float]:
    poller = client().begin_single_label_classify(
        [text],
        project_name=os.environ["CLASSIFY_PROJECT"],
        deployment_name=os.environ["CLASSIFY_DEPLOYMENT"],
    )
    doc = list(poller.result())[0]
    if doc.is_error:
        raise RuntimeError(doc.error)
    top = doc.classifications[0]
    return top.category, round(top.confidence_score, 2)


def sentiment(text: str) -> tuple[str, float]:
    result = client().analyze_sentiment([text])[0]
    if result.is_error:
        raise RuntimeError(result.error)
    return result.sentiment, round(result.confidence_scores.negative, 2)


def triage(text: str) -> dict:
    # Redact first so personal data never reaches anything that stores it
    redacted, pii_types = redact(text)
    category, confidence = classify(redacted)
    mood, negative = sentiment(redacted)

    urgent = negative > 0.7 or any(w in redacted.lower() for w in URGENT_WORDS)
    return {
        "category": category,
        "confidence": confidence,
        "needs_review": confidence < LOW_CONFIDENCE,
        "sentiment": mood,
        "negative_score": negative,
        "suggested_priority": "P2" if urgent else "P3",
        "pii_found": pii_types,
        "redacted_text": redacted,
    }


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit('Usage: python src/triage.py "ticket text"')
    print(json.dumps(triage(sys.argv[1]), indent=2, ensure_ascii=False))
