import detail.exceptions as exceptions

LAST_CHARACTER = -2
UNIX_NORMALIZED = None


def is_garbled(filename):
    try:
        with open(filename, 'r', newline=UNIX_NORMALIZED) as f:
            for (line_no, line) in enumerate(f, 1):
                if len(line) > 1 and str.isspace(line[LAST_CHARACTER]):
                    return (True, line_no)
        return (False, None)

    except (IOError, ValueError) as e:
        raise exceptions.OperationFailed(e)


def run(args):
    (garbled, line_no) = is_garbled(args.file)
    if garbled:
        raise exceptions.ConventionBreached('line: ', line_no)
