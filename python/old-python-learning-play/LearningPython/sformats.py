#!/usr/bin/env python
"""
Various specialized string display formatting utilities.
Test with canned self-test or command-line arguments.
Compatible with Python 2.6 and Python 3.0+
"""

def commas(N):
    """
    format positive integer N for display with commas 
    between digit groupings xxx,yyy,zzz
    """
    sign = '-' if N < 0 else ''
    digits = str(abs(N))
    assert(digits.isdigit())
    result = ''
    while digits:
        digits, last3 = digits[:-3], digits[-3:]
        result = (last3 + ',' + result) if result else last3
    result = sign + result
    return result

def money(N, width=0):
    """
    format N for display with commas, 2 decimal digits,
    leading $ and sign, and optional padding: $ -xx,yyy.zz
    """
    sign    = '-' if N < 0 else ''
    N       = abs(N)
    whole   = commas(int(N))
    fract   = ('%.2f' % N)[-2:]
    format  = '%s%s.%s' % (sign, whole, fract)

    return  '$%*s' % (width, format)

if __name__ == '__main__':
    def selftest():
        tests  = 0, 1, -1
        tests += 12, 123, 1234, 12345, 123456, 1234567
        tests += 2 ** 32, 2 ** 100
        for test in tests:
            print(commas(test))

        print('')
        tests  = 0, 1, -1, 1.23, 1., 1.2, 3.14159
        tests += 12.34, 12.344, 12.345, 12.346
        tests += 2 ** 32, (2 ** 32 + .2345)
        tests += 1.2345, 1.2, 0.2345
        tests += -1.2345, -1.2, -0.2345
        tests += -(2 ** 32), -(2 ** 32 + .2345)
        tests += 2 ** 100, -(2 ** 100)
        for test in tests:
            print('%s [%s]' % (money(test,17), test))

    import sys
    if len(sys.argv) == 1:
        selftest()
    else:
        print(money(float(sys.argv[1]), int(sys.argv[2])))



# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
