import detail.machine_interface as machine_interface


def run(args):
    machine_interface.run(('clang-format', '-style=file', '-i', args.file))
