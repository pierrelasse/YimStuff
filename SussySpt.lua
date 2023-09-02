yu = require "yimutils"

SussySpt = {}

function SussySpt:new()
    SussySpt:initUtils()

    yu.set_notification_title_prefix("[SussySpt]")

    local tab = gui.get_tab("SussySpt")
    SussySpt.tab = tab

    SussySpt:initTabSelf()
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
                return nil
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

function yu.notify(type, message, title)
    local _title = "[SussySpt] " .. (title or "")
    if type == 1 or type == "info" then
        gui.show_message(_title, message)
    elseif type == 2 or type == "warn" or type == "warning" then
        gui.show_warning(_title, message)
    elseif type == 3 or type == "error" or type == "severe" then
        gui.show_error(_title, message)
    end
end

function SussySpt:initTabSelf()
    local tab = tbs.getTab(SussySpt.tab, " Self")
    tab:clear()

    tab:add_button("Refresh", function()
        SussySpt:initTabSelf()
    end)
    tab:add_separator()

    tab:add_button("Remove bounty ["..globals.get_int(1 + 2359296 + 5150 + 13)..">2880000]", function()
        globals.set_int(1 + 2359296 + 5150 + 13, 2880000)
        SussySpt:initTabSelf()
    end)

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

    tab:add_text("BadSport ["..yesNoBool(stats.get_bool("MPPLY_CHAR_IS_BADSPORT")).."]:")
    tab:add_sameline()
    tab:add_button("Add"..iml(), function()
        stats.set_int("MPPLY_BADSPORT_MESSAGE", -1)
        stats.set_int("MPPLY_BECAME_BADSPORT_NUM", -1)
        stats.set_float("MPPLY_OVERALL_BADSPORT", 60000)
        stats.set_bool("MPPLY_CHAR_IS_BADSPORT", true)
        SussySpt:initTabSelf()
    end)
    tab:add_sameline()
    tab:add_button("Remove"..iml(), function()
        stats.set_int("MPPLY_BADSPORT_MESSAGE", 0)
        stats.set_int("MPPLY_BECAME_BADSPORT_NUM", 0)
        stats.set_float("MPPLY_OVERALL_BADSPORT", 0)
        stats.set_bool("MPPLY_CHAR_IS_BADSPORT", false)
        SussySpt:initTabSelf()
    end)

    tab:add_text("Mental State ["..stats.get_float("MPPLY_PLAYER_MENTAL_STATE").."]:")
    tab:add_sameline()
    tab:add_button("Reset"..iml(), function()
        stats.set_float(yu.mpx().."PLAYER_MENTAL_STATE", 0)
        SussySpt:initTabSelf()
    end)

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

    SussySpt.disableInvis = function()
        SussySpt.invisible = nil
        SussySpt.ensureVis(true, yu.ppid(), yu.veh())
    end

    SussySpt.toggleVis = function()
        if SussySpt.invisible == true then
            SussySpt.disableInvis()
        else
            SussySpt.invisible = true
        end
    end

    tab:add_text("Invisible:")
    tab:add_sameline()
    tab:add_button("Enable"..iml(), function()
        SussySpt.invisible = true
    end)
    tab:add_sameline()
    tab:add_button("Disable"..iml(), function()
        SussySpt.disableInvis()
    end)

    yu.key_listener.add_callback(yu.keys["L"], function()
        SussySpt.toggleVis()
        log.info("You are now "..yu.shc(SussySpt.invisible, "invisible", "visible").."!")
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

function SussySpt:initTabHeist()
    local tab = tbs.getTab(SussySpt.tab, " Heist & Missions")
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

            prepsTab:add_text("Primary Target ("..yu.dict_get_or_default(a.primarytargets, stats.get_int(yu.mpx().."H4CNF_TARGET"), "???").." ["..stats.get_int(yu.mpx().."H4CNF_TARGET").."]):")
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
            
            prepsTab:add_text("Approach ("..yu.dict_get_or_default(a.approaches, stats.get_int(yu.mpx().."H4_MISSIONS"), "???").." ["..stats.get_int(yu.mpx().."H4_MISSIONS").."]):")
            for k, v in pairs(a.approaches) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Approach' to "..a.approaches[k].." ["..stats.get_int(yu.mpx().."H4_PROGRESS").."]")
                    stats.set_int(yu.mpx().."H4_MISSIONS", k) 
                    initTabPreps()
                end)
            end

            prepsTab:add_text("Weapons ("..yu.dict_get_or_default(a.weapons, stats.get_int(yu.mpx().."H4CNF_WEAPONS"), "???").." ["..stats.get_int(yu.mpx().."H4CNF_WEAPONS").."]):")
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

        local function initTabCuts()
            local cutsTab = tbs.getTab(aparTab, "   Cuts", "apar")
            cutsTab:clear()

            local a = {
                cashReceivers = {
                    [1] = "All",
                    [2] = "Only Crew",
                    [3] = "Only Me"
                },
                fleeca = false,
                lock = false
            }

            yu.set_stat("TAB_HEISTS_APAR_CR", 1)
            cutsTab:add_text("Cash Receiver ("..yu.dict_get_or_default(a.cashReceivers, yu.get_stat("TAB_HEISTS_APAR_CR")).." ["..yu.get_stat("TAB_HEISTS_APAR_CR").."]):")
            for k, v in pairs(a.cashReceivers) do
                cutsTab:add_sameline()
                cutsTab:add_button(v..iml(), function()
                    yu.notify(1, "Set 'Cash Receiver' to "..a.cashReceivers[k].." ["..k.."]")
                    yu.set_stat("TAB_HEISTS_APAR_CR", k)
                    initTabCuts()
                end)
            end

            -- cutsTab:add_button("Fleeca Job ($15m) ("..boolToStr(a.fleeca, "enabled", "disabled")..")", function()
            --     if a.lock == true then
            --         yu.notify(3, "Button is currently on lock. Please wait")
            --         return
            --     end
            --     a.lock = true
            --     if a.fleeca then
            --         a.fleeca = true
            --         initTabCuts()
            --         script.run_in_fiber(function(sc)
            --             if a.cashReceiver == 1 then
            --                 -- globals.set_int(1936397 + 1 + 1, 100 - (7453 * 2))
            --                 -- globals.set_int(1936397 + 1 + 2, 7453)
            --                 sc:sleep(1)
            --                 menu.send_key_press(13)
            --                 sc:sleep(1)
            --                 menu.send_key_press(27)
            --                 sc:sleep(1)
            --                 -- globals.set_int(1938365 + 3008 + 1, 7453)
            --             elseif a.cashReceiver == 2 then
            --                 -- globals.set_int(1936397 + 1 + 1, 100 - (7453 * 2))
            --                 -- globals.set_int(1936397 + 1 + 2, 7453)
            --                 sc:sleep(1)
            --                 menu.send_key_press(13)
            --                 sc:sleep(1)
            --                 menu.send_key_press(27)
            --             elseif a.cashReceiver == 3 then
            --                 globals.set_int(1938365 + 3008 + 1, 7453)
            --             end
            --             a.lock = false
            --             yu.notify(1, "Applied!", "Fleeca Job ($15m)")
            --         end)
            --     else
            --         -- globals.set_int(1936399, 60)
            --         -- globals.set_int(1936400, 40)
            --         -- globals.set_int(1938365 + 3008 + 1, 60)
            --     end
            --     initTabCuts()
            -- end)
        end

        local function initTabExtra()
            local extraTab = tbs.getTab(aparTab, "   Extra", "apar")
            extraTab:clear()

            extraTab:add_button("Skip Fleeca hack", function()
                locals.set_int("fm_mission_controller", 11760 + 24, 7)
            end)

            extraTab:add_button("Skip Fleeca drill", function()
                locals.set_int("fm_mission_controller", 11760 + 24, 7)
            end)

            extraTab:add_button("Instant finish (solo only)", function()
                locals.set_int("fm_mission_controller", 19710, 12) 
                locals.set_int("fm_mission_controller", 28331 + 1, 99999) 
                locals.set_int("fm_mission_controller", 31587 + 69, 99999)
            end)
        end

        initTabPreps()
        initTabCuts()
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

            prepsTab:add_text("Target ("..yu.dict_get_or_default(a.targets, stats.get_int(yu.mpx().."H3OPT_TARGET")).." ["..stats.get_int(yu.mpx().."H3OPT_TARGET").."]):")
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

            prepsTab:add_text("Gunman ("..yu.dict_get_or_default(a.gunmans, stats.get_int(yu.mpx().."H3OPT_CREWWEAP")).." ["..stats.get_int(yu.mpx().."H3OPT_CREWWEAP").."]):")
            for k, v in pairs(a.gunmans) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Gunman' to "..a.gunmans[k].." ["..k.."]")
                    stats.set_int(yu.mpx().."H3OPT_CREWWEAP", k)
                end)
            end

            prepsTab:add_text("Driver ("..yu.dict_get_or_default(a.drivers, stats.get_int(yu.mpx().."H3OPT_CREWDRIVER")).." ["..stats.get_int(yu.mpx().."H3OPT_CREWDRIVER").."]):")
            for k, v in pairs(a.drivers) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Driver' to "..a.drivers[k].." ["..k.."]")
                    stats.set_int(yu.mpx().."H3OPT_CREWDRIVER", k)
                end)
            end

            prepsTab:add_text("Hacker ("..yu.dict_get_or_default(a.hackers, stats.get_int(yu.mpx().."H3OPT_CREWHACKER")).." ["..stats.get_int(yu.mpx().."H3OPT_CREWHACKER").."]):")
            for k, v in pairs(a.hackers) do
                prepsTab:add_sameline()
                prepsTab:add_button(v, function()
                    yu.notify(1, "Set 'Hacker' to "..a.hackers[k].." ["..k.."]")
                    stats.set_int(yu.mpx().."H3OPT_CREWHACKER", k)
                end)
            end

            prepsTab:add_text("Mask ("..yu.dict_get_or_default(a.masks, stats.get_int(yu.mpx().."H3OPT_MASKS")).." ["..stats.get_int(yu.mpx().."H3OPT_CREWHACKER").."]):")
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
                STATS.STAT_SET_INT(joaat(yu.mpx().."GANGOPS_FLOW_MISSION_PROG"), 7, true)
                STATS.STAT_SET_INT(joaat(yu.mpx().."GANGOPS_FM_MISSION_PROG"), 7, true)
            end)
            
            prepsTab:add_button("OneClick Act 2: The Bodgan Problem Setup", function()
                STATS.STAT_SET_INT(joaat(yu.mpx().."GANGOPS_FLOW_MISSION_PROG"), 240, true)
                STATS.STAT_SET_INT(joaat(yu.mpx().."GANGOPS_FM_MISSION_PROG"), 248, true)
            end)
            
            prepsTab:add_button("OneClick Act 3: Doomsday Scenario Setup", function()
                STATS.STAT_SET_INT(joaat(yu.mpx().."GANGOPS_FLOW_MISSION_PROG"), 15872, true)
                STATS.STAT_SET_INT(joaat(yu.mpx().."GANGOPS_FM_MISSION_PROG"), 16128, true)
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

            prepsTab:add_text("Mission ("..yu.dict_get_or_default(a.missions, stats.get_int(yu.mpx().."TUNER_CURRENT")).." ["..stats.get_int(yu.mpx().."TUNER_CURRENT").."]):")
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

        otherTab:add_text("Popularity: " .. stats.get_int(yu.mpx().."CLUB_POPULARITY") .. "/1000")
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

    
--     v.tab.money = {}
--     v.tab.money._ = v.tab._:add_tab(" Money")
--     v.tab.money._:add_text(
--         "Here are the best and safest ways to cheat money in GTA 5 online.")
--     v.tab.money._:add_text(
--         "BUT DO NOT GET A LOT OF MONEY, AND USE THE ''STAT EDITOR' SECTION FOR ACCOUNT SAFETY!!!")
--     v.tab.money._:add_text("Make money in moderation!")
--     v.tab.money.ceo = {}
--     v.tab.money.ceo._ = v.tab.money._:add_tab(" CEO")
--     v.tab.money.ceo.how2use = v.tab.money.ceo._:add_tab(" How2Use")
--     v.tab.money.ceo.how2use:add_text("For the buy Mission:")
--     v.tab.money.ceo.how2use:add_text(
--         "1) Click ''Show computer'' and select ''CEO''")
--     v.tab.money.ceo.how2use:add_text(
--         "2) select ur warhouse and start the 1 Crate Mission for 2k$")
--     v.tab.money.ceo.how2use:add_text(
--         "3) wait 1 second -> now your warehouse is full.")
--     v.tab.money.ceo.how2use:add_separator()
--     v.tab.money.ceo.how2use:add_text("How to get money")
--     v.tab.money.ceo.how2use:add_text(
--         " Click ''Show computer'' and select ''CEO'', click ''Sell Cargo'' and wait")
--     v.tab.money.ceo.how2use:add_text(
--         "Click ''CEO'' as many times as you need to make money (1 click = 6 m dollars)")
--     v.tab.money.ceo.how2use:add_text("Disable it and everything is normal again")
--     v.tab.money.ceo._:add_button("Show Computer", function()
--         local playerIndex = globals.get_int(1574918)
--         if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 0 then
--             run_script("apparcadebusinesshub")
--         else
--             if globals.get_int(1895156 + playerIndex * 609 + 10 + 429 + 1) == 1 then
--                 run_script("apparcadebusinesshub")
--             else
--                 gui.show_message("Don't forget to register as CEO/Leader")
--                 run_script("apparcadebusinesshub")
--             end
--         end
--     end)
--     v.tab.money.casino = {}
--     v.tab.money.casino._ = v.tab.money._:add_tab(" Casino")
--     v.tab.money.casino._:add_text("Chips can be bought")
--     v.tab.money.casino._:add_button("Chips set to 1000000000", function()
--         script.run_in_fiber(function(script)
--             STATS.STAT_SET_INT(joaat("MPPLY_CASINO_CHIPS_PUR_GD"), -1000000000,
--                                true)
--         end)
--     end)
--     v.tab.money.casino._:add_button("Chips reset to 0", function()
--         script.run_in_fiber(function(script)
--             STATS.STAT_SET_INT(joaat("MPPLY_CASINO_CHIPS_PUR_GD"), 0, true)
--         end)
--     end)
--     v.tab.he = {}
--     v.tab.he._ = v.tab._:add_tab(" Heist Editor")
--     v.tab.he.cayo = {}
--     v.tab.he.cayo._ = v.tab.he._:add_tab(" Cayo Perico Heist")
--     v.tab.he.cayo._:add_button("Setup Panther + Hard Mode", function()
--         PlayerIndex = globals.get_int(1574918)
--         if PlayerIndex == 0 then
--             mpx = "MP0_"
--         else
--             mpx = "MP1_"
--         end
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4CNF_BS_GEN"), 131071, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4CNF_BS_ENTR"), 63, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4CNF_BS_ABIL"), 63, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4CNF_WEAPONS"), 5, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4CNF_WEP_DISRP"), 3, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4CNF_ARM_DISRP"), 3, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4CNF_HEL_DISRP"), 3, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4CNF_TARGET"), 5, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4CNF_TROJAN"), 2, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4CNF_APPROACH"), -1, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_CASH_I"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_CASH_C"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_WEED_I"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_WEED_C"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_COKE_I"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_COKE_C"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_CASH_I"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_GOLD_I"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_GOLD_C"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_PAINT"), -1, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4_PROGRESS"), 131055, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_CASH_I_SCOPED"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_CASH_C_SCOPED"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_WEED_I_SCOPED"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_WEED_C_SCOPED"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_COKE_I_SCOPED"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_COKE_C_SCOPED"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_GOLD_I_SCOPED"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_GOLD_C_SCOPED"), 0, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4LOOT_PAINT_SCOPED"), -1, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4_MISSIONS"), 65535, true)
--         STATS.STAT_SET_INT(joaat(yu.mpx().."H4_PLAYTHROUGH_STATUS"), 32, true)
--     end)
--     v.tab.he.cayo._:add_button("remove all cameras", function()
--         for _, ent in pairs(entities.get_all_objects_as_handles()) do
--             for __, cam in pairs(CamList) do
--                 if ENTITY.GET_ENTITY_MODEL(ent) == cam then
--                     ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true)
--                     ENTITY.DELETE_ENTITY(ent)
--                 end
--             end
--         end
--     end)
--     CamList = {
--         joaat("prop_cctv_cam_01a"), joaat("prop_cctv_cam_01b"),
--         joaat("prop_cctv_cam_02a"), joaat("prop_cctv_cam_03a"),
--         joaat("prop_cctv_cam_04a"), joaat("prop_cctv_cam_04c"),
--         joaat("prop_cctv_cam_05a"), joaat("prop_cctv_cam_06a"),
--         joaat("prop_cctv_cam_07a"), joaat("prop_cs_cctv"), joaat("p_cctv_s"),
--         joaat("hei_prop_bank_cctv_01"), joaat("hei_prop_bank_cctv_02"),
--         joaat("ch_prop_ch_cctv_cam_02a"),
--         joaat("xm_prop_x17_server_farm_cctv_01")
--     }
--     v.tab.he.cayo._:add_sameline()
--     v.tab.he.cayo._:add_button("Removed Perico hoplites", function()
--         for _, ent in pairs(entities.get_all_peds_as_handles()) do
--             if ENTITY.GET_ENTITY_MODEL(ent) == 193469166 then
--                 ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true)
--                 ENTITY.DELETE_ENTITY(ent)
--             end
--         end
--     end)
--     v.tab.he.fleeca = {}
--     v.tab.he.fleeca._ = v.tab.he._:add_tab(" Fleeca Heist")
--     v.tab.he.fleeca._:add_button("Skip Prep", function()
--         PlayerIndex = globals.get_int(1574907)
--         if PlayerIndex == 0 then
--             mpx = "MP0_"
--         else
--             mpx = "MP1_"
--         end
--         STATS.STAT_SET_INT(joaat(yu.mpx().."HEIST_PLANNING_STAGE"), -1, true)
--     end)
--     v.tab.he.fleeca._:add_sameline()
--     v.tab.he.fleeca._:add_button("Reset Prep", function()
--         PlayerIndex = globals.get_int(1574907)
--         if PlayerIndex == 0 then
--             mpx = "MP0_"
--         else
--             mpx = "MP1_"
--         end
--         STATS.STAT_SET_INT(joaat(yu.mpx().."HEIST_PLANNING_STAGE"), 0, true)
--     end)

