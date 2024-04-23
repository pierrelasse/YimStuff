local tasks = require("../../../tasks")
local values = require("../../../values")

function exports.register(tab)
    local tab2 = SussySpt.rendering.newTab("Stats")

    do -- ANCHOR Other
        local tab3 = SussySpt.rendering.newTab("Other")

        local a = {
            stats = {
                -- {Stat, Type, Display}
                { "MPPLY_IS_CHEATER",         1, "Is cheater" },
                { "MPPLY_ISPUNISHED",         1, "Is punished" },
                { "MPPLY_IS_HIGH_EARNER",     1, "High earner" },
                { "MPPLY_WAS_I_BAD_SPORT",    1, "Was i badsport" },
                { "MPPLY_CHAR_IS_BADSPORT",   1, "Is character badsport" },

                { "MPPLY_OVERALL_CHEAT",      2, "Overall cheat" },
                { "MPPLY_OVERALL_BADSPORT",   2, "Overall badsport" },
                { "MPPLY_PLAYERMADE_TITLE",   2, "Playermade title" },
                { "MPPLY_PLAYERMADE_DESC",    2, "Playermade description" },

                { "MPPLY_GRIEFING",           2, "Reports -> Griefing" },
                { "MPPLY_EXPLOITS",           2, "Reports -> Exploits" },
                { "MPPLY_GAME_EXPLOITS",      2, "Reports -> Game exploits" },
                { "MPPLY_TC_ANNOYINGME",      2, "Reports -> Text chat -> Annoying me" },
                { "MPPLY_TC_HATE",            2, "Reports -> Text chat -> Hate Speech" },
                { "MPPLY_VC_ANNOYINGME",      2, "Reports -> Voice chat > Annoying me" },
                { "MPPLY_VC_HATE",            2, "Reports -> Voice chat > Hate Speech" },
                { "MPPLY_OFFENSIVE_LANGUAGE", 2, "Reports -> Offensive language" },
                { "MPPLY_OFFENSIVE_TAGPLATE", 2, "Reports -> Offensive tagplate" },
                { "MPPLY_OFFENSIVE_UGC",      2, "Reports -> Offensive content" },
                { "MPPLY_BAD_CREW_NAME",      2, "Reports -> Bad crew name" },
                { "MPPLY_BAD_CREW_MOTTO",     2, "Reports -> Bad crew motto" },
                { "MPPLY_BAD_CREW_STATUS",    2, "Reports -> Bad crew status" },
                { "MPPLY_BAD_CREW_EMBLEM",    2, "Reports -> Bad crew emblem" },
                { "MPPLY_FRIENDLY",           2, "Commend -> Friendly" },
                { "MPPLY_HELPFUL",            2, "Commend -> Helpful" },
            },
            abilities = {
                -- {Display, Getter, Setter, Value, Changed value}
                { "Stamina",      "STAMINA",             "SCRIPT_INCREASE_STAM" },
                { "Strength",     "STRENGTH",            "SCRIPT_INCREASE_STRN" },
                { "Shooting",     "SHOOTING_ABILITY",    "SCRIPT_INCREASE_SHO" },
                { "Stealth",      "STEALTH_ABILITY",     "SCRIPT_INCREASE_STL" },
                { "Flying",       "FLYING_ABILITY",      "SCRIPT_INCREASE_FLY" },
                { "Driving",      "WHEELIE_ABILITY",     "SCRIPT_INCREASE_DRIV" },
                { "Diving",       "LUNG_CAPACITY",       "SCRIPT_INCREASE_LUNG" },
                { "Mental State", "PLAYER_MENTAL_STATE", nil }
            }
        }

        local function refreshStats()
            local displayAll = yu.rendering.isCheckboxChecked("online_stats_other_stats_all") == true
            for k, v in pairs(a.stats) do
                v[4] = nil
                if v[2] == 1 then
                    local value = stats.get_bool(v[1])
                    if displayAll or value then
                        v[4] = tostring(value)
                    end
                elseif v[2] == 2 then
                    local value = stats.get_int(v[1])
                    if displayAll or value ~= 0 then
                        v[4] = yu.format_num(value)
                    end
                end
            end

            a.ischeater = NETWORK.NETWORK_PLAYER_IS_CHEATER()
        end

        local function refreshAbilityValue(mpx, i)
            local data = a.abilities[i]
            if data == nil then
                return
            end

            local stat = mpx..data[2]
            a.abilities[i][4] = i == 8 and stats.get_float(stat) or stats.get_int(stat)
            a.abilities[i][5] = nil
        end

        local function refreshAbilityValues()
            local mpx = yu.mpx()
            for k, v in pairs(a.abilities) do
                refreshAbilityValue(mpx, k)
            end
        end

        local function refresh()
            refreshStats()
            refreshAbilityValues()
        end
        tasks.addTask(refresh)

        function tab3.render()
            if ImGui.SmallButton("Refresh") then
                tasks.addTask(refresh)
            end

            if ImGui.TreeNodeEx("Stats") then
                if ImGui.Button("Refresh##stats") then
                    tasks.addTask(refreshStats)
                end

                ImGui.SameLine()

                yu.rendering.renderCheckbox("Show all", "online_stats_other_stats_all", function()
                    tasks.addTask(refreshStats)
                end)

                if a.ischeater then
                    ImGui.Text("You are marked as a cheater!")
                end

                for k, v in pairs(a.stats) do
                    if v[4] ~= nil then
                        ImGui.Text(v[3]..": "..v[4])
                    end
                end

                if SussySpt.dev then
                    ImGui.Spacing()

                    if ImGui.Button("Clear reports (test)") then
                        tasks.addTask(function()
                            stats.set_int("MPPLY_REPORT_STRENGTH", 0)
                            stats.set_int("MPPLY_COMMEND_STRENGTH", 0)
                            stats.set_int("MPPLY_GRIEFING", 0)
                            stats.set_int("MPPLY_VC_ANNOYINGME", 0)
                            stats.set_int("MPPLY_VC_HATE", 0)
                            stats.set_int("MPPLY_TC_ANNOYINGME", 0)
                            stats.set_int("MPPLY_TC_HATE", 0)
                            stats.set_int("MPPLY_OFFENSIVE_LANGUAGE", 0)
                            stats.set_int("MPPLY_OFFENSIVE_TAGPLATE", 0)
                            stats.set_int("MPPLY_OFFENSIVE_UGC", 0)
                            stats.set_int("MPPLY_BAD_CREW_NAME", 0)
                            stats.set_int("MPPLY_BAD_CREW_MOTTO", 0)
                            stats.set_int("MPPLY_BAD_CREW_STATUS", 0)
                            stats.set_int("MPPLY_BAD_CREW_EMBLEM", 0)
                            stats.set_int("MPPLY_GAME_EXPLOITS", 0)
                            stats.set_int("MPPLY_EXPLOITS", 0)
                            stats.set_int("MPPLY_BECAME_CHEATER_NUM", 0)
                            stats.set_int("MPPLY_GAME_EXPLOITS", 0)
                            stats.set_int("MPPLY_PLAYER_MENTAL_STATE", 0)
                            stats.set_int("MPPLY_PLAYERMADE_TITLE", 0)
                            stats.set_int("MPPLY_PLAYERMADE_DESC", 0)
                            stats.set_int("MPPLY_KILLS_PLAYERS_CHEATER", 0)
                            stats.set_int("MPPLY_DEATHS_PLAYERS_CHEATER", 0)
                            stats.set_bool("MPPLY_ISPUNISHED", false)
                            stats.set_bool("MPPLY_WAS_I_CHEATER", false)
                            stats.set_int("MPPLY_OVERALL_BADSPORT", 0)
                            stats.set_int("MPPLY_OVERALL_CHEAT", 0)
                        end)
                    end
                end

                ImGui.TreePop()
            end

            if ImGui.TreeNodeEx("Abilities") then
                if ImGui.SmallButton("Refresh##abilities") then
                    yu.rif(refreshAbilityValues)
                end

                ImGui.Spacing()

                ImGui.PushItemWidth(331)
                for k, v in pairs(a.abilities) do
                    do
                        local value, used
                        if k == 8 then
                            value, used = ImGui.DragFloat(v[1], v[5] or v[4], .2, 0, 100)
                        else
                            value, used = ImGui.DragInt(v[1], v[5] or v[4], .2, 0, 100)
                        end

                        if used then
                            if value == v[4] then
                                a.abilities[k][5] = nil
                            else
                                a.abilities[k][5] = value
                            end
                        end
                    end

                    if v[5] ~= nil then
                        ImGui.SameLine()

                        if ImGui.SmallButton("Apply##abilities_"..k) then
                            tasks.addTask(function()
                                if not yu.is_num_between(v[5], 0, 100) then
                                    return
                                end

                                local mpx = yu.mpx()
                                for i = 2, 3 do
                                    if k == 8 and i == 3 then
                                        break
                                    end

                                    local stat = mpx..v[i]

                                    local val
                                    if i == 3 then
                                        val = v[5] - v[4]
                                    else
                                        val = v[5]
                                    end

                                    if k == 8 then
                                        if i == 2 then
                                            stats.set_float(stat, val)
                                        end
                                    else
                                        stats.set_int(stat, val)
                                        -- log.info("SET "..stat.." TO "..val)
                                    end
                                end

                                refreshAbilityValue(mpx, k)
                            end)
                        end
                    end
                end
                ImGui.PopItemWidth()

                ImGui.TreePop()
            end

            if SussySpt.dev and ImGui.TreeNodeEx("Badsport") then
                if ImGui.SmallButton("Add##badsport") then
                    tasks.addTask(function()
                        stats.set_int("MPPLY_BADSPORT_MESSAGE", -1)
                        stats.set_int("MPPLY_BECAME_BADSPORT_NUM", -1)
                        stats.set_float("MPPLY_OVERALL_BADSPORT", 60000)
                        stats.set_bool("MPPLY_CHAR_IS_BADSPORT", true)
                    end)
                end

                ImGui.SameLine()

                if ImGui.SmallButton("Remove##badsport") then
                    tasks.addTask(function()
                        stats.set_int("MPPLY_BADSPORT_MESSAGE", 0)
                        stats.set_int("MPPLY_BECAME_BADSPORT_NUM", 0)
                        stats.set_float("MPPLY_OVERALL_BADSPORT", 0)
                        stats.set_bool("MPPLY_CHAR_IS_BADSPORT", false)
                    end)
                end

                ImGui.TreePop()
            end

            if SussySpt.dev and ImGui.TreeNodeEx("Bounty") then
                if ImGui.SmallButton("Remove bounty") then
                    tasks.addTask(function()
                        globals.set_int(values.g.bounty_self_time, 2880000)
                    end)
                end

                ImGui.TreePop()
            end
        end

        tab2.sub[1] = tab3
    end

    do -- ANCHOR Loader
        local tab3 = SussySpt.rendering.newTab("Loader")

        local a = {
            input =
            "# This is a comment\nbool SOME_STAT 0\nbool MPX_SOME_STAT 1\nbool SOME_STAT true\nbool MPX_SOME_STAT false\nint SOME_STAT 1\nfloat MPX_SOME_STAT 1.23",
            types = {
                "bool",
                "int",
                "float"
            }
        }

        -- TODO Support for masked, globals?

        local function load()
            if type(a.input) ~= "string" then
                return
            end

            local tokens = {}
            local mpx = yu.mpx()

            local lines = string.split(a.input, "\n")
            for k, v in pairs(lines) do
                local text = v:strip()
                if text:len() ~= 0 and not text:startswith("#") then
                    text = text:split("#")[1]
                    local parts = text:split(" ")

                    local type = parts[1]
                    local stat = parts[2]
                    local value = parts[3]

                    if type == nil then
                        lines[k] = "#"..v.." # Could not read type"
                    elseif stat == nil then
                        lines[k] = "#"..v.." # Could not read stat"
                    elseif value == nil then
                        lines[k] = "#"..v.." # Could not read value"
                    else
                        type = yu.get_key_from_table(a.types, type, nil)
                        if type == nil then
                            lines[k] = "#"..v.." # Invalid type"
                            goto continue
                        end

                        if stat:startswith("MPX_") then
                            stat = mpx..stat:sub(5)
                        end

                        if type == 1 then
                            if value == "false" or value == "0" then
                                value = false
                            elseif value == "true" or value == "1" then
                                value = true
                            else
                                lines[k] = "#"..v.." # Invalid value for bool type"
                                goto continue
                            end
                        elseif type == 2 then
                            if string.contains(value, ".") then
                                lines[k] = "#"..v.." # An integer as value is required"
                                goto continue
                            end
                            value = tonumber(value)
                            if value == nil then
                                lines[k] = "#"..v.." # Invalid value for int type"
                                goto continue
                            end
                        elseif type == 3 then
                            value = tonumber(value)
                            if value == nil then
                                lines[k] = "#"..v.." # Invalid value for float type"
                                goto continue
                            end
                        end

                        table.insert(tokens, { type, stat, value })
                    end
                end
                ::continue::
            end
            a.input = table.join(lines, "\n")
            a.tokens = tokens
            a.tokenlength = yu.len(tokens).." stat/s loaded"
        end

        local function apply()
            local applied = 0

            for k, v in pairs(a.tokens) do
                local type = v[1]
                local stat = v[2]
                local value = v[3]

                if type == 1 then
                    stats.set_bool(stat, value)
                    applied = applied + 1
                elseif type == 2 then
                    stats.set_int(stat, value)
                    applied = applied + 1
                elseif type == 3 then
                    stats.set_float(stat, value)
                    applied = applied + 1
                end
            end

            yu.notify(1, applied.." stat/s where applied", "Online->Stats->Loader")
        end

        function tab3.render()
            if ImGui.Button("Load") then
                yu.rif(load)
            end

            if a.tokens ~= nil then
                ImGui.SameLine()

                if ImGui.Button("Apply") then
                    yu.rif(apply)
                end

                if SussySpt.dev then
                    ImGui.SameLine()

                    if ImGui.Button("Dump tokens") then
                        tasks.addTask(function()
                            log.info("===[ TOKEN DUMP ]===")

                            for k, v in pairs(a.tokens) do
                                local type = v[1]
                                local stat = v[2]
                                local value = tostring(v[3])
                                log.info(k..": {type="..a.types[type].."["..type.."],stat="..stat..",value="..value.."}")
                            end

                            log.info("====================")
                        end)
                    end
                end
            end

            if a.tokenlength ~= nil then
                ImGui.Text(a.tokenlength)
            end

            do
                local x, y = ImGui.GetContentRegionAvail()
                local text, _ = ImGui.InputTextMultiline("##input", a.input, 2500000, x, y)
                if a.input ~= text then
                    a.input = text
                    a.tokens = nil
                    a.tokenlength = nil
                end
            end
            SussySpt.pushDisableControls(ImGui.IsItemActive())
        end

        tab2.sub[2] = tab3
    end

    tab.sub[3] = tab2
end

return exports
