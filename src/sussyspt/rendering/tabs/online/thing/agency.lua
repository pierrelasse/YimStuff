local tasks = require("../../../../tasks")
local values = require("../../../../values")

function exports.register(tab2)
    local tab3 = SussySpt.rendering.newTab("Agency")

    do -- ANCHOR Preperations
        local tab4 = SussySpt.rendering.newTab("Preperations")

        local a = {
            vipcontracts = {
                [3] = "Nightlife Leak -> Investigation: The Nightclub",
                [4] = "Nightlife Leak -> Investigation: The Marina",
                [12] = "Nightlife Leak -> Nightlife Leak/Finale",
                [28] = "High Society Leak -> Investigation: The Country Club",
                [60] = "High Society Leak -> Investigation: Guest List",
                [124] = "High Society Leak -> High Society Leak/Finale",
                [252] = "South Central Leak -> Investigation: Davis",
                [508] = "South Central Leak -> Investigation: The Ballas",
                [2044] = "South Central Leak -> South Central Leak/Finale",
                [-1] = "Studio Time",
                [4092] = "Don't Fuck With Dre"
            },
            vipcontractssort = {
                [1] = 3,
                [2] = 4,
                [3] = 12,
                [4] = 28,
                [5] = 60,
                [6] = 124,
                [7] = 252,
                [8] = 508,
                [9] = 2044,
                [10] = -1,
                [11] = 4092
            }
        }

        local function refresh()
            local mpx = yu.mpx()

            a.vipcontract = stats.get_int(mpx.."FIXER_STORY_BS")
        end
        tasks.addTask(refresh)

        function tab4.render()
            if ImGui.SmallButton("Refresh") then
                tasks.addTask(refresh)
            end

            ImGui.Separator()

            local re = yu.rendering.renderList(a.vipcontracts, a.vipcontract, "vipcontract", "The Dr. Dre VIP Contract", a.vipcontractssort)
            if re.changed then
                a.vipcontract = re.key
                a.vipcontractchanged = true
            end

            ImGui.Spacing()

            if ImGui.Button("Apply##stats") then
                tasks.addTask(function()
                    local changes = 0

                    -- The Dr. Dre VIP Contract
                    if a.vipcontractchanged then
                        changes = changes + 1

                        stats.set_int(yu.mpx("FIXER_STORY_BS"), a.vipcontract)

                        for k, v in pairs({"FIXER_GENERAL_BS","FIXER_COMPLETED_BS","FIXER_STORY_STRAND","FIXER_STORY_COOLDOWN"}) do
                            stats.set_int(yu.mpx(v), -1)
                        end

                        if a.vipcontract == -1 then
                            stats.set_int(yu.mpx("FIXER_STORY_STRAND"), -1)
                        end
                    end

                    yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied.", "Agency")
                    for k, v in pairs(a) do
                        if tostring(k):endswith("changed") then
                            a[k] = nil
                        end
                    end
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Complete preps") then
                tasks.addTask(function()
                    for k, v in pairs({"FIXER_GENERAL_BS","FIXER_COMPLETED_BS","FIXER_STORY_BS","FIXER_STORY_COOLDOWN"}) do
                        stats.set_int(yu.mpx(v), -1)
                    end
                end)
            end
        end

        tab3.sub[1] = tab4
    end

    do -- ANCHOR Extra
        local tab4 = SussySpt.rendering.newTab("Extra")

        function tab4.render()
            if ImGui.Button("Instant finish (solo)") then
                tasks.addTask(function()
                    locals.set_int("fm_mission_controller_2020", values.g.agency_instantfinish1, 51338752)
                    locals.set_int("fm_mission_controller_2020", values.g.agency_instantfinish2, 50)
                end)
            end

            ImGui.Spacing()

            if ImGui.Button("Remove cooldown") then
                tasks.addTask(function()
                    globals.set_int(values.g.fm + values.g.agency_cooldown, 0)
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

        tab3.sub[2] = tab4
    end

    tab2.sub[2] = tab3
end -- !SECTION

return exports
