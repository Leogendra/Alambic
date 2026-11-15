import xml.etree.ElementTree as ET
from PIL import Image, ImageDraw
from pathlib import Path
from datetime import datetime

BRANDING = Path(__file__).resolve().parent
SVG = BRANDING / "icon.svg"
RES = BRANDING.parents[1] / "android" / "app" / "src" / "main" / "res"
DENSITIES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
SUPERSAMPLING = 8
TIMESTAMP = datetime.now().isoformat(sep=" ", timespec="seconds")
HEADER = f'<?xml version="1.0" encoding="utf-8"?>\n<!-- Generated from assets/branding/icon.svg at {TIMESTAMP}. -->\n'


def shapes(element, fill=None, opacity=1.0):
    # Flattens the <g>s: yields (tag, element, fill, opacity) with the group attributes applied.
    fill = element.get("fill", fill)
    opacity *= float(element.get("opacity", "1"))
    tag = element.tag.split("}")[-1]
    if tag in ("svg", "g"):
        for child in element:
            yield from shapes(child, fill, opacity)
    elif tag in ("rect", "circle"):
        yield tag, element, fill.upper(), opacity
    else:
        raise ValueError(f"Unsupported SVG element: {tag}")


def rgba(fill, opacity):
    return tuple(int(fill[i:i + 2], 16) for i in (1, 3, 5)) + (round(opacity * 255),)


def render(root, size):
    big = size * SUPERSAMPLING
    scale = big / float(root.get("viewBox").split()[2])
    image = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    for tag, element, fill, opacity in shapes(root):
        layer = Image.new("RGBA", (big, big), (0, 0, 0, 0))
        draw = ImageDraw.Draw(layer)
        if tag == "rect":
            radius = float(element.get("rx", "0")) * scale
            draw.rounded_rectangle([0, 0, big - 1, big - 1], radius=radius, fill=rgba(fill, opacity))
        else:
            cx, cy, r = (float(element.get(a)) * scale for a in ("cx", "cy", "r"))
            draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=rgba(fill, opacity))
        image = Image.alpha_composite(image, layer)
    return image.resize((size, size), Image.LANCZOS)


def vector(circles, size_dp, viewport, translate, color=None):
    # An Android vector drawable of the circles, all painted in color if given.
    paths = ""
    for cx, cy, r, fill, opacity in circles:
        alpha = "" if opacity == 1 else f' android:fillAlpha="{opacity:g}"'
        paths += (
            f'        <path android:fillColor="{color or fill}"{alpha}\n'
            f'            android:pathData="M{cx - r:g},{cy:g}a{r:g},{r:g} 0,1 0,{2 * r:g} 0a{r:g},{r:g} 0,1 0,{-2 * r:g} 0Z"/>\n'
        )
    return (
        HEADER
        + '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
        + f'    android:width="{size_dp}dp" android:height="{size_dp}dp"\n'
        + f'    android:viewportWidth="{viewport:g}" android:viewportHeight="{viewport:g}">\n'
        + f'    <group android:translateX="{translate[0]:g}" android:translateY="{translate[1]:g}">\n'
        + paths
        + "    </group>\n</vector>\n"
    )


def write(path, content):
    path.write_text(content, encoding="utf-8", newline="\n")
    print(f"Wrote {path.relative_to(BRANDING.parents[1])}")


if __name__ == "__main__":
    root = ET.parse(SVG).getroot()
    canvas = float(root.get("viewBox").split()[2])
    background = next(fill for tag, _, fill, _ in shapes(root) if tag == "rect")
    circles = [
        (*(float(element.get(a)) for a in ("cx", "cy", "r")), fill, opacity)
        for tag, element, fill, opacity in shapes(root) if tag == "circle"
    ]

    # Legacy launcher icons, Android 7 and older.
    for density, size in DENSITIES.items():
        path = RES / f"mipmap-{density}" / "ic_launcher.png"
        render(root, size).save(path, optimize=True)
        print(f"Wrote {path.relative_to(BRANDING.parents[1])}")

    # Adaptive icon, Android 8+: the canvas maps to the 72dp visible area of the 108dp layer.
    write(RES / "values" / "ic_launcher_background.xml",
          HEADER + f'<resources>\n    <color name="ic_launcher_background">{background}</color>\n</resources>\n')
    write(RES / "drawable" / "ic_launcher_foreground.xml",
          vector(circles, 108, canvas * 1.5, (canvas / 4, canvas / 4)))

    # Status bar icon: Android only keeps the alpha, so the circles are white, cropped to their bounds.
    left, right = min(c[0] - c[2] for c in circles), max(c[0] + c[2] for c in circles)
    top, bottom = min(c[1] - c[2] for c in circles), max(c[1] + c[2] for c in circles)
    viewport = round(max(right - left, bottom - top)) + 4
    write(RES / "drawable" / "ic_notification.xml",
          vector(circles, 24, viewport, (viewport / 2 - (left + right) / 2, viewport / 2 - (top + bottom) / 2), "#FFFFFF"))
