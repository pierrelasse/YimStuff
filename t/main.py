
import os as _os
from sys import argv as args

from Utils import Utils as _Utils
from TException import TException as _TException
from Config import Config as _Config
from Help import printHelp as _printHelp

def main():
    root = _Utils.normpath(__file__ + "/../..") # Path to project

    if not _os.path.isfile(root + "/t.bat"):
        raise _TException("Couldn't locate project directory")

    _Config.loadConfig(root)
    _Config.loadScriptsPath()

    if len(args) <= 1:
        _printHelp()

    else:
        cmd = args[1]

        _Utils.ensureDir(root + "/out")

        if cmd == "u" or cmd == "update":
            from commands.Update import run
            run(root)

        elif cmd == "r" or cmd == "release":
            from commands.Release import run
            run(root)

        else:
            _printHelp()

if __name__ == "__main__":
    try:
        main()

    except _TException as tex:
        print("Error: {}".format(tex.message()))

    # except Exception as ex:
    #     print("Exception: {}".format(ex))
