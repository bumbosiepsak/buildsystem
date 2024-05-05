from check_format_xml import is_garbled
import detail.exceptions as exceptions
import detail.text_files as text_files


def run(args):
    (garbled, file_wants) = is_garbled(args.file)
    if garbled:
        try:
            with open(args.file, 'w', encoding='utf-8', newline=text_files.get_line_ending(args.file)) as f:
                f.write(file_wants)

        except (IOError, ValueError) as e:
            raise exceptions.OperationFailed(e)
