import detail.exceptions as exceptions
import detail.text_files as text_files


def is_garbled(filename):
    try:
        with open(filename, 'r', newline=text_files.AS_IS) as f:
            for (line_no, line) in enumerate(f, 1):
                if line.endswith(text_files.WINDOWS) or line.endswith(text_files.MAC):
                    return (True, line_no)
        return (False, None)

    except (IOError, ValueError) as e:
        raise exceptions.OperationFailed(e)


def run(args):
    (garbled, line_no) = is_garbled(args.file)
    if garbled:
        raise exceptions.ConventionBreached('line: ', line_no)
