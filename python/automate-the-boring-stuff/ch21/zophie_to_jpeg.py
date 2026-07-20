#!/usr/bin/env python
from PIL import Image

cat_im = Image.open("zophie.png")
width, height = cat_im.size
print(cat_im.filename, "is a", str(width), "x", str(height), cat_im.format)
cat_im.save("zophie.jpg")

quarter_sized_im = cat_im.resize((int(width / 2), int(height / 2)))
quarter_sized_im.save("quartersized.png")

cat_im.rotate(90).save("rotated90.png")
cat_im.rotate(180).save("rotated180.png")
cat_im.rotate(270).save("rotated270.png")
