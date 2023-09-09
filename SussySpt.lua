yu = require "yimutils"

SussySpt = {
    version = "1.0.3",
    versionid = 5
}

function SussySpt:new()
    SussySpt:initUtils()

    yu.set_notification_title_prefix("[SussySpt] ")

    local tab = gui.get_tab("SussySpt")
    SussySpt.tab = tab

    tab:add_text("Version: "..SussySpt.version)
    tab:add_text("Version id: "..SussySpt.versionid)

    SussySpt.rendercb = {}
    SussySpt.add_render = function(cb)
        if cb ~= nil then
            SussySpt.rendercb[yu.gun()] = cb
        end
    end

    SussySpt:initRendering(tab)
    tab:add_imgui(function()
        for k, v in pairs(SussySpt.rendercb) do
            v()
        end
    end)

    SussySpt:initTabSelf()
    SussySpt:initTabHBO()
    -- SussySpt:initTabLua()
    SussySpt:initTabQA()

    SussySpt:initTabHeist()
    SussySpt:initTabMisc()
    SussySpt:initTabCMM()

    event.register_handler(menu_event.ChatMessageReceived, function(player_id, chat_message)
        log.info("[CHAT] "..PLAYER.GET_PLAYER_NAME(player_id)..": "..chat_message)
    end)

    script.register_looped("sussyspt", function()
        if SussySpt.invisible == true then
            SussySpt.ensureVis(false, yu.ppid(), yu.veh())
        end
    end)

    yu.notify(1, "Loaded successfully! In freemode: "..yu.boolstring(yu.is_script_running("freemode"), "Yep", "fm script no run so no?"), "Loaded!")
end

function SussySpt:initRendering(tab)
    SussySpt.refreshInOnline = function()
        SussySpt.in_online = yu.is_script_running("freemode")
        return SussySpt.in_online
    end
    SussySpt.refreshInOnline()

    tab:add_separator()
    tab:add_button("Recheck if online", SussySpt.refreshInOnline)
    tab:add_text("Categories:")
    SussySpt.add_render(function()
        yu.rendering.renderCheckbox("Self", "cat_self", function(state) end)
        if SussySpt.in_online then
            yu.rendering.renderCheckbox("HBO", "cat_hbo", function(state) end)
        end

        yu.rendering.renderCheckbox("Quick actions", "cat_qa", function(state) end)

        -- yu.rendering.renderCheckbox("Lua", "cat_lua", function(state) end)
    end)
end

function SussySpt:initUtils()
    run_script = function(name)
        script.run_in_fiber(function(runscript)
            SCRIPT.REQUEST_SCRIPT(name)
            repeat runscript:yield() until SCRIPT.HAS_SCRIPT_LOADED(name)
            SYSTEM.START_NEW_SCRIPT(name, 5000)
            SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(name)
        end)
    end

    function requireScript(name)
        if yu.is_script_running(name) == false then
            yu.notify(3, "Script '"..name.."' is not running!")
            return false
        end
        return true
    end

    function removeAllCameras()
        for _, ent in pairs(entities.get_all_objects_as_handles()) do
            for __, cam in pairs({
                joaat("prop_cctv_cam_01a"), joaat("prop_cctv_cam_01b"),
                joaat("prop_cctv_cam_02a"), joaat("prop_cctv_cam_03a"),
                joaat("prop_cctv_cam_04a"), joaat("prop_cctv_cam_04c"),
                joaat("prop_cctv_cam_05a"), joaat("prop_cctv_cam_06a"),
                joaat("prop_cctv_cam_07a"), joaat("prop_cs_cctv"),
                joaat("p_cctv_s"), joaat("hei_prop_bank_cctv_01"),
                joaat("hei_prop_bank_cctv_02"), joaat("ch_prop_ch_cctv_cam_02a"),
                joaat("xm_prop_x17_server_farm_cctv_01")}) do
                if ENTITY.GET_ENTITY_MODEL(ent) == cam then
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true)
                    ENTITY.DELETE_ENTITY(ent)
                end
            end
        end
    end

    function yesNoBool(bool)
        return yu.boolstring(bool, "yes", "no")
    end

    function iml()
        return "##"..yu.gun()
    end


    tbs = {
        tabs = {},
        getTab = function(tab, name, cat)
            if tab == nil or name == nil then
                return gui.get_tab("void")
            end
            local key = name..
                (function()
                    if cat ~= nil then
                        return "-"..cat
                    end
                    return ""
                end)()
            if tbs.tabs[key] == nil then
                tbs.tabs[key] = tab:add_tab(name..iml())
            end
            return tbs.tabs[key]
        end
    }
end

