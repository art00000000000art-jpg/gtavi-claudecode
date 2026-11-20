---
name: rule-check
description: Check a finished clip against technical specs, campaign rules and banned content before posting. Use before every upload, or when the user asks "is this ok to post".
---

# Rule check

Run:

`python "${CLAUDE_PLUGIN_ROOT}/scripts/check.py" <clip.mp4> --campaign campaigns.md`

It checks: length, 1080x1920, audio present, the campaign's rules from `campaigns.md`, banned content (leaks, "play early", piracy) and story spoilers.

Story spoilers follow Rockstar's video policy: no ending, no edited mix of cutscenes or plot dialogue, no other big story reveal, and no in-game TV show or comedy performance on its own. Isolated cutscene clips get taken down. A "SPOILER" label does not make a clip allowed.

- Story words in the hook or caption: FAIL. Rewrite them. Use `--story-approved "<reason>"` only when the match is false (for example "the chase ending" on a police chase), never to post a real reveal.
- Story words spoken in the clip: WARN. Read them and decide with the frames.
- Frames: the script writes 3 stills to `<clip>_frames/`. Open each one with Read. Gameplay usually shows the HUD (minimap, wanted level). No HUD, letterbox bars, a cinematic camera or a TV show on screen means a cutscene or an isolated show: drop the clip. Only then re-run with `--story-reviewed`.

Then:

1. Show PASS, WARN or FAIL per check in a short list.
2. On FAIL: fix the cause (re-cut with `clip-cutter`, add the credit, trim, pick another moment) and re-run. Do not argue with a failed check, and never pass `--story-reviewed` without looking at the frames.
3. Read the caption yourself too. It must credit the creator in the text, no invented facts, no "official" wording, and match the platform's caption rules in the playbook.
4. The script cannot judge everything. If the campaign rules are `unknown` or missing, ask the human to paste them.
5. Only after all checks pass, send the human the clip, caption and credit and wait for "yes". The human posts it. Never auto-upload.
