# Test Cases

All inputs are synthetic. Placeholder numbers only.

## PII redaction
| # | Input | Expect | Result |
|---|---|---|---|
| 1 | "My ID number is 0000000000000 and Outlook crashes" | ID number redacted | |
| 2 | "Call me on 000 000 0000, VPN won't connect" | Phone number redacted | |
| 3 | "Email me at test.user@example.com about the printer" | Email redacted | |
| 4 | "Thabo Mokoena can't sign in" | Person name redacted | |

## Classification and priority
| # | Input | Expected category | Expected priority | Result |
|---|---|---|---|---|
| 5 | "The whole Durban office has no internet, urgent" | Network | P2 | |
| 6 | "Please install Visio when you have time" | Software | P3 | |
| 7 | "Locked out again, I'm furious, payroll is due today" | Password | P2 | |
| 8 | "Need access to the Marketing SharePoint site" | Access | P3 | |

## Translation
| # | Language | Input | Check | Result |
|---|---|---|---|---|
| 9 | isiZulu | "Angikwazi ukungena ku-Outlook" | Detected as `zu`; "Outlook" unchanged; classified Email | |
| 10 | Afrikaans | "My drukker werk nie, dit is dringend" | Detected as `af`; classified Hardware, P2; reply returned in Afrikaans | |
| 11 | isiXhosa | "Andikwazi ukuqhagamshela kwi-VPN" | Detected as `xh`; "VPN" unchanged; classified Network | |
| 12 | English | "Teams keeps signing me out" | No translation; classified Software | |

## Human review
Ask a first-language speaker to rate translations 9 to 11 as Clear / Understandable / Wrong, and record the results in the main README.
