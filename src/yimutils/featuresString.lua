function string.startswith(str, prefix)
    return (str == nil or prefix == nil or prefix == "") or str:sub(1, #prefix) == prefix
end

function string.endswith(str, ending)
    return (str == nil or ending == nil or ending == "") or str:sub(- #ending) == ending
end

function string.replace(str, what, with)
    if type(str) == "string" and type(what) == "string" and type(with) == "string" then
        return string.gsub(str, what, with)
    end
end

function string.uppercase(str)
    if type(str) == "string" then
        return string.upper(str)
    end
end

function string.lowercase(str)
    if type(str) == "string" then
        return string.lower(str)
    end
end

function string.contains(str, value)
    if type(str) == "string" and type(value) == "string" then
        return string.find(str, value, 1, true) ~= nil
    end
end

function string.containsregex(str, pattern)
    if type(str) == "string" then
        return string.match(str, pattern)
    end
end

function string.length(str)
    if type(str) == "string" then
        return string.len(str)
    end
end

function string.split(str, delimiter, max)
    if type(str) ~= "string" or str == "" then return {} end

    delimiter = delimiter or " "
    local result = {}
    local pattern = "(.-)"..delimiter:gsub("([^%w])", "%%%1")

    for part in string.gmatch(str, pattern) do
        table.insert(result, part)
        if max ~= nil and max - 1 > 0 then break end
    end

    local remainder = string.sub(str, #table.concat(result, delimiter) + #delimiter + 1)
    if remainder ~= "" then
        table.insert(result, remainder)
    end

    return result
end

function string.strip(str)
    if type(str) == "string" then
        return str:gsub("^%s*(.-)%s*$", "%1")
    end
end

function string.trim(str)
    if type(str) == "string" then
        return str:gsub("%s+", " ")
    end
end

function string.substring(str, startIndex, endIndex)
    if type(str) == "string" then
        return string.sub(str, startIndex, endIndex)
    end
end

function string.getCharacterAtIndex(str, index)
    if type(str) == "string" and type(index) == "number" and index >= 1 and index <= #str then
        return str:sub(index, index)
    end
end
