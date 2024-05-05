import argparse
import os
import sys

FAILED = 'FAILED: '
CMAKE_LIST0 = ';'
CMAKE_LIST1 = '\n'


def print_something(*details):
    print(*details, sep='', file=sys.stderr)


def announce_success():
    sys.exit(0)


def announce_failure(*why):
    print_something(FAILED, *why)
    sys.exit(1)


def announce_convention_breached(operation, file, *details):
    print_something(
        FAILED, 'In ', os.path.basename(operation), " - convention breached by: '{}' ".format(file), *details
    )
    sys.exit(0)


def announce_failure_bad_setup(operation, file, *reason):
    announce_failure(
        'In ', os.path.basename(operation), " - bad setup/configuration for '{}',".format(file), ' why: ', *reason
    )


def announce_failure_bad_file(operation, file, *reason):
    announce_failure('In ', os.path.basename(operation), " - bad file: '{}',".format(file), ' why: ', *reason)


def announce_interrupted(operation, file, *reason):
    announce_failure('In ', os.path.basename(operation), " - interrupting at: '{}',".format(file), ' why: ', *reason)


class ArgumentParser(argparse.ArgumentParser):
    def error(self, message):
        announce_failure('Bad options for {self.prog}:', message)


def cmake_list(separated):
    return separated.split(CMAKE_LIST0)


def cmake_list_of_lists(separated):
    return [inner_list.split(CMAKE_LIST1) for inner_list in cmake_list(separated)]
