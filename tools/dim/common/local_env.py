"""Reads secret keys from the project's root .env file (gitignored, never committed).

Format: one KEY=value per line, '#' starts a comment, quotes around the value are optional.
A variable already set in the terminal wins over the file. Values are never printed.
"""
import os
from pathlib import Path

ENV_FILE = Path(__file__).resolve().parents[3] / ".env"


def parse(text):
    values = {}
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key, value = key.strip(), value.strip()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1]
        if key and value:
            values[key] = value
    return values


def load(path=ENV_FILE):
    """Puts the file's values into os.environ (only missing ones). Returns True if the file exists."""
    if not path.is_file():
        return False
    for key, value in parse(path.read_text(encoding="utf-8-sig")).items():
        os.environ.setdefault(key, value)
    return True
