#!/usr/bin/env python
import typer


# You don't need to define app for something this simple.
def greet(greeting: str = "Hiya", name: str = "Tammy"):
    print(f"{greeting} {name}")


if __name__ == "__main__":
    typer.run(greet)
