#!/usr/bin/env python
import os
import random
import sys
import time

TOP = chr(9600)  # Character 9600 is '▀'
BOTTOM = chr(9604)  # Character 9604 is '▄'
FULL = chr(9608)  # Character 9608 is '█'

# Set the snowstorm density to the command line argument:
DENSITY = 4  # Default snow density is 4%
if len(sys.argv) > 1:
    DENSITY = int(sys.argv[1])


def clear():
    os.system("cls" if os.name == "nt" else "clear")


while True:
    clear()  # Clear the terminal window

    # Loop over reach row and column:
    for y in range(20):
        for x in range(40):
            if random.randint(0, 99) < DENSITY:
                # Print snow:
                print(random.choice([TOP, BOTTOM]), end="")
            else:
                # Print empty space:
                print(" ", end="")

    # Print the snow-covered ground:
    print("\n" + FULL * 40 + "\n" + FULL * 40)
    print("(Ctrl-C to stop.)")

    time.sleep(0.2)  # Pause for a bit.
