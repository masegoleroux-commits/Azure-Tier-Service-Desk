"""Full flow: translate to English if needed, then redact, classify and prioritise.

Usage:
    python src/pipeline.py "My drukker werk nie, dit is dringend"
"""
import json
import sys
from datetime import datetime
from pathlib import Path

from translate import to_english
from triage import triage


def run(text: str) -> dict:
    lang, english = to_english(text)
    result = triage(english)
    result["original_language"] = lang
    result["processed_at"] = datetime.now().isoformat(timespec="seconds")
    return result


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit('Usage: python src/pipeline.py "ticket text"')
    output = run(sys.argv[1])
    out_dir = Path(__file__).resolve().parent.parent / "sample-output"
    out_dir.mkdir(exist_ok=True)
    out_file = out_dir / f"triage-{datetime.now():%Y%m%d-%H%M%S}.json"
    out_file.write_text(json.dumps(output, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(output, indent=2, ensure_ascii=False))
    print(f"\nSaved to {out_file}")
