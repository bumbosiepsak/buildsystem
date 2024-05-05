import detail.exceptions as exceptions


def run(args):
    try:
        with open(args.file, 'r') as f:
            if '#pragma once' in f.readline():
                return

    except (IOError, ValueError) as e:
        raise exceptions.OperationFailed(e)

    raise exceptions.ConventionBreached()
