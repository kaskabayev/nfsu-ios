#!/usr/bin/env python3
"""Draw the original artwork of this repository. No third-party images.

    python3 tools/make_art.py            # needs Pillow and the DejaVu fonts

Writes:
  assets/nfsu2_logo.png                         Switch loading screen (500x180, RGBA)
  assets/icon.jpg                               Switch NRO icon (256x256)
  games/<game>/ios/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
  games/<game>/ios/icon/AppIcon*.png            loose sizes for sideload tools

The design is a dark asphalt gradient, a neon light streak, a large "U2" or
"U1" and a small "XBOX RECOMP" line. After a change to the logo run
tools/make_logo.py to rebuild src/nfsu2_logo.h.
"""
import math
import os
import random
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

FONT_DIRS = ("/usr/share/fonts/truetype/dejavu", "/usr/share/fonts/dejavu",
             "/usr/share/fonts/TTF", "/Library/Fonts", "/System/Library/Fonts/Supplemental")
FONT_BOLD = "DejaVuSans-Bold.ttf"

# game id -> (label, accent colour of the streak)
GAMES = {
    "nfsu2": ("U2", (40, 215, 255)),
    "nfsu1": ("U1", (255, 140, 40)),
}


def font(size):
    for d in FONT_DIRS:
        p = os.path.join(d, FONT_BOLD)
        if os.path.exists(p):
            return ImageFont.truetype(p, size)
    sys.exit("DejaVuSans-Bold.ttf not found; install the DejaVu fonts")


def lerp(a, b, t):
    return tuple(int(round(x + (y - x) * t)) for x, y in zip(a, b))


def asphalt(w, h, seed):
    """Dark vertical gradient with a faint vignette and fine grain."""
    top, bottom = (30, 34, 42), (6, 7, 10)
    img = Image.new("RGB", (w, h))
    px = img.load()
    rnd = random.Random(seed)
    for y in range(h):
        row = lerp(top, bottom, (y / (h - 1)) ** 0.8)
        for x in range(w):
            dx, dy = (x - w / 2) / (w / 2), (y - h / 2) / (h / 2)
            v = 1.0 - 0.35 * min(1.0, math.hypot(dx, dy) ** 2)
            n = rnd.randint(-5, 5)
            px[x, y] = tuple(max(0, min(255, int(c * v) + n)) for c in row)
    return img


def streak_layer(w, h, accent, y0, y1, thick):
    """A slanted neon band from the left edge (height y0) to the right (y1)."""
    mask = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(mask)
    d.polygon([(-w * 0.05, y0 - thick), (w * 1.05, y1 - thick),
               (w * 1.05, y1 + thick), (-w * 0.05, y0 + thick)], fill=255)
    core = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(core)
    d.polygon([(-w * 0.05, y0 - thick * 0.28), (w * 1.05, y1 - thick * 0.28),
               (w * 1.05, y1 + thick * 0.28), (-w * 0.05, y0 + thick * 0.28)], fill=255)
    glow = mask.filter(ImageFilter.GaussianBlur(thick * 0.9))
    glow = glow.point(lambda v: min(255, int(v * 1.6)))
    layer = Image.new("RGBA", (w, h), accent + (0,))
    layer.putalpha(glow)
    body = Image.new("RGBA", (w, h), lerp(accent, (255, 255, 255), 0.25) + (0,))
    body.putalpha(mask.point(lambda v: int(v * 0.55)))
    layer.alpha_composite(body)
    white = Image.new("RGBA", (w, h), (255, 255, 255, 0))
    white.putalpha(core.filter(ImageFilter.GaussianBlur(thick * 0.06)))
    layer.alpha_composite(white)
    return layer