function SussySpt:initTabSelf()
    SussySpt.ensureVis = function(state, id, veh)
        if state ~= true and state ~= false then
            return nil
        end
        if id ~= nil then
            ENTITY.SET_ENTITY_VISIBLE(id, state, 0)
        end
        if veh ~= nil then
            ENTITY.SET_ENTITY_VISIBLE(veh, state, 0)
        end
    end

    SussySpt.enableVis = function()
        SussySpt.invisible = nil
        SussySpt.ensureVis(true, yu.ppid(), yu.veh())
    end

    yu.rendering.setCheckboxChecked("self_invisible", false)

    local tabBarId = "##self_tabbar"

    local currentMentalState
    local function updateMentalState()
        currentMentalState = stats.get_float("MPPLY_PLAYER_MENTAL_STATE")
    end
    updateMentalState()

    local currentBadsport
    local function updateBadsport()
        currentBadsport = stats.get_bool("MPPLY_CHAR_IS_BADSPORT")
    end
    updateBadsport()
    local badsportEnable = "Enable"..iml()
    local badsportDisable = "Disable"..iml()

    SussySpt.add_render(function()
        if yu.rendering.isCheckboxChecked("cat_self") then
            if ImGui.Begin("Self") then
                ImGui.BeginTabBar(tabBarId)

                if (ImGui.BeginTabItem("General")) then

                    yu.rendering.renderCheckbox("Invisible (Press 'L' to toggle)", "self_invisible", function(state)
                        if state then
                            SussySpt.invisible = true
                        else
                            SussySpt.enableVis()
                        end
                    end)

                    if ImGui.Button("Remove blackscreen") then
                        yu.add_task(function()
                            CAM.DO_SCREEN_FADE_IN(0)
                        end)
                    end

                    ImGui.EndTabItem()
                end

                if SussySpt.in_online then
                    if (ImGui.BeginTabItem("Stats")) then
                        if ImGui.Button("Reset MentalState ["..currentMentalState.."]") then
                            yu.notify(1, "Reset mental state?")
                            updateMentalState()
                        end

                        ImGui.Text("BadSport ["..yu.boolstring(currentBadsport, "yes (L)", "no").."]:")
                        ImGui.SameLine()
                        if ImGui.Button(badsportEnable) then
                            stats.set_int("MPPLY_BADSPORT_MESSAGE", -1)
                            stats.set_int("MPPLY_BECAME_BADSPORT_NUM", -1)
                            stats.set_float("MPPLY_OVERALL_BADSPORT", 60000)
                            stats.set_bool("MPPLY_CHAR_IS_BADSPORT", true)
                        end
                        ImGui.SameLine()
                        if ImGui.Button(badsportDisable) then
                            stats.set_int("MPPLY_BADSPORT_MESSAGE", 0)
                            stats.set_int("MPPLY_BECAME_BADSPORT_NUM", 0)
                            stats.set_float("MPPLY_OVERALL_BADSPORT", 0)
                            stats.set_bool("MPPLY_CHAR_IS_BADSPORT", false)
                        end

                        if ImGui.Button("Remove bounty") then
                            globals.set_int(1 + 2359296 + 5150 + 13, 2880000)
                        end

                        ImGui.EndTabItem()
                    end

                    if (ImGui.BeginTabItem("Unlocks")) then
                        if ImGui.Button("Unlock fast run and reload") then
                            stats.set_int(yu.mpx().."CHAR_ABILITY_1_UNLCK", -1)
                            stats.set_int(yu.mpx().."CHAR_ABILITY_2_UNLCK", -1)
                            stats.set_int(yu.mpx().."CHAR_ABILITY_3_UNLCK", -1)
                            stats.set_int(yu.mpx().."CHAR_FM_ABILITY_1_UNLCK", -1)
                            stats.set_int(yu.mpx().."CHAR_FM_ABILITY_2_UNLCK", -1)
                            stats.set_int(yu.mpx().."CHAR_FM_ABILITY_3_UNLCK", -1)
                            yu.notify(2, "Switch sessions to apply changes", "Balls")
                        end

                        ImGui.EndTabItem()
                    end
                end

                ImGui.EndTabBar()
            end
            ImGui.End()
        end
    end)

    yu.key_listener.add_callback(yu.keys["L"], function()
        if not HUD.IS_PAUSE_MENU_ACTIVE() then
            if SussySpt.invisible == true then
                SussySpt.enableVis()
            else
                SussySpt.invisible = true
            end
            log.info("You are now "..yu.shc(SussySpt.invisible, "invisible", "visible").."!")
        end
    end)

    -- old

    local tab = tbs.getTab(SussySpt.tab, " Self")
    tab:clear()

    tab:add_button("Refresh", function()
        SussySpt:initTabSelf()
    end)
    tab:add_separator()

    tab:add_text("Fast Run and Reload:")
    tab:add_sameline()
    tab:add_button("Add"..iml(), function()
        stats.set_int(yu.mpx().."CHAR_ABILITY_1_UNLCK", -1)
        stats.set_int(yu.mpx().."CHAR_ABILITY_2_UNLCK", -1)
        stats.set_int(yu.mpx().."CHAR_ABILITY_3_UNLCK", -1)
        stats.set_int(yu.mpx().."CHAR_FM_ABILITY_1_UNLCK", -1)
        stats.set_int(yu.mpx().."CHAR_FM_ABILITY_2_UNLCK", -1)
        stats.set_int(yu.mpx().."CHAR_FM_ABILITY_3_UNLCK", -1)
        SussySpt:initTabSelf()
    end)
    tab:add_sameline()
    tab:add_button("Remove"..iml(), function()
        stats.set_int(yu.mpx().."CHAR_ABILITY_1_UNLCK", 0)
        stats.set_int(yu.mpx().."CHAR_ABILITY_2_UNLCK", 0)
        stats.set_int(yu.mpx().."CHAR_ABILITY_3_UNLCK", 0)
        stats.set_int(yu.mpx().."CHAR_FM_ABILITY_1_UNLCK", 0)
        stats.set_int(yu.mpx().."CHAR_FM_ABILITY_2_UNLCK", 0)
        stats.set_int(yu.mpx().."CHAR_FM_ABILITY_3_UNLCK", 0)
        SussySpt:initTabSelf()
    end)

    local function initTabStats()
        local statsTab = tbs.getTab(tab, "  Stats", "self")
        statsTab:clear()

        statsTab:add_button("Refresh", function()
            initTabStats()
        end)
        statsTab:add_separator()

        statsTab:add_text("Marked as:")
        statsTab:add_text("  - Cheater: " .. yesNoBool(stats.get_bool("MPPLY_IS_CHEATER")))
        statsTab:add_text("  - BadSport: " .. yesNoBool(stats.get_bool("MPPLY_WAS_I_BAD_SPORT")))
        statsTab:add_text("  - HighEarner: " .. yesNoBool(stats.get_bool("MPPLY_IS_HIGH_EARNER")))
        statsTab:add_separator()
        statsTab:add_text("Reports:")
        statsTab:add_text("  - Griefing: " .. stats.get_int("MPPLY_GRIEFING"))
        statsTab:add_text("  - Exploits: " .. stats.get_int("MPPLY_EXPLOITS"))
        statsTab:add_text("  - Game Exploits: " .. stats.get_int("MPPLY_GAME_EXPLOITS"))
        statsTab:add_text("  - Text Chat > Annoying Me: " .. stats.get_int("MPPLY_TC_ANNOYINGME"))
        statsTab:add_text("  - Text Chat > Hate Speech: " .. stats.get_int("MPPLY_TC_HATE"))
        statsTab:add_text("  - Voice Chat > Hate Speech: " .. stats.get_int("MPPLY_VC_ANNOYINGME"))
        statsTab:add_text("  - Voice Chat > Hate Speech: " .. stats.get_int("MPPLY_VC_HATE"))
        statsTab:add_text("  - Offensive Language: " .. stats.get_int("MPPLY_OFFENSIVE_LANGUAGE"))
        statsTab:add_text("  - Offensive Tagplate: " .. stats.get_int("MPPLY_OFFENSIVE_TAGPLATE"))
        statsTab:add_text("  - Offensive Content: " .. stats.get_int("MPPLY_OFFENSIVE_UGC"))
        statsTab:add_text("  - Bad Crew Name: " .. stats.get_int("MPPLY_BAD_CREW_NAME"))
        statsTab:add_text("  - Bad Crew Motto: " .. stats.get_int("MPPLY_BAD_CREW_MOTTO"))
        statsTab:add_text("  - Bad Crew Status: " .. stats.get_int("MPPLY_BAD_CREW_STATUS"))
        statsTab:add_text("  - Bad Crew Emblem: " .. stats.get_int("MPPLY_BAD_CREW_EMBLEM"))
        statsTab:add_text("  - Friendly: " .. stats.get_int("MPPLY_FRIENDLY"))
        statsTab:add_text("  - Helpful: " .. stats.get_int("MPPLY_HELPFUL"))
        statsTab:add_separator()
        statsTab:add_text("Other:")

        -- v.tab.self._:add_text("Casino:")
        -- v.tab.self._:add_button("Skip Fingerprint", function()
        --     local i = 52964;
        --     local heist_script = script("fm_mission_controller")
        --     if heist_script and heist_script:is_active() then
        --         if heist_script:get_int(i) == 3 or heist_script:get_int(i) == 4 then
        --             heist_script:set_int(i, 5)
        --         end
        --     end
        --     v:notify(1, "[Casino] Skipped!")
        -- end)
        -- v.tab.self._:add_separator()

        -- v.tab.resetMentalState = v.tab.self._:add_button("Reset MentalState",
        --                                                  function()
        --     stats.set_float(yu.mpx().."PLAYER_MENTAL_STATE", 0)
        --     v:notify(1, "[Self] Reset PLAYER_MENTAL_STATE?")
        -- end)

        -- v.tab.self.stats = {}
        -- v.tab.self.stats._ = v.tab.self._:add_tab(" Stats")
        local function addIntStat(key, stat)
            statsTab:add_text("  - "..key..": "..yu.format_num(stats.get_int(stat)))
        end

        addIntStat("Earned Money", "MPPLY_TOTAL_EVC")
        addIntStat("Spent Money", "MPPLY_TOTAL_SVC")
        addIntStat("Players Killed", "MPPLY_KILLS_PLAYERS")
        addIntStat("Deatsh per player", "MPPLY_DEATHS_PLAYER")
        addIntStat("PvP K/D Ratio", "MPPLY_KILL_DEATH_RATIO")
        addIntStat("Deathmatches Published", "MPPLY_AWD_FM_CR_DM_MADE")
        addIntStat("Races Published", "MPPLY_AWD_FM_CR_RACES_MADE")
        addIntStat("Screenshots Published", "MPPLY_NUM_CAPTURES_CREATED")
        addIntStat("LTS Published", "MPPLY_AWD_FM_CR_RACES_MADE")
        addIntStat("Persons who have played your misions", "MPPLY_AWD_FM_CR_PLAYED_BY_PEEP")
        addIntStat("Likes to missions", "MPPLY_AWD_FM_CR_MISSION_SCORE")
        addIntStat("Traveled (metters)", "MPPLY_CHAR_DIST_TRAVELLED")
        addIntStat("Swiming", yu.mpx().."DIST_SWIMMING")
        addIntStat("Walking", yu.mpx().."DIST_WALKING")
        addIntStat("Running", yu.mpx().."DIST_RUNNING")
        addIntStat("Highest fall without dying", yu.mpx().."LONGEST_SURVIVED_FREEFALL")
        addIntStat("Driving Cars", yu.mpx().."DIST_CAR")
        addIntStat("Driving motorbikes", yu.mpx().."DIST_BIKE")
        addIntStat("Flying Helicopters", yu.mpx().."DIST_HELI")
        addIntStat("Flying Planes", yu.mpx().."DIST_PLANE")
        addIntStat("Driving Botes", yu.mpx().."DIST_BOAT")
        addIntStat("Driving ATVs", yu.mpx().."DIST_QUADBIKE")
        addIntStat("Driving Bicycles", yu.mpx().."DIST_BICYCLE")
        addIntStat("Longest Front Willie", yu.mpx().."LONGEST_STOPPIE_DIST")
        addIntStat("Longest Willie", yu.mpx().."LONGEST_WHEELIE_DIST")
        addIntStat("Largest driving without crashing", yu.mpx().."LONGEST_DRIVE_NOCRASH")
        addIntStat("Longest Jump", yu.mpx().."FARTHEST_JUMP_DIST")
        addIntStat("Longest Jump in Vehicle", yu.mpx().."HIGHEST_JUMP_REACHED")
        addIntStat("Highest Hidraulic Jump", yu.mpx().."LOW_HYDRAULIC_JUMP")
    end

    local function initTabUnlocks()
        local unlocksTab = tbs.getTab(tab, "  Unlocks", "self")
        unlocksTab:clear()

        unlocksTab:add_text("LSCustoms")
        unlocksTab:add_button("Unlock hidden Liveries", function()
            stats.set_int("MPPLY_XMASLIVERIES", -1)
            for i = 1, 20 do
                stats.set_int("MPPLY_XMASLIVERIES" .. i, -1)
            end
        end)

        unlocksTab:add_separator()

        unlocksTab:add_text("LSCarMeet")
        unlocksTab:add_text("  Buy a membership, activate, sit in a test car and go to the track.")
        unlocksTab:add_text("  If your level is not 1, then activate and buy something in the LSCM store.")
        unlocksTab:add_text("  If you've used LS Tuners awards unlock before, all unlocks will be temporary only.")

        unlocksTab:add_button("Unlock Trade Prices for headlights", function()
            for i = 18, 29 do
                stats.set_bool_masked(yu.mpx().."ARENAWARSPSTAT_BOOL0", true, i)
            end
        end)
        unlocksTab:add_button("Unlock podium prize", function()
            stats.set_bool(yu.mpx().."CARMEET_PV_CHLLGE_CMPLT", true)
            stats.set_bool(yu.mpx().."CARMEET_PV_CLMED", false)
        end)

        unlocksTab:add_separator()
        unlocksTab:add_text("Flight School")
        unlocksTab:add_button("Unlock all Gold Medals", function()
            stats.set_int("MPPLY_NUM_CAPTURES_CREATED", 100)
            for i = 0, 9 do
                stats.set_int("MPPLY_PILOT_SCHOOL_MEDAL_" .. i , -1)
                stats.set_int(yu.mpx().."PILOT_SCHOOL_MEDAL_" .. i, -1)
                stats.set_bool(yu.mpx().."PILOT_ASPASSEDLESSON_" .. i, true)
            end
        end)

        unlocksTab:add_separator()

        unlocksTab:add_text("Shooting Stand thing")
        unlocksTab:add_button("Unlock All Shooting Range Rewards", function()
            stats.set_int(yu.mpx().."SR_HIGHSCORE_1", 690)
            stats.set_int(yu.mpx().."SR_HIGHSCORE_2", 1860)
            stats.set_int(yu.mpx().."SR_HIGHSCORE_3", 2690)
            stats.set_int(yu.mpx().."SR_HIGHSCORE_4", 2660)
            stats.set_int(yu.mpx().."SR_HIGHSCORE_5", 2650)
            stats.set_int(yu.mpx().."SR_HIGHSCORE_6", 450)
            stats.set_int(yu.mpx().."SR_TARGETS_HIT", 269)
            stats.set_int(yu.mpx().."SR_WEAPON_BIT_SET", -1)
            stats.set_bool(yu.mpx().."SR_TIER_1_REWARD", true)
            stats.set_bool(yu.mpx().."SR_TIER_3_REWARD", true)
            stats.set_bool(yu.mpx().."SR_INCREASE_THROW_CAP", true)
        end)

        unlocksTab:add_separator()

        unlocksTab:add_text("Arena War")
        unlocksTab:add_button("Unlock Trade Prices for Vehicles", function()
            for i = 1, 16 do
                stats.set_bool_masked(yu.mpx().."ARENAWARSPSTAT_BOOL0", true, i)
            end
            for i = 11, 19 do
                stats.set_bool_masked(yu.mpx().."ARENAWARSPSTAT_BOOL2", true, i)
            end
        end)

        unlocksTab:add_button("Unlock Trade Prices for Headlights", function()
            for i = 18, 29 do
                stats.set_bool_masked(yu.mpx().."ARENAWARSPSTAT_BOOL0", true, i)
            end
        end)
    end

    initTabStats()
    initTabUnlocks()
