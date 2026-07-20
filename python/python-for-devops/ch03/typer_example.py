#!/usr/bin/env python
"""
Command-line tool using typer
"""

import typer

app = typer.Typer()
# invoke_without_command=True is to call callback to show help if we run "script.py sailors"
ships_app = typer.Typer(help="Ship related commands", invoke_without_command=True)
app.add_typer(ships_app, name="ships")


# this callback shows help if we just run "script.py"
@app.callback(invoke_without_command=True)
def main_callback(ctx: typer.Context):
    if ctx.invoked_subcommand is None:
        print(ctx.get_help())


# this is to make help appear if we run "script.py ships"
@ships_app.callback()
def ships_callback(ctx: typer.Context):
    if ctx.invoked_subcommand is None:
        print(ctx.get_help())


@ships_app.command(help="Sail a ship")
def sail():
    ship_name = "Your ship"
    print(f"{ship_name} is setting sail")


# we didn't want to name 'list_ships' just 'list' to shadow the built-in
@ships_app.command(name="list", help="List all of the ships")
def list_ships():
    ship_list = ["John B", "Yankee Clipper", "Pequod"]
    print(f"Ships: {', '.join(ship_list)}")


@app.command(help="Talk to a sailor")
def sailors(
    name: str = typer.Argument(..., help="Sailor's name"),
    greeting: str = typer.Option("Ahoy there", help="Greeting for sailor"),
):
    message = f"{greeting} {name}"
    print(message)


if __name__ == "__main__":
    app()
