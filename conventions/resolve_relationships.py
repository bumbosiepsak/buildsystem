#!/usr/bin/env python3

from pathlib import Path
import detail.user_interface as user_interface
import fnmatch
import glob
import os
import sys


def get_args(argv):
    parser = user_interface.ArgumentParser()

    parser.add_argument(
        '--source-dir', dest='source_dir', action='store', type=str, required=True, help='Sources root dir'
    )

    parser.add_argument(
        '--convention-names',
        dest='convention_names',
        action='store',
        type=user_interface.cmake_list,
        required=True,
        help='List of convention names'
    )

    parser.add_argument(
        '--globs-included',
        dest='globs_included',
        action='store',
        type=user_interface.cmake_list_of_lists,
        required=True,
        help='List of lists of included globs'
    )

    parser.add_argument(
        '--globs-excluded',
        dest='globs_excluded',
        action='store',
        type=user_interface.cmake_list_of_lists,
        required=True,
        help='List of lists of excluded globs'
    )

    return parser.parse_args(argv[1:])


def serialize(args, stream, paths_vs_names):
    path_and_names = iter(paths_vs_names.items())
    try:
        (path, names) = next(path_and_names)
        while True:
            stream.write(Path(path).relative_to(args.source_dir).as_posix())
            stream.write(user_interface.CMAKE_LIST1)
            stream.write(user_interface.CMAKE_LIST1.join(names))

            (path, names) = next(path_and_names)

            stream.write(user_interface.CMAKE_LIST0)

    except StopIteration:
        pass


def resolve_globs(args):
    paths_vs_names = {}

    names_vs_globs_excluded = dict(zip(args.convention_names, args.globs_excluded))

    globs_included_vs_names = {}
    for (name, globs_included) in zip(args.convention_names, args.globs_included):
        for glob_included in globs_included:
            globs_included_vs_names.setdefault(glob_included, set()).add(name)

    for (glob_included, names) in globs_included_vs_names.items():
        for path in glob.iglob(glob_included, recursive=True):
            path = os.path.normpath(path)
            if os.path.isfile(path):
                for name in names:
                    if not any(fnmatch.fnmatch(path, glob_excluded) for glob_excluded in names_vs_globs_excluded[name]):
                        paths_vs_names.setdefault(path, []).append(name)

    for names in paths_vs_names.values():
        names.sort()

    return paths_vs_names


def run(args):
    paths_vs_names = resolve_globs(args)
    serialize(args, sys.stdout, paths_vs_names)


if __name__ == '__main__':
    run(get_args(sys.argv))
    sys.exit(0)
