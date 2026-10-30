"""Makes two fake teacher portraits (simple avatars, not real people) for the demo rows in db/seed/teachers_demo.sql."""
from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path(__file__).parent / "upload"


def avatar(name, top, bottom, skin):
    size = 480
    img = Image.new("RGB", (size, size))
    d = ImageDraw.Draw(img)
    for y in range(size):   # vertical gradient background
        t = y / (size - 1)
        d.line([(0, y), (size, y)], fill=tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    d.ellipse((130, 60, 350, 280), fill=skin)                  # head
    d.pieslice((40, 300, 440, 700), 180, 360, fill=(250, 250, 250))   # shoulders
    d.ellipse((130, 60, 350, 170), fill=(60, 45, 40))          # hair
    d.ellipse((140, 110, 340, 280), fill=skin)
    d.ellipse((190, 170, 215, 195), fill=(40, 40, 40))         # eyes
    d.ellipse((265, 170, 290, 195), fill=(40, 40, 40))
    d.arc((200, 200, 280, 250), 20, 160, fill=(120, 60, 60), width=5)   # smile
    img.save(OUT / name, optimize=True)


OUT.mkdir(exist_ok=True)
avatar("demo-kimya.png", (96, 165, 250), (30, 64, 175), (240, 200, 170))
avatar("demo-biologiya.png", (134, 239, 172), (21, 128, 61), (225, 180, 150))
