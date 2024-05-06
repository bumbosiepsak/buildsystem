from yapf.yapflib.errors import YapfError
from yapf.yapflib.yapf_api import FormatFile
import detail.disk as disk
import detail.exceptions as exceptions


def run(args):
    style_config = disk.file_in_tree(args.file, 'py-format.ini')

    if style_config is None:
        raise exceptions.BadSetup('Config file missing: py-format.ini')

    try:
        FormatFile(args.file, style_config=style_config, in_place=True)

    except YapfError as e:
        raise exceptions.OperationFailed(e)
