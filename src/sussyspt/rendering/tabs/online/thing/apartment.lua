local tasks = require("../../../tasks")
local values = require("../../../values")

function exports.register(tab2)
    local tab3 = SussySpt.rendering.newTab("Apartment")

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
        local tab4 = SussySpt.rendering.newTab("Preperations")

        function tab4.render()
            if ImGui.Button("Complete preps") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("HEIST_PLANNING_STAGE"), -1)
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Reset preps") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("HEIST_PLANNING_STAGE"), 0)
                end)
            end
        end

        tab3.sub[1] = tab4
    end

    do -- ANCHOR Extra
        local tab4 = SussySpt.rendering.newTab("Extra")

        function tab4.render()
            if ImGui.Button("Unlock replay screen") then
                tasks.addTask(function()
                    globals.set_int(values.g.apartment_replay, 27)
                end)
            end
            yu.rendering.tooltip("This allows you to play any heist you want and unlocks heist cancellation from Lester")

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

            ImGui.Spacing()

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

        tab3.sub[2] = tab4
    end

    do -- ANCHOR Cuts
        local tab4 = SussySpt.rendering.newTab("Cuts")

        function tab4.render()
            ImGui.Text("$15m cuts")
            ImGui.Text(" > Currently under development. Tutorial coming soon maybe")
            ImGui.Text(" > Fleeca currently works the best")
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

        tab3.sub[3] = tab4
    end

    tab2.sub[1] = tab3
end

return exports
