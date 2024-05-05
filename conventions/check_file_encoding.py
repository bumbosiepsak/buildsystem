import chardet
import detail.exceptions as exceptions


def read_file(file):
    try:
        with open(file, 'rb') as f:
            return f.read()

    except (IOError, ValueError) as e:
        raise exceptions.OperationFailed(e)


def get_encoding(file):
    contents = read_file(file)

    try:
        return chardet.detect(contents)['encoding']

    except Exception as e:
        raise exceptions.OperationFailed(e)


def run(args):
    encoding = get_encoding(args.file)

    if encoding not in ('ascii', 'utf-8', None):
        raise exceptions.ConventionBreached('got: ', encoding)
