local versionType = 0 --[[VERSIONTYPE]]
local build = 0 --[[BUILD]]
local versionId = 3258 --[[VERSIONID]]

local version = { 1, 4, 3 } -- {major, minor, patch}
local versionStr = table.join(version, ".")

return {
    versionId = versionId,
    versionType = versionType,
    version = versionStr,
    build = build
}
