#!/usr/bin/env python
def is_divisible_by_2_or_5(n):
    """
      >>> is_divisible_by_2_or_5(8)
      True
      >>> is_divisible_by_2_or_5(7)
      False
      >>> is_divisible_by_2_or_5(5)
      True
      >>> is_divisible_by_2_or_5(9)
      False
    """
    return n % 2 == 0 or n % 5 == 0

def compare(a, b):
    """
      >>> compare(5, 4)
      1
      >>> compare(7, 7)
      0
      >>> compare(2, 3)
      -1
      >>> compare(42, 1)
      1
    """
    if a < b: 
        return -1
    elif a > b:
        return 1
    else:
        return 0

if __name__ == '__main__':
    # Run from command line.
    # No output == doctests passed
    # Run script with -v command line option for verbose output
    import doctest
    doctest.testmod()

