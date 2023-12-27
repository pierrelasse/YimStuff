
from time import time as _time

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
        lines[5] = lines[5].replace("0--[[BUILD]]", str(_time()).split(".")[0])

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
