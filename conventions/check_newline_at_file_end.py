import detail.exceptions as exceptions
import os


def is_garbled(filename):
    try:
        with open(filename, 'rb') as f:
            f.seek(0, os.SEEK_END)
            if f.tell():
                f.seek(-1, os.SEEK_END)
                if f.read() not in (b'\r', b'\n'):
                    return True
        return False

    except (IOError, ValueError) as e:
        raise exceptions.OperationFailed(e)


def run(args):
    if is_garbled(args.file):
        raise exceptions.ConventionBreached()
