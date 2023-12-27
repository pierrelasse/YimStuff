
import shutil as _shutil

from OldFunctionsIDontKnowWhereToPut import convertLines, increaseSussySptVersionId
from StaticStorage import StaticStorage as _StaticStorage

def run(root):
    with open(root + "/out/SussySpt.lua", "w") as f:
        lines = convertLines(increaseSussySptVersionId(), {"versionType": _StaticStorage.VersionType.DEV})
        f.write("\n".join(lines))

    scriptsPath = _StaticStorage.scriptsPath
    _shutil.copy(root + "/out/SussySpt.lua", scriptsPath + "/SussySpt.lua")
    _shutil.copy(root + "/yimutils.lua", scriptsPath + "/yimutils.lua")

    print("> Update - Success!", end="")
