#!/usr/bin/env python3
def doc_string():
    """This line should be a short, concise summary of the object's purpose.

    The line before this should always be blank to set off this paragraph.  
    No empty line is needed if your description was only one line.
    The first line should begin with a capital and end with a period.
    This area is optional and  has one or more paragraphs describing the
    object's calling conventions, its side effects, etc.  Note that
    identation is not stripped from this paragraph.
    """
    pass    # pass does nothing

print("1) Use 4-space indentation, and no tabs.")
print("2) Lines should not exceed 79 characters.")
print("3) Use blank lines to separate functions and classes,")
print("4) and larger blocks of code inside functions.")
print("5) When possible, put comments on a line of their own.")
print("6) Use docstrings.  Like so:")
print(doc_string.__doc__)
print("7) Use spaces around operators and after commands, but")
print("   not directly inside bracketing constructs: a = f(1, 2) + g(3, 4).")
print("8) Use CamelCase for functions and lower_case_with_undersocres for")
print("   functions and methods.  Always use self as the name of the ")
print("   first method argument.")
print("9) Don't use fancy encodings unnecessarily.  UTF-8 should be fine.")
print("0) Don't use non-ASCII characters in identifiers.")
