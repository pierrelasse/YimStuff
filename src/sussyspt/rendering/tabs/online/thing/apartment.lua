local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")

local exports = {
    name = "Apartment"
}

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Apartment")

    local a = {
        cuts15m = {
            heists = {
                ["The Freeca Job"] = 7453,
                ["The Prison Break"] = 2142,
                ["The Humane Labs Raid"] = 1587,
                ["The Pacific Standard Job"] = 1000,
                ["Series A Funding"] = 2121
            },
            set = {
                crew = function(v)
                    globals.set_int(values.g.apartment_cuts_other + 1, 100 - (v * 4))
                    globals.set_int(values.g.apartment_cuts_other + 2, v)
                    globals.set_int(values.g.apartment_cuts_other + 3, v)
                    globals.set_int(values.g.apartment_cuts_other + 4, v)
                end,
                self = function(v)
                    globals.set_int(values.g.apartment_cuts_self, v)
                end
            }
        }
    }

    do -- ANCHOR Preperations
        local tab2 = SussySpt.rendering.newTab("Preperations")

        function tab2.render()
            if ImGui.Button("Complete preperations") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("HEIST_PLANNING_STAGE"), -1)
                end)
            end

            if ImGui.Button("Reset preperations") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("HEIST_PLANNING_STAGE"), 0)
                end)
            end
        end

        tab.sub[1] = tab2
    end

    do -- ANCHOR Extra
        local tab2 = SussySpt.rendering.newTab("Extra")

        function tab2.render()
            if ImGui.Button("Unlock replay screen") then
                tasks.addTask(function()
                    globals.set_int(values.g.apartment_replay, 27)
                end)
            end
            yu.rendering.tooltip("This allows you to play any heist you want and unlocks heist cancellation from Lester")

            ImGui.SameLine()

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

            ImGui.Spacing()

            if ImGui.Button("All ready") then
                tasks.addTask(function()
                    globals.set_int(2657921 + 1 + (1 * 463) + 266, 6)
                    globals.set_int(2657921 + 1 + (2 * 463) + 266, 6)
                    globals.set_int(2657921 + 1 + (3 * 463) + 266, 6)
                end)
            end

            ImGui.SameLine()

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

            ImGui.Separator()

            ImGui.Text("Fleeca")

            ImGui.SameLine()

            if ImGui.Button("Skip hack##fleeca") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller") then
                        locals.set_int("fm_mission_controller", values.l.apartment_fleeca_hackstage, 7)
                    end
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Skip drill##fleeca") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller") then
                        locals.set_float("fm_mission_controller", values.l.apartment_fleeca_drillstage, 100)
                    end
                end)
            end
        end

        tab.sub[2] = tab2
    end

    do -- ANCHOR $15m cuts
        local tab2 = SussySpt.rendering.newTab("$15m cuts")

        tab2.should_display = SussySpt.getDev

        function tab2.render()
            ImGui.Text("> Very buggy. Just use silentnight for now")
            ImGui.Spacing()

            if a.cuts15mactive ~= true then
                for k, v in pairs(a.cuts15m.heists) do
                    if ImGui.Button(k) then
                        a.cuts15mactive = true
                        yu.rif(function(rs)
                            a.cuts15m.set.crew(v)

                            a.cuts15m.set.self(v)

                            a.cuts15mactive = nil
                        end)
                    end
                end
            else
                ImGui.Text("Applying. Please wait")
            end
        end

        tab.sub[3] = tab2
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

return exports
