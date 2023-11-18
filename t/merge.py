import os

def hasNext(chars: dict, index: int, str: str) -> bool:
    for k, v in enumerate(str):
        if chars.get(index + k) != v:
            return (False, 0)
    return (True, len(str))


def merge(file, lines):
    lines_out = []

    for line in lines:
        if len(line.strip()) == 0:
            continue

        chars = {k: v for k, v in enumerate(list(line))}
        chars_length = len(chars)

        in_string = False
        require: int = None
        requireP: int = None

        index = -1
        while True:
            index += 1
            if index >= chars_length:
                break

            if chars.get(index) == '"' and chars.get(index - 1) != "\\":
                in_string = not in_string

            elif not in_string:
                nextResult = hasNext(chars, index, 'require("')
                if nextResult[0]:
                    require = index
                    index += nextResult[1]
                    requireP = index

            if in_string and require != None:
                if chars.get(index) == '"' and chars.get(index + 1) == ")":
                    require_path = ""
                    for i in range(index - requireP):
                        require_path += chars.get(i + requireP)
                    index += 2

                    for i in range(index - require):
                        chars[i + require] = ""

                    content = ""
                    content_path = f"{os.path.dirname(file)}/{require_path}.lua"
                    if not os.path.isfile(content_path):
                        print(f"File {content_path} not found")
                        exit(-1)
                    with open(content_path, "r") as f:
                        content = '\n'.join(f.read().split("\n")[1:])

                    chars[require] = content[7:]

                    require = None

        line = ""
        for k in chars:
            v = chars[k]
            line += v
        lines_out += line + "\n"

    return lines_out
