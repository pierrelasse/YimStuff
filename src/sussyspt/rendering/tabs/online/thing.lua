local tasks = require("../../../tasks")
local values = require("../../../values")
local removeAllCameras = require("../../../util/removeAllCameras")

function exports.register(tab)
    local tab2 = SussySpt.rendering.newTab("Thing")

    local function addUnknownValue(tbl, v)
        if tbl[v] == nil then
            tbl[v] = "??? ["..(v or "<null>").."]"
        end
    end



    do -- SECTION Agency
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

    do -- SECTION Auto Shop
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

        do -- ANCHOR Preperations
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

        do -- ANCHOR Cooldowns
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
    end -- !SECTION

    do -- SECTION Kosatka
        local tab3 = SussySpt.rendering.newTab("Kosatka")

        do -- SECTION Heist
            local tab4 = SussySpt.rendering.newTab("Heist")

            local a = {
                primarytargets = {
                    [0] = "Sinsimito Tequila $630K",
                    [1] = "Ruby Necklace $700K",
                    [2] = "Bearer Bonds $770K",
                    [4] = "Minimadrazzo Files $1,1M|1,21M",
                    [3] = "Pink Diamond $1,3M|1,43M",
                    [5] = "Panther Statue $1,9M|2,09M",
                },
                storages = {
                    [1] = "None",
                    [2] = "Cash",
                    [3] = "Weed",
                    [4] = "Coke",
                    [5] = "Gold",
                },
                storagesid = {
                    [2] = "CASH",
                    [3] = "WEED",
                    [4] = "COKE",
                    [5] = "GOLD"
                },
                compoundstorageamounts = {
                    [0] = 0,
                    [1] = 64,
                    [2] = 128,
                    [3] = 196,
                    [4] = 204,
                    [5] = 220,
                    [6] = 252,
                    [7] = 253,
                    [8] = 255
                },
                islandstorageamounts = {
                    [0] = 0,
                    [1] = 8388608,
                    [2] = 12582912,
                    [3] = 12845056,
                    [4] = 12976128,
                    [5] = 13500416,
                    [6] = 14548992,
                    [7] = 16646144,
                    [8] = 16711680,
                    [9] = 16744448,
                    [10] = 16760832,
                    [11] = 16769024,
                    [12] = 16769536,
                    [13] = 16770560,
                    [14] = 16770816,
                    [15] = 16770880,
                    [16] = 16771008,
                    [17] = 16773056,
                    [18] = 16777152,
                    [19] = 16777184,
                    [20] = 16777200,
                    [21] = 16777202,
                    [22] = 16777203,
                    [23] = 16777211,
                    [24] = 16777215
                },
                difficulties = {
                    [126823] = "Normal",
                    [131055] = "Hard",
                },
                approaches = {
                    [65283] = "Kosatka",
                    [65413] = "Alkonost",
                    [65289] = "Velum",
                    [65425] = "Stealth Annihilator",
                    [65313] = "Patrol Boat",
                    [65345] = "Longfin",
                    [65535] = "*All*",
                },
                weapons = {
                    [1] = "Aggressor [Assault SG + Machine Pistol + Machete + Grenade]",
                    [2] = "Conspirator [Military Rifle + AP + Knuckles + Stickies]",
                    [3] = "Crackshot [Sniper + AP + Knife + Molotov]",
                    [4] = "Saboteur [SMG Mk2 + SNS Pistol + Knife + Pipe Bomb]",
                    [5] = "Marksman [AK-47? + Pistol .50? + Machete + Pipe Bomb]",
                },
                supplytrucklocations = {
                    [1] = "Airport",
                    [2] = "North Dock",
                    [3] = "Main Dock - East",
                    [4] = "Main Dock - West",
                    [5] = "Inside Compound",
                }
            }

            local function getStorage(i)
                if stats.get_int(yu.mpx().."H4LOOT_CASH_"..i) > 0 then
                    return 2
                elseif stats.get_int(yu.mpx().."H4LOOT_WEED_"..i) > 0 then
                    return 3
                elseif stats.get_int(yu.mpx().."H4LOOT_COKE_"..i) > 0 then
                    return 4
                elseif stats.get_int(yu.mpx().."H4LOOT_GOLD_"..i) > 0 then
                    return 5
                end
                return 1
            end

            local function refreshStats()
                a.primarytarget = stats.get_int(yu.mpx("H4CNF_TARGET"))
                addUnknownValue(a.primarytargets, a.primarytarget)

                a.compoundstorage = getStorage("C")
                addUnknownValue(a.storages, a.compoundstorage)

                local compoundstorageid = a.storagesid[a.compoundstorage]
                if compoundstorageid == nil then
                    a.compoundstorageamount = 0
                else
                    a.compoundstorageamount = yu.get_key_from_table(a.compoundstorageamounts, stats.get_int(yu.mpx("H4LOOT_"..compoundstorageid.."_C_SCOPED")), 0)
                end

                a.islandstorage = getStorage("I")
                addUnknownValue(a.storages, a.islandstorage)

                local islandstorageid = a.storagesid[a.islandstorage]
                if islandstorageid == nil then
                    a.islandstorageamount = 0
                else
                    a.islandstorageamount = yu.get_key_from_table(a.islandstorageamounts, stats.get_int(yu.mpx("H4LOOT_"..islandstorageid.."_I_SCOPED")), 0)
                end

                a.paintings = stats.get_int(yu.mpx("H4LOOT_PAINT_SCOPED")) > 0
                yu.rendering.setCheckboxChecked("hbo_cayo_paintings", a.paintings)

                a.difficulty = stats.get_int(yu.mpx().."H4_PROGRESS")
                addUnknownValue(a.difficulties, a.difficulty)

                a.approach = stats.get_int(yu.mpx().."H4_MISSIONS")
                addUnknownValue(a.approaches, a.approach)

                a.weapon = stats.get_int(yu.mpx().."H4CNF_WEAPONS")
                addUnknownValue(a.weapons, a.weapon)

                a.supplytrucklocation = stats.get_int(yu.mpx().."H4CNF_TROJAN")
                addUnknownValue(a.supplytrucklocations, a.supplytrucklocation)

                yu.rendering.setCheckboxChecked("hbo_cayo_cuttingpowder", stats.get_int(yu.mpx().."H4CNF_TARGET") == 3)
            end
            tasks.addTask(refreshStats)

            local function refreshCuts()
                a.cuts = {}
            end
            refreshCuts()

            local function refreshExtra()
                -- if yu.is_script_running("fm_mission_controller_2020") then
                --     a.lifes = locals.get_int("fm_mission_controller_2020", 43059 + 865 + 1)
                --     a.realtake = locals.get_int("fm_mission_controller_2020", 40004 + 1392 + 53)
                -- else
                --     a.lifes = 0
                --     a.realtake = 289700
                -- end
            end
            -- refreshExtra()

            local cooldowns = {}
            local function refreshCooldowns()
                for k, v in pairs({"H4_TARGET_POSIX", "H4_COOLDOWN", "H4_COOLDOWN_HARD"}) do
                    cooldowns[k] = " "..v..": "..yu.format_seconds(stats.get_int(yu.mpx()..v) - os.time())
                end
            end
            tasks.addTask(refreshCooldowns)

            function tab4.render()
                ImGui.BeginGroup()
                yu.rendering.bigText("Preperations")

                ImGui.PushItemWidth(360)

                do
                    local ptr = yu.rendering.renderList(a.primarytargets, a.primarytarget, "hbo_cayo_pt", "Primary target")
                    if ptr.changed then
                        yu.notify(1, "Set Primary Target to "..a.primarytargets[ptr.key].." ["..ptr.key.."]", "Cayo Perico Heist")
                        a.primarytarget = ptr.key
                        a.primarytargetchanged = true
                    end

                    local fcsr = yu.rendering.renderList(a.storages, a.compoundstorage, "hbo_cayo_fcs", "Fill compound storages")
                    if fcsr.changed then
                        yu.notify(1, "Set Fill compound storages to "..a.storages[fcsr.key].." ["..fcsr.key.."]", "Cayo Perico Heist")
                        a.compoundstorage = fcsr.key
                        a.compoundstoragechanged = true
                    end

                    local fcsar, fcsavc = ImGui.SliderInt("Compound storage amount", a.compoundstorageamount, 0, #a.compoundstorageamounts - 1, a.compoundstorageamount.."##hbo_cayo_compoundstorageamount", 1)
                    if fcsavc then
                        a.compoundstorageamount = fcsar
                        a.compoundstorageamountchanged = true
                    end

                    local fisr = yu.rendering.renderList(a.storages, a.islandstorage, "hbo_cayo_fcs", "Fill island storages")
                    if fisr.changed then
                        yu.notify(1, "Set Fill island storages to "..a.storages[fisr.key].." ["..fisr.key.."]", "Cayo Perico Heist")
                        a.islandstorage = fisr.key
                        a.islandstoragechanged = true
                    end

                    local fisar, fisavc = ImGui.SliderInt("Islands storage amount", a.islandstorageamount, 0, #a.islandstorageamounts - 1, a.islandstorageamount.."##hbo_cayo_paintingsamount", 1)
                    if fisavc then
                        a.islandstorageamount = fisar
                        a.islandstorageamountchanged = true
                    end

                    yu.rendering.renderCheckbox("Add paintings", "hbo_cayo_paintings", function(state)
                        a.paintings = state
                        a.paintingschanged = true
                    end)

                    local dr = yu.rendering.renderList(a.difficulties, a.difficulty, "hbo_cayo_d", "Difficulty")
                    if dr.changed then
                        yu.notify(1, "Set Difficulty to "..a.difficulties[dr.key].." ["..dr.key.."]", "Cayo Perico Heist")
                        a.difficulty = dr.key
                        a.difficultychanged = true
                    end

                    local ar = yu.rendering.renderList(a.approaches, a.approach, "hbo_cayo_a", "Approach")
                    if ar.changed then
                        yu.notify(1, "Set Approach to "..a.approaches[ar.key].." ["..ar.key.."]", "Cayo Perico Heist")
                        a.approach = ar.key
                        a.approachchanged = true
                    end

                    local wr = yu.rendering.renderList(a.weapons, a.weapon, "hbo_cayo_w", "Weapons")
                    if wr.changed then
                        yu.notify(1, "Set Weapons to "..a.weapons[wr.key].." ["..wr.key.."]", "Cayo Perico Heist")
                        a.weapon = wr.key
                        a.weaponchanged = true
                    end

                    local stlr = yu.rendering.renderList(a.supplytrucklocations, a.supplytrucklocation, "hbo_cayo_stl", "Supply truck location")
                    if stlr.changed then
                        yu.notify(1, "Set Supply truck location to "..a.supplytrucklocations[stlr.key].." ["..stlr.key.."]", "Cayo Perico Heist")
                        a.supplytrucklocation = stlr.key
                        a.supplytrucklocationchanged = true
                    end
                end

                yu.rendering.renderCheckbox("Cutting powder", "hbo_cayo_cuttingpowder", function(state)
                    a.cuttingpowderchanged = true
                end)
                yu.rendering.tooltip("Guards will have reduced firing accuracy during the finale mission")

                ImGui.PopItemWidth()

                ImGui.Spacing()

                if ImGui.Button("Apply##stats") then
                    tasks.addTask(function()
                        local changes = 0

                        -- Primary Target
                        if a.primarytargetchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H4CNF_TARGET", a.primarytarget)
                        end

                        -- Fill Compound Storages
                        if a.compoundstoragechanged or a.compoundstorageamountchanged then
                            changes = changes + 1
                            local amount = a.compoundstorageamounts[a.compoundstorageamount]
                            if a.compoundstorage == 1 then
                                stats.set_int(yu.mpx().."H4LOOT_CASH_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_C_SCOPED", 0)
                            elseif a.compoundstorage == 2 then
                                stats.set_int(yu.mpx().."H4LOOT_CASH_C", amount)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_C_SCOPED", amount)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_V", 90000)
                            elseif a.compoundstorage == 3 then
                                stats.set_int(yu.mpx().."H4LOOT_CASH_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_C", amount)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_C_SCOPED", amount)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_V", 147870)
                            elseif a.compoundstorage == 4 then
                                stats.set_int(yu.mpx().."H4LOOT_CASH_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_C", amount)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_C_SCOPED", amount)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_V", 200095)
                            elseif a.compoundstorage == 5 then
                                stats.set_int(yu.mpx().."H4LOOT_CASH_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_C", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_C_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_C", amount)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_C_SCOPED", amount)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_V", 330350)
                            end
                        end

                        -- Fill Island Storages
                        if a.islandstoragechanged or a.islandstorageamountchanged then
                            changes = changes + 1
                            local amount = a.islandstorageamounts[a.islandstorageamount]
                            if a.islandstorage == 1 then
                                stats.set_int(yu.mpx().."H4LOOT_CASH_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_I_SCOPED", 0)
                            elseif a.islandstorage == 2 then
                                stats.set_int(yu.mpx().."H4LOOT_CASH_I", amount)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_I_SCOPED", amount)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_V", 90000)
                            elseif a.islandstorage == 3 then
                                stats.set_int(yu.mpx().."H4LOOT_CASH_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_I", amount)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_I_SCOPED", amount)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_V", 147870)
                            elseif a.islandstorage == 4 then
                                stats.set_int(yu.mpx().."H4LOOT_CASH_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_I", amount)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_I_SCOPED", amount)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_V", 200095)
                            elseif a.islandstorage == 5 then
                                stats.set_int(yu.mpx().."H4LOOT_CASH_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_CASH_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_WEED_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_I", 0)
                                stats.set_int(yu.mpx().."H4LOOT_COKE_I_SCOPED", 0)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_I", amount)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_I_SCOPED", amount)
                                stats.set_int(yu.mpx().."H4LOOT_GOLD_V", 330350)
                            end
                        end

                        -- Paintings
                        if a.paintingschanged then
                            changes = changes + 1
                            -- stats.set_int(yu.mpx("H4LOOT_PAINT"), a.paintings)
                            -- stats.set_int(yu.mpx("H4LOOT_PAINT_SCOPED"), a.paintings)
                            -- stats.set_int(yu.mpx("H4LOOT_PAINT_C"), 127)
                            -- stats.set_int(yu.mpx("H4LOOT_PAINT_C_SCOPED"), 127)
                            -- stats.set_int(yu.mpx("H4LOOT_PAINT_V"), 189500)
                            if a.paintings then
                                stats.set_int(yu.mpx("H4LOOT_PAINT"), 127)
                                stats.set_int(yu.mpx("H4LOOT_PAINT_SCOPED"), 127)
                            else
                                stats.set_int(yu.mpx("H4LOOT_PAINT"), 0)
                                stats.set_int(yu.mpx("H4LOOT_PAINT_SCOPED"), 0)
                            end
                            stats.set_int(yu.mpx("H4LOOT_PAINT_V"), 343863)
                        end

                        -- Difficulty
                        if a.difficultychanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H4_PROGRESS", a.difficulty)
                        end

                        -- Approach
                        if a.approachchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H4_MISSIONS", a.approach)
                        end

                        -- Weapons
                        if a.weaponchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H4CNF_WEAPONS", a.weapon)
                        end

                        -- Truck Location
                        if a.supplytrucklocationchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H4CNF_TROJAN", a.supplytrucklocation)
                        end

                        -- Cutting Powder
                        if a.cuttingpowderchanged then
                            changes = changes + 1
                            if yu.rendering.isCheckboxChecked("hbo_cayo_cuttingpowder") then
                                stats.set_int(yu.mpx().."H4CNF_TARGET", 3)
                            else
                                stats.set_int(yu.mpx().."H4CNF_TARGET", 2)
                            end
                        end

                        yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied. (Re)enter your kosatka to see changes.", "Cayo Perico Heist")
                        for k, v in pairs(a) do
                            if tostring(k):endswith("changed") then
                                a[k] = nil
                            end
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Refresh##stats") then
                    tasks.addTask(refreshStats)
                end

                ImGui.SameLine()

                if ImGui.Button("Reload planning board") then
                --     if SussySpt.requireScript("heist_island_planning") then
                --         locals.set_int("heist_island_planning", 1526, 2)
                --     end
                end

                if ImGui.Button("Unlock accesspoints & approaches") then
                    tasks.addTask(function()
                        stats.set_int(yu.mpx().."H4CNF_BS_GEN", -1)
                        stats.set_int(yu.mpx().."H4CNF_BS_ENTR", 63)
                        stats.set_int(yu.mpx().."H4CNF_APPROACH", -1)
                        yu.notify("POI, accesspoints, approaches stuff should be unlocked i think", "Cayo Perico Heist")
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Remove fencing fee & pavel cut") then
                --     tasks.addTask(function()
                --         globals.set_float(262145 + 29470, -.1)
                --         globals.set_float(291786, 0)
                --         globals.set_float(291787, 0)
                --     end)
                end
                yu.rendering.tooltip("I think no one wants to add them back...")

                if ImGui.Button("Complete Preps") then
                    tasks.addTask(function()
                        stats.set_int(yu.mpx().."H4CNF_UNIFORM", -1)
                        stats.set_int(yu.mpx().."H4CNF_GRAPPEL", -1)
                        stats.set_int(yu.mpx().."H4CNF_TROJAN", 5)
                        stats.set_int(yu.mpx().."H4CNF_WEP_DISRP", 3)
                        stats.set_int(yu.mpx().."H4CNF_ARM_DISRP", 3)
                        stats.set_int(yu.mpx().."H4CNF_HEL_DISRP", 3)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset heist") then
                    tasks.addTask(function()
                        stats.set_int(yu.mpx().."H4_MISSIONS", 0)
                        stats.set_int(yu.mpx().."H4_PROGRESS", 0)
                        stats.set_int(yu.mpx().."H4CNF_APPROACH", 0)
                        stats.set_int(yu.mpx().."H4CNF_BS_ENTR", 0)
                        stats.set_int(yu.mpx().."H4CNF_BS_GEN", 0)
                    end)
                end

                ImGui.EndGroup()
                ImGui.Separator()
                ImGui.BeginGroup()

                yu.rendering.bigText("Cuts")

                SussySpt.renderCutsSlider(a.cuts, 1)
                SussySpt.renderCutsSlider(a.cuts, 2)
                SussySpt.renderCutsSlider(a.cuts, 3)
                SussySpt.renderCutsSlider(a.cuts, 4)
                SussySpt.renderCutsSlider(a.cuts, -2)

                if ImGui.Button("Apply##cuts") then
                --     for k, v in pairs(a.cuts) do
                --         if k == -2 then
                --             globals.set_int(2684820 + 6606, v)
                --         else
                --             globals.set_int(1978495 + 825 + 56 + k, v)
                --         end
                --     end
                end

                ImGui.SameLine()

                if ImGui.Button("Refresh##cuts") then
                    tasks.addTask(refreshCuts)
                end

                ImGui.EndGroup()
                ImGui.Separator()
                ImGui.BeginGroup()

                yu.rendering.bigText("Extra")

                if ImGui.Button("Remove all cameras") then
                    tasks.addTask(removeAllCameras)
                end
                yu.rendering.tooltip("This can make your game crash. Be careful")

                if ImGui.Button("Skip sewer tunnel cut") then
                    tasks.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020")
                            and (locals.get_int("fm_mission_controller_2020", 28446) >= 3
                                or locals.get_int("fm_mission_controller_2020", 28446) <= 6) then
                            locals.set_int("fm_mission_controller_2020", 28446, 6)
                            yu.notify("Skipped sewer tunnel cut (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip door hack") then
                    tasks.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020")
                            and locals.get_int("fm_mission_controller_2020", 54024) ~= 4 then
                            locals.set_int("fm_mission_controller_2020", 54024, 5)
                            yu.notify("Skipped door hack (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                if ImGui.Button("Skip fingerprint hack") then
                    tasks.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020")
                            and locals.get_int("fm_mission_controller_2020", 23669) == 4 then
                            locals.set_int("fm_mission_controller_2020", 23669, 5)
                            yu.notify("Skipped fingerprint hack (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip plasmacutter cut") then
                    tasks.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020") then
                            locals.set_float("fm_mission_controller_2020", 29685 + 3, 100)
                            yu.notify("Skipped plasmacutter cut (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                if ImGui.Button("Obtain the primary target") then
                    tasks.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020") then
                            locals.set_int("fm_mission_controller_2020", 29684, 5)
                            locals.set_int("fm_mission_controller_2020", 29685, 3)
                        end
                    end)
                end
                yu.rendering.tooltip("It works i guess but the object will not get changed")

                ImGui.SameLine()

                if ImGui.Button("Remove the drainage pipe") then
                    tasks.addTask(function()
                        local hash = joaat("prop_chem_grill_bit")
                        for k, v in pairs(entities.get_all_objects_as_handles()) do
                            if ENTITY.GET_ENTITY_MODEL(v) == hash then
                                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v, false, false)
                                ENTITY.DELETE_ENTITY(v)
                            end
                        end
                    end)
                end
                yu.rendering.tooltip("This is good")

                if ImGui.Button("Instant finish") then
                    tasks.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020") then
                            locals.set_int("fm_mission_controller_2020", 45450, 9)
                            locals.set_int("fm_mission_controller_2020", 46829, 50)
                            yu.notify("Idk if you should use this but i i capitan", "Cayo Perico Heist")
                        end
                    end)
                end
                yu.rendering.tooltip("This is really weird and only you get money i think")

                ImGui.Spacing()

                if ImGui.Button("Refresh##extra") then
                    tasks.addTask(refreshExtra)
                end

                ImGui.PushItemWidth(390)

                -- local lifesValue, lifesChanged = ImGui.SliderInt("Lifes", a.lifes, 0, 10)
                -- yu.rendering.tooltip("Only works when you are playing alone (i think)")
                -- if lifesChanged then
                --     a.lifes = lifesValue
                -- end

                -- ImGui.SameLine()

                -- if ImGui.Button("Apply##lifes") then
                --     if SussySpt.requireScript("fm_mission_controller_2020") then
                --         locals.set_int("fm_mission_controller_2020", 43059 + 865 + 1, a.lifes)
                --     end
                -- end

                -- local realTakeValue, realTakeChanged = ImGui.SliderInt("Real take", a.realtake, 100000, 2897000, yu.format_num(a.realtake))
                -- yu.rendering.tooltip("Set real take to 2,897,000 for 100% or smth")
                -- if realTakeChanged then
                --     a.realtake = realTakeValue
                -- end

                -- ImGui.SameLine()

                -- if ImGui.Button("Apply##realtake") then
                --     if SussySpt.requireScript("fm_mission_controller_2020") then
                --         locals.set_int("fm_mission_controller_2020", 40004 + 1392 + 53, a.realtake)
                --     end
                -- end

                -- ImGui.Text("Simulate bag for:")
                -- for i = 1, 4 do
                --     ImGui.SameLine()
                --     if ImGui.Button(i.." Player"..yu.shc(i == 1, "", "s")) then
                --         tasks.addTask(function()
                --             globals.set_int(292084, 1800 * i)
                --         end)
                --     end
                -- end

                -- ImGui.PopItemWidth()
                ImGui.Separator()

                if ImGui.Button("Refresh##cooldowns") then
                    tasks.addTask(refreshCooldowns)
                end

                for k, v in pairs(cooldowns) do
                    ImGui.Text(v)
                end

                ImGui.EndGroup()
            end

            tab3.sub[1] = tab4
        end -- !SECTION

        do -- SECTION Kosatka
            local tab4 = SussySpt.rendering.newTab("Kosatka")

            function tab4.render()
                ImGui.Text("\\/ Placeholder. Does not work")

                yu.rendering.renderCheckbox("Remove kosatka missle cooldown", "kosatka_nomisslecd", function(state)
                    tasks.addTask(function()
                        -- globals.set_int(292539, yu.shc(state, 0, 60000))
                    end)
                end)

                yu.rendering.renderCheckbox("Higher kosatka missle range", "kosatka_longermisslerange", function(state)
                    tasks.addTask(function()
                        -- globals.set_int(292540, yu.shc(state, 4000, 99999))
                    end)
                end)
            end

            tab3.sub[2] = tab4
        end -- !SECTION

        tab2.sub[4] = tab3
    end -- !SECTION

    do -- SECTION Salvage Yard
        local tab3 = SussySpt.rendering.newTab("Salvage Yard")

        local a = {
            loaded = false,

            cooldown = {
                value = 0,

                getStatHashForCharStat = function()--Position - 0xD247
                    return STATS.GET_STAT_HASH_FOR_CHARACTER_STAT_(0, 12230, yu.playerindex(2))
                end,
                get = function(self)
                    local success, result = STATS.STAT_GET_INT(self.getStatHashForCharStat(), 0, -1)
                    if not success then
                        return nil
                    end
                    return result - NETWORK.GET_CLOUD_TIME_AS_INT()
                end,
                set = function(self, secs)
                    STATS.STAT_SET_INT(self.getStatHashForCharStat(), NETWORK.GET_CLOUD_TIME_AS_INT() + secs, false)
                end
            },

            vehicleSearch = "",
            vehicles = {"lm87","cinquemila","autarch","tigon","champion","tenf","sm722","omnisegt","growler","deity","italirsx","coquette4",
                "jubilee","astron","comet7","torero","cheetah2","turismo2","infernus2","stafford","gt500","viseris","mamba","coquette3",
                "stingergt","ztype","broadway","vigero2","buffalo4","ruston","gauntlet4","dominator8","btype3","swinger","feltzer3","omnis",
                "tropos","jugular","patriot3","toros","caracara2","sentinel3","weevil","kanjo","eudora","kamacho","hellion","ellie","hermes",
                "hustler","turismo3","buffalo5","stingertt","virtue","ignus","zentorno","neon","furia","zorrusso","thrax","vagner","panthere",
                "italigto","s80","tyrant","entity3","torero2","neo","corsita","paragon","btype2","comet4","fr36","everon2","komoda","tailgater2",
                "jester3","jester4","euros","zr350","cypher","dominator7","baller8","casco","yosemite2","everon","penumbra2","vstr","dominator9",
                "schlagen","cavalcade3","clique","boor","sugoi","greenwood","brigham","issi8","seminole2","kanjosj","previon"},
            translatedVehicles = {},

            slot = 1,
            robberies = {
                "The Cargo Ship",
                "The Gangbanger",
                "The Duggan",
                "The Podium",
                "The McTony"
            }
        }

        for k, v in pairs(a.vehicles) do
            a.translatedVehicles[k] = vehicles.get_vehicle_display_name(joaat(v))
        end

        do -- SECTION Robbery
            local tab4 = SussySpt.rendering.newTab("Robbery")

            local function tick() -- ANCHOR tick
                local mpx = yu.mpx()

                a.savlv23 = stats.get_int(mpx.."SALV23_GEN_BS")
                a.canSkipPreps = (a.savlv23 & (1 << 0)) ~= 0
                a.robbery = tunables.get_int("SALV23_VEHICLE_ROBBERY_"..a.slot)
                a.vehicle = tunables.get_int("SALV23_VEHICLE_ROBBERY_ID_"..a.slot) - 1
                a.canKeep = tunables.get_bool("SALV23_VEHICLE_ROBBERY_CAN_KEEP_"..a.slot)

                a.loaded = nil
            end

            function tab4.render() -- ANCHOR render
                tasks.tasks.thing_salvageyard_robbery_tick = tick

                if a.loaded == false then
                    return
                end

                do
                    ImGui.PushItemWidth(342)
                    local value, changed = ImGui.SliderInt("Slot", a.slot, 1, 3)
                    if changed then
                        a.slot = value
                    end
                    ImGui.PopItemWidth()
                end

                ImGui.BeginGroup()
                ImGui.Text("Robbery ["..tostring(a.robbery).."]")
                if ImGui.BeginListBox("##robbery_list", 150, 262) then
                    for k, v in pairs(a.robberies) do
                        local selected = a.robbery == k
                        if ImGui.Selectable(v, selected) and not selected then
                            tasks.addTask(function()
                                tunables.set_int("SALV23_VEHICLE_ROBBERY_"..a.slot, k)
                            end)
                        end
                        yu.rendering.tooltip(k)
                    end

                    ImGui.EndListBox()
                end
                ImGui.EndGroup()

                ImGui.SameLine()

                ImGui.BeginGroup()
                ImGui.Text("Vehicle ["..tostring(a.vehicle).."]")

                ImGui.PushItemWidth(180)
                do
                    local resp = yu.rendering.input("text", {
                        label = "##vehicle_search",
                        hint = "Search...",
                        text = a.vehicleSearch
                    })
                    SussySpt.pushDisableControls(ImGui.IsItemActive())
                    if resp ~= nil and resp.changed then
                        a.vehicleSearch = resp.text:lowercase()
                    end
                end
                ImGui.PopItemWidth()

                if ImGui.BeginListBox("##vehicle_list", 180, 224) then
                    for k, v in pairs(a.translatedVehicles) do
                        if a.vehicles[k]:contains(a.vehicleSearch) or v:lowercase():contains(a.vehicleSearch) then
                            local selected = a.vehicle == k
                            if ImGui.Selectable(v, selected) and not selected then
                                tasks.addTask(function()
                                    tunables.set_int("SALV23_VEHICLE_ROBBERY_ID_"..a.slot, k + 1)
                                end)
                            end
                            if ImGui.IsItemHovered() then
                                ImGui.SetTooltip(a.vehicles[k])
                            end
                        end
                    end

                    ImGui.EndListBox()
                end
                ImGui.EndGroup()

                ImGui.SameLine()

                ImGui.BeginGroup()

                ImGui.Text("Options")

                do
                    local state, toggled = ImGui.Checkbox("Can keep", a.canKeep)
                    yu.rendering.tooltip("Allows you to buy the vehicle")
                    if toggled then
                        tunables.set_bool("SALV23_VEHICLE_ROBBERY_CAN_KEEP_"..a.slot, state)
                    end
                end

                ImGui.EndGroup()

                ImGui.Spacing()

                ImGui.BeginDisabled(not a.canSkipPreps)
                if ImGui.Button("Skip preps") then
                    tasks.addTask(function()
                        stats.set_int(yu.mpx("SALV23_FM_PROG"), -1)
                    end)
                end
                ImGui.EndDisabled()

                ImGui.Separator()

                ImGui.Text("Weekly cooldown")

                ImGui.SameLine()

                if ImGui.Button("Remove") then
                    tasks.addTask(function()
                        tunables.set_int(values.t.salvageyard_week, stats.get_int("MPX_SALV23_WEEK_SYNC") + 1)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Restore") then
                    tasks.addTask(function()
                        tunables.set_int(values.t.salvageyard_week, stats.get_int("MPX_SALV23_WEEK_SYNC"))
                    end)
                end

                ImGui.Spacing()

                ImGui.Text("Robbery delay")
                ImGui.SameLine()
                do
                    ImGui.PushItemWidth(148)
                    local resp = yu.rendering.input("int", {
                        label = "##cooldown_input",
                        value = a.cooldown.value
                    })
                    if resp ~= nil and resp.changed then
                        a.cooldown.value = resp.value
                    end
                    ImGui.PopItemWidth()
                    yu.rendering.tooltip("Sets the cooldown below in seconds.\n'An error has occurred. There is a short delay before you can start another robbery.'")
                end

                ImGui.SameLine()

                if ImGui.Button("Set##cooldown") then
                    tasks.addTask(function()
                        a.cooldown:set(a.cooldown.value)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Get##cooldown") then
                    tasks.addTask(function()
                        a.cooldown.value = a.cooldown:get()
                    end)
                end
            end

            tab3.sub[1] = tab4
        end -- !SECTION

        tab2.sub[5] = tab3
    end -- !SECTION

    do -- SECTION Motorcycle Club
        local tab3 = SussySpt.rendering.newTab("Motorcycle Club")

        tab2.sub[6] = tab3
    end -- !SECTION

    do -- SECTION Organization
        local tab3 = SussySpt.rendering.newTab("Organization")

        tab2.sub[7] = tab3
    end -- !SECTION

    do -- SECTION Bunker
        local tab3 = SussySpt.rendering.newTab("Bunker")

        tab2.sub[8] = tab3
    end -- !SECTION

    do -- SECTION Arcade
        local tab3 = SussySpt.rendering.newTab("Arcade")

        do -- SECTION Heist
            local tab4 = SussySpt.rendering.newTab("Heist")

            local a = {
                targets = {
                    [0] = "Cash",
                    [1] = "Gold",
                    [2] = "Art",
                    [3] = "Diamonds",
                },
                approaches = {
                    [1] = "Normal - Silent & Sneaky",
                    [2] = "Normal - BigCon",
                    [3] = "Normal - Aggressive",
                    [4] = "Hard - Silent & Sneaky",
                    [5] = "Hard - BigCon",
                    [6] = "Hard - Aggressive"
                },
                gunmans = {
                    [1] = "Karl Abolaji (5%)",
                    [2] = "Gustavo Mota (9%)",
                    [3] = "Charlie Reed (7%)",
                    [4] = "Chester McCoy (10%)",
                    [5] = "Patrick McReary (8%)",
                    [7] = "None"
                },
                weaponvariations = {
                    [0] = "Worst",
                    [1] = "Best"
                },
                drivers = {
                    [1] = "Karim Denz (5%)",
                    [4] = "Zach Nelson (6%)",
                    [2] = "Taliana Martinez (7%)",
                    [3] = "Eddie Toh (9%)",
                    [5] = "Chester McCoy (10%)"
                },
                vehiclevariations = {
                    [0] = "Worst",
                    [1] = "Fine",
                    [2] = "Good",
                    [3] = "Best"
                },
                hackers = {
                    [1] = "Rickie Lukens (3%)",
                    [2] = "Christian Feltz (7%)",
                    [3] = "Yohan Blair (5%)",
                    [4] = "Avi Schwartzman (10%)",
                    [5] = "Page Harris (9%)",
                    [6] = "None"
                },
                masks = {
                    [-1] = "None",
                    [1] = "Geometic Set",
                    [2] = "Hunter Set",
                    [3] = "Oni Half Mask Set",
                    [4] = "Emoji Set",
                    [5] = "Ornate Skull Set",
                    [6] = "Lucky Fruit Set",
                    [7] = "Guerilla Set",
                    [8] = "Clown Set",
                    [9] = "Animal Set",
                    [10] = "Riot Set",
                    [11] = "Oni Full Mask Set",
                    [12] = "Hockey Set"
                },
                guardstrengthes = {
                    [0] = "Strongest",
                    [1] = "Strong",
                    [2] = "Weak",
                    [3] = "Weakest"
                }
            }

            local function getApproach()
                local a,b,c,d=stats.get_int(yu.mpx("H3_LAST_APPROACH")),stats.get_int(yu.mpx("H3_HARD_APPROACH")),stats.get_int(yu.mpx("H3_APPROACH")),stats.get_int(yu.mpx("H3OPT_APPROACH"))
                if a==3 and b==2 and c==1 and d==1 then return 1
                elseif a==3 and b==1 and c==2 and d==2 then return 2
                elseif a==1 and b==2 and c==3 and d==3 then return 3
                elseif a==2 and b==1 and c==3 and d==1 then return 4
                elseif a==1 and b==2 and c==3 and d==2 then return 5
                elseif a==2 and b==3 and c==1 and d==3 then return 6
                end
                return -1
            end

            local function refreshStats()
                a.target = stats.get_int(yu.mpx().."H3OPT_TARGET")
                addUnknownValue(a.targets, a.target)

                a.approach = getApproach()
                if a.approach == -1 then
                    a.approaches[a.approach] = "Failed to figure out the approach"
                else
                    addUnknownValue(a.approaches, a.approach)
                end

                a.gunman = stats.get_int(yu.mpx().."H3OPT_CREWWEAP")
                addUnknownValue(a.gunmans, a.gunman)

                a.weaponvariation = stats.get_int(yu.mpx("H3OPT_WEAPS"))
                if a.weaponvariation ~= 0 or a.weaponvariation ~= 1 then
                    a.weaponvariation = 0
                end

                a.driver = stats.get_int(yu.mpx().."H3OPT_CREWDRIVER")
                addUnknownValue(a.drivers, a.driver)

                a.vehiclevariation = stats.get_int(yu.mpx("H3OPT_VEHS"))
                addUnknownValue(a.vehiclevariations, a.vehiclevariation)

                a.hacker = stats.get_int(yu.mpx("H3OPT_CREWHACKER"))
                addUnknownValue(a.hackers, a.hacker)

                a.mask = stats.get_int(yu.mpx().."H3OPT_MASKS")
                addUnknownValue(a.masks, a.mask)

                a.guardstrength = stats.get_int(yu.mpx("H3OPT_DISRUPTSHIP"))
                addUnknownValue(a.guardstrengthes, a.guardstrength)

                a.splvl = stats.get_int(yu.mpx("H3OPT_KEYLEVELS"))
                if yu.is_num_between(a.splvl, 0, 2) then
                    a.splvl = 2
                end
            end
            tasks.addTask(refreshStats)

            local function refreshCuts()
                a.cuts = {}
            end
            refreshCuts()

            local function refreshExtra()
                -- if yu.is_script_running("fm_mission_controller") then
                --     a.lifes = locals.get_int("fm_mission_controller", 27400)
                -- else
                --     a.lifes = 0
                -- end
            end
            -- refreshExtra()

            local cooldowns = {}
            local function updateCooldowns()
                for k, v in pairs({"H3_COMPLETEDPOSIX", "MPPLY_H3_COOLDOWN"}) do
                    cooldowns[k] = " "..v..": "..yu.format_seconds(stats.get_int(yu.mpx(v)) - os.time())
                end
            end
            tasks.addTask(updateCooldowns)


            function tab4.render()
                ImGui.Text("To skip the first scopeout mission, use the heisteditor, unlock cancellation, and call lester to cancel the heist")
                ImGui.Spacing()

                ImGui.PushItemWidth(360)
                do
                    local appr = yu.rendering.renderList(a.approaches, a.approach, "hbo_casino_app", "Approach")
                    if appr.changed then
                        yu.notify(1, "Set Approach to "..a.approaches[appr.key].." ["..appr.key.."]", "Diamond Casino Heist")
                        a.approach = appr.key
                        a.approachchanged = true
                    end

                    local tr = yu.rendering.renderList(a.targets, a.target, "hbo_casino_t", "Target")
                    if tr.changed then
                        yu.notify(1, "Set Target to "..a.targets[tr.key].." ["..tr.key.."]", "Diamond Casino Heist")
                        a.target = tr.key
                        a.targetchanged = true
                    end

                    local gmr = yu.rendering.renderList(a.gunmans, a.gunman, "hbo_casino_gm", "Gunman")
                    if gmr.changed then
                        yu.notify(1, "Set Gunman to "..a.gunmans[gmr.key].." ["..gmr.key.."]", "Diamond Casino Heist")
                        a.gunman = gmr.key
                        a.gunmanchanged = true
                    end

                    local wwr = yu.rendering.renderList(a.weaponvariations, a.weaponvariation, "hbo_casino_ww", "Weapon variation")
                    if wwr.changed then
                        yu.notify(1, "Set Weapon variation to "..a.weaponvariations[wwr.key].." ["..wwr.key.."]", "Diamond Casino Heist")
                        a.weaponvariation = wwr.key
                    end

                    local dr = yu.rendering.renderList(a.drivers, a.driver, "hbo_casino_d", "Driver")
                    if dr.changed then
                        yu.notify(1, "Set Driver to "..a.drivers[dr.key].." ["..dr.key.."]", "Diamond Casino Heist")
                        a.driver = dr.key
                        a.driverchanged = true
                    end

                    local vvr = yu.rendering.renderList(a.vehiclevariations, a.vehiclevariation, "hbo_casino_vv", "Vehicle variation")
                    if vvr.changed then
                        yu.notify(1, "Set Vehicle variation to "..a.vehiclevariations[vvr.key].." ["..vvr.key.."]", "Diamond Casino Heist")
                        a.vehiclevariation = vvr.key
                        a.vehiclevariationchanged = true
                    end

                    local hr = yu.rendering.renderList(a.hackers, a.hacker, "hbo_casino_h", "Hacker")
                    if hr.changed then
                        yu.notify(1, "Set Hacker to "..a.hackers[hr.key].." ["..hr.key.."]", "Diamond Casino Heist")
                        a.hacker = hr.key
                        a.hackerchanged = true
                    end

                    local mr = yu.rendering.renderList(a.masks, a.mask, "hbo_casino_m", "Mask")
                    if mr.changed then
                        yu.notify(1, "Set Mask to "..a.masks[mr.key].." ["..mr.key.."]", "Diamond Casino Heist")
                        a.mask = mr.key
                        a.maskchanged = true
                    end

                    local gsr = yu.rendering.renderList(a.guardstrengthes, a.guardstrength, "hbo_casino_gs", "Guard strength")
                    if gsr.changed then
                        yu.notify(1, "Set Guard strength to "..a.guardstrengthes[gsr.key].." ["..gsr.key.."]", "Diamond Casino Heist")
                        a.guardstrength = gsr.key
                    end

                    local spLvlValue, spLvlChanged = ImGui.SliderInt("Security pass level", a.splvl, 0, 2)
                    if spLvlChanged then
                        a.splvl = spLvlValue
                    end

                end

                ImGui.PopItemWidth()

                ImGui.Spacing()

                if ImGui.Button("Apply") then
                    tasks.addTask(function()
                        local changes = 0

                        -- Approach
                        if a.approachchanged then
                            changes = changes + 1
                            local k = a.approach
                            if k == 1 then
                                stats.set_int(yu.mpx().."H3_LAST_APPROACH", 3)
                                stats.set_int(yu.mpx().."H3_HARD_APPROACH", 2)
                                stats.set_int(yu.mpx().."H3_APPROACH", 1)
                                stats.set_int(yu.mpx().."H3OPT_APPROACH", 1)
                            elseif k == 2 then
                                stats.set_int(yu.mpx().."H3_LAST_APPROACH", 3)
                                stats.set_int(yu.mpx().."H3_HARD_APPROACH", 1)
                                stats.set_int(yu.mpx().."H3_APPROACH", 2)
                                stats.set_int(yu.mpx().."H3OPT_APPROACH", 2)
                            elseif k == 3 then
                                stats.set_int(yu.mpx().."H3_LAST_APPROACH", 1)
                                stats.set_int(yu.mpx().."H3_HARD_APPROACH", 2)
                                stats.set_int(yu.mpx().."H3_APPROACH", 3)
                                stats.set_int(yu.mpx().."H3OPT_APPROACH", 3)
                            elseif k == 4 then
                                stats.set_int(yu.mpx().."H3_LAST_APPROACH", 2)
                                stats.set_int(yu.mpx().."H3_HARD_APPROACH", 1)
                                stats.set_int(yu.mpx().."H3_APPROACH", 3)
                                stats.set_int(yu.mpx().."H3OPT_APPROACH", 1)
                            elseif k == 5 then
                                stats.set_int(yu.mpx().."H3_LAST_APPROACH", 1)
                                stats.set_int(yu.mpx().."H3_HARD_APPROACH", 2)
                                stats.set_int(yu.mpx().."H3_APPROACH", 3)
                                stats.set_int(yu.mpx().."H3OPT_APPROACH", 2)
                            elseif k == 6 then
                                stats.set_int(yu.mpx().."H3_LAST_APPROACH", 2)
                                stats.set_int(yu.mpx().."H3_HARD_APPROACH", 3)
                                stats.set_int(yu.mpx().."H3_APPROACH", 1)
                                stats.set_int(yu.mpx().."H3OPT_APPROACH", 3)
                            end
                        end

                        -- Target
                        if a.targetchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx("H3OPT_TARGET"), a.target)
                        end

                        -- Gunman
                        if a.gunmanchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx("H3OPT_CREWWEAP"), a.gunman)
                        end

                        -- Weapon variation
                        if a.weaponvariationchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx("H3OPT_WEAPS"), a.weaponvariation)
                        end

                        -- Driver
                        if a.driverchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H3OPT_CREWDRIVER", a.driver)
                        end

                        -- Vehicle variation
                        if a.vehiclevariationchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx("H3OPT_VEHS"), a.vehiclevariation)
                        end

                        -- Hacker
                        if a.hackerchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H3OPT_CREWHACKER", a.hacker)
                        end

                        -- Mask
                        if a.maskchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H3OPT_MASKS", a.mask)
                        end

                        yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied.", "Diamond Casino Heist")
                        for k, v in pairs(a) do
                            if tostring(k):endswith("changed") then
                                a[k] = nil
                            end
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Refresh##stats") then
                    tasks.addTask(refreshStats)
                end

                -- ImGui.SameLine()

                -- if ImGui.Button("Reload planning board") then
                --     tasks.addTask(function()
                --         local oldBS0 = stats.get_int("H3OPT_BITSET0")
                --         local oldBS1 = stats.get_int("H3OPT_BITSET1")
                --         local integerLimit = 2147483647
                --         stats.set_int("H3OPT_BITSET0", math.random(integerLimit))
                --         stats.set_int("H3OPT_BITSET1", math.random(integerLimit))
                --         tasks.addTask(function()
                --             stats.set_int("H3OPT_BITSET0", oldBS0)
                --             stats.set_int("H3OPT_BITSET1", oldBS1)
                --         end)
                --     end)
                -- end
                -- yu.rendering.tooltip("I think this only works when opened")

                if ImGui.Button("Unlock POI & accesspoints") then
                    tasks.addTask(function()
                        local mpx = yu.mpx()
                        stats.set_int(mpx.."H3OPT_POI", -1)
                        stats.set_int(mpx.."H3OPT_ACCESSPOINTS", -1)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Remove npc cuts") then
                    tasks.addTask(function()
                        local b = 262145

                        -- Lester
                        globals.set_int(b + 28998, 0)

                        -- Gunman, Driver, and Hacker
                        for k, v in ipairs({29024, 29029, 29035}) do
                            for i = 0, 4 do
                                globals.set_int(b + v + i, 0)
                            end
                        end
                    end)
                end

                if ImGui.Button("Complete Preps") then
                    tasks.addTask(function()
                        local mpx = yu.mpx()
                        stats.set_int(mpx.."H3OPT_DISRUPTSHIP", a.guardstrength)
                        stats.set_int(mpx.."H3OPT_KEYLEVELS", a.splvl)
                        stats.set_int(mpx.."H3OPT_VEHS", 3)
                        stats.set_int(mpx.."H3OPT_WEAPS", a.weaponvariation)
                        stats.set_int(mpx.."H3OPT_BITSET0", -1)
                        stats.set_int(mpx.."H3OPT_BITSET1", -1)
                        stats.set_int(mpx.."H3OPT_COMPLETEDPOSIX", -1)
                        yu.notify(1, "You might need to wait some time before the heist is ready")
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset heist") then
                    tasks.addTask(function()
                        local mpx = yu.mpx()
                        stats.set_int(mpx.."H3OPT_BITSET1", 0)
                        stats.set_int(mpx.."H3OPT_BITSET0", 0)
                        stats.set_int(mpx.."H3OPT_POI", 0)
                        stats.set_int(mpx.."H3OPT_ACCESSPOINTS", 0)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Unlock cancellation") then
                    tasks.addTask(function()
                        local mpx = yu.mpx()
                        stats.set_int(mpx.."CAS_HEIST_NOTS", -1)
                        stats.set_int(mpx.."CAS_HEIST_FLOW", -1)
                    end)
                end

                -- ImGui.EndGroup()
                -- ImGui.Separator()
                -- ImGui.BeginGroup()

                -- yu.rendering.bigText("Cuts")

                -- -- SussySpt.renderCutsSlider(a.cuts, 1)
                -- -- SussySpt.renderCutsSlider(a.cuts, 2)
                -- -- SussySpt.renderCutsSlider(a.cuts, 3)
                -- -- SussySpt.renderCutsSlider(a.cuts, 4)
                -- -- SussySpt.renderCutsSlider(a.cuts, -2)

                -- if ImGui.Button("Apply##cuts") then
                --     -- for k, v in pairs(a.cuts) do
                --     --     if k == -2 then
                --     --         globals.set_int(2691426, v)
                --     --     else
                --     --         globals.set_int(1963945 + 1497 + 736 + 92 + k, v)
                --     --     end
                --     -- end
                -- end

                -- ImGui.SameLine()

                -- if ImGui.Button("Refresh##cuts") then
                --     tasks.addTask(refreshCuts)
                -- end

                -- ImGui.EndGroup()
                -- ImGui.Separator()
                -- ImGui.BeginGroup()

                -- yu.rendering.bigText("Extra")

                -- if ImGui.Button("Set all players ready") then
                --     -- tasks.addTask(function()
                --     --     for i = 0, 3 do
                --     --         globals.set_int(1974016 + i, -1)
                --     --     end
                --     -- end)
                -- end

                -- if ImGui.Button("Skip fingerprint hack") then
                --     -- tasks.addTask(function()
                --     --     if SussySpt.requireScript("fm_mission_controller") and locals.get_int("fm_mission_controller", 52964) == 4 then
                --     --         locals.set_int("fm_mission_controller", 52964, 5)
                --     --     end
                --     -- end)
                -- end

                -- ImGui.SameLine()

                -- if ImGui.Button("Skip keypad hack") then
                --     -- tasks.addTask(function()
                --     --     if SussySpt.requireScript("fm_mission_controller")
                --     --         and locals.get_int("fm_mission_controller", 54026) ~= 4 then
                --     --         locals.set_int("fm_mission_controller", 54026, 5)
                --     --     end
                --     -- end)
                -- end

                -- ImGui.SameLine()

                -- if ImGui.Button("Skip vault door drill") then
                --     -- tasks.addTask(function()
                --     --     if SussySpt.requireScript("fm_mission_controller") then
                --     --         locals.set_int(
                --     --             "fm_mission_controller",
                --     --             10108,
                --     --             locals.get_int("fm_mission_controller", 10138)
                --     --         )
                --     --     end
                --     -- end)
                -- end

                -- ImGui.Spacing()

                -- if ImGui.Button("Refresh##extra") then
                --     tasks.addTask(refreshExtra)
                -- end

                -- -- local lifesValue, lifesChanged = ImGui.SliderInt("Lifes", a.lifes, 0, 10)
                -- -- yu.rendering.tooltip("Not tested")
                -- -- if lifesChanged then
                -- --     a.lifes = lifesValue
                -- -- end

                -- -- ImGui.SameLine()

                -- -- if ImGui.Button("Apply##lifes") then
                -- --     if SussySpt.requireScript("fm_mission_controller") then
                -- --         locals.set_int("fm_mission_controller", 27400, a.lifes)
                -- --     end
                -- -- end

                -- ImGui.Separator()

                -- if ImGui.Button("Refresh cooldowns") then
                --     tasks.addTask(updateCooldowns)
                -- end

                -- for k, v in pairs(cooldowns) do
                --     ImGui.Text(v)
                -- end

                -- ImGui.EndGroup()
            end

            tab3.sub[1] = tab4
        end -- !SECTION

        do -- SECTION Games
            local tab4 = SussySpt.rendering.newTab("Games")

            do -- SECTION Go Go Space Monkey
                local tab5 = SussySpt.rendering.newTab("Go Go Space Monkey")

                tab5.script = "ggsm_arcade"
                tab5.scriptHashed = joaat(tab5.script)
                tab5.scriptRunning = false

                tab5.musicStopEvent = "ARCADE_SM_STOP"

                tab5.godmode = false

                tab5.playerShipIndex = 1

                tab5.weapons = {
                    "Default", "Beam", "Cone Spread", "Laser", "Shot", "Shot Rapid", "Spread",
                    "Timed Spread", "Enemy Vulcan", "Cluster Bomb", "Fruit Bowl",
                    "Granana Glasses", "Granana Glasses 2", "Granana Hair", "Granana Spread",
                    "Granana Spread 2", "Exp Shell", "Player Vulcan", "Scatter",
                    "Homing Rocket", "Dual Arch", "Wave Blaster", "Back Vulcan", "Bread Spread",
                    "Smooth IE Spread", "Smooth IE Vulcan", "Dank Cannon", "Dank Rocket",
                    "Dank Homing Rocket", "Dank Scatter", "Dank Spread", "Dank Cluster Bomb",
                    "Acid", "Acid Vulkan", "Marine Launcher", "Marine Spread", "Test Weapon"
                }

                tab5.powerups = {"Decoy", "Nuke", "Repulse", "Shield", "Stun"}
                tab5.powerupSlots = {"Defense", "Special"}
                tab5.powerupSlot = 2

                tab5.sectors = {
                    "Earth", "Asteroid Belt", "Pink Ring", "Yellow Clam", "Dough Ball",
                    "Banana Star", "Boss Rush", "Boss Test"
                }

                function tab5.getTimePlayed()
                    local seconds = MISC.GET_GAME_TIMER() - locals.get_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_stats + values.l.arcadegames_ggsm_playtime)
                    return yu.format_seconds(seconds)
                end

                function tab5.tick()
                    tab5.scriptRunning = yu.is_script_running_hash(tab5.scriptHashed)

                    if tab5.scriptRunning then
                        tab5.playerShipIndex = 1 + (locals.get_int(tab5.script, 703 + 2680) * 56)

                        tab5.lives = locals.get_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_playerlives)
                        tab5.score = locals.get_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_stats + values.l.arcadegames_ggsm_score)
                        tab5.kills = locals.get_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_stats + values.l.arcadegames_ggsm_kills)
                        tab5.powerupsCollected = locals.get_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_stats + values.l.arcadegames_ggsm_powerupscollected)
                        tab5.pos = locals.get_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_entities + tab5.playerShipIndex + values.l.arcadegames_ggsm_position)

                        tab5.timePlayed = MISC.GET_GAME_TIMER() - locals.get_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_stats + values.l.arcadegames_ggsm_playtime)
                        tab5.timePlayedFormatted = yu.format_seconds(tab5.timePlayed)

                        if tab5.godmode then
                            tab5.heal = true
                        end

                        if tab5.heal then
                            locals.set_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_entities + tab5.playerShipIndex + values.l.arcadegames_ggsm_hp, 4)
                            tab5.heal = false
                        end

                        if tab5.weapon ~= nil then
                            locals.set_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_entities + tab5.playerShipIndex + values.l.arcadegames_ggsm_weapontype, tab5.weapon + 1)
                            tab5.weapon = nil
                        end

                        if tab5.powerup ~= nil then
                            locals.set_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_weaponslot + (tab5.powerupSlot + 1), values.l.arcadegames_ggsm_powerups[tab5.powerup + 1])
                            tab5.powerup = nil
                        end

                        if tab5.sector ~= nil then
                            locals.set_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_stats + values.l.arcadegames_ggsm_sector, tab5.sector)
                            tab5.sector = nil
                        end
                    end
                end

                function tab5.render()
                    tasks.tasks.thing_arcade_games_ggsm = tab5.tick

                    if not tab5.scriptRunning then
                        ImGui.Text("The Go Go Space Monkey script is not running")
                        return
                    end

                    do
                        local newvalue, changed = ImGui.InputInt("Lives", tab5.lives)
                        if changed then
                            local value = math.max(1, math.min(100, newvalue))
                            locals.set_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_playerlives, value)
                        end
                    end

                    ImGui.Spacing()

                    do
                        local newvalue, changed = ImGui.InputInt("Score", tab5.score)
                        if changed then
                            local value = math.max(0, math.min(9999999, newvalue))
                            locals.set_int(tab5.script, values.l.arcadegames_ggsm_data + values.l.arcadegames_ggsm_stats + values.l.arcadegames_ggsm_score, value)
                        end
                    end

                    ImGui.Spacing()

                    do
                        local state, toggled = ImGui.Checkbox("Godmode", tab5.godmode)
                        if toggled then
                            tab5.godmode = state
                        end
                    end

                    ImGui.Spacing()

                    if ImGui.Button("Heal") then
                        tab5.heal = true
                    end

                    ImGui.SameLine()

                    if ImGui.Button("Stop Music") then
                        tasks.addTask(function()
                            AUDIO.TRIGGER_MUSIC_EVENT(tab5.musicStopEvent)
                        end)
                    end

                    ImGui.Separator()

                    do
                        ImGui.Text("Weapons")

                        if ImGui.BeginListBox("##weapons_list", 150, 262) then
                            for k, v in pairs(tab5.weapons) do
                                if ImGui.Selectable(v, false) then
                                    tab5.weapon = k
                                end
                            end

                            ImGui.EndListBox()
                        end
                    end

                    ImGui.Separator()

                    do
                        ImGui.Text("Power-Ups")

                        ImGui.Text("  Collected: "..tab5.powerupsCollected)

                        do
                            ImGui.PushItemWidth(342)
                            local value, changed = ImGui.SliderInt("Slot", tab5.powerupSlot, 1, 2, tab5.powerupSlots[tab5.powerupSlot])
                            if changed then
                                tab5.powerupSlot = value
                            end
                            ImGui.PopItemWidth()
                        end

                        if ImGui.BeginListBox("##powerups_list", 150, 262) then
                            for k, v in pairs(tab5.powerups) do
                                if ImGui.Selectable(v, false) then
                                    tab5.powerup = k
                                end
                            end

                            ImGui.EndListBox()
                        end
                    end
                end

                tab4.sub[1] = tab5
            end -- !SECTION

            tab3.sub[2] = tab4
        end -- !SECTION

        tab2.sub[9] = tab3
    end -- !SECTION

    do -- SECTION Nightclub
        local tab3 = SussySpt.rendering.newTab("Nightclub")

        local a = {
            storages = {
                [0] = {
                    "Cargo and Shipments (CEO Office Special Cargo Warehouse or Smuggler's Hangar)",
                    "Cargo and Shipments",
                    50
                },
                [1] = {
                    "Sporting Goods (Gunrunning Bunker)",
                    "Sporting Goods",
                    100
                },
                [2] = {
                    "South American Imports (M/C Cocaine Lockup)",
                    "S. A. Imports",
                    10
                },
                [3] = {
                    "Pharmaceutical Research (M/C Methamphetamine Lab)",
                    "Pharmaceutical Research",
                    20
                },
                [4] = {
                    "Organic Produce (M/C Weed Farm)",
                    "Organic Produce",
                    80
                },
                [5] = {
                    "Printing & Copying (M/C Document Forgery Office)",
                    "Printing & Copying",
                    60
                },
                [6] = {
                    "Cash Creation (M/C Counterfeit Cash Factory)",
                    "Cash Creation",
                    40
                },
            },
            storageflags =
                ImGuiTableFlags.BordersV
                + ImGuiTableFlags.BordersOuterH
                + ImGuiTableFlags.RowBg
        }

        local function refresh()
            a.popularity = stats.get_int(yu.mpx().."CLUB_POPULARITY")

            a.storage = {}
            local storageGlob = globals.get_int(286713)
            for k, v in pairs(a.storages) do
                local stock = stats.get_int(yu.mpx("HUB_PROD_TOTAL_"..k))
                a.storage[k] = {
                    stock.."/"..v[3],
                    "$"..yu.format_num(storageGlob * stock)
                }
            end
        end
        tasks.addTask(refresh)

        local nightclubScript = "am_mp_nightclub"

        local function collectSafeNow()
            locals.set_int(nightclubScript, 732, 1)
        end

        local function ensureScriptAndCollectSafe()
            if yu.is_script_running(nightclubScript) then
                collectSafeNow()
            else
                -- yu.rif(function(fs)
                --     SCRIPT.REQUEST_SCRIPT(nightclubScript)
                --     repeat fs:yield() until SCRIPT.HAS_SCRIPT_LOADED(nightclubScript)
                --     SYSTEM.START_NEW_SCRIPT_WITH_NAME_HASH(joaat(nightclubScript), 3650)
                --     repeat fs:yield() until yu.is_script_running(nightclubScript)
                --     collectSafeNow()
                --     SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(nightclubScript)
                -- end)
                yu.notify(3, "You need to be in your nightclub for this!", "Not implemented yet")
            end
        end

        function tab3.render()
            if ImGui.Button("Refresh") then
                tasks.addTask(refresh)
            end

            ImGui.Separator()

            ImGui.BeginGroup()

            ImGui.PushItemWidth(140)
            local pnv, pc ImGui.InputInt("Popularity", a.popularity, 0, 1000)
            yu.rendering.tooltip("Type number in and then click Set :D")
            ImGui.PopItemWidth()
            if pc then
                a.popularity = pnv
            end

            ImGui.SameLine()

            if ImGui.Button("Set##popularity") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx().."CLUB_POPULARITY", a.popularity)
                    refresh()
                end)
            end
            yu.rendering.tooltip("Set the popularity to the input field")

            ImGui.SameLine()

            if ImGui.Button("Refill##popularity") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx().."CLUB_POPULARITY", 1000)
                    a.popularity = 1000
                    refresh()
                end)
            end
            yu.rendering.tooltip("Set the popularity to 1000")

            if ImGui.Button("Pay now") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("CLUB_PAY_TIME_LEFT"), -1)
                end)
            end
            yu.rendering.tooltip("This will decrease the popularity by 50 and will put $50k in the safe.")

            ImGui.SameLine()

            if ImGui.Button("Collect money") then
                tasks.addTask(ensureScriptAndCollectSafe)
            end
            yu.rendering.tooltip("Experimental")

            ImGui.EndGroup()
            ImGui.BeginGroup()
            yu.rendering.bigText("Storage")

            if ImGui.BeginTable("##storage_table", 3, 3905) then
                ImGui.TableSetupColumn("Goods")
                ImGui.TableSetupColumn("Stock")
                ImGui.TableSetupColumn("Stock price")
                ImGui.TableSetupColumn("Actions")
                ImGui.TableHeadersRow()

                local row = 0
                for k, v in pairs(a.storages) do
                    local storage = a.storage[k]
                    if storage ~= nil then
                        ImGui.TableNextRow()
                        ImGui.PushID(row)
                        ImGui.TableSetColumnIndex(0)
                        ImGui.TextWrapped(v[2])
                        yu.rendering.tooltip(v[1])
                        ImGui.TableSetColumnIndex(1)
                        ImGui.Text(storage[1])
                        ImGui.TableSetColumnIndex(2)
                        ImGui.Text(storage[2])
                        ImGui.PopID()
                        row = row + 1
                    end
                end

                ImGui.EndTable()
            end

            ImGui.EndGroup()
            ImGui.BeginGroup()
            yu.rendering.bigText("Other")

            yu.rendering.renderCheckbox("Remove Tony's cut", "hbo_nightclub_tony", function(state)
                tasks.addTask(function()
                    globals.set_float(286403, yu.shc(state, 0, .025))
                end)
            end)
            yu.rendering.tooltip("Set Tony's cut to 0.\nWhen disabled, the cut will be set back to 0.025.")

            ImGui.EndGroup()
        end

        tab2.sub[10] = tab3
    end -- !SECTION

    do -- SECTION Casino
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
    end -- !SECTION

    tab.sub[2] = tab2
end

return exports