end

function SussySpt:initTabHBO()
    local toRender = {}
    local function addToRender(cb)
        toRender[yu.gun()] = cb
    end

    local function addUnknownValue(tbl, v)
        if tbl[v] == nil then
            tbl[v] = "??? ["..v.."]"
        end
    end

    local function initCayo()
        local a = {
            primarytargets = {
                [0] = "Sinsimito Tequila $900K|990K",
                [1] = "Ruby Necklace $1M|1,1M",
                [2] = "Bearer Bonds $1,1M|1,12M",
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
            a.primarytarget = stats.get_int(yu.mpx().."H4CNF_TARGET")
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

            a.paintingsamount = yu.get_between_or_default(stats.get_int(yu.mpx("H4LOOT_PAINT_SCOPED")), 0, 7)

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

        refreshStats()

        local cooldowns = {}
        local function updateCooldowns()
            for k, v in pairs({"H4_TARGET_POSIX", "H4_COOLDOWN", "H4_COOLDOWN_HARD"}) do
                cooldowns[k] = " "..v..": "..yu.format_seconds(stats.get_int(yu.mpx()..v) - os.time())
            end
        end
        updateCooldowns()

        addToRender(function()
            if (ImGui.BeginTabItem("Cayo Perico Heist")) then
                ImGui.BeginGroup()
                yu.rendering.bigText("Preperations")

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

                local par, pavc = ImGui.SliderInt("Paintings amount", a.paintingsamount, 0, 7, a.paintingsamount.."##hbo_cayo_paintingsamount", 1)
                if pavc then
                    a.paintingsamount = par
                    a.paintingsamountchanged = true
                end

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

                yu.rendering.renderCheckbox("Cutting powder", "hbo_cayo_cuttingpowder", function(state)
                    a.cuttingpowderchanged = true
                end)
                if ImGui.IsItemHovered() then
                    ImGui.SetTooltip("Pros don't need this ;)")
                end

                ImGui.Spacing()

                if ImGui.Button("Apply") then
                    yu.add_task(function()
                        local changes = 0

                        -- Primary Target
                        if a.primarytargetchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx().."H4CNF_TARGET", a.primarytarget)
                        end

                        -- Fill Compound Storages
                        if a.compoundstoragechanged or a.compoundstorageamountchanged then
                            changes = yu.add(changes, 1)
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
                            changes = yu.add(changes, 1)
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
                        if a.paintingsamountchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx("H4LOOT_PAINT"), a.paintingsamount)
                            stats.set_int(yu.mpx("H4LOOT_PAINT_SCOPED"), a.paintingsamount)
                            stats.set_int(yu.mpx("H4LOOT_PAINT_V"), 189500)
                        end

                        -- Difficulty
                        if a.difficultychanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx().."H4_PROGRESS", a.difficulty)
                        end

                        -- Approach
                        if a.approachchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx().."H4_MISSIONS", a.approach)
                        end

                        -- Weapons
                        if a.weaponchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx().."H4CNF_WEAPONS", a.weapon)
                        end

                        -- Truck Location
                        if a.supplytrucklocationchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx().."H4CNF_TROJAN", a.supplytrucklocation)
                        end

                        -- Cutting Powder
                        if a.cuttingpowderchanged then
                            changes = yu.add(changes, 1)
                            if yu.rendering.isCheckboxChecked("hbo_cayo_cuttingpowder") then
                                stats.set_int(yu.mpx().."H4CNF_TARGET", 3)
                            else
                                stats.set_int(yu.mpx().."H4CNF_TARGET", 2)
                            end
                        end

                        yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied. (Re)enter your kosatka to see changes.", "Cayo Perico Heist")
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Refresh settings") then
                    yu.add_task(refreshStats)
                end

                if ImGui.Button("Unlock accesspoints & approaches") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx().."H4CNF_BS_GEN", -1)
                        stats.set_int(yu.mpx().."H4CNF_BS_ENTR", 63)
                        stats.set_int(yu.mpx().."H4CNF_APPROACH", -1)
                        yu.notify("POI, accesspoints, approaches stuff should be unlocked i think", "Cayo Perico Heist")
                    end)
                end


                if ImGui.Button("Complete Preps") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx().."H4CNF_UNIFORM", -1)
                        stats.set_int(yu.mpx().."H4CNF_GRAPPEL", -1)
                        stats.set_int(yu.mpx().."H4CNF_TROJAN", 5)
                        stats.set_int(yu.mpx().."H4CNF_WEP_DISRP", 3)
                        stats.set_int(yu.mpx().."H4CNF_ARM_DISRP", 3)
                        stats.set_int(yu.mpx().."H4CNF_HEL_DISRP", 3)
                        yu.notify("Preperations completed :)", "Cayo Perico Heist")
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset Preps") then
                    yu.add_task(function()
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

                yu.rendering.bigText("Extra")

                if ImGui.Button("Remove all cameras") then
                    removeAllCameras()
                end

                if ImGui.Button("Skip sewer tunnel cut") then
                    if requireScript("fm_mission_controller_2020")
                        and (locals.get_int("fm_mission_controller_2020", 28446) >= 3
                            or locals.get_int("fm_mission_controller_2020", 28446) <= 6) then
                        locals.set_int("fm_mission_controller_2020", 28446, 6)
                        yu.notify("Skipped sewer tunnel cut (or?)", "Cayo Perico Heist")
                    end
                end

                ImGui.SameLine()

                if ImGui.Button("Skip door hack") then
                    if requireScript("fm_mission_controller_2020")
                        and locals.get_int("fm_mission_controller_2020", 54024) ~= 4 then
                        locals.set_int("fm_mission_controller_2020", 54024, 5)
                        yu.notify("Skipped door hack (or?)", "Cayo Perico Heist")
                    end
                end

                if ImGui.Button("Skip fingerprint hack") then
                    if requireScript("fm_mission_controller_2020")
                        and locals.get_int("fm_mission_controller_2020", 23669) == 4 then
                        locals.set_int("fm_mission_controller_2020", 23669, 5)
                        yu.notify("Skipped fingerprint hack (or?)", "Cayo Perico Heist")
                    end
                end

                ImGui.SameLine()

                if ImGui.Button("Skip plasmacutter cut") then
                    if requireScript("fm_mission_controller_2020") then
                        locals.set_float("fm_mission_controller_2020", 29685 + 3, 100)
                        yu.notify("Skipped plasmacutter cut (or?)", "Cayo Perico Heist")
                    end
                end

                if ImGui.Button("Instant finish (solo only)") then
                    if requireScript("fm_mission_controller_2020") then
                        locals.set_int("fm_mission_controller_2020", 45450, 9)
                        locals.set_int("fm_mission_controller_2020", 46829, 50)
                        yu.notify("Idk if you should use this but i i capitan", "Cayo Perico Heist")
                    end
                end

                ImGui.Spacing()

                if ImGui.Button("Refresh cooldowns") then
                    yu.add_task(updateCooldowns)
                end

                for k, v in pairs(cooldowns) do
                    ImGui.Text(v)
                end



                ImGui.EndGroup()

                ImGui.EndTabItem()
            end
        end)
    end

    local function initNightclub()
        local popularity
        local function updatePopularity()
            popularity = stats.get_int(yu.mpx().."CLUB_POPULARITY")
        end
        updatePopularity()

        addToRender(function()
            if (ImGui.BeginTabItem("Nightclub")) then
                if ImGui.Button("Refresh") then
                    yu.add_task(updatePopularity)
                end

                ImGui.Separator()

                ImGui.Text("Popularity: "..popularity.."/1000")

                if ImGui.Button("Refill popularity") then
                    stats.set_int(yu.mpx().."CLUB_POPULARITY", 1000)
                    yu.add_task(updatePopularity)
                end

                ImGui.EndTabItem()
            end
        end)
    end

    initCayo()
    initNightclub()

    local tabBarId = "##cat_hbo"
    SussySpt.add_render(function()
        if SussySpt.in_online and yu.rendering.isCheckboxChecked("cat_hbo") then
            if ImGui.Begin("HBO (Heists, Businesses & Other)") then
                ImGui.BeginTabBar(tabBarId)

                for k, v in pairs(toRender) do
                    v()
                end

                ImGui.EndTabBar()
            end
            ImGui.End()
        end
    end)
