
# A Review of Regex Symbols

Remember: [Regex 101](https://regex101.com/)

- The ? matches zero or one instance of the preceding qualifier.
- The * matches zero or more instance of the preceding qualifier.
- The + matches one or more instances of the preceding qualifier.
- The {n} matches exactly n instances of the preceding qualifier.
- The {n,} matches n or mroe instances of the preceding qualifier.
- The {,m} matches 0 to m instances of the preceding qualifier.
- The {n,m} matches at least n and at most m instances of the preceding qualifer.
- {n,m}? or *? or +? performs a non-greedy match of the preceding qualifier.
- ^spam means the string must begin with spam.
- spam$ means the string must end with spam.
- The . matches any character, except newlien characters.
- The \d, \w, and \s match a digit, word, or space character, respectively.
- The \D, \W, and \S match anything except a digit, word, or space character, respectively. [abc] matches any character between the square brackets (such as a, b, or c).
- [^abc] matches any character that isn't between the square brackets.
- (Hello) groups 'Hello' together as a single qualifier

# Humre

When using Humre, you use it to write your regex but still need `re` to compile your regex before using it. Below is a summary of what it makes available and a phone number example, but you can find more at the [Humre Package Page](https://pypi.org/project/Humre/).

## Humre Constants

The following Humre constants exist for escaped characters:

PERIOD		    OPEN_PAREN	OPEN_BRACKET	PIPE
DOLLAR_SIGN	    CLOSE_PAREN	CLOSE_BRACKET	CARET
QUESTION_MARK	ASTERISK	OPEN_BRACE	    TILDE
HASHTAG		    PLUS		CLOSE_BRACE	
AMPERSAND	    MINUS		BACKSLASH	

There are also constants for NEWLINE, TAB, QUOTE, and DOUBLE_QUOTE. Back references from r'\1' to r'\99' are represented as BACK_1 to BACK_99.

## Table 9-2: Humre Functions

Humre function              Regex string
group('A')                  r'(A)'
optional('A')               r'A?
either('A', 'B', 'C')      r'A|B|C'
exactly(3, 'A')             'A{3}'
between(3, 5, 'A')          'A{3,5}'
at_least(3, 'A')            'A{3,}'
at_most(3, 'A')             'A{,3}'
chars('A-Z')                '[A-Z]'
nonchars('A-Z')             '[^A-Z]'
zero_or_more('A')           'A*'
zero_or_more_lazy('A')      'A*?'
one_or_more('A')            'A+'
one_or_more_lazy('A')       'A+?'
starts_with('A')            '^A'
ends_with('A')              'A$'
starts_and_ends_with('A')   '^A$'
named_group('name', 'A')    '(?P<name>A)

Any Hume function that takes a string with concatenate multiple comma separated strings so group(DIGIT, PERIOD, DIGIT) is equivalent to group(DIGIT + PERIOD + DIGIT).

There is also a table 9-3 of Humre Convenience Functions such as optional_group('A') instead of optional(group('A'))

## Constants for regex patterns:

ANY_SINGLE                  .
ANYTHING_LAZY               .*?
ANYTHING_GREEDY             .*
SOMETHING_LAZY              .+?
SOMETHING_GREEDY            .+

## Example: The Phone Number Expression with Humre

'''python
import re
from humre import *
phone_regex = group(
    optional_group(either(exactly(3, DIGIT),            # Area code
                    OPEN_PAREN + exactly(3, DIGIT) + CLOSE_PAREN)),
    optional(group_either(WHITESPACE, '-', PERIOD)),    # Separator
    group(exactly(3, DIGIT)),                           # First three digits
    group_either(WHITESPACE, '-', PERIOD),              # Separator
    group(exactly(4, DIGIT)),                           # Last four digits
    optional_group(                                     # Extension
        zero_or_more(WHITESPACE),
        group_either('ext', 'x', r'ext\.'),
        zero_or_more(WHITESPACE),
        group(between(2, 5, DIGIT))
    )
)
pattern = re.compile(phone_regex)
match = pattern.search('My number is 415-555-1212.')
print(match.group())
```

- To see what any regex looks like with humre, pass it to humre.parse() which returns a string of Python source code!
