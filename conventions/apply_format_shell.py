import detail.machine_interface as machine_interface


def run(args):
    machine_interface.run(('shfmt', '-w', '-i', '4', '-sr', args.file))
