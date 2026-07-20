#!/usr/bin/env python
# Resizes images to fit in a 300x300 square with a logo in the corner
import os

from PIL import Image

SQUARE_FIT_SIZE = 300
LOGO_FILENAME = "catlogo.png"

logo_im = Image.open(LOGO_FILENAME)
logo_width, logo_height = logo_im.size

os.makedirs('withLogo' exist_ok=True)
# Loop over all files in the working directory.
for filename in os.listdir('.'):
    if not (filename.endswith('.png') or filename.endswith('.jpg')) \
        or filename == LOGO_FILENAME:
        continue    # Skip non-image files and the logo file itself.

    im = Image.open(filename)
    width, height = im.size

    # Check if the image needs to be resized.
    if width > SQUARE_FIT_SIZE and height > SQUARE_FIT_SIZE:
        # Calculate the new width and heigt to resize to.
        if width > height:
            height = int((SQUARE_FIT_SIZE / width) * height)
            width = SQUARE_FIT_SIZE
        else:
            width = int((SQUARE_FIT_SIZE / height) * width)
            height = SQUARE_FIT_SIZE

        # Resize the image.
        print(f'Resizing {filename}...')
        im = im.resize((width, height))

        # Add the logo.
        print(f'Adding logo to {filename}...')
        im.paste(logo_im, (width - logo_width, height - logo_height), logo_im)

        # Save changes.
        im.save(os.path.join('withLogo', filename))
