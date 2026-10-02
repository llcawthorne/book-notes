---
creationDate: 2026-10-02 06:55
modifiedDate: 2026-10-02 06:55
tags: [architecture, book-notes, programming]
parent:
  - "[[Book Notes]]"
---

# The Programmer's Brain

- When trying to understand unfamiliar code, it may be useful to temporarily
  inline function definitions rather than looking them up and to rewrite
  unfamiliar language constructs using simpler notation.
- You can analyze code from an IDE and easily inline parts and add comments
  with explanations you had to look elsewhere for.
- It is easiest to analyze code from a fixed *focal point* such as the main
  method or the source of an error. When working with well-documented code, you
  can generally view method documentation comments and you may choose to inline
  part of that in a comment on what the method does or else focus more on what
  the method is doing here, such as what is being passed and what it returns.
- It can be helpful to annotate code you don't understand with a question mark,
  so you know to focus on it more later or ask someone about it. An exclamation
  mark for important lines may also be helpful.
- Roles of Variables Framework
  - fixed value - a variable whose value does not change after initialization
    (any `val`).
  - stepper - the variable iterating through a list of values in a loop (`i` in
    `for (i in 1..10)`).
  - flag - a variable used to indicate something has happened or is the case
    (`isError`, often booleans but can be ints or even strings).
  - walker - a walker iterates over values in a data structure, but unlike a
    stepper where the values are in a known-in-advance ordering, a walker
    traverses a data structure in a way unknown before the loop starts. Walkers
    may be pointers or integer indices pointing at a list index in binary search
    but more often point to values in a stack or nodes of a tree.
  - most recent holder - a variable that holds the most recently encountered
    value in a series of values, such as the last line from `readLine()` or the
    latest list value indexed by a stepper.
  - most wanted value - holds the best value so far of what's being searched for,
    like the max/min we've found in a list.
  - gatherer (accumulator) - a variable that collects data and aggregates it
    into one value, like a `runningTotal`.
  - container - any data structure that holds multiple elements that can be
    added or removed. Note that sometimes the accumulator is a container, like
    the Set of Power Sets or the Stack in RPN.
  - follower - tracks a previous or subsequent value, like `previousElement` in
    a linked list or the `lowerIndex` in a binary search. Always accompanies
    another variable.
  - organizer - holds temporary transformations, like the `Array<Char>` from a
    String transformed for character-based search or a sorted version of a list
    to search. Often also temporary.
  - temporary - variables used very briefly and often given names like `temp` or
    `t`. Used to swap data or store values of intermediate computations.
- Identifier names consisting of words engender better understanding and
  debugging than those made of abbreviations or letters. Don't sacrifice
  maintainability to save keystrokes. But keep them to four words or less. When
  you feel the need to include a comment to explain a variable name, this often
  means the variable name should include another concept.
- Obviously avoid code smells. But also avoid linguistic antipatterns. Your
  method names should match what they do. `getCustomers` should return a
  collection of customers and `isX` should return a Boolean. Likewise setters
  should not do things in addition to setting.
- One of the best ways to deal with interruptions is to offload as much of your
  thought processes as possible to notes or comments to make it easy to pick up
  where you left off.
- Type systems have been shown in research to help developers locate and fix
  errors.
- Beware of overloading new hires when onboarding. Try to focus on single
  activities (like just reading the code) at first, start with concrete examples
  and focus on code at first and not diagrams, and be aware everything is new
  for them in your code base. Or else you may get the wrong impression that they
  are slow and give them the impression every task is going to be difficult.
