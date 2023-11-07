import os
import sys
import time
import json
import shutil

def normpath(path):
    return os.path.normpath(path).replace("\\", "/")

def printHelp():
    print("<help>")

def main():
    args = sys.argv
    root = normpath(__file__ + "/../..")
    configFile = root + "/config.json"

    if not os.path.isfile(configFile):
        shutil.copy(root + "/t/sample_config.json", configFile)
        print("Copied sample config")

    with open(configFile, "r") as f:
        config = json.loads(f.read())

    cfg = {
        "scriptsPath": normpath(os.path.expandvars(config["scripts_path"]))
    }

    if not os.path.isdir(cfg["scriptsPath"]):
        print("Invalid scripts path [{}]".format(cfg["scriptsPath"]))
        return

    if len(args) <= 1:
        printHelp()
    else:
        cmd = args[1]

        if cmd == "u" or cmd == "update":
            shutil.copy(root + "/yimutils.lua", cfg["scriptsPath"] + "/yimutils.lua")

            with open("SussySpt.lua", "r+") as f:
                lines = f.readlines()
                if len(lines) >= 3:
                    lines[2] = f"    versionid = {int(lines[2].split()[-1][:-1]) + 1},\n"
                    f.seek(0)
                    f.writelines(lines)
                    f.truncate()

                    with open(cfg["scriptsPath"] + "/SussySpt.lua", "w") as f2:
                        if len(lines) >= 5:
                            lines[3] = lines[3].replace("0--[[VERSIONTYPE]]", "2")
                            lines[4] = lines[4].replace("0--[[BUILD]]", str(time.time()).split(".")[0])
                            f2.writelines(lines)
        else:
            printHelp()

if __name__ == "__main__":
    main()
