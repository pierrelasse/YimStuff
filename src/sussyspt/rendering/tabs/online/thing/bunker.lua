local values = require("sussyspt/values")
local tasks = require("sussyspt/tasks")
local cmm = require("sussyspt/util/cmm")

local exports = {
    name = "Bunker"
}

local function resupply()
    globals.set_int(values.g.bunker_resupply_base + 6, 1)
end

local function instantSell()
    local scriptName = "gb_gunrunning"
    if SussySpt.requireScript(scriptName) then
        locals.set_int(scriptName, values.l.bunker_instant_sell, 0)
    end
end

-- local function triggerResearch()
--     local mpx = yu.mpx()
--     stats.set_int(mpx.."GR_RESEARCH_PRODUCTION_TIME", 0)
--     stats.set_int(mpx.."GR_RESEARCH_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
--     stats.set_int(mpx.."GR_RESEARCH_UPGRADE_STAFF_REDUCTION_TIME", 0)
-- end

function exports.load()
    exports.stage = nil
end

function exports.render()
    if ImGui.Button("Open computer") then tasks.addTask(cmm.bunker) end

    ImGui.Spacing()

    if ImGui.Button("Resupply [broken]") then tasks.addTask(resupply) end
    -- ImGui.SameLine()
    -- if ImGui.Button("Trigger research") then tasks.addTask(triggerResearch) end

    if ImGui.Button("Instant sell [broken (probably)]") then tasks.addTask(instantSell) end

    ImGui.Spacing()

    if ImGui.Button("Unlock shooting range") then
        tasks.addTask(function()
            local mpx = yu.mpx()
            stats.set_int(mpx.."SR_HIGHSCORE_1", 690)
            stats.set_int(mpx.."SR_HIGHSCORE_2", 1860)
            stats.set_int(mpx.."SR_HIGHSCORE_3", 2690)
            stats.set_int(mpx.."SR_HIGHSCORE_4", 2660)
            stats.set_int(mpx.."SR_HIGHSCORE_5", 2650)
            stats.set_int(mpx.."SR_HIGHSCORE_6", 450)
            stats.set_int(mpx.."SR_TARGETS_HIT", 269)
            stats.set_int(mpx.."SR_WEAPON_BIT_SET", -1)
            stats.set_bool(mpx.."SR_TIER_1_REWARD", true)
            stats.set_bool(mpx.."SR_TIER_3_REWARD", true)
            stats.set_bool(mpx.."SR_INCREASE_THROW_CAP", true)
        end)
    end

    if ImGui.Button("Some other unlocks idk") then
        tasks.addTask(function()
            local mpx = yu.mpx()
            for i = 0, 63 do
                stats.set_bool_masked(mpx.."DLCGUNPSTAT_BOOL0", true, i, mpx)
                stats.set_bool_masked(mpx.."DLCGUNPSTAT_BOOL1", true, i, mpx)
                stats.set_bool_masked(mpx.."DLCGUNPSTAT_BOOL2", true, i, mpx)
                stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL0", true, i, mpx)
                stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL1", true, i, mpx)
                stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL2", true, i, mpx)
                stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL3", true, i, mpx)
                stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL4", true, i, mpx)
                stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL5", true, i, mpx)
            end
            local bitSize = 8
            for i = 0, 64 / bitSize - 1 do
                stats.set_masked_int(mpx.."GUNRPSTAT_INT0", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT1", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT2", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT3", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT4", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT5", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT6", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT7", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT8", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT9", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT10", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT11", -1, i * bitSize, bitSize)
                stats.set_masked_int(mpx.."GUNRPSTAT_INT12", -1, i * bitSize, bitSize)
            end
        end)
    end
end

return exports
