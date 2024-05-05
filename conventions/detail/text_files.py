MAC = '\r'
WINDOWS = '\r\n'
UNIX = '\n'
MISSING = ''

AS_IS = ''
NORMALIZED = None

NEWLINE = UNIX
INDENT = '    '


def extract_line_ending(line):
    if line.endswith(WINDOWS):
        return WINDOWS
    elif line.endswith(MAC):
        return MAC
    elif line.endswith(UNIX):
        return UNIX
    else:
        return MISSING


def get_line_ending(filename):
    with open(filename, 'r', newline=AS_IS) as f:
        return extract_line_ending(f.readline())
