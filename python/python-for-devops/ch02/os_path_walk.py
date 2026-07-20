#!/usr/bin/env python
"""os_walk_dir.py - walk through a tree printing information about found files

Called like: 'python os_path_walk.py walk_path /Users/Lewis/'
Prints filename, last access time, and size for files.
Recurses on any child directories
"""

import os

import fire


def walk_path(parent_path):
    print(f"Checking: {parent_path}")
    childs = os.listdir(parent_path)

    for child in childs:
        child_path = os.path.join(parent_path, child)
        if os.path.isfile(child_path):
            last_access = os.path.getatime(child_path)
            size = os.path.getsize(child_path)
            print(f"File: {child_path}")
            print(f"\tlast accessed: {last_access}")
            print(f"\tsize: {size}")
        elif os.path.isdir(child_path):
            walk_path(child_path)


# Note, the above is the hard way of doing:
def walk_path2(parent_path):
    for parent_path, directories, files in os.walk(parent_path):
        print(f"Checking: {parent_path}")
        for file_name in files:
            file_path = os.path.join(parent_path, file_name)
            last_access = os.path.getatime(file_path)
            size = os.path.getsize(file_path)
            print(f"File: {file_path}")
            print(f"\tlast accessed: {last_access}")
            print(f"\tsize: {size}")


if __name__ == "__main__":
    fire.Fire()
