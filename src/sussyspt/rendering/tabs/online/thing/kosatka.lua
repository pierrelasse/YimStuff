local tasks = require("sussyspt/tasks")
local removeAllCameras = require("sussyspt/util/removeAllCameras")
local addUnknownValue = require("./addUnknownValue")

local exports = {}

function exports.register(tab2)
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
end

return exports
