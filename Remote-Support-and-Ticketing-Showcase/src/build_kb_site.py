"""Builds a simple static website from the Markdown knowledge base articles.

Reads knowledge-base/*.md and writes kb-site/index.html plus one page per article.
"""
from pathlib import Path
import html

import markdown

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "knowledge-base"
OUT = ROOT / "kb-site"

STYLE = """
body{font-family:Segoe UI,Arial,sans-serif;max-width:820px;margin:0 auto;padding:24px 16px;line-height:1.6;color:#1b1b1b;background:#fff}
a{color:#0f6cbd}h1{font-size:1.8rem}code{background:#f3f3f3;padding:2px 4px;border-radius:4px}
pre{background:#f3f3f3;padding:12px;overflow-x:auto}li{margin:4px 0}.back{display:inline-block;margin-bottom:16px}
@media (prefers-color-scheme:dark){body{background:#1b1b1b;color:#eee}code,pre{background:#2b2b2b}a{color:#62abf5}}
"""


def page(title: str, body: str) -> str:
    return (
        "<!doctype html><html lang='en'><head><meta charset='utf-8'>"
        "<meta name='viewport' content='width=device-width,initial-scale=1'>"
        f"<title>{html.escape(title)}</title><style>{STYLE}</style></head>"
        f"<body>{body}</body></html>"
    )


def main() -> None:
    OUT.mkdir(exist_ok=True)
    links = []
    for md_file in sorted(SRC.glob("*.md")):
        if md_file.name.lower() == "readme.md":
            continue
        text = md_file.read_text(encoding="utf-8")
        title = text.splitlines()[0].lstrip("# ").strip()
        body = markdown.markdown(text, extensions=["tables", "fenced_code"])
        out_name = md_file.stem + ".html"
        (OUT / out_name).write_text(
            page(title, f"<a class='back' href='index.html'>&larr; All articles</a>{body}"),
            encoding="utf-8",
        )
        links.append(f"<li><a href='{out_name}'>{html.escape(title)}</a></li>")

    index = "<h1>IT Help Centre</h1><p>Step-by-step guides for common IT issues.</p><ul>" + "".join(links) + "</ul>"
    (OUT / "index.html").write_text(page("IT Help Centre", index), encoding="utf-8")
    print(f"Built {len(links)} articles into {OUT}")


if __name__ == "__main__":
    main()
