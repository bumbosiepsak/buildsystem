from yapf.yapflib.errors import YapfError
from yapf.yapflib.yapf_api import FormatFile
import detail.disk as disk
import detail.exceptions as exceptions


def is_garbled(filename, config_filename):
    config_path = disk.file_in_tree(filename, config_filename)

    if config_path is None:
        raise exceptions.BadSetup('Config file missing: {}'.format(config_filename))

    try:
        (_, _, changed) = FormatFile(filename, style_config=config_path, print_diff=True)
        return changed

    except YapfError as e:
        raise exceptions.OperationFailed(e)


def run(args):
    if is_garbled(args.file, 'py-format.ini'):
        raise exceptions.ConventionBreached()
