from os.path import splitext
import detail.disk as disk
import detail.exceptions as exceptions
import importlib.util


def get_config_module(filename, config_filename):
    config_path = disk.file_in_tree(filename, config_filename)

    if config_path is None:
        raise exceptions.BadSetup('Config file missing: {}'.format(config_filename))

    try:
        spec = importlib.util.spec_from_file_location("allowed_file_extensions", config_path)
        config_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(config_module)
        return config_module
    except ImportError as e:
        raise exceptions.BadSetup('Config file malformed: ', config_path, ' ', e)


def get_allowed_file_extensions(config_module):
    try:
        return config_module.ALLOWED_FILE_EXTENSIONS
    except AttributeError as e:
        raise exceptions.BadSetup('Config file malformed: ', config_module.__file__, ' ', e)


def run(args):
    allowed_file_extensions = get_allowed_file_extensions(get_config_module(args.file, 'allowed_file_extensions.py'))

    if splitext(args.file)[1].lower() not in allowed_file_extensions:
        raise exceptions.ConventionBreached(
            'expected to have an allowed extension: ', ', '.join(allowed_file_extensions)
        )
