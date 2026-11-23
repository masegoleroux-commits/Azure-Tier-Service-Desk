# Smart Ticket Triage and Multilingual Support

## The problem
Tickets arrive unsorted, frustrated users wait in the same queue as routine requests, users sometimes paste ID numbers and phone numbers into tickets, and not every user is most comfortable writing in English.

## What it does
- **Redacts personal data** (ID numbers, phone numbers, emails) with Azure AI Language PII detection before anything is stored
- **Classifies** each ticket into Password, Email, Hardware, Network, Access or Software with a custom text classification model trained on 60 synthetic tickets
- **Flags urgency** using sentiment analysis plus urgent keywords
- **Translates** tickets written in isiZulu, Afrikaans or other languages into English for the analyst, and the reply back, keeping technical terms unchanged

## Architecture
```
Incoming ticket text
      │
      ▼
Azure AI Translator ──(not English)──► English text for analyst
      │
      ▼
Azure AI Language: PII detection ──► redacted text (only this is stored)
      │
      ├──► Custom text classification ──► category + confidence
      └──► Sentiment analysis ──────────► priority suggestion
      │
      ▼
JSON result ──► analyst reviews ──► reply translated back to user's language
```

## Tech used
Azure AI Language (custom single-label classification, PII detection, sentiment analysis), Azure AI Translator, Azure Storage, Python

## Setup
### 1. Azure resources
1. Create an **Azure AI Language** resource (Free F0). When asked, enable **custom text classification** and create or link a storage account.
2. Create an **Azure AI Translator** resource (Free F0).

### 2. Train the classifier
1. In the storage account, create a container named `ticket-triage` and upload everything in `data/training/`.
2. Open https://language.cognitive.azure.com > **Create new** > **Custom text classification** > **Single label**.
3. Choose **Import project** and upload `data/labels.json` (or create a project named `ticket-triage` and label the files by hand).
4. **Train** > new model `ticket-model-v1` > use the Train/Test split defined in the labels file.
5. Review **Model performance**; screenshot precision, recall and F1.
6. **Deploy** the model as `production`.

### 3. Run
```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env      # then fill in your keys
python src/pipeline.py "Ngicela usizo, angikwazi ukungena ku-Outlook. Inombolo yami ithi 000 000 0000."
python src/evaluate.py
```

| Script | Purpose |
|---|---|
| `src/triage.py` | PII redaction, classification and sentiment for one English ticket |
| `src/translate.py` | Detect language, translate to English, translate replies back |
| `src/pipeline.py` | Full flow: translate if needed, then triage |
| `src/evaluate.py` | Runs the 12 test tickets and reports accuracy |

## Testing
[tests/test-cases.md](tests/test-cases.md)

## Results
| Measure | Result |
|---|---|
| Classifier accuracy on the 12 test tickets | <fill in from evaluate.py> |
| Language Studio F1 score | <fill in> |
| PII correctly redacted (of test cases) | <fill in> |
| Translations rated understandable by a first-language speaker | <fill in> |

## Guardrails
- Only redacted text is saved; the original is discarded
- Suggested category and priority are reviewed by an analyst, never applied blindly
- Low-confidence classifications (below 0.6) are marked for manual review
- Supports POPIA principles by minimising personal information stored in tickets

## Screenshots
| File | Shows |
|---|---|
| `screenshots/01-language-studio-labels.png` | Labelled training data |
| `screenshots/02-model-performance.png` | Precision, recall and F1 |
| `screenshots/03-triage-output.png` | Redacted, classified ticket |
| `screenshots/04-translation-zulu.png` | isiZulu ticket translated and reply sent back |
| `screenshots/05-evaluate-results.png` | Accuracy report |

## What I learned
<your notes>

## Future improvements
- Retrain with real (redacted) ticket history
- Connect to the ticketing tool so category and priority are set on arrival

## Data notice
All tickets, names, ID numbers and phone numbers are synthetic. Placeholder numbers such as `0000000000000` and `000 000 0000` are used for PII tests.
