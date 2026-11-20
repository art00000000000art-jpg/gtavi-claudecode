<div align="center">

<img src="docs/logo.png" width="300" alt="gtavi-claudecode logo">

<h1 align="center">gtavi-claudecode</h1>

<p align="center"><b>Rockstar made the game.<br>Claude Code makes you the money.</b></p>

<p align="center">GTA 6 is out. Claude Code watches the biggest streams, catches the second chat explodes and hands you a checked, ready-to-post vertical clip. Campaigns pay per 1,000 views on approved clips. You approve, you post.</p>

<p align="center"><img src="https://img.shields.io/badge/Claude_Code-plugin-e8457f" alt="Claude Code: plugin"> <img src="https://img.shields.io/badge/skills-16-e8457f" alt="skills: 16"> <img src="https://img.shields.io/badge/clips-1080x1920-e8457f" alt="clips: 1080x1920"> <img src="https://img.shields.io/badge/languages-5-e8457f" alt="languages: 5"></p>
<p align="center"><img src="https://img.shields.io/badge/GTA_6-out_now-e8457f" alt="GTA 6: out now"> <img src="https://img.shields.io/badge/license-MIT-e8457f" alt="license: MIT"></p>
<p align="center"><sub>Unofficial fan project. Not affiliated with Rockstar Games, Take-Two or Anthropic.</sub></p>
<p align="center"><a href="#first-run-paste-this-into-claude-code">Quick start</a> · <a href="#two-ways-to-make-money">Make money</a> · <a href="#whats-inside">Skills</a> · <a href="#the-rules-that-make-clips-win">Clip rules</a> · <a href="#run-the-scripts-yourself">Scripts</a></p>

</div>

