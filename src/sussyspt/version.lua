local versionType = 0 --[[VERSIONTYPE]]
local build = 0 --[[BUILD]]
local versionId = 3287 --[[VERSIONID]]

local version = { 1, 4, 4 } -- {major, minor, patch}
local versionStr = table.join(version, ".")

return {
    versionId = versionId,
    versionType = versionType,
    version = versionStr,
    build = build
}
