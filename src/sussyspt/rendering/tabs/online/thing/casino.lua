local tasks = require("../../../tasks")
local values = require("../../../values")
local addUnknownValue = require("./addUnknownValue")

function exports.register(tab2)
    local tab3 = SussySpt.rendering.newTab("Casino")

    do -- SECTION Slots
        local tab4 = SussySpt.rendering.newTab("Slots")

        tab3.sub[1] = tab4
    end -- !SECTION

    do -- SECTION Lucky wheel
        local tab4 = SussySpt.rendering.newTab("Lucky wheel")

        tab4.a = {}
        local a = tab4.a

        a.script = "casino_lucky_wheel"
        a.scriptHashed = joaat(a.script)

        a.prizes = {
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

        function a.tick()
            a.scriptRunning = yu.is_script_running_hash(a.scriptHashed)
        end

        function a.win(prize)
            if a.scriptRunning then
                locals.set_int(a.script, values.l.lucky_wheel_win_state + values.l.lucky_wheel_prize, prize)
                locals.set_int(a.script, values.l.lucky_wheel_win_state + values.l.lucky_wheel_prize_state, 11)
            end
            return a.scriptRunning
        end

        function tab4.render()
            tasks.tasks.online_thing_casino_lucky_wheel = a.tick

            if not a.scriptRunning then
                ImGui.Text("Please go near the lucky wheel at the Diamond Casino")
                return
            end

            ImGui.Text("Click on a prize to win it")

            local x, y = ImGui.GetContentRegionAvail()
            if ImGui.BeginListBox("##prizes", 150, y) then
                for k, v in pairs(a.prizes) do
                    if ImGui.Selectable(v, false) then
                        tasks.addTask(function()
                            a.win(k)
                        end)
                    end
                end
                ImGui.EndListBox()
            end
        end

        tab3.sub[2] = tab4
    end -- !SECTION

    do -- SECTION Story missions
        local tab4 = SussySpt.rendering.newTab("Story missions")

        local storyMissions = {
            [1048576] = "Loose Cheng",
            [1310785] = "House Keeping",
            [1310915] = "Strong Arm Tactics",
            [1311175] = "Play to Win",
            [1311695] = "Bad Beat",
            [1312735] = "Cashing Out"
        }
        local storyMissionIds = {
            [1048576] = 0,
            [1310785] = 1,
            [1310915] = 2,
            [1311175] = 3,
            [1311695] = 4,
            [1312735] = 5
        }
        local storyMission
        local function updateStoryMission()
            storyMission = stats.get_int(yu.mpx("VCM_FLOW_PROGRESS"))
            addUnknownValue(storyMissions, storyMission)
        end
        tasks.addTask(updateStoryMission)

        function tab4.render()
            local smr = yu.rendering.renderList(storyMissions, storyMission, "hbo_casinoresort_sm", "Story mission")
            if smr.changed then
                storyMission = smr.key
            end

            ImGui.SameLine()

            if ImGui.Button("Apply##sm") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("VCM_STORY_PROGRESS"), storyMissionIds[storyMission])
                    stats.set_int(yu.mpx("VCM_FLOW_PROGRESS"), storyMission)
                end)
            end
        end

        tab3.sub[3] = tab4
    end -- !SECTION

    tab2.sub[11] = tab3
end

return exports
