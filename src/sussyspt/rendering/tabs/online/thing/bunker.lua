local values = require("sussyspt/values")
local tasks = require("sussyspt/tasks")
local cmm = require("sussyspt/util/cmm")

local exports = {
    name = "Bunker"
}

local function resupply()
    globals.set_int(values.g.resupply_base + 6, 1)
end

local function triggerResearch()
    local mpx = yu.mpx()
    stats.set_int(mpx.."GR_RESEARCH_PRODUCTION_TIME", 0)
    stats.set_int(mpx.."GR_RESEARCH_UPGRADE_EQUIPMENT_REDUCTION_TIME", 0)
    stats.set_int(mpx.."GR_RESEARCH_UPGRADE_STAFF_REDUCTION_TIME", 0)
end

local BUCg1 = values.g.fm + 21505 -- bunker unlocker cooldown global 1 (946764522)
local BUCg2 = values.g.fm + 21757 -- bunker unlocker cooldown global 2 ("GR_RESEARCH_CAPACITY")
local BUCg3 = values.g.fm + 21758 -- bunker unlocker cooldown global 3 ("GR_RESEARCH_PRODUCTION_TIME")
local BUCg4 = values.g.fm + 21759 -- bunker unlocker cooldown global 4 ("GR_RESEARCH_UPGRADE_EQUIPMENT_REDUCTION_TIME")
local BUAg1 = values.g.fm + 21761 -- bunker unlocker additional global 1 (1485279815)
local BUAg2 = values.g.fm + 21762 -- bunker unlocker additional global 2 (2041812011)

local function setResearch(a, b, c, d, e)
    globals.set_int(BUCg1, a)
    globals.set_int(BUCg2, b)
    for i = BUCg3, BUCg4, 1 do
        globals.set_int(i, c)
    end
    globals.set_int(BUAg1, d)
    globals.set_int(BUAg2, e)
end

function exports.load()
    exports.stage = nil
end

function exports.render()
    if ImGui.Button("Open computer") then tasks.addTask(cmm.bunker) end

    ImGui.Spacing()

    if ImGui.Button("Resupply") then tasks.addTask(resupply) end

    ImGui.SameLine()

    if ImGui.Button("Trigger research") then tasks.addTask(triggerResearch) end

    if SussySpt.dev then
        if ImGui.Button("Research A") then
            tasks.addTask(function()
                setResearch(1, 1, 1, 0, 0)
            end)
        end

        ImGui.SameLine()

        if ImGui.Button("Research B") then
            tasks.addTask(function()
                setResearch(60, 300000, 45000, 2, 1)
            end)
        end

        ImGui.SameLine()

        if ImGui.Button("Research C") then
            tasks.addTask(function()
                globals.set_int(2695900, 1)
            end)
        end
    end

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
end

return exports
