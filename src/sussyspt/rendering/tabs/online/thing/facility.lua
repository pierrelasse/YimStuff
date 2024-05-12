local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")
local renderCutsSlider = require("sussyspt/util/renderCutsSlider")

local exports = {
    name = "Facility"
}

function exports.registerHeist(parentTab)
    local tab = SussySpt.rendering.newTab("Heist")

    local act
    local acts = {
        "Data Breaches",
        "Bogdan Problem",
        "Doomsday Scenario"
    }
    local actsData = {
        [-1] = {
            progress = 0,
            status = 0
        },
        {
            progress = 503,
            status = 229383
        },
        {
            progress = 240,
            status = 229378
        },
        {
            progress = 16368,
            status = 229380
        }
    }

    local prepsCompleted = true
    local actResetted = false

    local cuts = {}

    local function getAct(mpx)
        local expProgress = stats.get_int(mpx.."GANGOPS_FLOW_MISSION_PROG")
        -- local expStatus = stats.get_int(mpx.."GANGOPS_HEIST_STATUS")
        for k, v in pairs(actsData) do
            if k ~= -1 then
                if expProgress == v.progress
                -- and expStatus == v.status
                then
                    return k
                end
            end
        end
        return -1
    end

    local devStats = nil
    local function updateDevStats()
        devStats = {}

        local mpx = yu.mpx()
        for _, stat in pairs({
            "GANGOPS_FLOW_MISSION_PROG",
            "GANGOPS_HEIST_STATUS",
            "GANGOPS_FLOW_NOTIFICATIONS",
            "GANGOPS_FM_MISSION_PROG"
        }) do
            devStats[stat] = stats.get_int(mpx..stat)
        end
    end

    local function applyAct(index)
        local actData = actsData[index]
        if actData == nil then return end
        local mpx = yu.mpx()
        stats.set_int(mpx.."GANGOPS_FLOW_MISSION_PROG", actData.progress)
        stats.set_int(mpx.."GANGOPS_HEIST_STATUS", actData.status)
        stats.set_int(mpx.."GANGOPS_FLOW_NOTIFICATIONS", 1557)
        stats.set_int(mpx.."GANGOPS_FM_MISSION_PROG", 0)
    end

    local function cutsCallback(index, newValue)
        if index == 0 then
            cuts[index] = globals.set_int(values.g.facility_cutsSelf, newValue)
        else
            globals.set_int(values.g.facility_cuts + index, newValue)
        end
    end

    local function tick()
        local mpx = yu.mpx()

        act = getAct(mpx)

        prepsCompleted = stats.get_int(mpx.."GANGOPS_FM_MISSION_PROG") == -1

        actResetted =
            stats.get_int(mpx.."GANGOPS_FLOW_MISSION_PROG") == 0
            and stats.get_int(mpx.."GANGOPS_HEIST_STATUS") == 0

        -- allReady =
        -- globals.get_int(values.g.cayo_readyState(1)) == 1
        -- and globals.get_int(values.g.cayo_readyState(2)) == 1
        -- and globals.get_int(values.g.cayo_readyState(3)) == 1

        for i = 0, 4 do
            if i == 0 then
                cuts[i] = globals.get_int(values.g.facility_cutsSelf)
            else
                cuts[i] = globals.get_int(values.g.facility_cuts + i)
            end
        end
    end

    function tab.render()
        tasks.tasks.screen = tick

        if ImGui.TreeNodeEx("Planning") then
            if act ~= nil then
                ImGui.BeginGroup()
                if ImGui.BeginListBox("##act_list", 200, 126) then
                    for k, v in pairs(acts) do
                        local selected = act == k
                        if ImGui.Selectable(v, selected) and not selected then
                            tasks.addTask(function()
                                applyAct(k)
                            end)
                        end
                    end
                    ImGui.EndListBox()
                end
                ImGui.EndGroup()

                ImGui.SameLine()

                ImGui.BeginGroup()

                if ImGui.Button("Teleport to planning screen") then
                    tasks.addTask(function()
                        ENTITY.SET_ENTITY_COORDS_WITHOUT_PLANTS_RESET(
                            yu.ppid(), 352.723, 4874.619, -60.793, false, false, false, false)
                    end)
                end
                yu.rendering.tooltip("Use this while inside your facility")

                ImGui.SameLine()

                if ImGui.Button("Reload planning screen") then
                    tasks.addTask(function(rs)
                        locals.set_int("gb_gang_ops_planning", 182, 6) -- Release resources - 0x21431
                        rs:yield()
                        locals.set_int("gb_gang_ops_planning", 182, 3) -- Set show screen
                    end)
                end

                ImGui.BeginDisabled(prepsCompleted)
                if ImGui.Button("Complete preperations") then
                    tasks.addTask(function()
                        stats.set_int(yu.mpx().."GANGOPS_FM_MISSION_PROG", -1)
                    end)
                end
                ImGui.EndDisabled()

                ImGui.SameLine()

                ImGui.BeginDisabled(actResetted)
                if ImGui.Button("Reset act") then
                    tasks.addTask(function()
                        applyAct(-1)
                    end)
                end
                ImGui.EndDisabled()

                ImGui.EndGroup()

                if SussySpt.dev then
                    ImGui.Spacing()
                    ImGui.Separator()
                    ImGui.Text("Stats")
                    ImGui.SameLine()
                    if ImGui.SmallButton("Refresh") then
                        tasks.addTask(updateDevStats)
                    end

                    if devStats ~= nil then
                        for k, v in pairs(devStats) do
                            ImGui.Text(k..": "..v)
                        end
                    end
                end
            end
            ImGui.TreePop()
        end

        if ImGui.TreeNodeEx("Starting") then
            ImGui.Text("Cuts")
            renderCutsSlider(cuts, 0, cutsCallback)
            renderCutsSlider(cuts, 1, cutsCallback)
            renderCutsSlider(cuts, 2, cutsCallback)
            renderCutsSlider(cuts, 3, cutsCallback)
            renderCutsSlider(cuts, 4, cutsCallback)

            ImGui.TreePop()
        end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.register(tab)
    exports.registerHeist(tab)
end

return exports
