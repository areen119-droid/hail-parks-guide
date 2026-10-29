"""Text features for the Hail Parks Guide chatbot.

The Flutter app repeats these exact steps in Dart
(lib/services/guide_model.dart), so any change here must be made there too.
"""
import re

FEATURE_VERSION = 1

_DIACRITICS = re.compile(r"[ً-ْٰـ]")  # harakat, tatweel
_NOT_LETTER = re.compile(r"[^ء-يa-z0-9]+")


def normalize(text: str) -> str:
    """Lowercase, strip diacritics, unify letter forms, keep letters/digits."""
    text = text.lower()
    text = _DIACRITICS.sub("", text)
    text = re.sub("[إأآٱ]", "ا", text)
    text = text.replace("ى", "ي").replace("ة", "ه").replace("ؤ", "و").replace("ئ", "ي")
    text = _NOT_LETTER.sub(" ", text)
    return text.strip()


def features(text: str) -> set:
    """Whole words plus 3-letter pieces of each word (handles ال, و, spelling)."""
    feats = set()
    for word in normalize(text).split():
        feats.add("w:" + word)
        padded = "#" + word + "#"
        for i in range(len(padded) - 2):
            feats.add("c:" + padded[i:i + 3])
    return feats
