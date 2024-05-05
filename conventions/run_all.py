#!/usr/bin/env python3

from importlib import import_module
from pathlib import Path
import detail.exceptions as exceptions
import detail.user_interface as user_interface
import signal
import sys


def get_args(argv):
    parser = user_interface.ArgumentParser()

    parser.add_argument('--type', dest='type', action='store', type=str, required=True, help='Convention type')

    parser.add_argument('--file', dest='file', action='store', type=str, required=True, help='File to be processed')

    parser.add_argument(
        '--names', dest='names', action='store', type=user_interface.cmake_list, required=True, help='Convention name'
    )

    parser.add_argument(
        '--output', dest='output', action='store', type=Path, required=True, help='Output dependency file'
    )

    parser.add_argument(
        '--verdict', dest='verdict', action='store', type=Path, required=True, help='Output verdict file'
    )

    return parser.parse_args(argv[1:])


def install_exit_handlers():
    exit_signal_names = (
        'SIGBREAK',
        'SIGHUP',
        'SIGQUIT',
        'SIGTERM',
    )
    default_exit_handler = signal.getsignal(signal.SIGINT)
    for exit_signal_name in exit_signal_names:
        exit_signal = getattr(signal, exit_signal_name, None)
        if exit_signal:
            signal.signal(exit_signal, default_exit_handler)


install_exit_handlers()

args = get_args(sys.argv)

try:
    args.output.exists() and args.output.unlink()  # NOTE: Making up for CMake

    for name in args.names:
        operation = '_'.join((args.type, name))
        try:
            module = import_module(operation)
        except ImportError as e:
            user_interface.announce_failure('Missing convention plugin: ', operation, ' or its dependency: ', e)

        module.run(args)

    args.output.touch()

    user_interface.announce_success()

except exceptions.BadSetup as e:
    user_interface.announce_failure_bad_setup(operation, args.file, e)

except exceptions.OperationFailed as e:
    user_interface.announce_failure_bad_file(operation, args.file, e)

except exceptions.ConventionBreached as e:
    args.verdict.touch()
    user_interface.announce_convention_breached(operation, args.file, e)

except KeyboardInterrupt as e:
    user_interface.announce_interrupted(operation, args.file, e)