end

function SussySpt:initTabLua()
    local toRender = {}
    local function addToRender(cb)
        toRender[yu.gun()] = cb
    end

    local function initExecuter()
        local emptyString = ""
        local inputText = emptyString
        local errorText = emptyString

        addToRender(function()
            if (ImGui.BeginTabItem("Executer")) then

                if ImGui.Button("Clear") then
                    inputText = emptyString
                end

                ImGui.SameLine()

                if ImGui.Button("Execute") then
                    errorText = emptyString
                    local compiledFunction, errorMessage = loadstring(inputText)
                    if compiledFunction then
                        local success, errorOrResult = pcall(compiledFunction)

                        if not success then
                            errorText = errorOrResult
                        end
                    else
                        errorText = errorMessage or emptyString
                    end
                end

                inputText, _ = ImGui.InputTextMultiline("##cat_lua_executer_input", inputText, 256, 300.0, 150.0, 0)

                if errorText and errorText ~= emptyString then
                    ImGui.Text("Error: "..errorText)
                end

                ImGui.EndTabItem()
            end
        end)
    end

    initExecuter()

    local tabBarId = "##cat_lua"

    SussySpt.add_render(function()
        if yu.rendering.isCheckboxChecked("cat_lua") then
            if ImGui.Begin("Lua") then
                ImGui.BeginTabBar(tabBarId)

                for k, v in pairs(toRender) do
                    v()
                end

                ImGui.EndTabBar()
            end
            ImGui.End()
        end
    end)
end

