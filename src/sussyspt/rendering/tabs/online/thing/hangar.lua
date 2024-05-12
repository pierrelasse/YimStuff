local tasks = require("sussyspt/tasks")
local blipTp = require("sussyspt/util/blipTp")

local exports = {
    name = "Hangar"
}

local function resupply()
    stats.set_bool_masked(yu.mpx().."DLC22022PSTAT_BOOL3", true, 9)
end

local function tpTo() blipTp(569 --[[ radar_sm_hangar ]]) end

function exports.load()
    exports.stage = nil
end

function exports.render()
    if ImGui.Button("Teleport to hangar") then tasks.addTask(tpTo) end

    ImGui.Spacing()

    if ImGui.Button("Resupply cargo") then tasks.addTask(resupply) end
end

return exports