> **Copy of the original.** This repository is a copy of [Bodila51/gtavi-claudecode](https://github.com/Bodila51/gtavi-claudecode) by **Bodila51**, kept available while the original repository is offline. It was taken from the public mirror gzonlin/gtavi-claudecode. All credit goes to the original author; the code is published under the original MIT license (see [LICENSE](LICENSE)). Only the install commands and repository links were changed to point at this repository.

```
/plugin marketplace add art00000000000art-jpg/gtavi-claudecode
/plugin install gtavi-claudecode@gtavi-claudecode
```

Two lines in Claude Code. In 10 minutes you have: the tools installed, your page folder, today's trending GTA 6 videos, the best moments picked and your first vertical clips ready to post.

## First run: paste this into Claude Code

```
Use gtavi-claudecode. Set up my GTA 6 clip page, ask me your 4 questions in one message,
then do everything after one "yes": find live clipping campaigns, show today's trending
GTA 6 videos and live streams, find the best moments in the top one, cut my first 3 clips
with hooks, check them against the campaign rules, and tell me what to post where.
```

## Two ways to make money

**1. Paid clipping campaigns (fastest).** Streamers and brands pay clippers per 1,000 views on approved clips. Every campaign sets its own rate, budget and rules, and they change daily, so `campaign-finder` reads them live and never guesses a number. For scale: in early November 2026 gaming campaigns on Whop Content Rewards had a median of about $1.13 per 1K views ([OpenClip](https://openclip.app/clipping/gta-6-clipping)), while the one GTA 6 campaign listed there on November 12 to 14 was a music promotion at $0.70 per 1K, capped at $35 per clip ([Content Rewards](https://contentrewards.com/articles/gta-6-clipping)). You read the rules, clip only that creator, post, submit the link.

**Read Rockstar's video policy before you earn from clips.** It covers non-commercial fan videos and defines non-commercial as not earning money from the posted footage and not using it to promote a product or service. It says it does not apply to advertisements or music videos, and Take-Two can take material down at any time ([policy](https://support.rockstargames.com/articles/200153756/rockstar-games-video-policy)). Paid clipping sits outside that written permission; campaigns that use GTA 6 footage to sell a song, app or brand carry the most risk, and `campaign-finder` flags them. This is not legal advice.

**2. Your own faceless GTA 6 page (bigger, slower).** The built-in playbook runs it: daily content mix, credit rules, caption templates, a week-by-week launch-month plan, a big-drop plan for trailers and updates, and a learning loop. Platforms don't pay for reposted clips, so the page grows on speed, useful tips and credited clips, then earns through campaigns and partnerships.

No income is promised. Your result depends on speed, picks and hooks, and the scoreboard shows what works.

## The rules that make clips win

- Hook in the first second. Say why to keep watching ("the hidden car nobody found").
- 7 to 30 seconds. Cut dead air at the start, end on the payoff.
- Big captions in the safe area. Most people watch muted.
- Make it yours: hook, tip, commentary. Never a plain re-upload. Credit the creator in your post.
- Launch month (from Nov 19): help and secrets beat first looks. HOW TO posts, verified hidden spots, credited gameplay. The week-by-week plan is in `playbook`.
- Gameplay, not story. No cutscenes, ending or plot reveals: Rockstar has isolated cutscene clips taken down, and a SPOILER label doesn't change that.
- Every repeated question in your comments becomes a HOW TO post.
- One test per day. No verdict before 24 hours, prefer the 72 h numbers.

## What's inside

| Skill | What you get |
|---|---|
| `setup` | Installs ffmpeg, yt-dlp and faster-whisper, asks 4 questions, builds your page folder |
| `campaign-finder` | Live campaigns: rate per 1K views, budget left, rules, link |
| `trend-radar` | GTA 6 videos from the last 24 h ranked by views per hour |
| `stream-finder` | Who is streaming GTA 6 right now, ranked by viewers |
| `moment-finder` | Best 15 to 40 s moments, scored by loudness spikes, hype words, YouTube "most replayed" and chat spikes |
| `live-mode` | Records a live stream and cuts a clip every time chat explodes |
| `twitch-reaction` | Reaction clips like the viral ones: the streamer's face on top, the game below, a big title on the seam. Finds the top GTA 6 Twitch streams with no account, reads chat and finds the webcam by itself |
| `clip-cutter` | 1080x1920 clip: word-by-word captions, hook box, -14 LUFS. Fill, blurred background or facecam on top |
| `hook-writer` | 3 hook options per clip |
| `rule-check` | Length, format, hashtags, banned content and story spoilers checked before you post. Exports frames so cutscenes get caught |
| `multilang` | One clip in 5 languages: translated word-by-word captions and hook in ES, PT, DE, RU, optional stock-voice hook. Non-English GTA pages are almost empty |
| `questions-to-posts` | Pulls repeated questions from GTA subreddits and your comments, turns the answered ones into HOW TO posts |
| `secrets-map` | Builds a database of hidden spots, money, cars and collectibles from clips, with timestamp and credit. Verified ones become evergreen tip posts |
| `cheat-codes` | All reported GTA 6 cheat codes with unlock tasks and sources, turned into a 4-slide cheat carousel |
| `playbook` | Your full daily routine, the launch-month plan and the big-drop plan |
| `learning-loop` | Scoreboard, one test per day, payouts from real numbers only |

Nothing is uploaded automatically. You approve every post.

## Hard rules

No leaks, no "play early" or "free download" posts, no piracy, no GTA Online money or AFK bots, no story spoilers or isolated cutscenes, no in-game TV shows on their own, no fake news, never pretends to be Rockstar. Every fact needs an official source.

## Run the scripts yourself

```
pip install -r requirements.txt
python scripts/trends.py --query "gta 6" --hours 24
python scripts/streams.py --query "gta 6"
python scripts/moments.py "https://www.youtube.com/watch?v=..." --top 8
python scripts/cut.py jobs/<id> --pick 2 --layout facecam --hook "Nobody noticed this"
python scripts/check.py jobs/<id>/edits/clip_2.mp4 --campaign campaigns.md
# look at jobs/<id>/edits/clip_2_frames/, then:
python scripts/check.py jobs/<id>/edits/clip_2.mp4 --campaign campaigns.md --story-reviewed
python scripts/live.py "https://www.youtube.com/watch?v=<live>" --minutes 60
```

Windows, macOS or Linux, Python 3.10+. An NVIDIA GPU makes transcription faster; on the CPU a 12-minute video takes about 5 minutes.

MIT license.
