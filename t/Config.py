
import os as _os
import json as _json
import shutil as _shutil

from TException import TException as _TException
from StaticStorage import StaticStorage as _StaticStorage
from Utils import Utils as _Utils

class Config:
    rConfigFilePath = "/config.json"

    def loadConfig(root):
        """Loads the config from the file"""

        path = root + Config.rConfigFilePath

        Config.ensureConfigFile(root)

        with open(path, "r") as f:
            _StaticStorage.config = _json.loads(f.read())

    def ensureConfigFile(root):
        """Ensures the existance of the local config file"""

        path = root + Config.rConfigFilePath

        if _os.path.isdir(path):
            raise _TException("Error: Config file is a directory")

        if not _os.path.isfile(path):
            _shutil.copy(root + "/t/assets/sample_config.json", path)

            from Help import printWelcome
            printWelcome()

    def loadScriptsPath():
        """Converts the scripts_path value from the config"""

        if _StaticStorage.config == None:
            return

        scriptsPath = _StaticStorage.config["scripts_path"]
        absolutePath = _os.path.expandvars(scriptsPath)
        path = _Utils.normpath(absolutePath)

        if not _os.path.isdir(path):
            raise _TException("Invalid scripts path: {}".format(path))

        _StaticStorage.scriptsPath = path
