local function load() yu = require("../yimutils/main") end

local success, result = pcall(load)
local err
if not success then
    err = result
elseif yu == nil then
    err = "The returned value was nil"
elseif type(yu) ~= "table" then
    err = "The returned value was not a table but from type "..type(yu)
end
if err ~= nil then
    log.warning("Error: Could not load yimutils: "..err)
    return
end

return true
