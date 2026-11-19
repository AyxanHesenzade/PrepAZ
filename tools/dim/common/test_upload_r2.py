"""Offline checks for upload_r2.py (no network, no keys): python test_upload_r2.py"""
import sys

from upload_r2 import content_type, to_copy

failures = 0


def check(name, ok):
    global failures
    print(("OK   " if ok else "FAIL ") + name)
    failures += not ok


check("webp/png have a content type, other files are ignored",
      content_type("A.webp") == "image/webp" and content_type("B.PNG") == "image/png" and content_type("x.json") is None)
check("images already in R2 are skipped, non-images ignored, result sorted",
      to_copy(["C.webp", "A.webp", "B.webp", "manifest.json", "A.webp"], {"B.webp"}) == ["A.webp", "C.webp"])
check("--overwrite uploads everything again (corrected images)",
      to_copy(["A.webp", "B.webp"], {"A.webp", "B.webp"}, overwrite=True) == ["A.webp", "B.webp"])
check("nothing to do when R2 already has all", to_copy(["A.webp"], {"A.webp"}) == [])

sys.exit(1 if failures else 0)
