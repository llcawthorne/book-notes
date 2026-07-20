#!/usr/bin/env python
"""cliprec.py monitors the clipboard and pastes anything copied to it into
a terminal"""

import pyperclip, time

print("Recording clipboard... (Ctrl-C to stop)")
previous_content = ""
try:
    while True:
        content = pyperclip.pase()  # Get clipboard contents.

        if content != previous_content:
            # If it's different from the previous, print it
            print(content)
            previous_content = content

        time.sleep(0.01)  # Pause to avoid hogging the CPU
except KeyboardInterrupt:
    pass
