import detail.exceptions as exceptions
import detail.text_files as text_files
import json


def get_file_is(filename):
    try:
        with open(filename, 'r', newline=text_files.NORMALIZED) as f:
            return f.read()

    except (IOError, ValueError) as e:
        raise exceptions.OperationFailed(e)


def get_file_wants(text):
    try:
        return json.dumps(json.loads(text), indent=text_files.INDENT, sort_keys=True) + text_files.UNIX

    except json.JSONDecodeError as e:
        raise exceptions.OperationFailed(e)


def is_garbled(filename):
    file_is = get_file_is(filename)
    file_wants = get_file_wants(file_is)
    return (file_is != file_wants, file_wants)


def run(args):
    if is_garbled(args.file)[0]:
        raise exceptions.ConventionBreached()
