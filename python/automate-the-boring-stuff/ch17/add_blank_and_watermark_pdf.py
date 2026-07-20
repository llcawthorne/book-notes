#!/usr/bin/env python
import pypdf

writer = pypdf.PdfWriter()
writer.append("Recursion_Chapter1.pdf")
writer.add_blank_page()
writer.insert_blank_page(index=2)
# a *stamp* or *overlay* goes on top of existing content
# a *watermark* displays under existing content
watermark_page = pypdf.PdfReader("watermark.pdf").pages[0]
for page in writer.pages:
    page.merge_page(watermark_page, over=False)
with open("with_watermark.pdf", "wb") as file:
    writer.write(file)
