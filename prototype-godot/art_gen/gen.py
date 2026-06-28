#!/usr/bin/env python
"""Tarkeez art generator — calls Gemini image models, saves PNGs.

Supports reference images (for character/style consistency) and a shared
style preamble so the whole asset set looks like one game.
"""
import base64, json, os, sys, time, urllib.request, urllib.error

HERE = os.path.dirname(os.path.abspath(__file__))
KEY = open(os.path.join(HERE, ".key")).read().strip()
RAW = os.path.join(HERE, "..", "art_raw")
os.makedirs(RAW, exist_ok=True)

# House style — prepended to every prompt so assets cohere.
STYLE = (
    "Cute modern mobile-game art, warm hand-painted storybook style with soft "
    "cel shading, gentle gradients, clean rounded shapes, soft rim light, no "
    "harsh outlines. Cozy, calm, premium quality like Alto's Odyssey meets "
    "Monument Valley. Middle-Eastern / Arabian desert-oasis theme. "
)

def _endpoint(model):
    return f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"

def gen(prompt, out, refs=None, model="gemini-2.5-flash-image", tries=4, transparent=False):
    # resumable: don't redo an asset we already have
    if os.path.exists(os.path.join(RAW, out)) and "--force" not in sys.argv:
        print(f"  skip {out} (exists)")
        return True
    parts = [{"text": STYLE + prompt}]
    for rp in (refs or []):
        with open(rp, "rb") as f:
            b = base64.b64encode(f.read()).decode()
        parts.append({"inline_data": {"mime_type": "image/png", "data": b}})
    body = {
        "contents": [{"parts": parts}],
        "generationConfig": {"responseModalities": ["IMAGE"]},
    }
    data = json.dumps(body).encode()
    for attempt in range(tries):
        req = urllib.request.Request(_endpoint(model), data=data, method="POST")
        req.add_header("Content-Type", "application/json")
        req.add_header("X-goog-api-key", KEY)
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                resp = json.load(r)
        except urllib.error.HTTPError as e:
            msg = e.read().decode()[:300]
            print(f"  HTTP {e.code} on {out}: {msg}")
            if e.code in (429, 500, 503) and attempt < tries - 1:
                time.sleep(6 * (attempt + 1)); continue
            return False
        except Exception as e:
            print(f"  ERR {out}: {e}")
            time.sleep(4); continue
        img = _extract(resp)
        if img:
            path = os.path.join(RAW, out)
            with open(path, "wb") as f:
                f.write(img)
            print(f"  OK {out} ({len(img)//1024} KB)")
            return True
        else:
            print(f"  no image in response for {out}; retrying")
            time.sleep(3)
    return False

def _extract(resp):
    for c in resp.get("candidates", []):
        for p in c.get("content", {}).get("parts", []):
            d = p.get("inlineData") or p.get("inline_data")
            if d and d.get("data"):
                return base64.b64decode(d["data"])
    return None

if __name__ == "__main__":
    # quick single-shot test:  python gen.py "<prompt>" out.png [model]
    p = sys.argv[1]
    out = sys.argv[2]
    model = sys.argv[3] if len(sys.argv) > 3 else "gemini-2.5-flash-image"
    ok = gen(p, out, model=model)
    sys.exit(0 if ok else 1)
