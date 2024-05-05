'''
Expected release notes format (no trailing whitespace):
Version v1.2.3:
- ZUPAX-4567: A very useful change
    Further description of the very useful change
- ZUPAX-4567: Change delivered for amusement
    Further description of the change delivered for amusement

Version v1.2.2:
- ZUPAX-4567: Some older change
'''

from distutils.version import StrictVersion
import detail.exceptions as exceptions
import re

RELEASE_TITLE = re.compile(r'^Version v(?P<version>[0-9][.][0-9][.][0-9])$')
RELEASE_ITEM_TITLE = re.compile(r'^- [A-Z]+-[0-9]+ .+\S$')
RELEASE_ITEM_DESCRIPTION = re.compile(r'^[ ]{4}.+\S$')
VERSION_SCALE_BEGIN = '0.0.0'
INVALID_LINE_NUMBER = -1


def strip_newline(line):
    return line.rstrip('\r\n')


def match_release_section(textfile, line_no):
    line = strip_newline(textfile.readline())

    release_header = RELEASE_TITLE.match(line)
    if not release_header:
        raise exceptions.ConventionBreached('line: ', line_no, ' - expecting release title, got: "{}"'.format(line))

    for (line_no, line) in enumerate(textfile, line_no + 1):
        line = strip_newline(line)

        if not line:
            return (release_header['version'], line_no)

        if not RELEASE_ITEM_DESCRIPTION.match(line) and not RELEASE_ITEM_TITLE.match(line):
            raise exceptions.ConventionBreached(
                'line: ', line_no, ' - expecting release item title/description, got: "{}"'.format(line)
            )

    return (VERSION_SCALE_BEGIN, INVALID_LINE_NUMBER)


def run(args):
    try:
        with open(args.file, 'r') as f:
            (current_version, line_no) = match_release_section(f, 1)
            (previous_version, _) = match_release_section(f, line_no)

            if StrictVersion(current_version) <= StrictVersion(previous_version):
                raise exceptions.ConventionBreached(
                    'line 1: current version: ', current_version, ' not advanced from previous: ', previous_version
                )

    except (IOError, ValueError) as e:
        raise exceptions.OperationFailed(e)
