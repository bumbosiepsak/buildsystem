class OperationFailed(Exception):
    pass


class BadSetup(OperationFailed):
    pass


class ConventionBreached(Exception):
    def __init__(self, *why):
        self.why = ''.join(map(str, why))

    def __str__(self):
        return self.why
