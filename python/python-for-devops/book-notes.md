# Python for DevOps

by Noah Gift, Kennedy Behrman, Alfredo Deza, and Grig Gheorghiu

## Chapter 1 - Python Essentials for DevOps

- A perfectly serviceable Python review.
- List comprehensions are powerful and idiomatic:

```python
squares = [i*i for i in range(10) if i%2==0]
```

- As are dict comprehensions:

```python
cap_map = {x: x.upper() for x in letters}
```

- And even generator comprehensions:

```python
>>> list_o_nums = [x for x in range(100)]   # not a generator
>>> gen_o_nums = (x for x in range(100))
>>> list_o_nums
[0, 1, 2, 3, ... 97, 98, 99]
>>> gen_o_nums
<generator object <genexpr> at 0x10ea14408>
>>> import sys
>>> sys.getsizeof(list_o_nums)
912
>>> sys.getsizeof(gen_o_nums)
120
```

- Use docstrings!

```python
def my_function():
    '''This is a doc string.

    It should describe what the function does,
    what parameters work, and what the
    function returns.
    '''
```

- lambda's are convenient:

```python
>>> items = [[0, 'a', 2], [5, 'b', 0], [2, 'c', 1]]
>>> sorted(items, key=lambda item: item[1])
[[0, 'a', 2], [5, 'b', 0], [2, 'c', 1]]
>>> sorted(items, key=lambda item: item[2])
[[5, 'b', 0], [2, 'c', 1], [0, 'a', 2]]
```

- It had a lovely review of regexes, but I just finished a chapter on that elsewhere.

```python
cc_list = '''Ezra Koenig <ekoenig@vpwk.com>,
Rostam Batmanglij <rostam@vpwk.com>,
Chris Tomson <ctomson@vpwk.com,
Bobbi Baio <bbaio@vpwk.com'''
matched = re.finditer("(?P<name>\w+)\@(?P<SLC>\w+)\.(?<TLD>\w+)", cc_list)
for m in matched:
    print(m.groupdict())
Out:
{'name': 'ekoenig', 'SLD': 'vpwk', 'TLD': 'com'}
{'name': 'rostam', 'SLD': 'vpwk', 'TLD': 'com'}
{'name': 'ctomson', 'SLD': 'vpwk', 'TLD': 'com'}
{'name': 'cbaio', 'SLD': 'vpwk', 'TLD': 'com'}

>>> re.sub("\d", "#", "The pass you entered was 09876")
'The passcode you entered was #####'
>>> users = re.sub("(?P<name>\w+)\@(?P<SLD>\w+)\.(?P<TLD>\w+)",
...                 "\g<TLD>.\g<SLD>.\g<name>", cc_list)
>>> print users
Out:
Ezra Koenig <com.vpwk.ekoenig>,
Rostam Batmanglij <com.vpwk.rostam>,
Chris Tomson <com.vpwk.ctomson,
Chris Baio <com.vpwk.cbaio
```

- There was also a bit on IPython (installable via pip). IPython can run shell
  commands and has magic functions. IPython uses ! in front of shell commands
  and store the command output in variables.

```python
In  [3]: var_ls = !ls -l
In  [4]: type(var)
Out [4]: IPython.utils.text.SList
```

- The `SList` type converts a regular shell command into an object with three
  methods: `fields`, `grep`, and `sort`.

```python
In  [6]: df = !df
In  [7]: df.sort(3, nums = True)
Out [7]: # Lots of sorted df output
In  [8]: ls = !ls -l /usr/bin
In  [9]: ls.grep("kill")
Out [9]:
['-rwxr-xr-x   1 root   wheel      1621 Aug 20  2018 kill.d',
 '-rwxr-xr-x   1 root   wheel     23984 Mar 20 23:10 killall',
 '-rwxr-xr-x   1 root   wheel     30512 Mar 20 23:10 pkill']
```

- You can also use IPython magic commands. `%%bash` let's you input and run a
  bash script. `%%writefile` will let you write a file, and `%who` will show
  you what is loaded into memory.