def text_layer(w, h, text, size, cx, cy, accent):
    """Big label: white-to-pale fill, dark edge, soft glow in the accent colour."""
    f = font(size)
    mask = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(mask)
    d.text((cx, cy), text, font=f, fill=255, anchor="mm")
    bbox = mask.getbbox()
    glow = Image.new("RGBA", (w, h), accent + (0,))
    glow.putalpha(mask.filter(ImageFilter.GaussianBlur(size * 0.06)).point(lambda v: int(v * 0.7)))
    # Edge: the mask grown by a few pixels, in near-black.
    edge_mask = mask.filter(ImageFilter.MaxFilter(max(3, (size // 40) | 1)))
    edge = Image.new("RGBA", (w, h), (4, 5, 8, 0))
    edge.putalpha(edge_mask)
    # Fill: vertical gradient over the glyph box.
    fill = Image.new("RGBA", (w, h), (255, 255, 255, 0))
    fp = fill.load()
    top, bot = bbox[1], bbox[3]
    for y in range(top, bot):
        t = (y - top) / max(1, bot - top - 1)
        c = lerp((255, 255, 255), lerp((255, 255, 255), accent, 0.55), t ** 1.5)
        for x in range(bbox[0], bbox[2]):
            fp[x, y] = c + (0,)
    fill.putalpha(mask)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.alpha_composite(glow)
    out.alpha_composite(edge)
    out.alpha_composite(fill)
    return out, bbox


def small_line(w, h, text, size, cx, cy, spacing, colour):
    """Letter-spaced single line, centred on (cx, cy)."""
    f = font(size)
    widths = [f.getlength(c) for c in text]
    total = sum(widths) + spacing * (len(text) - 1)
    x = cx - total / 2
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for c, cw in zip(text, widths):
        d.text((x, cy), c, font=f, fill=colour + (255,), anchor="lm")
        x += cw + spacing
    return layer


def icon(label, accent, n=1024, seed=1):
    ss = 2  # draw at 2x, scale down for smooth edges
    s = n * ss
    img = asphalt(s, s, seed).convert("RGBA")
    img.alpha_composite(streak_layer(s, s, accent, s * 0.74, s * 0.60, s * 0.022))
    txt, _ = text_layer(s, s, label, int(s * 0.62), s * 0.5, s * 0.40, accent)
    img.alpha_composite(txt)
    img.alpha_composite(small_line(s, s, "XBOX RECOMP", int(s * 0.062), s * 0.5, s * 0.865,
                                   int(s * 0.012), (200, 208, 218)))
    return img.convert("RGB").resize((n, n), Image.LANCZOS)


def logo(label, accent, w=500, h=180):
    ss = 3
    W, H = w * ss, h * ss
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    img.alpha_composite(streak_layer(W, H, accent, H * 0.70, H * 0.52, H * 0.030))
    txt, _ = text_layer(W, H, label, int(H * 0.82), W * 0.5, H * 0.40, accent)
    img.alpha_composite(txt)
    img.alpha_composite(small_line(W, H, "XBOX RECOMP", int(H * 0.115), W * 0.5, H * 0.90,
                                   int(H * 0.025), (205, 212, 222)))
    return img.resize((w, h), Image.LANCZOS)


def save_icon_set(img, base):
    iconset = os.path.join(base, "ios", "Assets.xcassets", "AppIcon.appiconset")
    loose = os.path.join(base, "ios", "icon")
    os.makedirs(iconset, exist_ok=True)
    os.makedirs(loose, exist_ok=True)
    img.save(os.path.join(iconset, "AppIcon-1024.png"), optimize=True)   # RGB, no alpha
    for name, size in (("AppIcon60x60@2x.png", 120), ("AppIcon60x60@3x.png", 180),
                       ("AppIcon76x76@2x~ipad.png", 152),
                       ("AppIcon83.5x83.5@2x~ipad.png", 167)):
        img.resize((size, size), Image.LANCZOS).save(os.path.join(loose, name), optimize=True)


def main():
    for game, (label, accent) in GAMES.items():
        save_icon_set(icon(label, accent, seed=7 if game == "nfsu2" else 11),
                      os.path.join(ROOT, "games", game))
        print("icons:", game)
    os.makedirs(os.path.join(ROOT, "assets"), exist_ok=True)
    label, accent = GAMES["nfsu2"]
    logo(label, accent).save(os.path.join(ROOT, "assets", "nfsu2_logo.png"), optimize=True)
    icon(label, accent, 256, seed=7).save(os.path.join(ROOT, "assets", "icon.jpg"),
                                          quality=92)
    print("assets: nfsu2_logo.png, icon.jpg")


if __name__ == "__main__":
    main()
