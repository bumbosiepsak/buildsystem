from check_no_trailing_whitespace import is_garbled
import detail.exceptions as exceptions
import detail.text_files as text_files


def run(args):
    if is_garbled(args.file)[0]:
        try:
            lines = []

            with open(args.file, 'r', newline=text_files.AS_IS) as f:
                for line in f:
                    lines.append(line.rstrip())
                    lines.append(text_files.extract_line_ending(line))

            with open(args.file, 'w', newline=text_files.AS_IS) as f:
                for line in lines:
                    f.write(line)

        except (IOError, ValueError) as e:
            raise exceptions.OperationFailed(e)
