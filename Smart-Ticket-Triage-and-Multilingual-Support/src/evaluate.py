"""Runs the classifier against the test tickets in data/labels.json and reports accuracy.

Usage:
    python src/evaluate.py
"""
import json
from collections import Counter
from pathlib import Path

from triage import classify

ROOT = Path(__file__).resolve().parent.parent


def main() -> None:
    labels = json.loads((ROOT / "data" / "labels.json").read_text(encoding="utf-8"))
    tests = [d for d in labels["assets"]["documents"] if d["dataset"] == "Test"]

    correct, mistakes, per_class = 0, [], Counter()
    for doc in tests:
        text = (ROOT / "data" / "training" / doc["location"]).read_text(encoding="utf-8").strip()
        expected = doc["class"]["category"]
        predicted, confidence = classify(text)
        if predicted == expected:
            correct += 1
            per_class[expected] += 1
        else:
            mistakes.append((doc["location"], expected, predicted, confidence, text))

    total = len(tests)
    lines = [f"Accuracy: {correct}/{total} ({correct / total:.0%})", "", "Correct per category:"]
    for cat in sorted({d["class"]["category"] for d in tests}):
        n = sum(1 for d in tests if d["class"]["category"] == cat)
        lines.append(f"  {cat}: {per_class[cat]}/{n}")
    if mistakes:
        lines += ["", "Misclassified:"]
        lines += [f"  {f}: expected {e}, got {p} ({c}) - {t}" for f, e, p, c, t in mistakes]

    report = "\n".join(lines)
    print(report)
    (ROOT / "sample-output" / "evaluation-report.txt").write_text(report + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
