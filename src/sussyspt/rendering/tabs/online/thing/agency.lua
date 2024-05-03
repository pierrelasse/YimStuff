local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")

local exports = {}

function exports.registerVIPContracts(parentTab)
    local tab = SussySpt.rendering.newTab("VIP Contracts")

    local vipcontract
    local vipcontracts = {
        [3] = "[Nightlife Leak] Investigation: The Nightclub",
        [4] = "[Nightlife Leak] Investigation: The Marina",
        [12] = "[Nightlife Leak] Nightlife Leak/Finale",
        [28] = "[High Society Leak] Investigation: The Country Club",
        [60] = "[High Society Leak] Investigation: Guest List",
        [124] = "[High Society Leak] High Society Leak/Finale",
        [252] = "[South Central Leak] Investigation: Davis",
        [508] = "[South Central Leak] Investigation: The Ballas",
        [2044] = "[South Central Leak] South Central Leak/Finale",
        [-1] = "Studio Time",
        [4092] = "Don't Fuck With Dre"
    }
    local vipcontractsIds = {
        3, 4, 12, 28, 60, 124, 252, 508, 2044, -1, 4092
    }

    local scriptName = "fm_mission_controller_2020"
    local scriptHash = joaat(scriptName)
    local scriptRunning = false

    local prepsCompleted = true
    local noCooldown = false
    local cannotInstantFinish = true

    local prepsStats = { "FIXER_GENERAL_BS", "FIXER_COMPLETED_BS", "FIXER_STORY_STRAND", "FIXER_STORY_COOLDOWN" }

    local function completePreps()
        local mpx = yu.mpx()
        for _, stat in pairs(prepsStats) do
            stats.set_int(mpx..stat, -1)
        end
    end

    local function arePrepsCompleted(mpx)
        for _, stat in pairs(prepsStats) do
            if stats.get_int(mpx..stat) ~= -1 then
                return false
            end
        end
        return true
    end

    local function tick()
        local mpx = yu.mpx()

        vipcontract = stats.get_int(mpx.."FIXER_STORY_BS")

        scriptRunning = yu.is_script_running_hash(scriptHash)
        if scriptRunning then
            cannotInstantFinish = not yu.is_host_of_script(scriptName)
        end

        prepsCompleted = arePrepsCompleted(mpx)
        noCooldown = globals.get_int(values.g.agency_cooldown) == 0
    end

    function tab.render()
        tasks.tasks.screen = tick

        if vipcontract == nil then
            ImGui.Text("Loading...")
            return
        end

        ImGui.BeginGroup()
        if ImGui.BeginListBox("##vipcontract_list", 410, 310) then
            for _, k in pairs(vipcontractsIds) do
                local v = vipcontracts[k]
                local selected = vipcontract == k
                if ImGui.Selectable(v, selected) and not selected then
                    tasks.addTask(function ()
                        local mpx = yu.mpx()
                        stats.set_int(mpx.."FIXER_STORY_BS", k)
                        if k == -1 then
                            stats.set_int(mpx.."FIXER_STORY_STRAND", -1)
                        end
                    end)
                end
            end

            ImGui.EndListBox()
        end
        ImGui.EndGroup()

        ImGui.SameLine()

        ImGui.BeginGroup()

        ImGui.BeginDisabled(prepsCompleted)
        if ImGui.Button("Complete preperations") then
            tasks.addTask(completePreps)
        end
        ImGui.EndDisabled()
        -- TODO: Reset preps

        ImGui.BeginDisabled(noCooldown)
        if ImGui.Button("Remove cooldown") then
            tasks.addTask(function()
                globals.set_int(values.g.agency_cooldown, 0)
            end)
        end
        ImGui.EndDisabled()

        ImGui.BeginDisabled(not scriptRunning or cannotInstantFinish)
        if ImGui.Button("Instant finish") then
            tasks.addTask(function()
                locals.set_int(scriptName, values.g.agency_instantfinish1, 51338752)
                locals.set_int(scriptName, values.g.agency_instantfinish2, 50)
            end)
        end
        ImGui.EndDisabled()

        ImGui.EndGroup()
    end

    parentTab.sub[1] = tab
end

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Agency")
    exports.registerVIPContracts(tab)
    parentTab.sub[#parentTab.sub + 1] = tab
end

return exports
