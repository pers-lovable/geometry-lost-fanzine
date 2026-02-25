#!/usr/bin/env python3
"""Generate a QR code PNG with transparent background."""

import sys
import qrcode
from PIL import Image, ImageDraw


def make_transparent_qr(url, output_path, box_size=10, border=4):
    qr = qrcode.QRCode(
        box_size=box_size,
        border=border,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
    )
    qr.add_data(url)
    qr.make(fit=True)
    matrix = qr.get_matrix()

    n = len(matrix)
    size = (n + 2 * border) * box_size
    img = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)

    for y, row in enumerate(matrix):
        for x, val in enumerate(row):
            if val:
                x1 = (x + border) * box_size
                y1 = (y + border) * box_size
                draw.rectangle(
                    [x1, y1, x1 + box_size - 1, y1 + box_size - 1],
                    fill=(0, 0, 0, 255),
                )

    img.save(output_path, "PNG")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <url> <output.png>", file=sys.stderr)
        sys.exit(1)
    make_transparent_qr(sys.argv[1], sys.argv[2])