function SussySpt:initTabQA()
    SussySpt.add_render(function()
        if yu.rendering.isCheckboxChecked("cat_qa") then
            if ImGui.Begin("Quick actions") then
                if ImGui.Button("Heal") then
                    yu.add_task(function()
                        ENTITY.SET_ENTITY_HEALTH(yu.ppid(), PED.GET_PED_MAX_HEALTH(yu.ppid()), 0);
			            PED.SET_PED_ARMOUR(yu.ppid(), PLAYER.GET_PLAYER_MAX_ARMOUR(yu.pid()));
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Refill health") then
                    yu.add_task(function()
                        ENTITY.SET_ENTITY_HEALTH(yu.ppid(), PED.GET_PED_MAX_HEALTH(yu.ppid()), 0);
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Refill armor") then
                    yu.add_task(function()
                        PED.SET_PED_ARMOUR(yu.ppid(), PLAYER.GET_PLAYER_MAX_ARMOUR(yu.pid()));
                    end)
                end

                if ImGui.Button("Clear wanted level") then
                    yu.add_task(function()
                        PLAYER.CLEAR_PLAYER_WANTED_LEVEL(yu.pid())
                    end)
                end

                if ImGui.Button("Repair vehicle") then
                    local veh = yu.veh()
                    if veh ~= nil then
                        VEHICLE.SET_VEHICLE_FIXED(veh)
                        VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, 0.0);
                    end
                end
            end
            ImGui.End()
        end
    end)
end

function SussySpt:initTabHeist()
    local tab = tbs.getTab(SussySpt.tab, " Heists & Stuff idk")
    tab:clear()

    local function initTabCayo()
        local cayoTab = tbs.getTab(tab, "  Cayo Perico Heist", "heists")
        cayoTab:clear()

        local a = {
            primarytargets = {
                [0] = "Tequila $900K",
                [1] = "Necklace $1M",
                [2] = "Bonds $1,1M",
                [3] = "Diamond $1,3M",
                [5] = "Statue $1,9M"
            },
            storages = {
                [1] = "None",
                [2] = "Cash",
                [3] = "Weed",
                [4] = "Coke",
                [5] = "Gold"
            },
            difficulties = {
                [126823] = "Normal",
                [131055] = "Hard"
            },
            approaches = {
                [65283] = "Kosatka",
                [65413] = "Alkonost",
                [65289] = "Velum",
                [65425] = "Stealth Annihilator",
                [65313] = "Patrol Boat",
                [65345] = "Longfin",
                [65535] = "*All*"
            },
            weapons = {
                [1] = "Aggressor",
                [2] = "Conspirator",
                [3] = "Crackshot",
                [4] = "Saboteur",
                [5] = "Marksman"
            },
        }

        local function initTabPreps()
            local prepsTab = tbs.getTab(cayoTab, "   Preps", "cayo")
            prepsTab:clear()

            prepsTab:add_button("Refresh", function()
                initTabPreps()
            end)
            prepsTab:add_separator()

            local function getStorage(i)
                if stats.get_int(yu.mpx().."H4LOOT_CASH_"..i) > 0 then
                    return "Cash ["..stats.get_int(yu.mpx().."H4LOOT_CASH_"..i).."]"
                elseif stats.get_int(yu.mpx().."H4LOOT_WEED_"..i) > 0 then
                    return "Weed ["..stats.get_int(yu.mpx().."H4LOOT_WEED_"..i).."]"
                elseif stats.get_int(yu.mpx().."H4LOOT_COKE_"..i) > 0 then
                    return "Coke ["..stats.get_int(yu.mpx().."H4LOOT_COKE_"..i).."]"
                elseif stats.get_int(yu.mpx().."H4LOOT_GOLD_"..i) > 0 then
                    return "Gold ["..stats.get_int(yu.mpx().."H4LOOT_GOLD_"..i).."]"
                end
                return "None"
            end

            local function getPaintings()
                local v = stats.get_int(yu.mpx().."H4LOOT_PAINT_C")
                if v == 0 then
                    return "Disabled"
                elseif v == 127 then
                    return "Enabled"
                end
                return "???. H4LOOT_PAINT_C="..stats.get_int(yu.mpx().."H4LOOT_PAINT_C")
                    ..",H4LOOT_PAINT_C_SCOPED="..stats.get_int(yu.mpx().."H4LOOT_PAINT_C_SCOPED")
                    ..",H4LOOT_PAINT_V="..stats.get_int(yu.mpx().."H4LOOT_PAINT_V")
            end

            local function getDifficulty()
                local v = stats.get_int(yu.mpx().."H4_PROGRESS")
                if v == 126823 then
                    return "Normal"
                elseif v == 131055 then
                    return "Hard"
                end
                return "???"
            end

            prepsTab:add_text("Primary Target ("..yu.get_or_default(a.primarytargets, stats.get_int(yu.mpx().."H4CNF_TARGET"), "???").." ["..stats.get_int(yu.mpx().."H4CNF_TARGET").."]):")
            for k, v in pairs(a.primarytargets) do
                prepsTab:add_sameline()
                prepsTab:add_button(v..iml(), function()
                    yu.notify(1, "Set 'Primary Target' to "..a.primarytargets[k].." ["..k.."]")
                    stats.set_int(yu.mpx().."H4CNF_TARGET", k)
                    initTabPreps()
                end)
            end

            prepsTab:add_text("Fill Compound Storages ("..getStorage("C").."):")
            for k, v in pairs(a.storages) do
                prepsTab:add_sameline()
                prepsTab:add_button(v..iml(), function()
                    yu.notify(1, "Set 'Fill Compound Storages' to "..getStorage("C").."["..k.."]")

                    if k == 1 then
                        stats.set_int(yu.mpx().."H4LOOT_CASH_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_C_SCOPED", 0)
                    elseif k == 2 then
                        stats.set_int(yu.mpx().."H4LOOT_CASH_C", 255)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_C_SCOPED", 255)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_V", 90000)
                    elseif k == 3 then
                        stats.set_int(yu.mpx().."H4LOOT_CASH_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_C", 255)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_C_SCOPED", 255)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_V", 147870)
                    elseif k == 4 then
                        stats.set_int(yu.mpx().."H4LOOT_CASH_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_C", 255)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_C_SCOPED", 255)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_V", 200095)
                    elseif k == 5 then
                        stats.set_int(yu.mpx().."H4LOOT_CASH_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_C", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_C_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_C", 255)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_C_SCOPED", 255)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_V", 330350)
                    end

                    initTabPreps()
                end)
            end

            prepsTab:add_text("Fill Island Storages ("..getStorage("I").."):")
            for k, v in pairs(a.storages) do
                prepsTab:add_sameline()
                prepsTab:add_button(v..iml(), function()
                    yu.notify(1, "Set 'Fill Island Storages' to "..getStorage("I").."["..k.."]")

                    if k == 1 then
                        stats.set_int(yu.mpx().."H4LOOT_CASH_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_I_SCOPED", 0)
                    elseif k == 2 then
                        stats.set_int(yu.mpx().."H4LOOT_CASH_I", 16777215)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_I_SCOPED", 16777215)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_V", 90000)
                    elseif k == 3 then
                        stats.set_int(yu.mpx().."H4LOOT_CASH_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_I", 16777215)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_I_SCOPED", 16777215)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_V", 147870)
                    elseif k == 4 then
                        stats.set_int(yu.mpx().."H4LOOT_CASH_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_I", 16777215)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_I_SCOPED", 16777215)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_V", 200095)
                    elseif k == 5 then
                        stats.set_int(yu.mpx().."H4LOOT_CASH_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_CASH_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_WEED_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_I", 0)
                        stats.set_int(yu.mpx().."H4LOOT_COKE_I_SCOPED", 0)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_I", 16777215)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_I_SCOPED", 16777215)
                        stats.set_int(yu.mpx().."H4LOOT_GOLD_V", 330350)
                    end

                    initTabPreps()
                end)
            end

            prepsTab:add_text("Add Paintings ("..getPaintings().." ["..stats.get_int(yu.mpx().."H4LOOT_PAINT_C").."]):")
            prepsTab:add_sameline()
            prepsTab:add_button("Enable"..iml(), function()
                stats.set_int(yu.mpx().."H4LOOT_PAINT", 16)
                stats.set_int(yu.mpx().."H4LOOT_PAINT_SCOPED", 16)
                stats.set_int(yu.mpx().."H4LOOT_PAINT_V", 199710)
                stats.set_int(yu.mpx().."H4LOOT_PAINT_C", 0)
                stats.set_int(yu.mpx().."H4LOOT_PAINT_C_SCOPED", 0)
                -- stats.set_int(yu.mpx().."H4LOOT_PAINT_C", 127)
                -- stats.set_int(yu.mpx().."H4LOOT_PAINT_C_SCOPED", 127)
                -- stats.set_int(yu.mpx().."H4LOOT_PAINT_V", 189500)
                yu.notify(1, "Enabled 'Add Paintings'. Value: ["..stats.get_int(yu.mpx().."H4LOOT_PAINT_C").."]")
                initTabPreps()
            end)
            prepsTab:add_sameline()
            prepsTab:add_button("Disable"..iml(), function()
                stats.set_int(yu.mpx().."H4LOOT_PAINT_C", 0)
                stats.set_int(yu.mpx().."H4LOOT_PAINT_C_SCOPED", 0)
                yu.notify(1, "Disabled 'Add Paintings'. Value: ["..stats.get_int(yu.mpx().."H4LOOT_PAINT_C").."]")
                initTabPreps()
            end)

            prepsTab:add_text("Difficulty ("..getDifficulty().." ["..stats.get_int(yu.mpx().."H4_PROGRESS").."]):")
            for k, v in pairs(a.difficulties) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Difficulty' to "..a.difficulties[k].." ["..stats.get_int(yu.mpx().."H4_PROGRESS").."]")
                    stats.set_int(yu.mpx().."H4_PROGRESS", k)
                    initTabPreps()
                end)
            end

            prepsTab:add_text("Approach ("..yu.get_or_default(a.approaches, stats.get_int(yu.mpx().."H4_MISSIONS"), "???").." ["..stats.get_int(yu.mpx().."H4_MISSIONS").."]):")
            for k, v in pairs(a.approaches) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Approach' to "..a.approaches[k].." ["..stats.get_int(yu.mpx().."H4_PROGRESS").."]")
                    stats.set_int(yu.mpx().."H4_MISSIONS", k)
                    initTabPreps()
                end)
            end

            prepsTab:add_text("Weapons ("..yu.get_or_default(a.weapons, stats.get_int(yu.mpx().."H4CNF_WEAPONS"), "???").." ["..stats.get_int(yu.mpx().."H4CNF_WEAPONS").."]):")
            for k, v in pairs(a.weapons) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Weapons' to "..a.weapons[k].." ["..stats.get_int(yu.mpx().."H4CNF_WEAPONS").."]")
                    stats.set_int(yu.mpx().."H4CNF_WEAPONS", k)
                    initTabPreps()
                end)
            end

            prepsTab:add_separator()

            prepsTab:add_button("Unlock all Accesspoints & Approaches", function()
                stats.set_int(yu.mpx().."H4CNF_BS_GEN", -1)
                stats.set_int(yu.mpx().."H4CNF_BS_ENTR", 63)
                stats.set_int(yu.mpx().."H4CNF_APPROACH", -1)
            end)
            prepsTab:add_sameline()
            prepsTab:add_button("Complete Preps", function()
                stats.set_int(yu.mpx().."H4CNF_UNIFORM", -1)
                stats.set_int(yu.mpx().."H4CNF_GRAPPEL", -1)
                stats.set_int(yu.mpx().."H4CNF_TROJAN", 5)
                stats.set_int(yu.mpx().."H4CNF_WEP_DISRP", 3)
                stats.set_int(yu.mpx().."H4CNF_ARM_DISRP", 3)
                stats.set_int(yu.mpx().."H4CNF_HEL_DISRP", 3)
                stats.set_int(yu.mpx().."H4_PLAYTHROUGH_STATUS", 10)
                initTabPreps()
            end)
            prepsTab:add_sameline()
            prepsTab:add_button("Reset Preps", function()
                if requireScript("heist_island_planning") then
                    locals.set_int("heist_island_planning", 1526, 2)
                    yu.notify(1, "Success?")
                end
                initTabPreps()
            end)
        end

        local function initTabExtra()
            local extraTab = tbs.getTab(cayoTab, "   Extra", "cayo")
            extraTab:clear()

            extraTab:add_button("Refresh", function()
                initTabExtra()
            end)
            extraTab:add_separator()

            extraTab:add_button("Remove all cameras", function()
                removeAllCameras()
            end)

            extraTab:add_separator()

            extraTab:add_text("Big Bag (Limit set to 1800->99998)")
            extraTab:add_sameline()
            extraTab:add_button("Enable", function()
                globals.set_int(262145 + 29939, 99998)
            end)
            extraTab:add_sameline()
            extraTab:add_button("Disable", function()
                globals.set_int(262145 + 29939, 1800)
            end)

            extraTab:add_separator()

            extraTab:add_button("Skip FingerPrint Hack", function()
                if requireScript("fm_mission_controller_2020") and locals.get_int("fm_mission_controller_2020", 23669) == 4 then
                    locals.set_int("fm_mission_controller_2020", 23669, 5)
                    yu.notify("Success!", "Skip FingerPrint Hack")
                end
            end)

            extraTab:add_button("Skip PlasmaCutter Cut", function()
                if requireScript("fm_mission_controller_2020") then
                    locals.set_float("fm_mission_controller_2020", 29685 + 3, 100)
                end
            end)

            extraTab:add_button("Skip Sewer Tunnel Cut", function()
                if requireScript("fm_mission_controller_2020") and (locals.get_int("fm_mission_controller_2020", 28446) >= 3
                    or locals.get_int("fm_mission_controller_2020", 28446) <= 6) then
                    locals.set_int("fm_mission_controller_2020", 28446, 6)
                    yu.notify("Success!", "Skip Sewer Tunnel Cut")
                end
            end)

            extraTab:add_button("Skip door hack", function()
                if requireScript("fm_mission_controller_2020") and locals.get_int("fm_mission_controller_2020", 54024) ~= 4 then
                    locals.set_int("fm_mission_controller_2020", 54024, 5)
                end
            end)

            extraTab:add_separator()

            extraTab:add_button("Instant Finish (solo only)", function()
                if requireScript("fm_mission_controller_2020") then
                    locals.set_int("fm_mission_controller_2020", 45450, 9)
                    locals.set_int("fm_mission_controller_2020", 46829, 50)
                end
            end)

            extraTab:add_separator()

            extraTab:add_text("H4_TARGET_POSIX: "..yu.format_seconds(stats.get_int(yu.mpx().."H4_TARGET_POSIX") - os.time()))
            extraTab:add_text("H4_COOLDOWN: "..yu.format_seconds(stats.get_int(yu.mpx().."H4_COOLDOWN") - os.time()))
            extraTab:add_text("H4_COOLDOWN_HARD: "..yu.format_seconds(stats.get_int(yu.mpx().."H4_COOLDOWN_HARD") - os.time()))

            extraTab:add_button("Remove Cooldown (for solo)", function()
                stats.set_int(yu.mpx().."H4_TARGET_POSIX", 1659643454)
                stats.set_int(yu.mpx().."H4_COOLDOWN", 0)
                stats.set_int(yu.mpx().."H4_COOLDOWN_HARD", 0)
            end)

            extraTab:add_button("Remove Cooldown (with friends)", function()
                stats.set_int(yu.mpx().."H4_TARGET_POSIX", 1659429119)
                stats.set_int(yu.mpx().."H4_COOLDOWN", 0)
                stats.set_int(yu.mpx().."H4_COOLDOWN_HARD", 0)
            end)
        end

        initTabPreps()
        initTabExtra()
    end

    local function initTabApar()
        local aparTab = tbs.getTab(tab, "  Apartement Heists", "heists")
        aparTab:clear()

        aparTab:add_text("Complete Preps for fleeca:")
        aparTab:add_text("  Pay for the preparation, start the first")
        aparTab:add_text("  mission and as soon as you are sent to")
        aparTab:add_text("  scout, change the session, come back to")
        aparTab:add_text("  planning room, press «Complete Preps»")
        aparTab:add_text("  white board and press «E» and leave")
        aparTab:add_text("")
        aparTab:add_text("Complete Preps for other heists:")
        aparTab:add_text("  Start the mission and leave after the 1st")
        aparTab:add_text("  cutscene ends, press «Complete Preps»")
        aparTab:add_text("  near white board and press «E»")

        local function initTabPreps()
            local prepsTab = tbs.getTab(aparTab, "   Preps", "apar")
            prepsTab:clear()

            prepsTab:add_button("Complete Preps (any heist)", function()
                stats.set_int(yu.mpx().."HEIST_PLANNING_STAGE", -1)
            end)
            prepsTab:add_sameline()
            prepsTab:add_button("Reset Preps", function()
                stats.set_int(yu.mpx().."HEIST_PLANNING_STAGE", 0)
            end)
        end

        local function initTabExtra()
            local extraTab = tbs.getTab(aparTab, "   Extra", "apar")
            extraTab:clear()

            extraTab:add_button("Skip fleeca hack", function()
                if requireScript("fm_mission_controller") then
                    locals.set_int("fm_mission_controller", 11760 + 24, 7)
                end
            end)

            extraTab:add_button("Skip fleeca drill", function()
                if requireScript("fm_mission_controller") then
                    locals.set_int("fm_mission_controller", 11760 + 24, 7)
                end
            end)

            extraTab:add_button("Instant finish (solo only)", function()
                if requireScript("fm_mission_controller") then
                    locals.set_int("fm_mission_controller", 19710, 12)
                    locals.set_int("fm_mission_controller", 28331 + 1, 99999)
                    locals.set_int("fm_mission_controller", 31587 + 69, 99999)
                end
            end)
        end

        initTabPreps()
        initTabExtra()
    end

    local function initTabCasino()
        local casinoTab = tbs.getTab(tab, "  Diamond Casino Heist", "heists")
        casinoTab:clear()

        local function initTabPreps()
            local prepsTab = tbs.getTab(casinoTab, "   Preps", "dc")
            prepsTab:clear()

            local a = {
                targets = {
                    [0] = "Cash",
                    [1] = "Gold",
                    [2] = "Art",
                    [3] = "Diamonds"
                },
                approaches = {
                    [1] = "Normal - Silent n Sneaky",
                    [2] = "Normal - Big Con",
                    [3] = "Normal - Aggressive",
                    [4] = "Hard - Silent n Sneaky",
                    [5] = "Hard - Big Con",
                    [6] = "Hard - Aggressive"
                },
                gunmans = {
                    [1] = "Karl Abolaji (5%)",
                    [3] = "Charlie Reed (7%)",
                    [5] = "Patrick McReary (8%)",
                    [2] = "Gustavo Mota (9%)",
                    [4] = "Chester McCoy (10%)"
                },
                drivers = {
                    [1] = "Karim Deniz (5%)",
                    [4] = "Zach Nelson (6%)",
                    [2] = "Taliana Martinez (7%)",
                    [3] = "Eddie Toh (9%)",
                    [5] = "Chester McCoy (10%)"
                },
                hackers = {
                    [1] = "Rickie Lukens (3%)",
                    [3] = "Yohan Blair (5%)",
                    [2] = "Christian Feltz (7%)",
                    [5] = "Page Harris (9%)",
                    [4] = "Avi Schwartzman (10%)"
                },
                masks = {
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
                }
            }

            local function getApproach()
                local a,b,c,d=stats.get_int(yu.mpx().."H3_LAST_APPROACH"),stats.get_int(yu.mpx().."H3_HARD_APPROACH"),stats.get_int(yu.mpx().."H3_APPROACH"),stats.get_int(yu.mpx().."H3OPT_APPROACH")
                if a==3 and b==2 and c==1 and d==1 then return 1
                elseif a==3 and b==1 and c==2 and d==2 then return 2
                elseif a==1 and b==2 and c==3 and d==3 then return 3
                elseif a==2 and b==1 and c==3 and d==1 then return 4
                elseif a==1 and b==2 and c==3 and d==2 then return 5
                elseif a==2 and b==3 and c==1 and d==3 then return 6
                end
            end

            prepsTab:add_text("Target ("..yu.get_or_default(a.targets, stats.get_int(yu.mpx().."H3OPT_TARGET")).." ["..stats.get_int(yu.mpx().."H3OPT_TARGET").."]):")
            for k, v in pairs(a.targets) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Target' to "..a.targets[k].." ["..k.."]")
                    stats.set_int(yu.mpx().."H3OPT_CREWWEAP", k)
                end)
            end

            prepsTab:add_text("Approach ("..(getApproach() or "???").."):")
            for k, v in pairs(a.approaches) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Approach' to "..a.approaches[k].." ["..k.."]")
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
                end)
            end

            prepsTab:add_text("Gunman ("..yu.get_or_default(a.gunmans, stats.get_int(yu.mpx().."H3OPT_CREWWEAP")).." ["..stats.get_int(yu.mpx().."H3OPT_CREWWEAP").."]):")
            for k, v in pairs(a.gunmans) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Gunman' to "..a.gunmans[k].." ["..k.."]")
                    stats.set_int(yu.mpx().."H3OPT_CREWWEAP", k)
                end)
            end

            prepsTab:add_text("Driver ("..yu.get_or_default(a.drivers, stats.get_int(yu.mpx().."H3OPT_CREWDRIVER")).." ["..stats.get_int(yu.mpx().."H3OPT_CREWDRIVER").."]):")
            for k, v in pairs(a.drivers) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Driver' to "..a.drivers[k].." ["..k.."]")
                    stats.set_int(yu.mpx().."H3OPT_CREWDRIVER", k)
                end)
            end

            prepsTab:add_text("Hacker ("..yu.get_or_default(a.hackers, stats.get_int(yu.mpx().."H3OPT_CREWHACKER")).." ["..stats.get_int(yu.mpx().."H3OPT_CREWHACKER").."]):")
            for k, v in pairs(a.hackers) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Hacker' to "..a.hackers[k].." ["..k.."]")
                    stats.set_int(yu.mpx().."H3OPT_CREWHACKER", k)
                end)
            end

            prepsTab:add_text("Mask ("..yu.get_or_default(a.masks, stats.get_int(yu.mpx().."H3OPT_MASKS")).." ["..stats.get_int(yu.mpx().."H3OPT_CREWHACKER").."]):")
            for k, v in pairs(a.masks) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Mask' to "..a.masks[k].." ["..k.."]")
                    stats.set_int(yu.mpx().."H3OPT_MASKS", k)
                end)
            end

            prepsTab:add_separator()

            prepsTab:add_button("Unlock all POI & Accesspoints", function()
                stats.set_int(yu.mpx().."H3OPT_POI", -1)
                stats.set_int(yu.mpx().."H3OPT_ACCESSPOINTS", -1)
            end)
            prepsTab:add_sameline()
            prepsTab:add_button("Complete Preps", function()
                stats.set_int(yu.mpx().."H3OPT_DISRUPTSHIP", 3)
                stats.set_int(yu.mpx().."H3OPT_KEYLEVELS", 2)
                stats.set_int(yu.mpx().."H3OPT_VEHS", 3)
                stats.set_int(yu.mpx().."H3OPT_WEAPS", 0)
                stats.set_int(yu.mpx().."H3OPT_BITSET0", -1)
                stats.set_int(yu.mpx().."H3OPT_BITSET1", -1)
                stats.set_int(yu.mpx().."H3OPT_COMPLETEDPOSIX", -1)
                yu.notify(1, "You will need to wait some time for the heist to be ready", "Diamond Casino Heist")
            end)
            prepsTab:add_sameline()
            prepsTab:add_button("Reset Preps", function()
                stats.set_int(yu.mpx().."H3OPT_BITSET1", 0)
                stats.set_int(yu.mpx().."H3OPT_BITSET0", 0)
            end)
            prepsTab:add_sameline()
            prepsTab:add_button("Unlock cancellation", function()
                stats.set_int(yu.mpx().."CAS_HEIST_NOTS", -1)
                stats.set_int(yu.mpx().."CAS_HEIST_FLOW", -1)
            end)
        end

        local function initTabExtra()
            local extraTab = tbs.getTab(casinoTab, "   Extra", "dc")
            extraTab:clear()

            extraTab:add_button("Remove all cameras", function()
                removeAllCameras()
            end)

            extraTab:add_separator()

            extraTab:add_button("Skip fingerprint hack", function()
                if requireScript("fm_mission_controller") and locals.get_int("fm_mission_controller", 52964) == 4 then
                    locals.set_int("fm_mission_controller", 52964, 5)
                end
            end)

            extraTab:add_button("Skip keypad hack", function()
                if requireScript("fm_mission_controller") and locals.get_int("fm_mission_controller", 54026) ~= 4 then
                    locals.set_int("fm_mission_controller", 54026, 5)
                end
            end)

            extraTab:add_button("Skip vault door drill", function()
                if requireScript("fm_mission_controller") then
                    locals.set_int("fm_mission_controller", 10101 + 7, locals.get_int("fm_mission_controller", 10101 + 37))
                end
            end)

            extraTab:add_separator()

            extraTab:add_text("H3_COMPLETEDPOSIX: "..stats.get_int(yu.mpx().."H3_COMPLETEDPOSIX"))
            extraTab:add_text("MPPLY_H3_COOLDOWN: "..yu.format_seconds(stats.get_int("MPPLY_H3_COOLDOWN") - os.time()))
            extraTab:add_button("Refresh cooldowns", function()
                initTabExtra()
            end)
            extraTab:add_sameline()
            extraTab:add_button("Remove cooldown", function()
                stats.set_int(yu.mpx().."H3_COMPLETEDPOSIX", -1)
                stats.set_int("MPPLY_H3_COOLDOWN", -1)
            end)
        end

        initTabPreps()
        initTabExtra()
    end

    local function initTabDDay()
        local ddayTab = tbs.getTab(tab, "  Doomsday", "heists")
        ddayTab:clear()

        local function initTabPreps()
            local prepsTab = tbs.getTab(ddayTab, "   Preps", "dday")
            prepsTab:clear()

            prepsTab:add_text("OneClick:")

            prepsTab:add_button("OneClick Act 1: The Data Breaches Setup", function()
                stats.set_int(yu.mpx().."GANGOPS_FLOW_MISSION_PROG", 7)
                stats.set_int(yu.mpx().."GANGOPS_FM_MISSION_PROG", 7)
            end)

            prepsTab:add_button("OneClick Act 2: The Bodgan Problem Setup", function()
                stats.set_int(yu.mpx().."GANGOPS_FLOW_MISSION_PROG", 240)
                stats.set_int(yu.mpx().."GANGOPS_FM_MISSION_PROG", 248)
            end)

            prepsTab:add_button("OneClick Act 3: Doomsday Scenario Setup", function()
                stats.set_int(yu.mpx().."GANGOPS_FLOW_MISSION_PROG", 15872)
                stats.set_int(yu.mpx().."GANGOPS_FM_MISSION_PROG", 16128)
            end)

            prepsTab:add_separator()

            prepsTab:add_text("Select Doomsday Act:")
            for k, v in pairs({
                [1] = "Data Breaches",
                [2] = "Bogdan Problem",
                [3] = "Doomsday Scenario"
            }) do
                prepsTab:add_button(v, function()
                    if k == 1 then
                        stats.set_int(yu.mpx().."GANGOPS_FLOW_MISSION_PROG", 503)
                        stats.set_int(yu.mpx().."GANGOPS_HEIST_STATUS", 229383)
                        stats.set_int(yu.mpx().."GANGOPS_FLOW_NOTIFICATIONS", 1557)
                    elseif k == 2 then
                        stats.set_int(yu.mpx().."GANGOPS_FLOW_MISSION_PROG", 240)
                        stats.set_int(yu.mpx().."GANGOPS_HEIST_STATUS", 229378)
                        stats.set_int(yu.mpx().."GANGOPS_FLOW_NOTIFICATIONS", 1557)
                    elseif k == 3 then
                        stats.set_int(yu.mpx().."GANGOPS_FLOW_MISSION_PROG", 16368)
                        stats.set_int(yu.mpx().."GANGOPS_HEIST_STATUS", 229380)
                        stats.set_int(yu.mpx().."GANGOPS_FLOW_NOTIFICATIONS", 1557)
                    end
                end)
            end

            prepsTab:add_separator()

            prepsTab:add_button("Complete Preps", function()
                stats.set_int(yu.mpx().."GANGOPS_FM_MISSION_PROG", -1)
            end)

            prepsTab:add_sameline()

            prepsTab:add_button("Reset Preps", function()
                stats.set_int(yu.mpx().."GANGOPS_FLOW_MISSION_PROG", 240)
                stats.set_int(yu.mpx().."GANGOPS_HEIST_STATUS", 0)
                stats.set_int(yu.mpx().."GANGOPS_FLOW_NOTIFICATIONS", 1557)
            end)
        end

        initTabPreps()
    end

    local function initTabAutoshop()
        local asTab = tbs.getTab(tab, "  AutoShop", "heists")
        asTab:clear()

        local a = {
            missions = {
                [0] = "Union Depository",
                [1] = "Superdollar Deal",
                [2] = "Bank Contract",
                [3] = "ECU Job",
                [4] = "Prison Contract",
                [5] = "Agency Deal",
                [6] = "Lost Contract",
                [7] = "Data Contract"
            }
        }

        local function initTabPreps()
            local prepsTab = tbs.getTab(asTab, "   Preps", "autoshop")
            prepsTab:clear()

            prepsTab:add_text("Mission ("..yu.get_or_default(a.missions, stats.get_int(yu.mpx().."TUNER_CURRENT")).." ["..stats.get_int(yu.mpx().."TUNER_CURRENT").."]):")
            for k, v in pairs(a.missions) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Mission' to "..a.missions[k].." ["..k.."]")
                    stats.set_int(yu.mpx().."TUNER_CURRENT", k)
                    initTabPreps()
                end)
            end

            prepsTab:add_separator()

            prepsTab:add_button("Complete Preps", function()
                if stats.get_int(yu.mpx().."TUNER_CURRENT") == 1 then
                    stats.set_int(yu.mpx().."TUNER_GEN_BS", 4351)
                else
                    stats.set_int(yu.mpx().."TUNER_GEN_BS", 12543)
                end
            end)
        end

        local function initTabExtra()
            local extraTab = tbs.getTab(asTab, "   Extra", "autoshop")
            extraTab:clear()

            extraTab:add_button("Instant Finish (solo only)", function()
                if requireScript("fm_mission_controller_2020") then
                    locals.set_int("fm_mission_controller_2020", 45450 + 1, 51338977)
                    locals.set_int("fm_mission_controller_2020", 45450 + 1378 + 1, 101)
                end
            end)

            extraTab:add_button("Cooldown remover", function()
                for i = 0, 7 do
                    stats.set_int(yu.mpx().."TUNER_CONTRACT"..i.."_POSIX")
                end
                initTabExtra()
            end)

            extraTab:add_separator()
            extraTab:add_button("Refresh", function()
                initTabExtra()
            end)

            extraTab:add_text("Cooldowns:")
            for i = 0, 7 do
                extraTab:add_text("  - "..(a.missions[i])..": "..yu.format_seconds(stats.get_int(yu.mpx().."TUNER_CONTRACT"..i.."_POSIX") - os.time()))
            end
        end

        initTabPreps()
        initTabExtra()
    end

    local function initTabOther()
        local otherTab = tbs.getTab(tab, "  Other")
        otherTab:clear()

        otherTab:add_button("Refresh", function()
            initTabOther()
        end)

        otherTab:add_separator()

        otherTab:add_text("Nightclub")

        otherTab:add_text("Popularity: "..stats.get_int(yu.mpx().."CLUB_POPULARITY").."/1000")
        otherTab:add_sameline()
        otherTab:add_button("Refill NightClub Popularity", function()
            stats.set_int(yu.mpx().."CLUB_POPULARITY", 1000)
            initTabOther()
        end)

        otherTab:add_separator()

        otherTab:add_text("Drug Wars")

        otherTab:add_text("Current cooldown: "..yu.format_seconds(stats.get_int(yu.mpx().."XM22JUGGALOWORKCDTIMER") - os.time() + 17))
        otherTab:add_sameline()
        otherTab:add_button("Remove Dax mission cooldown ", function()
            stats.set_int(yu.mpx().."XM22JUGGALOWORKCDTIMER", os.time() - 17)
            initTabOther()
        end)

        otherTab:add_text("Custom production delay ["..globals.get_int(262145+17576).."-135000]:")
        otherTab:add_sameline()
        otherTab:add_button("Set to 1", function()
            globals.set_int(262145+17576, 1)
            initTabOther()
        end)
        otherTab:add_sameline()
        otherTab:add_button("Reset to default", function()
            globals.set_int(262145+17576, 135000)
            initTabOther()
        end)

        otherTab:add_separator()

        otherTab:add_button("Remove VIP/MC cooldown ["..stats.get_int("MPPLY_VIPGAMEPLAYDISABLEDTIMER").."]", function()
            stats.set_int("MPPLY_VIPGAMEPLAYDISABLEDTIMER", 0)
            initTabOther()
        end)

        otherTab:add_separator()

        local function getCrates(amount)
            if requireScript("gb_contraband_buy") then
                locals.set_int("gb_contraband_buy", 604, 1)
                locals.set_int("gb_contraband_buy", 600, amount)
                locals.set_int("gb_contraband_buy", 790, 6)
                locals.set_int("gb_contraband_buy", 791, 4)
            end
        end

        otherTab:add_text("Get warehouse crate instantly:")
        for _, i in ipairs({1, 2, 3, 5, 10, 15, 20, 25, 30, 35}) do
            otherTab:add_sameline()
            otherTab:add_button(i, function() getCrates(i) end)
        end
    end

    initTabCayo()
    initTabApar()
    initTabCasino()
    initTabDDay()
    initTabAutoshop()
    initTabOther()
