local tasks = require("../../../../tasks")
local values = require("../../../../values")
local addUnknownValue = require("./addUnknownValue")

local exports = {}

function exports.register(tab2)
    local tab3 = SussySpt.rendering.newTab("Auto Shop")

    local a = {
        heists = {
            [0] = "Union Depository",
            [1] = "The Superdollar Deal",
            [2] = "The Bank Contract",
            [3] = "The ECU Job",
            [4] = "The Prison Contract",
            [5] = "The Agency Deal",
            [6] = "The Lost Contract",
            [7] = "The Data Contract",
        },
        cooldowns = {}
    }

    do     -- ANCHOR Preperations
        local tab4 = SussySpt.rendering.newTab("Preperations")

        local function refresh()
            local mpx = yu.mpx()

            a.heist = stats.get_int(mpx.."TUNER_CURRENT")
            addUnknownValue(a.heists, a.heist)
        end
        tasks.addTask(refresh)

        function tab4.render()
            if ImGui.SmallButton("Refresh") then
                tasks.addTask(refresh)
            end

            ImGui.Separator()

            ImGui.PushItemWidth(360)
            local re = yu.rendering.renderList(a.heists, a.heist, "heist", "Heist")
            if re.changed then
                a.heist = re.key
                a.heistchanged = true
            end
            ImGui.PopItemWidth()

            ImGui.Spacing()

            if ImGui.Button("Apply##stats") then
                tasks.addTask(function()
                    local changes = 0
                    local mpx = yu.mpx()

                    -- Heist
                    if a.heistchanged then
                        changes = changes + 1
                        stats.set_int(mpx.."TUNER_GEN_BS", yu.shc(a.heist == 1, 4351, 12543))
                        stats.set_int(mpx.."TUNER_CURRENT", a.heist)
                    end

                    yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied")
                    for k, v in pairs(a) do
                        if tostring(k):endswith("changed") then
                            a[k] = nil
                        end
                    end
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Complete Preps") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("TUNER_GEN_BS"), -1)
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Reset Preps") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("TUNER_GEN_BS"), 12467)
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Reset contract") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."TUNER_GEN_BS", 8371)
                    stats.set_int(mpx.."TUNER_CURRENT", -1)
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Reset stats") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("TUNER_COUNT"), 0)
                    stats.set_int(yu.mpx("TUNER_EARNINGS"), 0)
                end)
            end
            yu.rendering.tooltip("This will set how many contracts you've done to 0 and how much you earned from it")

            if ImGui.Button("Instant finish") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller_2020") then
                        locals.set_int("fm_mission_controller_2020", values.g.autoshop_instantfinish1, 51338977)
                        locals.set_int("fm_mission_controller_2020", values.g.autoshop_instantfinish2, 101)
                    end
                end)
            end
        end

        tab3.sub[1] = tab4
    end

    do     -- ANCHOR Cooldowns
        local tab4 = SussySpt.rendering.newTab("Cooldowns")

        local function refreshCooldown(mpx, i)
            local cooldown = math.max(0,
                                      stats.get_int(mpx.."TUNER_CONTRACT"..i.."_POSIX") - os.time())

            a.cooldowns[i] = {
                a.heists[i],
                yu.format_seconds(cooldown)
            }
        end

        local function refresh()
            local mpx = yu.mpx()
            for i = 0, 7 do
                refreshCooldown(mpx, i)
            end
        end
        tasks.addTask(refresh)

        function tab4.render()
            if ImGui.SmallButton("Refresh") then
                tasks.addTask(refresh)
            end

            ImGui.Separator()

            if ImGui.BeginTable("cooldowns", 3, 3905) then
                ImGui.TableSetupColumn("Contract")
                ImGui.TableSetupColumn("Cooldown")
                ImGui.TableSetupColumn("Actions")
                ImGui.TableHeadersRow()

                local row = 0
                for k, v in pairs(a.cooldowns) do
                    ImGui.TableNextRow()

                    ImGui.PushID(row)

                    ImGui.TableSetColumnIndex(0)
                    ImGui.Text(v[1])

                    ImGui.TableSetColumnIndex(1)
                    ImGui.Text(v[2])

                    ImGui.TableSetColumnIndex(2)
                    if ImGui.Button("Clear##row_"..row) then
                        tasks.addTask(function()
                            stats.set_int(yu.mpx("TUNER_CONTRACT"..k.."_POSIX"), os.time())
                            refreshCooldown(yu.mpx(), k)
                        end)
                    end

                    ImGui.PopID()
                    row = row + 1
                end

                ImGui.EndTable()
            end
        end

        tab3.sub[2] = tab4
    end

    tab2.sub[3] = tab3
end

return exports
