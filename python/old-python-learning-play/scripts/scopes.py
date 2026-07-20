#!/usr/bin/env python3
# the do_local() assignment doesn't change the value of spam in scope_test
# the nonlocal assignment does change the scope_test's spam value
# the global assignment changes the global value, but not scope_test's
def scope_test():
    def do_local():
        spam = "local spam"
    def do_nonlocal():
        nonlocal spam
        spam = "nonlocal spam"
    def do_global():
        global spam
        spam = "global spam"

    spam = "test spam"
    do_local()
    print("After local assignment:", spam)
    do_nonlocal()
    print("After nonlocal assignment:", spam)
    do_global()
    print("After global assignment:", spam)

scope_test()
print("In global scope:", spam)
