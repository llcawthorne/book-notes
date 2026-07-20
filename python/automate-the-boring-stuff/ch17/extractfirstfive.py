#!/usr/bin/env python
import pypdf

writer = pypdf.PdfWriter()
writer.append("Recursion_Chapter1.pdf", (0, 5))
# equivalent: writer.append("Recursion_Chapter1.pdf", [0, 1, 2, 3, 4])
with open("first-five_pages.pdf", "wb") as file:
    writer.write(file)
