import os


def parent_directories(directory):
    parent = os.path.dirname(directory)
    while parent != directory:
        yield parent
        directory = parent
        parent = os.path.dirname(parent)


def file_in_tree(start, name):
    for directory in parent_directories(start):
        bingo = os.path.join(directory, name)
        if os.path.isfile(bingo):
            return bingo.absolute()

    return None
