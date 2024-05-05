import detail.exceptions as exceptions
import detail.machine_interface as machine_interface


def run(args):
    try:
        machine_interface.run(('cpplint', '--quiet', args.file))

    except exceptions.OperationFailed as e:
        raise exceptions.ConventionBreached('\n', e)