end

function SussySpt:initTabMisc()
    local tab = tbs.getTab(SussySpt.tab, " Misc")
    tab:clear()

    tab:add_button("Remove all cameras", function()
        removeAllCameras()
    end)

    tab:add_separator()

    tab:add_button("Complete todays objectives (not goals idk + this WILL rate limit so not gud)", function()
        stats.set_int(yu.mpx().."COMPLETEDAILYOBJ", 100)
        stats.set_int(yu.mpx().."COMPLETEDAILYOBJTOTAL", 100)
        stats.set_int(yu.mpx().."TOTALDAYCOMPLETED", 100)
        stats.set_int(yu.mpx().."TOTALWEEKCOMPLETED", 400)
        stats.set_int(yu.mpx().."TOTALMONTHCOMPLETED", 1800)
        stats.set_int(yu.mpx().."CONSECUTIVEDAYCOMPLETED", 30)
        stats.set_int(yu.mpx().."CONSECUTIVEWEEKCOMPLETED", 4)
        stats.set_int(yu.mpx().."CONSECUTIVEMONTHCOMPLETE", 1)
        stats.set_int(yu.mpx().."COMPLETEDAILYOBJSA", 100)
        stats.set_int(yu.mpx().."COMPLETEDAILYOBJTOTALSA", 100)
        stats.set_int(yu.mpx().."TOTALDAYCOMPLETEDSA", 100)
        stats.set_int(yu.mpx().."TOTALWEEKCOMPLETEDSA", 400)
        stats.set_int(yu.mpx().."TOTALMONTHCOMPLETEDSA", 1800)
        stats.set_int(yu.mpx().."CONSECUTIVEDAYCOMPLETEDSA", 30)
        stats.set_int(yu.mpx().."CONSECUTIVEWEEKCOMPLETEDSA", 4)
        stats.set_int(yu.mpx().."CONSECUTIVEMONTHCOMPLETESA", 1)
        stats.set_int(yu.mpx().."AWD_DAILYOBJCOMPLETEDSA", 100)
        stats.set_int(yu.mpx().."AWD_DAILYOBJCOMPLETED", 100)
        stats.set_bool(yu.mpx().."AWD_DAILYOBJMONTHBONUS", true)
        stats.set_bool(yu.mpx().."AWD_DAILYOBJWEEKBONUS", true)
        stats.set_bool(yu.mpx().."AWD_DAILYOBJWEEKBONUSSA", true)
        stats.set_bool(yu.mpx().."AWD_DAILYOBJMONTHBONUSSA", true)
    end)

    tab:add_separator()

    tab:add_button("Skip Lamar missions", function()
        stats.set_bool(yu.mpx().."LOW_FLOW_CS_DRV_SEEN", true)
        stats.set_bool(yu.mpx().."LOW_FLOW_CS_TRA_SEEN", true)
        stats.set_bool(yu.mpx().."LOW_FLOW_CS_FUN_SEEN", true)
        stats.set_bool(yu.mpx().."LOW_FLOW_CS_PHO_SEEN", true)
        stats.set_bool(yu.mpx().."LOW_FLOW_CS_FIN_SEEN", true)
        stats.set_bool(yu.mpx().."LOW_BEN_INTRO_CS_SEEN", true)
        stats.set_int(yu.mpx().."LOWRIDER_FLOW_COMPLETE", 4)
        stats.set_int(yu.mpx().."LOW_FLOW_CURRENT_PROG", 9)
        stats.set_int(yu.mpx().."LOW_FLOW_CURRENT_CALL", 9)
        stats.set_int(yu.mpx().."LOW_FLOW_CS_HELPTEXT", 66)
    end)

    tab:add_button("Skip yacht missions", function()
        stats.set_int(yu.mpx().."YACHT_MISSION_PROG", 0)
        stats.set_int(yu.mpx().."YACHT_MISSION_FLOW", 21845)
        stats.set_int(yu.mpx().."CASINO_DECORATION_GIFT_1", -1)
    end)

    tab:add_button("Skip ULP missions", function()
        stats.set_int(yu.mpx().."ULP_MISSION_PROGRESS", 127)
        stats.set_int(yu.mpx().."ULP_MISSION_CURRENT", 0)
    end)

    tab:add_separator()

    tab:add_text("Kosatka (no work gud):")

    tab:add_text("  - Remove missle cooldown ["..globals.get_int(262145 + 30394).."]:")
    tab:add_sameline()
    tab:add_button("Enable"..iml(), function()
        globals.set_int(262145 + 30394, 0)
    end)
    tab:add_sameline()
    tab:add_button("Disable"..iml(), function()
        globals.set_int(262145 + 30394, 60000)
    end)

    tab:add_text("  - Set missle range to 99999 ["..globals.get_int(262145 + 30395).."]:")
    tab:add_sameline()
    tab:add_button("Enable"..iml(), function()
        globals.set_int(262145 + 30395, 99999)
    end)
    tab:add_sameline()
    tab:add_button("Disable"..iml(), function()
        globals.set_int(262145 + 30395, 4000)
    end)


    local function initTabSnow()
        local snowTab = tbs.getTab(tab, "  Snow", "misc")
        snowTab:clear()

        snowTab:add_button("Enable snow", function()
            globals.set_int(262145 + 4752, 1)
        end)
        snowTab:add_button("Disable snow", function()
            globals.set_int(262145 + 4752, 0)
        end)
    end

    initTabSnow()
