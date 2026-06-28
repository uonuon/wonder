#!/usr/bin/env python
"""Send a screenshot to Gemini for a concise, actionable UI/UX design critique.
   usage: python critique.py <image.png> "context about the screen"
"""
import base64, json, os, sys, urllib.request
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

HERE = os.path.dirname(os.path.abspath(__file__))
KEY = open(os.path.join(HERE, ".key")).read().strip()
MODEL = "gemini-2.5-flash"

PROMPT = (
    "You are a senior mobile product designer reviewing a screen from 'Tarkeez', "
    "a cozy Arabic-first focus/productivity app (a camel + desert oasis that grows "
    "as you focus; think Forest/Finch quality). Give a SHORT, blunt, prioritized "
    "critique: list the top 4-6 concrete visual/UX problems and for each a specific "
    "fix (spacing, hierarchy, color, alignment, sizing, polish). Focus on what would "
    "make it look premium and delightful. No praise, no preamble — just a numbered "
    "list of issue -> fix. Context: "
)

def main():
    img_path = sys.argv[1]
    ctx = sys.argv[2] if len(sys.argv) > 2 else ""
    with open(img_path, "rb") as f:
        b = base64.b64encode(f.read()).decode()
    body = {"contents": [{"parts": [
        {"text": PROMPT + ctx},
        {"inline_data": {"mime_type": "image/png", "data": b}},
    ]}]}
    req = urllib.request.Request(
        f"https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent",
        data=json.dumps(body).encode(), method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("X-goog-api-key", KEY)
    with urllib.request.urlopen(req, timeout=120) as r:
        resp = json.load(r)
    for c in resp.get("candidates", []):
        for p in c.get("content", {}).get("parts", []):
            if p.get("text"):
                print(p["text"])

if __name__ == "__main__":
    main()