## Chapter 2 - Automating Files and the Filesystem

- You open a file like `open_file = open(file_path)`, an optional second
  paramter is for mode ('r'/'w'/'a' with a 'b' appended for binary, but this
  defaults to 'r'. and then read the files with either `text = open_file.read()`
  or `text = open_file.readlines()` which splits the contents into a list of
  lines. Close the file with `open_file.close()` when finished.
- You do not need ot close if you open with a `with` statement:

```python
with open(file_path, 'r') as open_file:
    text = open_file.readlines()
assert(open_file.closed == True)
```

- `pathlib` handles the file object behind the scenes and gives you methods
  to `read_text()`, `read_bytes()`, `write_text()`, and `write_bytes()` on
  a `Path` object.
- The `json` module gives you `json.load(open_file)` and `json.dump(open_file)`
  to load json as Python objects and store Python objects as json.
- When dealing with nested data objects, the `pprint` function formats them
  nicely. You can just `from pprint import pprint` and call `pprint(object)`.
- `pyyaml` (installed via pip) gives you `data = yaml.safe_load(open_file)`
  and `yaml.dump(data, open_file)` methods.
- `csv` gives you a way to handle CSV files. `csv.read` is especially useful
  for large CSV files since it parses a line at a time:

```python
import csv
filepath = '/Users/Lewis/testdata.csv'
with_open(file_path, newline='') as csv_file:
    off reader = csv.read(csv_file, delimeter=',')
    for _ in range(5):
        print(next(off_reader))
```

- `csv` can also load a file with headers as keys while parsing a line at a time:

```python
import csv
with open('data.csv', mode='r', newline='', encoding='utf-8') as file:
    reader = csv.DictReader(file)
    # Loop through rows; each row is a dictionary
    for row in reader:
        print(row['ColumnName'])
```

- You can also load small CSV files into memory at once using
  `df = pd.read_csv(filename)` and interact with them through headings like
  `df['high']`. Pandas also gives you a number of methods for interacting with
  your data.
- A useful tip for dealing with regular expressions is to build them up a
  piece at a time from named groups. Ex: `r = r'(?P<IP>\d+\.\d+\.\d+\.\d+)'`
  finds the IP out of an HTTP log.
- `hashlib` includes secure algorithms for hashing include SHA1, SHA224, SHA384,
  SHA512, and RSA's MD5. Simple MD5 example:

```python
import hashlib
secret = "This is the password or document text"
bsecret = secret.encode()   # to convert secret to binary string for hashing
m = hashlib.md5()
m.update(bsecret)
print(m.digest)     # b'\xf5\x06\xe6...\x0f5E'
```

- Checking filehashes is especially easy with `hashlib` (Note: this example
  requirequires Python 3.11 or later - see Google for an earlier example if
  needed):

```python
import hashlib

def verify_file_hash(file_path, expected_hash, algorithm="sha256"):
    # Open the file in binary read mode ('rb')
    with open(file_path, "rb") as f:
        # Calculate the digest efficiently
        file_hash = hashlib.file_digest(f, algorithm).hexdigest()

    # Compare the calculated hash with your expected hash
    return file_hash.lower() == expected_hash.lower()

# Example Usage
target_file = "sample.zip"
known_sha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

if verify_file_hash(target_file, known_sha256):
    print("Verification successful! The file is original.")
else:
    print("Verification failed! The file may be tampered with or corrupted.")
```

- The `cryptography` (imported via pip) library is a popular choice for other
  Python encryption tasks.
- Useful methods of the `os` module:
  - `os.listdir('.')`
  - `os.rename(filename, targetname)`
  - `os.chmod(filename, 0o777)`
  - `os.mkdir('/tmp/emptydir')`
  - `os.makedirs('/tmp/dirname/dirchild/subfolder')`
  - `os.remove(filename)`
  - `os.rmdir('/tmp/emptydir')`
  - `os.removedirs('/tmp/dirname/dirchild/subfolder')` - this works up the
    tree deleting each empty directory found.
  - `os.stat(filename)` returns an `os.stat_result` object with a number of
    fields.
  - `os.path` provides a variety of ways to work with directories although a
    lot of them have been replaced by `pathlib.Path`:

  ```python
  In  [1]: import os
  In  [2]: cur_dir = os.getcwd()
  In  [3]: cur_dir
  Out [3]: '/Users/kbehrman/Google-Drive/projects/python-devops/samples/chapter4'
  In  [4]: os.path.split(cur_dir)
  Out [4]: ('/Users/kbehrman/Google-Drive/projects/python-devops/samples', 'chapter4')
  In  [5]: os.path.dirname(cur_dir)
  Out [5]: '/Users/kbehrman/Google-Drive/projects/python-devops/samples'
  In  [6]: os.path.basename(cur_dir)
  Out [6]: 'chapter4'
  ```

  - `os` methods can search for an rc file. Note that `__file__` holds a
    relative path to the executable file that needs to be expanded and os vars
    are not expanded unless passed through `expandvars` or `expanduser`.

  ```python
  def find_rc(rc_name=".examplerc"):
      # Check for Env variable
      var_name = "EXAMPLERC_DIR"
      if var_name in os.environ:
          var_path = os.path.join(f"${var_name}", rc_name)
          config_path = os.path.expandvars(var_path)
          if os.path.exists(config_path):
              return config_path

      # Check the current working directory
      config_path = os.path.join(os.getcwd(), rc_name)
      if os.path.exists(cofnig_path):
          return config_path

      # Check user home directory
      home_dir = os.path.expanduser("~/")
      config_path = os.path.join(home_dir, rc_name)
      if os.path.exists(config_path):
          return config_path

      # Check Directory of This file
      file_path = os.path.abspath(__file__)
      parent_path = os.path.dirname(file_path)
      config_path = os.path.join(parent_path, rc_name)
      if os.path.exists(config_path:
          return config_path

      print(f"File {rc_name} has not been found")
  ```

- There's an example of manually walking dirs in ch02/os_path_walk.py, but os
  includes an `os.walk(parent_path)` function that is a generator of a tuple
  contain the current path, a list of directories, and a list of files.
  That's an easier way to walk a tree:

```python
def walk_path(parent_path):
    for parent_path, directories, files in os.walk(parent_path):
        print(f"Checking: {parent_path}")
        for file_name in files:
            file_path = os.path.join(parent_path, file_name)
            last_access = os.path.getatime(file_path)
            size = os.path.getsize(file_path)
            print(f"File: {file_path}")
            print(f"\tlast accessed: {last_access}")
            print(f"\tsize: {size}")
```

- `pathlib.Path` represents path entries as `Path` objects and is the new way
  of handle paths without all the `os.path.join` calls. Here is the example
  before last (search for an .examplerc config file) using `Path`:

```python
from pathlib import Path    # Standard to import path since that's all we need

def find_rc(rc_name=".examplerc"):
    # Check for Env variable
    var_name = "EXAMPLERC_DIR
    example_dir = os.environ.get(var_name)
    if example_dir:
        dir_path = Path(example_dir)
        config_path = dir_path / rc_name
        if config_path.exists():
            return str(config_path)     # open would take a Path

    # Check the current working directory
    config_path = Path.cwd() / rc_name
    if config_path.exists():
        return str(config_path)

    # Check user home directory
    config_path = pathlib.Path.home() / rc_name
    if config_path.exists():
        return str(config_path)

    # Check directory of this file
    file_path = Path(__file__).resolve()    # __file__ is relative, resolve fixes
    parent_path = file_path.parent
    config_path = parent_path / rc_name
    if config_path.exists():
        return str(config_path)

    print(f"File {rc_name} has not been found")
```

## Chapter 3 - Working with the Command Line

- The `sys` module ofers access to variales and methods closely tied to the
  Python interpreter.
  - `sys.byteorder` shows the byteorder of your architecture, 'little'/'big'
  - `sys.getsizeof(var)` display the size of Python objects
  - `sys.platform` displays your operating system (darwin for Mac)
  - `sys.version_info` contains our Python version
- The `os` module has a grab bag of various attributes and functions relating
  to dealing with the operating system. The most common use of `os` is to get
  settings from environment variables.
  - `os.getcwd()` returns current working directory as a string.
  - `os.chdir('/tmp')` changes the current working directory.
  - `os.environ['LOGLEVEL'] = 'DEBUG'` sets LOGLEVEL for this and subprocesses.
  - `os.environ.get('LOGLEVEL')` gets LOGLEVEL.
  - `os.getlogin()` returns logged in user.
- The `subprocess` module can run applications outside Python from within code.
  - `cp = subprocess.run(['ls', '-l'],
      capture_output=True, universal_newlines=True)`  
    will run `ls -l` and capture it's output to a `stdout` attribute of the cp
    object.
    - `subprocess.run()` returns a `CompletedProcess` instance when the process
      completes.
    - In addition to `cp.stdout` there is a `cp.stderr` attribute.
    - `subprocess.run()` also takes a `check=True` parameter that throws an
      exception if the subprocess reports an error.
- You can run code only when a module is run as a script by checking
  `if __name__ == '__main__'`. When it is imported, `__name__` will be set
  differently.
- You can use the list `sys.argv` to access command-line arguments.
  `sys.argv[0]` is the name of the script. Other arguments (if provided) are in
  later positions.
- Don't parse your own arguments. There's packages for that. Three popular
  choices are `argparse`, `click`, and `python-fire`.
  - `argparse` has parser objects to which you attach commands and flags. The
    parser parses the arguments and you use the results in your code.
    - `argparse` supports commands with subcommands like `git stash pop`. An
      example is provided in [ch03/argparse_example.py](ch03/argparse_example.py).
    - Here is a simple example with a string message and one optional command
      line boolean and the standard `-h/--help` support:
    - `argparse` gives you a lot of control over your command-line interface,
      but it takes a lot of work on your part. The other options in this book
      are easier.

    ```python
    import argparse

    if __name__ == "__main__":
        parser = argparse.ArgumentParser(description="Echo your input")
        parser.add_argument("message", help="Message to echo")
        parser.add_argument("--twice", "-t", help="Do it twice", action="store_true")
        args = parser.parse_args()

        print(args.message)
        if args.twice:
            print(args.message)
    ```

  - `click` use *function decorators* to bind the command-line interface
    directly with your functions.
    - A *decorator* wraps a function and is declared with a special syntax:
      `@some_decorator` before the function definition. Then when the function
      is called, the wrapping decorator gets called instead.

    ```python
    import click

    @click.command()
    @click.option("--greeting", default="Hiya", help="How do you want to greet?")
    @click.option("--name", default="Tammy", help="Who do you want to greet?")
    def greet(greeting, name):
        print(f"{greeting} {name}")


    if __name__ == "__main__":
        greet()
    ```

  - The `fire` library uses introspection to create interfaces automatically. To explose a simple function, you call `fire.Fire` with it as an argument.

  ```python
  import fire

  def greet(greeting='Hiya', name='Tammy'):
      print(f"{greeting} {name}")

  if __name__ == '__main__':
      fire.Fire(greet)
  ```

  - I also rewrote these examples in `Typer`, a newer CLI library that uses
    type hints but otherwise is very similar to `Click`

  ```python
  import typer

  def greet(
      greeting: str = "Hiya",
      name: str = "Tammy"
  ):
      print(f"{greeting} {name}")

  if __name__ == "__main__":
      typer.run(greet)
  ```

  - Here's the full `Typer` example of an app with subcommands

  ```python
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
  ```

## Chapter 4 - Useful Linux Utilities

- A lot of this was information on performance utilities.
  - [Molotov](https://molotov.readthedocs.io/en/stable/) is a good load
    testing tool written in Python
  - [Locust](https://docs.locust.io/en/stable/) is more popular these days with
    better documentation and a Web UI.
- There were some useful one-liners and aliases:
  - `export PYTHONSTARTUP=$HOME/dotfiles/pythonstartup.py` # in .zshrc. Ex file:

  ```python
  import types
  import uuid

  helpers = types.ModuleType('helpers')
  helpers.uuid64 = uuid.uuid64()
  ```

  - `ssh -L 8080:localhost:80 lcawthorne@server.com -N` # to link remote
    server:80 to localhost:8080 without starting a shell.
  - `ls **/*.py` will traverse a path listing all `.py` files. Requires
    `shopt -s globstar` on BASH but built in to zsh.
  - in vim `:%s/old_text/new_text/gc` will search and replace with confirmation.
  - ps aux with grep, but remove grep from results
    - alias pg='ps aux | grep -v grep | grep $1'
  - The following function in zshrc acts a a kinda vim-sed with confirmation:
    - Ex: `vsed needs_root needs_root() **/*.py`

    ```zsh
    vsed() {
      search=$1
      replace=$2
      shift
      shift
      vim -c "bufdo! set eventignore-=Syntax| %s/$search/$replace/gce" $*
    }
    ```

  - An alias to clean up leftover python extra files:

  ```zsh
  alias pyclean='find . \
    \( -type f -name "*.py[co]" -o -type d -name "__pycache__" \) -delete &&
    echo "Removed pycs and __pycache__"'
  ```

  - Try to load a module

  ```zsh
  # To attempt to load a Python module and make sure it's installed
  try_module() {
      python -c "
  exec('''
  try:
      import ${1} as _
  except Exception as e:
      print(e)
  ''')"
  }
  ```

  - Find a module path and switch to the directory.

    ```zsh
    find_module_dir() {
      module=$(sed 's/-/_/g' <<< $1)
      MODULE_DIRECTORY=`python -c "
    exec('''
    try:
      import os.path as _, ${1}
      print(_.dirname(_.realpath(${1}.__file__)))
    except Exception as e:
      print(e)
    ''')"`
    if  [[ -d $MODULE_DIRECTORY ]]; then
        cd $MODULE_DIRECTORY
    else
        echo "Module ${1} not found or is not importable: $MODULE_DIRECTORY"
    fi
    }
    ```

  - Convert a csv to json.

  ```zsh
  # Convert a csv to json
  csv2json() {
      python -c "
  exec('''
  import csv,json
  print(json.dumps(list(csv.reader(open(\'${1}\')))))
  ''')"
  }
  ```

- Use `htop`
  - `F1` or `h` is help.
  - `/` to search.
  - `k` to send a signal to a process.
  - `t` toggles process list as tree.
  - `SHIFT i` sort by memory, `SHIFT p` sort by cpu, `SHIFT t` sort by time.
  - `s` will run `strace` on a process and `l` will run `lsof`.

- Use Python One-Liners
  - Set a break point and drop to the Python debugger (pdb):  
  `import pdb;pdb.set_trace()`
  - Set a break piont and drop to the Python debugger in IPython (ipdb):  
  `import ipdb;ipdb.set_trace()`
  - Start an IPython session at a given point:  
  `import IPython; IPython.embed()`
- In IPython you can use `%timeit` to time code:  
`%timeit for x in range(100): f(x)`
- To debug at the OS level, call `strace python script.py`).
  - `-f` to follow subprocesses
  - `-o outfile.txt` to save output to file

## Chapter 5 - Package Management

- Useful tip: setup an alias that cd's to your project and source's the venv.  
  `alias sugar="source ~/src/sugar/.venv/bin/activate && cd ~/src/sugar`
- You can easily run `!pip list --format=json` to get a list of packages in 
  IPython (or without ! at command prompt).
- The packaging advice in this book is dated. Use modern tools if you need to
  package anything. `setuptools` is the old way.

## Chapter 6 - Continuous Integration and Continuous Deployment
