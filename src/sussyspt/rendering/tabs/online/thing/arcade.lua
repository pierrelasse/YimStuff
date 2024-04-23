local tasks = require("../../../tasks")
local values = require("../../../values")
local addUnknownValue = require("./addUnknownValue")

function exports.register(tab2)
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
end

return exports
