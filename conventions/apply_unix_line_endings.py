from check_unix_line_endings import is_garbled
import detail.exceptions as exceptions
import detail.text_files as text_files


def run(args):
    if is_garbled(args.file)[0]:
        try:
            with open(args.file, 'r') as f:
                file_is = f.read()

            with open(args.file, 'w', newline=text_files.NEWLINE) as f:
                f.write(file_is)

        except (IOError, ValueError) as e:
            raise exceptions.OperationFailed(e)
