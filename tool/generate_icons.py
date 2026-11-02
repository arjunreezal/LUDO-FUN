"""Generates the LUDO app icon, launch images and web icons into branding/.

The mark is the board's centre pinwheel (red left, green top, yellow right,
blue bottom) on a light rounded tile, set on the brand navy.

Usage:  python tool/generate_icons.py      (requires Pillow: pip install pillow)
Then:   python tool/configure_platforms.py (copies them into android/ios/web)
"""
import os

from PIL import Image, ImageDraw

NAVY = (16, 24, 39)
TILE = (247, 248, 252)
RED = (233, 79, 100)
GREEN = (53, 184, 121)
YELLOW = (255, 200, 87)
BLUE = (67, 136, 245)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'branding')
SS = 4  # supersampling factor for smooth edges


def draw_mark(draw, x, y, size):
    """Draws the tile and pinwheel with its top-left at (x, y)."""
    radius = size * 0.26
    draw.rounded_rectangle([x, y, x + size, y + size], radius=radius, fill=TILE)
    inset = size * 0.17
    left, top = x + inset, y + inset
    right, bottom = x + size - inset, y + size - inset
    cx, cy = (left + right) / 2, (top + bottom) / 2
    triangles = [
        (RED, [(left, top), (left, bottom), (cx, cy)]),
        (GREEN, [(right, top), (left, top), (cx, cy)]),
        (YELLOW, [(right, bottom), (right, top), (cx, cy)]),
        (BLUE, [(left, bottom), (right, bottom), (cx, cy)]),
    ]
    stroke = max(1, round(size * 0.035))
    for color, points in triangles:
        draw.polygon(points, fill=color)
    for _, points in triangles:
        draw.line(points + [points[0]], fill=TILE, width=stroke, joint='curve')


def render(size, *, background, mark_fraction, rounded_background=False, alpha=False):
    big = size * SS
    mode = 'RGBA' if alpha else 'RGB'
    clear = (0, 0, 0, 0) if alpha else NAVY
    image = Image.new(mode, (big, big), clear)
    draw = ImageDraw.Draw(image)
    if background:
        if rounded_background:
            draw.rounded_rectangle([0, 0, big - 1, big - 1], radius=big * 0.22, fill=NAVY)
        else:
            draw.rectangle([0, 0, big, big], fill=NAVY)
    mark = big * mark_fraction
    offset = (big - mark) / 2
    draw_mark(draw, offset, offset, mark)
    return image.resize((size, size), Image.LANCZOS)


def save(image, *parts):
    path = os.path.join(OUT, *parts)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    image.save(path, optimize=True)
    return path


def main():
    written = []
    # Master icon (no transparency, as the App Store requires).
    written.append(save(render(1024, background=True, mark_fraction=0.62), 'app_icon_1024.png'))

    # iOS app icon set: file names match Flutter's generated Contents.json.
    ios = {
        'Icon-App-20x20@1x.png': 20, 'Icon-App-20x20@2x.png': 40, 'Icon-App-20x20@3x.png': 60,
        'Icon-App-29x29@1x.png': 29, 'Icon-App-29x29@2x.png': 58, 'Icon-App-29x29@3x.png': 87,
        'Icon-App-40x40@1x.png': 40, 'Icon-App-40x40@2x.png': 80, 'Icon-App-40x40@3x.png': 120,
        'Icon-App-60x60@2x.png': 120, 'Icon-App-60x60@3x.png': 180,
        'Icon-App-76x76@1x.png': 76, 'Icon-App-76x76@2x.png': 152,
        'Icon-App-83.5x83.5@2x.png': 167, 'Icon-App-1024x1024@1x.png': 1024,
    }
    for name, px in ios.items():
        written.append(save(render(px, background=True, mark_fraction=0.62), 'ios', 'AppIcon.appiconset', name))

    # iOS launch image (transparent, centred on the navy launch screen).
    for name, px in {'LaunchImage.png': 120, 'LaunchImage@2x.png': 240, 'LaunchImage@3x.png': 360}.items():
        written.append(save(render(px, background=False, mark_fraction=1.0, alpha=True), 'ios', 'LaunchImage.imageset', name))

    # Android legacy launcher icons (rounded square) and adaptive foregrounds.
    densities = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
    for density, scale in densities.items():
        written.append(save(render(round(48 * scale), background=True, mark_fraction=0.64,
                                   rounded_background=True, alpha=True),
                            'android', f'mipmap-{density}', 'ic_launcher.png'))
        # Adaptive icon foreground: 108dp canvas, mark inside the 66dp safe zone.
        written.append(save(render(round(108 * scale), background=False, mark_fraction=0.52, alpha=True),
                            'android', f'mipmap-{density}', 'ic_launcher_foreground.png'))
    # Launch logo shown on the Android launch screen (96dp at xxhdpi).
    written.append(save(render(288, background=False, mark_fraction=1.0, alpha=True),
                        'android', 'drawable-xxhdpi', 'launch_logo.png'))

    # Web icons.
    written.append(save(render(192, background=True, mark_fraction=0.62), 'web', 'icons', 'Icon-192.png'))
    written.append(save(render(512, background=True, mark_fraction=0.62), 'web', 'icons', 'Icon-512.png'))
    written.append(save(render(192, background=True, mark_fraction=0.5), 'web', 'icons', 'Icon-maskable-192.png'))
    written.append(save(render(512, background=True, mark_fraction=0.5), 'web', 'icons', 'Icon-maskable-512.png'))
    written.append(save(render(32, background=True, mark_fraction=0.7, rounded_background=True, alpha=True),
                        'web', 'favicon.png'))

    print(f'Wrote {len(written)} images to {OUT}')


if __name__ == '__main__':
    main()
