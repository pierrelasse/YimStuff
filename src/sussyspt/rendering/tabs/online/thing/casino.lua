local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")
local addUnknownValue = require("./addUnknownValue")

local exports = {
    name = "Casino"
}

function exports.registerManage(parentTab)
    local tab = SussySpt.rendering.newTab("Manage")

    local function tpTo()
        PED.SET_PED_COORDS_KEEP_VEHICLE(yu.ppid(), 925.2, 46.5, 80.4)
    end

    function tab.render()
        if ImGui.Button("Teleport to the Diamond Casino") then tasks.addTask(tpTo) end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.registerSlots(parentTab)
    local tab           = SussySpt.rendering.newTab("Slots")

    local scriptName    = "casino_slots"
    local scriptHash    = joaat(scriptName)
    local scriptRunning = false


    local slots_random_results_table = 1348


    local function tick()
        scriptRunning = yu.is_script_running_hash(scriptHash)

        if not scriptRunning then return end

        local shouldRig = yu.rendering.isCheckboxChecked("hbo_casinoresort_rsm")

        local needsRun = false

        if shouldRig then
            for slots_iter = 3, 195, 1 do
                if slots_iter ~= 67 and slots_iter ~= 132 then
                    if locals.get_int("casino_slots", (slots_random_results_table) + (slots_iter)) ~= 6 then
                        needsRun = true
                    end
                end
            end
        else
            local sum = 0
            for slots_iter = 3, 195, 1 do
                if slots_iter ~= 67 and slots_iter ~= 132 then
                    sum = sum + locals.get_int(scriptName, (slots_random_results_table) + (slots_iter))
                end
            end
            needsRun = sum == 1146
        end

        if needsRun then
            for slots_iter = 3, 195, 1 do
                if slots_iter ~= 67 and slots_iter ~= 132 then
                    local slot_result = 6
                    if shouldRig == false then
                        math.randomseed(os.time() + slots_iter)
                        slot_result = math.random(0, 7)
                    end
                    locals.set_int(scriptName, (slots_random_results_table) + (slots_iter), slot_result)
                end
            end
        end
    end

    function tab.render()
        tasks.tasks.screen = tick

        if not scriptRunning then
            ImGui.Text("Please head over to a slot machine at the Diamond Casino")
            return
        end

        ImGui.Text("Tip: Enable, spin, disable, spin, etc. to not get blocked")
        yu.rendering.renderCheckbox("Rig slot machines", "hbo_casinoresort_rsm")
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.registerLuckyWheel(parentTab)
    local tab = SussySpt.rendering.newTab("Lucky Wheel")

    tab.scriptName = "casino_lucky_wheel"
    tab.scriptHash = joaat(tab.scriptName)

    tab.prizes = {
        [0] = "CLOTHING (1)",
        [1] = "2,500 RP",
        [2] = "$20,000",
        [3] = "10,000 Chips",
        [4] = "DISCOUNT %",
        [5] = "5,000 RP",
        [6] = "$30,000",
        [7] = "15,000 Chips",
        [8] = "CLOTHING (2)",
        [9] = "7,500 RP",
        [10] = "20,000 Chips",
        [11] = "MYSTERY",
        [12] = "CLOTHING (3)",
        [13] = "10,000 RP",
        [14] = "$40,000",
        [15] = "25,000 Chips",
        [16] = "CLOTHING (4)",
        [17] = "15,000 RP",
        [18] = "VEHICLE"
    }

    function tab.tick()
        tab.scriptRunning = yu.is_script_running_hash(tab.scriptHash)
    end

    function tab.win(prize)
        if tab.scriptRunning then
            locals.set_int(tab.scriptName, values.l.lucky_wheel_win_state + values.l.lucky_wheel_prize, prize)
            locals.set_int(tab.scriptName, values.l.lucky_wheel_win_state + values.l.lucky_wheel_prize_state, 11)
        end
        return tab.scriptRunning
    end

    function tab.render()
        tasks.tasks.screen = tab.tick

        if not tab.scriptRunning then
            ImGui.Text("Please head over to the Lucky Wheel at the Diamond Casino")
            return
        end

        ImGui.Text("Click on a prize to win it")

        local _, y = ImGui.GetContentRegionAvail()
        if ImGui.BeginListBox("##prizes", 150, y) then
            for k, v in pairs(tab.prizes) do
                if ImGui.Selectable(v, false) then
                    tasks.addTask(function()
                        tab.win(k)
                    end)
                end
            end
            ImGui.EndListBox()
        end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.registerStoryMissions(parentTab)
    local tab = SussySpt.rendering.newTab("Story missions")

    local storyMission
    local storyMissionSet
    local storyMissions = {
        [0] = "Loose Cheng",
        [1] = "House Keeping",
        [2] = "Strong Arm Tactics",
        [3] = "Play to Win",
        [4] = "Bad Beat",
        [5] = "Cashing Out"
    }

    local function tick()
        local mpx = yu.mpx()

        if storyMissionSet ~= nil then
            stats.set_int(mpx.."VCM_STORY_PROGRESS", storyMissionSet)
            stats.set_int(mpx.."VCM_FLOW_PROGRESS", 1311695)
            storyMissionSet = nil
        end

        storyMission = stats.get_int(mpx.."VCM_STORY_PROGRESS")
        addUnknownValue(storyMissions, storyMission)
    end

    function tab.render()
        tasks.tasks.screen = tick

        if storyMission == nil then
            ImGui.Text("Loading...")
            return
        end

        if ImGui.BeginListBox("##storymission_list", 200, 170) then
            for k, v in pairs(storyMissions) do
                local selected = storyMission == k
                if ImGui.Selectable(v, selected) and not selected then
                    storyMissionSet = k
                end
            end

            ImGui.EndListBox()
        end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.register(tab)
    exports.registerManage(tab)
    exports.registerSlots(tab)
    exports.registerLuckyWheel(tab)
    exports.registerStoryMissions(tab)
end

return exports
