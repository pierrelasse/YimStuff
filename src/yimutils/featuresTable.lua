function table.length(tbl)
    if type(tbl) == "table" then
        local i = 0
        for k, v in pairs(tbl) do
            i = i + 1
        end
        return i
    end
end

function table.unpck(tbl, endIndex, startIndex)
    startIndex = startIndex or 1
    endIndex = endIndex or #tbl
    if startIndex <= endIndex then
        return tbl[startIndex], table.unpck(tbl, endIndex, startIndex + 1)
    end
end

function table.join(tbl, delimiter)
    local result = ""
    if type(tbl) == "table" and type(delimiter) == "string" then
        for i, value in ipairs(tbl) do
            result = result..value
            if i < #tbl then
                result = result..delimiter
            end
        end
    end
    return result
end

function table.swap(tbl, index1, index2)
    if type(tbl) == "table" and type(index1) == "number" and type(index2) == "number" then
        tbl[index1], tbl[index2] = tbl[index2], tbl[index1]
        return tbl
    end
end

function table.compare(tbl, tbl2)
    if type(tbl) == "table" and type(tbl2) == "table" then
        for k, v in pairs(tbl) do
            if v ~= tbl2[k] then
                return false
            end
        end
        return true
    end
end
