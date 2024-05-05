from lxml import etree
import detail.exceptions as exceptions
import detail.text_files as text_files


def get_file_is(filename):
    try:
        with open(filename, 'r', newline=text_files.NORMALIZED) as f:
            return f.read()

    except (IOError, ValueError) as e:
        raise exceptions.OperationFailed(e)


def get_file_wants(filename):
    try:
        xml = etree.parse(filename, etree.XMLParser(remove_blank_text=True, collect_ids=False))
        return etree.tostring(xml, pretty_print=True, xml_declaration=True, encoding='UTF-8').decode('utf-8')

    except etree.LxmlError as e:
        raise exceptions.OperationFailed(e)


def is_garbled(filename):
    file_is = get_file_is(filename)
    file_wants = get_file_wants(filename)
    return (file_is != file_wants, file_wants)


def run(args):
    if is_garbled(args.file)[0]:
        raise exceptions.ConventionBreached()
