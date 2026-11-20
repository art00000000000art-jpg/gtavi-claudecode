---
name: moment-finder
description: Find the best clip moments in a long video, stream VOD or local file. Use when the user gives a YouTube URL or video file and wants highlights, "find the moments", or candidates to cut.
---

# Moment finder

Run:

`python "${CLAUDE_PLUGIN_ROOT}/scripts/moments.py" <url-or-file> --top 8`

It writes `jobs/<id>/candidates.md`. Signals used: transcript with word timestamps (faster-whisper), loudness spikes, the YouTube "most replayed" heatmap and live-chat spikes, when available. A missing signal is skipped, not faked.

Then:

1. Read `jobs/<id>/candidates.md` and show each candidate: number, start-end, length, why it scored, transcript line.
2. Drop story moments at any time, not only in launch week: cutscenes, the ending, plot reveals and in-game TV or comedy shows on their own (Rockstar's video policy has them taken down). Candidates marked `WARNING possible story moment` need a close look. Also drop nudity and anything that looks like a leak. Prefer gameplay: driving, chases, NPC reactions, physics, map views, customization, funny fails.
3. Recommend the best 3 and say what hook angle each suggests.
4. Next step: `clip-cutter` with `--pick <n>`.

Record the source link and creator in `media/raw` notes. Credit the creator in the post caption.