end

function SussySpt:initTabCMM()
    local tab = tbs.getTab(SussySpt.tab, " CMM")
    tab:clear()

    tab:add_text("(Computers Management Menu)")
    tab:add_text("Works properly in session by invitations. in an open session does not work well")
        tab:add_button("Show Mastercontrol computer", function()
        local playerIndex = globals.get_int(1574918)
        if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 0 then
            run_script("apparcadebusinesshub")
        else
            if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 1 then
                run_script("apparcadebusinesshub")
            else
                gui.show_message("Don't forget to register as CEO/Leader")
                run_script("apparcadebusinesshub")
            end
        end
    end)
    tab:add_button("Show Nightclub computer", function()
        local playerIndex = globals.get_int(1574918)
        if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 0 then
            run_script("appbusinesshub")
        else
            if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 1 then
                run_script("appbusinesshub")
            else
                gui.show_message("Don't forget to register as CEO/Leader")
                run_script("appbusinesshub")
            end
        end
    end)
    tab:add_button("Show Argentur computer", function()
        local playerIndex = globals.get_int(1574918)
        if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 0 then
            run_script("appfixersecurity")
        else
            if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 1 then
                globals.set_int(1895156 + playerIndex * 609 + 10 + 429 + 1, 0)
                gui.show_message("prompt", "Converted to CEO")
                run_script("appfixersecurity")
            else
                gui.show_message("Don't forget to register as CEO/Leader",
                                 "It may also be a script detection error, known problem, no feedback required")
                run_script("appfixersecurity")
            end
        end
    end)
    tab:add_button("Show Bunker computer", function()
        local playerIndex = globals.get_int(1574918)
        if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 0 then
            run_script("appbunkerbusiness")
        else
            if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 1 then
                run_script("appbunkerbusiness")
            else
                gui.show_message("Don't forget to register as CEO/Leader",
                                 "It may also be a script detection error, known problem, no feedback required")
                run_script("appbunkerbusiness")
            end
        end
    end)
    tab:add_button("Show Hangar computer", function()
        local playerIndex = globals.get_int(1574918)
        if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 0 then
            run_script("appsmuggler")
        else
            if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 1 then
                run_script("appsmuggler")
            else
                gui.show_message("Don't forget to register as CEO/Leader",
                                 "It may also be a script detection error, known problem, no feedback required")
                run_script("appsmuggler")
            end
        end
    end)
    tab:add_button("Show Terrorbyte dashboard", function()
        local playerIndex = globals.get_int(1574918)
        if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 0 then
            run_script("apphackertruck")
        else
            if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 1 then
                run_script("apphackertruck")
            else
                gui.show_message("Don't forget to register as CEO/Leader",
                                 "It may also be a script detection error, known problem, no feedback required")
                run_script("apphackertruck")
            end
        end
    end)
    tab:add_button("Show Avenger panel", function()
        local playerIndex = globals.get_int(1574918)
        if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 0 then
            run_script("appAvengerOperations")
        else
            if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 1 then
                run_script("appAvengerOperations")
            else
                gui.show_message("Don't forget to register as CEO/Leader",
                                 "It may also be a script detection error, known problem, no feedback required")
                run_script("appAvengerOperations")
            end
        end
    end)
    tab:add_button(
        "Show Arcade computer (Work only in Arcad club or invite session)",
        function()
            local playerIndex = globals.get_int(1574918)
            if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 0 then
                run_script("apparcadebusiness")
            else
                if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) ==
                    1 then
                    run_script("apparcadebusiness")
                else
                    gui.show_message("Don't forget to register as CEO/Leader")
                    run_script("apparcadebusiness")
                end
            end
        end)
end

SussySpt:new()
