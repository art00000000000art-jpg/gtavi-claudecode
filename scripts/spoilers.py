"""Story-spoiler and in-game-TV terms, shared by moments.py and check.py.

Rockstar's video policy names spoilers as a takedown reason: the ending, an edited mix of
cutscenes or plot dialogue, or another big story reveal. Isolated cutscene clips are removed;
cutscenes are only tolerated inside a full playthrough or narrated Let's Play. Posting in-game
TV shows or comedy performances on their own is also named.
Policy: https://support.rockstargames.com/articles/200153756/rockstar-games-video-policy

A text match is a signal, not proof. A miss is not proof either: a cutscene with no telltale
words passes this check, which is why check.py also exports frames for a human/AI look.
"""
import re

_TERMS = [
    ("spoiler", r"\bspoilers?\b"),
    ("ending", r"(?<![-\w])(?:true |secret |real |good |bad )?endings?\b(?!\s+up\b)"),
    ("final mission", r"\b(?:final|last) missions?\b"),
    ("credits scene", r"\b(?:end|post)[- ]?credits?\b"),
    ("plot", r"\bplot(?: twist)?s?\b"),
    ("twist", r"\b(?:story|big|huge|crazy|shocking) twists?\b"),
    ("betrayal", r"\bbetray(?:s|ed|al)?\b"),
    ("cutscene", r"\bcut-?scenes?\b"),
    ("story recap", r"\b(?:full story|story (?:recap|explained|summary|spoilers?)|all cut-?scenes)\b"),
    ("cutscene movie", r"\b(?:gta ?(?:6|vi) (?:the )?movie|movie version|full movie)\b"),
    ("character fate", r"\b(?:jason|lucia)\b[^.!?\n]{0,20}\b(?:dies|died|is dead|gets killed|was killed|betrays|betrayed)\b"),
    ("who dies", r"\bwho (?:dies|died|betrays)\b"),
    ("in-game TV", r"\bin-?game (?:tv|television|tv show|comedy|stand-?up|show)s?\b"),
    ("full show", r"\bfull (?:tv|comedy|stand-?up) (?:show|episode|set)s?\b"),
]
_RX = [(name, re.compile(rx, re.I)) for name, rx in _TERMS]


def story_hits(text):
    """Names of the story/in-game-TV terms found in text, in list order, without duplicates."""
    if not text:
        return []
    return [name for name, rx in _RX if rx.search(text)]
