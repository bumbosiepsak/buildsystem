import detail.machine_interface as machine_interface


def run(args):
    machine_interface.run(('cmake-format', '--in-place', args.file))
