#!/usr/bin/env python3

import sys

sys.dont_write_bytecode = True

import argparse
import pathlib
import signal
import subprocess

FAILURE = 1


def get_args(argv):
    parser = argparse.ArgumentParser(prog='run_maven.py', description='Maven wrapper for defines injection')

    parser.add_argument(
        '--mvn-path', dest='mvn_path', action='store', type=pathlib.Path, required=True, help='Maven executable path'
    )

    parser.add_argument(
        '--properties-file',
        dest='properties_files',
        action='append',
        type=pathlib.Path,
        default=[],
        help='Properties files paths'
    )

    return parser.parse_known_args(argv)


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


def run(argv):
    (wrapper_args, args) = get_args(argv)

    try:
        mvn_path = wrapper_args.mvn_path.resolve()

        properties_options = []
        for properties_file in wrapper_args.properties_files:
            with open(properties_file) as p:
                for property_name_and_value in p.readlines():
                    properties_options.append('--define')
                    properties_options.append(property_name_and_value.strip())

        return subprocess.run([mvn_path, *properties_options, *args], check=False).returncode

    except FileNotFoundError:
        print(f'Running Maven failed: check if mvn installed and callable', file=sys.stderr)

    except (IOError, ValueError, subprocess.CalledProcessError) as e:
        print('Running Maven failed:', e, file=sys.stderr)

    except KeyboardInterrupt as e:
        print('Running Maven interrupted:', e, file=sys.stderr)

    return FAILURE


if __name__ == '__main__':
    install_exit_handlers()
    sys.exit(run(sys.argv[1:]))
