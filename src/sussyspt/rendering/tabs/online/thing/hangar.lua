local tasks = require("sussyspt/tasks")
local cmm = require("sussyspt/util/cmm")
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

local cargoTotal

local function tick()
    local mpx = yu.mpx()

    cargoTotal = stats.get_int(mpx.."HANGAR_CONTRABAND_TOTAL")
end

function exports.render()
    tasks.tasks.screen = tick
    if cargoTotal == nil then return end

    if ImGui.Button("Open computer") then tasks.addTask(cmm.hangar) end

    if ImGui.Button("Teleport to hangar") then tasks.addTask(tpTo) end

    ImGui.Separator()

    ImGui.Text("Cargo")

    ImGui.Text("Total cargo")
    ImGui.SameLine()
    ImGui.ProgressBar((cargoTotal / 50), 250, 30, cargoTotal.."/400 ("..(cargoTotal * 2).."%)")

    if ImGui.Button("Source random crate") then tasks.addTask(resupply) end
end

return exports
