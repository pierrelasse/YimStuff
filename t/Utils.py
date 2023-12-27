
import os as _os

class Utils:
    def normpath(path: str) -> str:
        """Normalizes a path and replaces backslashes with forward slashes"""

        return _os.path.normpath(path).replace("\\", "/")

    def ensureDir(dir: str) -> bool:
        """Ensures the existance of a directory"""

        if not _os.path.exists(dir):
            _os.mkdir(dir)
            return True
        else:
            return False

    def hasNext(chars: dict, index: int, str: str) -> bool:
        """Used in the merger thingy"""

        for k, v in enumerate(str):
            if chars.get(index + k) != v:
                return (False, 0)
        return (True, len(str))
