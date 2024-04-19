local versionType = 0 --[[VERSIONTYPE]]
local build = 0 --[[BUILD]]
local versionId = 3213

local version = {1, 3, 18, 0} -- {generation, major, minor, patch}
local versionStr = table.join(version, ".")

local function compare(compare, to)
    return false -- TODO: Implement
end

return {
    versionId = versionId,
    versionType = versionType,
    version = versionStr,
    build = build,
    compare = compare
}
