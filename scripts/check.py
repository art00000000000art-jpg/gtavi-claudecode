"""Pre-post check of a finished clip.

usage: python check.py <clip.mp4> [--campaign campaigns.md] [--caption "text"]
                       [--story-reviewed] [--story-approved "reason"]
Reads clip_<n>.json (written by cut.py) next to the clip if present. Exit code 1 on any FAIL.
campaigns.md lines understood: min_seconds: 15 / max_seconds: 60 / required_hashtags: #a #b / required_mention: @x

Story spoilers (Rockstar's video policy, see spoilers.py):
- story/spoiler words in the hook or caption: FAIL. --story-approved "reason" turns it into a WARN
  (only for a false match, e.g. "the chase ending" on a police chase; never for a real story reveal).
- story words spoken in the clip (transcript): WARN.
- 3 frames are written to <clip>_frames/. Look at them: no HUD or minimap, letterbox bars, a
  cinematic camera or an in-game TV show means a cutscene or isolated show: do not post it.
  The "frames reviewed" line FAILs until you re-run with --story-reviewed.
"""
import argparse, re, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent))
from common import ffprobe, load_json, run, tool
from spoilers import story_hits

BANNED = ["leak", "leaked build", "play early", "early access download", "free download", "crack", "piracy",
          "mod menu", "money glitch", "afk bot"]


def parse_campaign(path):
    rules = {"min": 7.0, "max": 60.0, "tags": [], "mention": None}
    if not path or not Path(path).exists():
        return rules, False
    txt = Path(path).read_text(encoding="utf-8", errors="replace")
    m = re.search(r"min_seconds:\s*(\d+(?:\.\d+)?)", txt, re.I)
    if m: rules["min"] = float(m.group(1))
    m = re.search(r"max_seconds:\s*(\d+(?:\.\d+)?)", txt, re.I)
    if m: rules["max"] = float(m.group(1))
    m = re.search(r"required_hashtags:\s*(.+)", txt, re.I)
    if m: rules["tags"] = re.findall(r"#\w+", m.group(1))
    m = re.search(r"required_mention:\s*(@\w+)", txt, re.I)
    if m: rules["mention"] = m.group(1)
    return rules, True


def fps_of(s):
    try:
        a, b = s.split("/"); return float(a) / float(b)
    except Exception:
        return 0.0


def banned_in(text):
    low = text.lower()
    return [b for b in BANNED if b in low]


def export_frames(clip, dur):
    """Write 3 stills (15%, 50%, 85% of the clip) for a cutscene/TV-show look. Returns the paths."""
    out = clip.parent / f"{clip.stem}_frames"
    out.mkdir(exist_ok=True)
    paths = []
    for i, t in enumerate((dur * 0.15, dur * 0.5, dur * 0.85), 1):
        p = out / f"frame_{i}.jpg"
        run([tool("ffmpeg"), "-y", "-v", "error", "-ss", f"{t:.2f}", "-i", str(clip),
             "-frames:v", "1", "-q:v", "3", str(p)], check=False)
        if p.exists():
            paths.append(p)
    return out, paths


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("clip"); ap.add_argument("--campaign"); ap.add_argument("--caption", default="")
    ap.add_argument("--story-reviewed", action="store_true",
                    help="you looked at the exported frames: gameplay, not a cutscene or an in-game TV show")
    ap.add_argument("--story-approved", default="", metavar="REASON",
                    help="the story-word match in hook/caption is a false match; say why")
    a = ap.parse_args()
    clip = Path(a.clip)
    res = []  # (name, status, detail) with status PASS / FAIL / WARN

    def add(name, ok, detail=""):
        res.append((name, "PASS" if ok else "FAIL", detail))

    def warn(name, detail=""):
        res.append((name, "WARN", detail))

    if not clip.exists():
        sys.exit(f"FAIL file not found: {clip}")
    side = clip.with_suffix(".json")
    meta = load_json(side) if side.exists() else {}
    rules, have_campaign = parse_campaign(a.campaign)
    p = ffprobe(clip)
    streams = p.get("streams", [])
    v = next((s for s in streams if s.get("codec_type") == "video"), None)
    au = next((s for s in streams if s.get("codec_type") == "audio"), None)
    dur = float(p.get("format", {}).get("duration", 0) or 0)

    add("resolution 1080x1920", bool(v) and (v.get("width"), v.get("height")) == (1080, 1920),
        f"{v.get('width')}x{v.get('height')}" if v else "no video")
    f = fps_of(v.get("r_frame_rate", "0/1")) if v else 0
    add("fps about 30", 29 <= f <= 31, f"{f:.2f}")
    add("has audio", au is not None)
    add(f"duration {rules['min']:g}-{rules['max']:g}s" + ("" if have_campaign else " (default)"),
        rules["min"] <= dur <= rules["max"], f"{dur:.1f}s")
    hook = meta.get("hook", "")
    hits = banned_in(hook + " " + a.caption)
    add("no banned terms in caption/hook", not hits, ", ".join(hits))
    if rules["tags"]:
        miss = [t for t in rules["tags"] if t.lower() not in a.caption.lower()]
        add("required hashtags", not miss, ("missing " + " ".join(miss)) if miss else " ".join(rules["tags"]))
    if rules["mention"]:
        ok = rules["mention"].lower() in a.caption.lower()
        add("required mention", ok, rules["mention"])
    if not have_campaign:
        add("campaign rules file", True, "none given, defaults used (NOT a rules check)")

    # story spoilers: words in what we write, words spoken in the clip, then a look at the frames
    shits = story_hits(hook + " " + a.caption)
    if not shits:
        add("no story/spoiler words in caption/hook", True)
    elif a.story_approved:
        warn("story/spoiler words in caption/hook", f"{', '.join(shits)}; approved as false match: {a.story_approved}")
    else:
        add("no story/spoiler words in caption/hook", False,
            f"{', '.join(shits)}; no story reveals, a SPOILER label does not make it ok")
    spoken = meta.get("text", "")
    thits = story_hits(spoken)
    if thits:
        warn("story words spoken in the clip", f"{', '.join(thits)}; check it is not a cutscene or plot reveal")
    fdir, frames = export_frames(clip, dur) if dur > 0 else (None, [])
    if a.story_reviewed:
        add("frames reviewed: gameplay, not a cutscene or in-game TV show", True, "confirmed with --story-reviewed")
    else:
        where = f"look at {fdir}" if frames else "no frames written, watch the clip"
        add("frames reviewed: gameplay, not a cutscene or in-game TV show", False,
            f"{where}, then re-run with --story-reviewed")

    for n, st, d in res:
        print(f"{st}  {n}" + (f"  [{d}]" if d else ""))
    bad = [r for r in res if r[1] == "FAIL"]
    warns = [r for r in res if r[1] == "WARN"]
    print("RESULT: " + ("FAIL" if bad else "PASS") + (f" ({len(warns)} warning(s), read them)" if warns and not bad else ""))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
