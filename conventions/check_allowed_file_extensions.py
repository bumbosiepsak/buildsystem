from os.path import splitext
import detail.disk as disk
import detail.exceptions as exceptions
import importlib.util


def get_config_module():
    config_file = disk.file_in_tree(__file__, 'allowed_file_extensions.py')

    if config_file is None:
        raise exceptions.BadSetup('Config file missing: allowed_file_extensions.py')

    try:
        spec = importlib.util.spec_from_file_location("allowed_file_extensions", config_file)
        config_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(config_module)
        return config_module
    except ImportError as e:
        raise exceptions.BadSetup('Config file malformed: ', config_file, ' ', e)


def get_allowed_file_extensions(config_module):
    try:
        return config_module.ALLOWED_FILE_EXTENSIONS
    except AttributeError as e:
        raise exceptions.BadSetup('Config file malformed: ', config_module.__file__, ' ', e)


def run(args):
    allowed_file_extensions = get_allowed_file_extensions(get_config_module())

    if splitext(args.file)[1].lower() not in allowed_file_extensions:
        raise exceptions.ConventionBreached(
            'expected to have an allowed extension: ', ', '.join(allowed_file_extensions)
        )
