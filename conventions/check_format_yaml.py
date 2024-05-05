import detail.disk as disk
import detail.exceptions as exceptions
import detail.text_files as text_files
import ruamel.yaml as yaml


def get_style_config(config_filename):
    config_path = disk.file_in_tree(__file__, config_filename)

    if config_path is None:
        raise exceptions.BadSetup('Config file missing: {}'.format(config_filename))

    try:
        with open(config_path, 'r') as f:
            return yaml.YAML().load(f)

    except (IOError, ValueError, yaml.YAMLError) as e:
        raise exceptions.BadSetup('Config file malformed: {}'.format(config_filename))


def get_file_is(filename):
    try:
        with open(filename, 'r', newline=text_files.NORMALIZED) as f:
            return f.read()

    except (IOError, ValueError) as e:
        raise exceptions.OperationFailed(e)


def get_file_wants(text, style_config):
    result = yaml.compat.StringIO()

    try:
        yaml.round_trip_dump(yaml.round_trip_load(text), result, **style_config)

    except yaml.YAMLError as e:
        raise exceptions.OperationFailed(e)

    except TypeError as e:
        raise exceptions.BadSetup('Config file with unknown option: {!s}'.format(e))

    return result.getvalue()


def is_garbled(filename):
    file_is = get_file_is(filename)
    file_wants = get_file_wants(file_is, get_style_config('ruamel-format.yml'))
    return (file_is != file_wants, file_wants)


def run(args):
    if is_garbled(args.file)[0]:
        raise exceptions.ConventionBreached()
