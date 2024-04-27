local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")

local exports = {}

function exports.registerVIPContracts(parentTab)
    local tab = SussySpt.rendering.newTab("VIP Contracts")

    local vipcontract
    local vipcontractSet
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

    local function completePreps(mpx)
        for _, stat in pairs({ "FIXER_GENERAL_BS", "FIXER_COMPLETED_BS", "FIXER_STORY_STRAND", "FIXER_STORY_COOLDOWN" }) do
            stats.set_int(mpx..stat, -1)
        end
    end

    local function tick()
        local mpx = yu.mpx()

        if vipcontractSet ~= nil then
            stats.set_int(mpx.."FIXER_STORY_BS", vipcontractSet)

            completePreps(mpx)

            if vipcontractSet == -1 then stats.set_int(mpx.."FIXER_STORY_STRAND", -1) end

            vipcontractSet = nil
        end

        vipcontract = stats.get_int(mpx.."FIXER_STORY_BS")

        scriptRunning = yu.is_script_running_hash(scriptHash)
    end

    function tab.render()
        tasks.tasks.screen = tick

        if vipcontract == nil then return end

        ImGui.Text("Vip Contracts")

        ImGui.BeginGroup()
        if ImGui.BeginListBox("##vipcontract_list", 410, 310) then
            for _, k in pairs(vipcontractsIds) do
                local v = vipcontracts[k]
                local selected = vipcontract == k
                if ImGui.Selectable(v, selected) and not selected then
                    vipcontractSet = k
                end
            end

            ImGui.EndListBox()
        end
        ImGui.EndGroup()

        ImGui.SameLine()

        ImGui.BeginGroup()

        if ImGui.Button("Remove cooldown") then
            tasks.addTask(function()
                globals.set_int(values.g.fm + values.g.agency_cooldown, 0)
            end)
        end

        ImGui.BeginDisabled(not scriptRunning)
        if ImGui.Button("Instant finish (solo)") then
            tasks.addTask(function()
                locals.set_int("fm_mission_controller_2020", values.g.agency_instantfinish1, 51338752)
                locals.set_int("fm_mission_controller_2020", values.g.agency_instantfinish2, 50)
            end)
        end
        ImGui.EndDisabled()

        ImGui.EndGroup()
    end

    parentTab.sub[1] = tab
end

function exports.registerExtra()
end

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Agency")

    exports.registerVIPContracts(tab)

    do -- ANCHOR Extra
        local tab2 = SussySpt.rendering.newTab("Extra")

        function tab2.render()
            ImGui.Spacing()

            if ImGui.Button("Remove cooldown") then
                tasks.addTask(function()

                end)
            end

            ImGui.Spacing()

            yu.rendering.renderCheckbox("$2m finale", "online_thing_agency_2mfinale", function(state)
                yu.rif(function(rs)
                    local p = values.g.fm + values.g.agency_payout
                    if state then
                        while yu.rendering.isCheckboxChecked("online_thing_agency_2mfinale") do
                            if SussySpt.in_online then
                                globals.set_int(p, 2500000)
                            end
                            rs:sleep(10)
                        end
                    else
                        globals.set_int(p, 1000000)
                    end
                end)
            end)
        end

        tab.sub[2] = tab2
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end -- !SECTION

return exports
