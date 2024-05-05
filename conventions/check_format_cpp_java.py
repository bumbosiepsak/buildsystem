from xml.etree.ElementTree import fromstring
import detail.exceptions as exceptions
import detail.machine_interface as machine_interface


def run(args):
    output = machine_interface.run(('clang-format', '-style=file', '-output-replacements-xml', args.file))

    if output:
        for _ in fromstring(output).iter('replacement'):
            raise exceptions.ConventionBreached()
