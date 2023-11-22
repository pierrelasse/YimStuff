import os
import sys
import time
import json
import shutil

def normpath(path):
    return os.path.normpath(path).replace("\\", "/")

def printHelp():
    print("<help>")

def convertLines(lines, config={}):
    lineCount = len(lines)

    if lineCount <= 7 or not isinstance(config, dict):
        raise Exception("Invalid args")

    type = lines[0].split(" ")
    if len(type) < 2:
        raise Exception("Content has no type specified")
    type = type[1]

    if type == "SussySpt":
        lines[4] = lines[4].replace("0--[[VERSIONTYPE]]", str(config["versionType"]))
        lines[5] = lines[5].replace("0--[[BUILD]]", str(time.time()).split(".")[0])

    elif type == "yimutils":
        pass

    else:
        raise Exception("Content has an invalid type")

    return lines

def increaseSussySptVersionId():
    with open("SussySpt.lua", "r+") as f:
        lines = f.read().split("\n")
        if len(lines) >= 4:
            lines[3] = "    versionid = {},".format(int(lines[3].split()[-1][:-1]) + 1)
            f.seek(0)
            f.write("\n".join(lines))
            f.truncate()
        return lines

def ensureDir(dir):
    if not os.path.exists(dir):
        os.mkdir(dir)

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
            ensureDir(root + "/out")

            should_merge = False if len(args) <= 2 else (args[2] == "m" or args[2] == "merge")

            merge = None
            if should_merge:
                from merge import merge as _merge
                merge = _merge

            with open(root + "/out/SussySpt.luao", "w") as f:
                lines = convertLines(increaseSussySptVersionId(), {"versionType": 2})

                if should_merge:
                    print("merging")
                    lines = merge(os.path.abspath("SussySpt.lua"), lines)

                f.write("\n".join(lines))

            shutil.copy(root + "/out/SussySpt.luao", cfg["scriptsPath"] + "/SussySpt.lua")
            if not should_merge:
                shutil.copy(root + "/yimutils.lua", cfg["scriptsPath"] + "/yimutils.lua")

        else:
            printHelp()

if __name__ == "__main__":
    main()
