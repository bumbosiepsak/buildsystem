import detail.exceptions as exceptions
import os


def run(args):
    if not os.path.exists(args.file):
        raise exceptions.OperationFailed('File does not exist')

    if os.path.islink(args.file):
        raise exceptions.ConventionBreached()
