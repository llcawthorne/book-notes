#!/usr/bin/env python
"A simple demonstration of Euler's GCD in Python"
import sys

def eugcd(int1, int2):
    "Where the magic happens"
    while int2:
        int1, int2 = int2, (int1 % int2)
    return int1

def prompt_inputs():
    "Get input for the GCD Function"
    number1 = 0
    number2 = 0
    while not number1 or not number2:
        try:
            number1 = int(raw_input("Enter a number: "))
            number2 = int(raw_input("Enter another number: "))
        except:
            number1 = 0
            number2 = 0
        # End While
    return number1, number2

if __name__ == "__main__":
    if len(sys.argv) == 3:
        try:
            num1 = int(sys.argv[1])
            num2 = int(sys.argv[2])
        except ValueError:
            num1, num2 = prompt_inputs()
    else:
        num1, num2 = prompt_inputs()

    mygcd = eugcd(num1, num2)

    print "GCD of %d and %d is %d" % (num1, num2, mygcd)
