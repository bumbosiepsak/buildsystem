import detail.exceptions as exceptions
import detail.machine_interface as machine_interface


def run(args):
    output = machine_interface.run(('shfmt', '-l', '-i', '4', '-sr', args.file))

    if output:
        raise exceptions.ConventionBreached()
