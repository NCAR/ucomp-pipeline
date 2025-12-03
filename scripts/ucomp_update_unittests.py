#!/usr/bin/env python

import os
import pathlib


PIPELINE_DIR = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
SRC_DIR = os.path.join(PIPELINE_DIR, "src")
UNIT_DIR = os.path.join(PIPELINE_DIR, "unit")


def convert_to_unittest(root, relative_path):
    # put _ut suffix in relative path subdirs
    p = pathlib.Path(os.path.dirname(relative_path))
    subdirs = [f"{d}_ut" for d in p.parts]
    subdirs = os.path.join(*subdirs) if len(subdirs) > 0 else ""

    # put _ut__define in the right place
    basename = os.path.basename(relative_path)
    basename_root, extension = os.path.splitext(basename)
    class_suffix = "__define"
    if basename_root.endswith(class_suffix):
        basename_root = basename_root[0:-len(class_suffix)]
    basename = f"{basename_root}_ut__define{extension}"

    return(os.path.join(os.path.join(root, subdirs), basename))


def find_unit_path(path, src_root, unit_root):
    """Remove prefix or fail.
    """
    if path.startswith(src_root):
        relative_path = path[len(src_root):]
        if relative_path.startswith("/"):
            relative_path = relative_path[1:]
        return(convert_to_unittest(unit_root, relative_path))
    raise FileNotFoundError from None


def main():
    print("#!/bin/sh")
    print()

    for dir, subdirs, files in os.walk(SRC_DIR):
        pro_files = [f for f in files if os.path.splitext(f)[1] == ".pro"]
        for f in files:
            if os.path.splitext(f)[1] != ".pro":
                continue

            src_filename = os.path.join(dir, f)
            unit_filename = find_unit_path(src_filename, SRC_DIR, UNIT_DIR)
            if not os.path.exists(unit_filename):
                unit_dir = os.path.dirname(unit_filename)
                if not os.path.exists(unit_dir):
                    os.makedirs(unit_dir)
                print(f"mgunit_template --parent-class UCoMPutTestCase {src_filename} > {unit_filename}")


if __name__ == "__main__":
    main()
