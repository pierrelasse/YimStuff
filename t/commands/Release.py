
import os as _os
import shutil as _shutil

from OldFunctionsIDontKnowWhereToPut import convertLines, increaseSussySptVersionId
from StaticStorage import StaticStorage as _StaticStorage
from Minify import Minify as _Minify

def run(root):
    print("> Release")

    lines = convertLines(increaseSussySptVersionId(), {"versionType": _StaticStorage.VersionType.RELEASE})

    with open(root + "/out/SussySpt.lua", "w") as f:
        f.write("\n".join(lines))

        print("  > Created SussySpt.lua")

    with open(root + "/out/SussySpt.Merged.lua", "w") as f:
        from Merger import Merger

        f.write("\n".join(Merger.merge(_os.path.abspath("SussySpt.lua"), lines)))

        print("  > Created SussySpt.Merged.lua")

    _shutil.copy(root + "/yimutils.lua", root + "/out/yimutils.lua")
    print("  > Created yimutils.lua")

    if _Minify.canMinify():
        print("  > Minifying")

        def minify(file):
            if _Minify.minify(root + "/out/" + file):
                print("    > Minified " + file)

        minify("SussySpt.lua")
        minify("SussySpt.Merged.lua")
        minify("yimutils.lua")
