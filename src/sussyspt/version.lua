local versionType = 0 --[[VERSIONTYPE]]
local build = 0 --[[BUILD]]
local versionId = 3213

local version = { 1, 4, 0 } -- {major, minor, patch}
local versionStr = table.join(version, ".")

return {
    versionId = versionId,
    versionType = versionType,
    version = versionStr,
    build = build
}
