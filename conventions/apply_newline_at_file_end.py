from check_newline_at_file_end import is_garbled
import detail.exceptions as exceptions
import detail.text_files as text_files


def run(args):
    if is_garbled(args.file):
        try:
            with open(args.file, 'a', newline=text_files.get_line_ending(args.file)) as f:
                f.write('\n')

        except (IOError, ValueError) as e:
            raise exceptions.OperationFailed(e)