--     v.tab.stateditor = {}
--     v.tab.stateditor._ = v.tab._:add_tab(" Stat Editor")
--     v.tab.stateditor._:add_text(
--         "Use ''Reset 1'' player or ''Reset 2 player'' and change session and exit the game to apply changes")
--     v.tab.stateditor._:add_separator()
--     v.tab.stateditor._:add_button("Reset 1 player", function()
--         gui.show_message("Player 1 Stats Reset",
--                          "Change session to apply changes")
--         script.run_in_fiber(function(script)
--             STATS.STAT_SET_INT(joaat("MPPLY_TOTAL_EVC"), 0, true)
--             STATS.STAT_SET_INT(joaat("MPPLY_TOTAL_SVC"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_EARN_BETTING"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_EARN_JOBS"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MOEARN_SHARED"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_EARN_JOBSHARED"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_NEY_EARN_SELLING_VEH"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_EARN_BETTING"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_SPENT_WEAPON_ARMOR"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_SPENT_VEH_MAINTENANCE"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_SPENT_STYLE_ENT"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_SPENT_PROPERTY_UTIL"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_SPENT_JOB_ACTIVITY"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_SPENT_BETTING"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_EARN_VEHICLE_EXPORT"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_SPENT_VEHICLE_EXPORT"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP0_MONEY_EARN_CLUB_DANCING"), 0, true)
--         end)
--     end)
--     v.tab.stateditor._:add_button("Reset 2 player", function()
--         gui.show_message("Player 2 Stats Reset",
--                          "Change session to apply changes")
--         script.run_in_fiber(function(script)
--             STATS.STAT_SET_INT(joaat("MPPLY_TOTAL_EVC"), 0, true)
--             STATS.STAT_SET_INT(joaat("MPPLY_TOTAL_SVC"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_EARN_BETTING"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_EARN_JOBS"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MOEARN_SHARED"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_EARN_JOBSHARED"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_NEY_EARN_SELLING_VEH"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_EARN_BETTING"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_SPENT_WEAPON_ARMOR"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_SPENT_VEH_MAINTENANCE"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_SPENT_STYLE_ENT"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_SPENT_PROPERTY_UTIL"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_SPENT_JOB_ACTIVITY"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_SPENT_BETTING"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_EARN_VEHICLE_EXPORT"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_SPENT_VEHICLE_EXPORT"), 0, true)
--             STATS.STAT_SET_INT(joaat("MP1_MONEY_EARN_CLUB_DANCING"), 0, true)
--         end)
--     end)
