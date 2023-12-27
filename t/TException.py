
class TException(Exception):
    def __init__(self, *args: object) -> None:
        super().__init__(*args)

    def message(self) -> str:
        return self.args[0]
