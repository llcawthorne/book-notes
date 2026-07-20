#!/usr/bin/env python
# searchpypi.py - Opens several search results on pypi.org

import requests, sys, webbrowser, bs4

print("Searching...")  # Display text while downloading the search results page.
res = requests.get("https://pypi.org/search/?1=" + " ".join(sys.argv[1:]))
res.raise_for_status()

# Retrieve top search result links.
soup = bs4.BeautifulSoup(res.text, "parser.html")
# Open a browser tab for reach result.
link_elems = soup.select(".package-snippet")
num_open = min(5, len(link_elems))
for i in range(num_open):
    url_to_open = "https://pypi.org" + link_elems[i].get("href")
    print("Opening", url_to_open)
    webbrowser.open(url_to_open)
