import detail.exceptions as exceptions
import os
import platform


def run(args):
    if not os.path.exists(args.file):
        raise exceptions.OperationFailed('File does not exist')

    if os.access(args.file, os.X_OK) and platform.system() != 'Windows':  # NOTE: Windows has its own rules
        raise exceptions.ConventionBreached()
