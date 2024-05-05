from yapf.yapflib.errors import YapfError
from yapf.yapflib.yapf_api import FormatFile
import detail.disk as disk
import detail.exceptions as exceptions


def is_garbled(file):
    style_config = disk.file_in_tree(__file__, 'py-format.ini')

    if style_config is None:
        raise exceptions.BadSetup('Config file missing: py-format.ini')

    try:
        (_, _, changed) = FormatFile(file, style_config=style_config, print_diff=True)
        return changed

    except YapfError as e:
        raise exceptions.OperationFailed(e)


def run(args):
    if is_garbled(args.file):
        raise exceptions.ConventionBreached()
