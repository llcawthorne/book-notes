#!/usr/bin/env
import pypdf

writer = pypdf.PdfWriter()
writer.append("Recursion_Chapter1.pdf")
for i in range(len(writer.pages)):
    writer.pages[i].rotate(90)
with open("rotated.pdf", "wb") as file:
    writer.write(file)
