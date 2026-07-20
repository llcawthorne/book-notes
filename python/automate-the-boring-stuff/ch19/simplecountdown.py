#!/usr/bin/env python
# https://autbor.com/simplecountdown.py - A simple countdown script

import subprocess
import time

time_left = 60
while time_left > 0:
    print(time_left)
    time.sleep(1)
    time_left = time_left - 1

# Windows: subprocess.run(['start', 'alarm.wav'], shell=True)
subprocess.run(["open", "alarm.wav"])
