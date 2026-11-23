#!/usr/bin/env python3
"""Make the claude.ai preview page from index.html.

claude.ai adds its own <html>/<head> wrapper, so the preview page is just the title,
the styles and the body of index.html. The fonts are copied next to it.

Usage: python3 tools/build-artifact.py [output-folder]   (default: build/)
"""
import re
import shutil
import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
out = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else root / "build"
src = (root / "index.html").read_text(encoding="utf-8")


def grab(pattern, label):
    found = re.search(pattern, src, re.S)
    if not found:
        sys.exit(f"index.html: could not find {label}")
    return found


title = grab(r"<title>.*?</title>", "the <title>").group(0)
style = grab(r"<style>.*?</style>", "the <style> block").group(0)
body = grab(r"<body>(.*)</body>", "the <body>").group(1).strip()

page = "\n".join([title, '<meta name="claude:viewport-fit-sides" content="cover">', style, "", body, ""])

out.mkdir(parents=True, exist_ok=True)
(out / "spoke-shot.html").write_text(page, encoding="utf-8")
(out / "fonts").mkdir(exist_ok=True)
for font in sorted((root / "fonts").glob("*.woff2")):
    shutil.copy2(font, out / "fonts" / font.name)
print(f"wrote {out / 'spoke-shot.html'} and fonts/")
