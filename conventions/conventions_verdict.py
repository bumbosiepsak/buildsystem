#!/usr/bin/env python3

import detail.user_interface as user_interface
import os
import sys


def get_args(argv):
    parser = user_interface.ArgumentParser()

    parser.add_argument(
        '--verdict', dest='verdict', action='store', type=str, required=True, help='Failure indicating file'
    )

    return parser.parse_args(argv[1:])


def run(args):
    verdict = os.path.normpath(args.verdict)
    is_any_convention_failed = os.path.exists(verdict)

    if is_any_convention_failed:
        user_interface.announce_failure('Conventions verdict')

    user_interface.announce_success()


if __name__ == '__main__':
    run(get_args(sys.argv))
