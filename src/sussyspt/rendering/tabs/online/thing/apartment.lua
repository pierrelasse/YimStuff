local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")

local exports = {
    name = "Apartment"
}

local function registerHeists(parentTab)
    local heist
    local heists = {
        "The Freeca Job",
        "The Prison Break",
        "The Humane Labs Raid",
        "The Pacific Standard Job",
        "Series A Funding"
    }

    local cuts15m = {
        crew = function(v, two)
            globals.set_int(values.g.apartment_cuts_other + 1, 100 - (v * (two and 2 or 4)))
            globals.set_int(values.g.apartment_cuts_other + 2, v)
            if not two then
                globals.set_int(values.g.apartment_cuts_other + 3, v)
                globals.set_int(values.g.apartment_cuts_other + 4, v)
            end
        end,
        self = function(v)
            globals.set_int(values.g.apartment_cuts_self, v)
        end,

        values = {
            7453, 2142,
            1587, 1000, 2121
        }
    }

    local function renderPlanning()
        if ImGui.TreeNodeEx("Planning") then
            -- ImGui.BeginGroup()
            -- if ImGui.BeginListBox("##heists_list", 210, 144) then
            --     for k, v in pairs(heists) do
            --         if ImGui.Selectable(v, heist == k) and heist ~= k then
            --             heist = k
            --         end
            --     end
            --     ImGui.EndListBox()
            -- end
            -- ImGui.EndGroup()

            -- ImGui.SameLine()

            ImGui.BeginGroup()

            if ImGui.Button("Unlock replay screen") then
                tasks.addTask(function()
                    globals.set_int(values.g.apartment_replay, 27)
                end)
            end
            yu.rendering.tooltip("This allows you to play any heist you want and unlocks heist cancellation from Lester")

            if ImGui.Button("Complete preperations") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."HEIST_PLANNING_STAGE", -1)
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Reset preperations") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."HEIST_PLANNING_STAGE", 0)
                end)
            end

            if ImGui.Button("Unlock disabled heists") then
                tasks.addTask(function()
                    globals.set_int(values.g.apartment_heistUnlock, 31)
                end)
            end

            if ImGui.Button("Unlock all jobs") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."HEIST_SAVED_STRAND_0", globals.get_int(values.g.apartment_jobs_1))
                    stats.set_int(mpx.."HEIST_SAVED_STRAND_0_L", 5)
                    stats.set_int(mpx.."HEIST_SAVED_STRAND_1", globals.get_int(values.g.apartment_jobs_2))
                    stats.set_int(mpx.."HEIST_SAVED_STRAND_1_L", 5)
                    stats.set_int(mpx.."HEIST_SAVED_STRAND_2", globals.get_int(values.g.apartment_jobs_3))
                    stats.set_int(mpx.."HEIST_SAVED_STRAND_2_L", 5)
                    stats.set_int(mpx.."HEIST_SAVED_STRAND_3", globals.get_int(values.g.apartment_jobs_4))
                    stats.set_int(mpx.."HEIST_SAVED_STRAND_3_L", 5)
                    stats.set_int(mpx.."HEIST_SAVED_STRAND_4", globals.get_int(values.g.apartment_jobs_5))
                    stats.set_int(mpx.."HEIST_SAVED_STRAND_4_L", 5)
                end)
            end


            ImGui.EndGroup()

            ImGui.TreePop()
        end
    end

    local function renderStarting()
        if ImGui.TreeNodeEx("Starting") then
            if heist ~= nil then
                if ImGui.Button("$15m cuts") then
                    tasks.addTask(function(rs)
                        local value = cuts15m.values[heist]
                        if value == nil then return end
                        cuts15m.crew(v)
                        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201 --[[ ENTER / NUMPAD ENTER ]], 1)
                        rs:sleep(1000)
                        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 202 --[[ BACKSPACE / ESC ]], 1)
                        rs:sleep(1000)
                        cuts15m.self(v)
                        yu.notify(1, "Cuts done", "Online->Thing->Apartment")
                    end)
                end
            end

            if ImGui.Button("All ready") then
                tasks.addTask(function()
                    globals.set_int(2657921 + 1 + (1 * 463) + 266, 6)
                    globals.set_int(2657921 + 1 + (2 * 463) + 266, 6)
                    globals.set_int(2657921 + 1 + (3 * 463) + 266, 6)
                end)
            end

            ImGui.TreePop()
        end
    end

    local function renderIngame()
        if ImGui.TreeNodeEx("Ingame") then
            if ImGui.Button("Instant finish (solo)") then
                tasks.addTask(function()
                    local script = "fm_mission_controller"
                    if SussySpt.requireScript(script) then
                        locals.set_int(script, values.l.apartment_instantfinish1, 12)
                        locals.set_int(script, values.l.apartment_instantfinish2, 99999)
                        locals.set_int(script, values.l.apartment_instantfinish3, 99999)
                    end
                end)
            end

            ImGui.Text("Fleeca")

            if ImGui.Button("Skip hack##fleeca") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller") then
                        locals.set_int("fm_mission_controller", values.l.apartment_fleeca_hackstage, 7)
                    end
                end)
            end

            if ImGui.Button("Skip drill##fleeca") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller") then
                        locals.set_float("fm_mission_controller", values.l.apartment_fleeca_drillstage, 100)
                    end
                end)
            end

            ImGui.TreePop()
        end
    end

    local tab = SussySpt.rendering.newTab("Heists")

    function tab.render()
        renderPlanning()
        renderStarting()
        renderIngame()
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.register(tab)
    registerHeists(tab)
end

return exports
