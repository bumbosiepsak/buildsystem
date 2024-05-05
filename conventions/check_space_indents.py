import detail.exceptions as exceptions
import re

INDENTATION = re.compile(r'^(\s*)\S?')
SINGLE_SPACE = ' '


def run(args):
    try:
        with open(args.file, 'r') as f:
            for (line_no, line) in enumerate(f, 1):
                indentation = INDENTATION.match(line[:-1]).group(1)
                if indentation.count(SINGLE_SPACE) != len(indentation):
                    raise exceptions.ConventionBreached('line: ', line_no)

    except (IOError, ValueError) as e:
        raise exceptions.OperationFailed(e)
