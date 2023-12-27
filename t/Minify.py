
import os as _os
import shutil as _shutil

from StaticStorage import StaticStorage as _StaticStorage

class Minify:
    ok: bool
    nodeJsPath: str
    minifyPath: str

    def getNodeJsPath() -> str:
        nodeJsPath = _StaticStorage.config.get("nodejs_path")

        if nodeJsPath == None:
            nodeJsPath = _shutil.which("node")

        if not _os.path.isfile(nodeJsPath):
            return False

        Minify.nodeJsPath = nodeJsPath
        return True

    def getMinifyPath():
        minifyPath = _StaticStorage.config.get("minify_path")

        # minify_path value was not set
        if minifyPath == None:
            return False

        # file does not exist
        if not _os.path.isfile(minifyPath):
            return False

        Minify.minifyPath = minifyPath
        return True

    def canMinify() -> bool:
        """Returns if the outputted files can be minified"""

        Minify.ok = Minify.getMinifyPath() and Minify.getNodeJsPath()
        return Minify.ok

    def minify(path) -> bool:
        """Minifies da file"""

        if Minify.ok != True:
            return False

        _os.system(f'"{Minify.nodeJsPath}" {Minify.minifyPath} {path}')

        return True
