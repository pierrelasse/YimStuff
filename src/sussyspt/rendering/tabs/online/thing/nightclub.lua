local tasks = require("sussyspt/tasks")

local exports = {
    name = "Nightclub"
}

-- Max safe value: Global_262145.f_24257 /* Tunable: NIGHTCLUBMAXSAFEVALUE */

local popularity
local popularityStat = "CLUB_POPULARITY"
local popularityMin = 0
local popularityMax = 1000

local payTimeStat = "CLUB_PAY_TIME_LEFT"

-- local storages = {
--     -- { Name, Description, Max }
--     [0] = { "Cargo and Shipments", "CEO Office Special Cargo Warehouse or Smuggler's Hangar", 50 },
--     { "Sporting Goods",          "Gunrunning Bunker",            10 },
--     { "S. A. Imports",           "M/C Cocaine Lockup",           10 },
--     { "Pharmaceutical Research", "M/C Methamphetamine Lab",      20 },
--     { "Organic Produce",         "M/C Weed Farm",                80 },
--     { "Printing & Copying",      "M/C Document Forgery Office",  60 },
--     { "Cash Creation",           "M/C Counterfeit Cash Factory", 40 }
-- }

local function tick()
    local mpx = yu.mpx()

    popularity = stats.get_int(mpx..popularityStat)
end

function exports.load()
    tasks.addTask(function()
        tick()
        exports.stage = nil
    end)
end

local function payNow()
    stats.set_int(yu.mpx()..payTimeStat, -1)
end

local function collectSafe()
    local scriptName = "am_mp_nightclub"
    if yu.is_script_running(scriptName) then
        locals.set_int(scriptName, 183 + 32 + 4, 3) -- Local_183.f_32->f_4
    else
        yu.notify(3, "You need to be in your nightclub", "Collect Safe")
    end
end

function exports.render()
    tasks.tasks.screen = tick

    ImGui.Text("Popularity")

    ImGui.SetNextItemWidth(50)
    local value, used = ImGui.InputInt("##popularity_input", popularity, popularityMin, popularityMax)
    SussySpt.pushDisableControls(ImGui.IsItemActive())
    if used then
        tasks.addTask(function()
            stats.set_int(yu.mpx()..popularityStat, math.min(math.max(value, popularityMin), popularityMax))
        end)
    end

    ImGui.SameLine()

    if ImGui.Button("Refill##popularity") then
        tasks.addTask(function() stats.set_int(yu.mpx()..popularityStat, popularityMax) end)
    end

    ImGui.Spacing()

    ImGui.Text("Safe")

    if ImGui.Button("Pay now##safe") then tasks.addTask(payNow) end

    ImGui.SameLine()

    if ImGui.Button("Collect##safe") then tasks.addTask(collectSafe) end
end

return exports
