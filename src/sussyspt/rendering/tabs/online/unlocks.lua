local tasks = require("../../../tasks")

local exports = {}

function exports.register(tab)
    local tab2 = SussySpt.rendering.newTab("Unlocks")

    do -- ANCHOR Other
        local tab3 = SussySpt.rendering.newTab("Other")

        local much = {
            ints = {
                ["CHAR_XP_FM"]=2165850,["SAWNOFF_ENEMY_KILLS"]=600,["SCRIPT_INCREASE_STAM"]=100,["SCRIPT_INCREASE_STRN"]=100,["SCRIPT_INCREASE_LUNG"]=100,
                ["SCRIPT_INCREASE_DRIV"]=100,["SCRIPT_INCREASE_FLY"]=100,["SCRIPT_INCREASE_SHO"]=100,["SCRIPT_INCREASE_STL"]=100,["RACES_WON"]=100,
                ["PISTOL_KILLS"]=600,["CMBTPISTOL_KILLS"]=600,["APPISTOL_KILLS"]=600,["MICROSMG_KILLS"]=600,["SMG_KILLS"]=600,["ASLTSHTGN_KILLS"]=600,
                ["PUMP_KILLS"]=600,["GRNLAUNCH_KILLS"]=600,["RPG_KILLS"]=600,["MINIGUNS_KILLS"]=600,["ASLTSMG_KILLS"]=600,["ASLTRIFLE_KILLS"]=600,
                ["CRBNRIFLE_KILLS"]=600,["ADVRIFLE_KILLS"]=600,["HVYSNIPER_KILLS"]=600,["SNIPERRFL_KILLS"]=600,["MG_KILLS"]=600,["CMBTMG_KILLS"]=600,
                ["PISTOL_ENEMY_KILLS"]=600,["CMBTPISTOL_ENEMY_KILLS"]=600,["APPISTOL_ENEMY_KILLS"]=600,["MICROSMG_ENEMY_KILLS"]=600,["SMG_ENEMY_KILLS"]=600,
                ["ASLTSHTGN_ENEMY_KILLS"]=600,["PUMP_ENEMY_KILLS"]=600,["GRNLAUNCH_ENEMY_KILLS"]=600,["RPG_ENEMY_KILLS"]=600,["MINIGUNS_ENEMY_KILLS"]=600,
                ["ASLTSMG_ENEMY_KILLS"]=600,["ASLTRIFLE_ENEMY_KILLS"]=600,["CRBNRIFLE_ENEMY_KILLS"]=600,["ADVRIFLE_ENEMY_KILLS"]=600,
                ["HVYSNIPER_ENEMY_KILLS"]=600,["SNIPERRFL_ENEMY_KILLS"]=600,["MG_ENEMY_KILLS"]=600,["CMBTMG_ENEMY_KILLS"]=600,["AWD_ENEMYDRIVEBYKILLS"]=600,
                ["USJS_COMPLETED"]=50,["USJS_FOUND"]=50,["DB_PLAYER_KILLS"]=1000,["KILLS_PLAYERS"]=1000,["AWD_FMHORDWAVESSURVIVE"]=21,
                ["AWD_CAR_BOMBS_ENEMY_KILLS"]=25,["AWD_FM_TDM_MVP"]=60,["AWD_HOLD_UP_SHOPS"]=20,["AWD_RACES_WON"]=101,["AWD_NO_ARMWRESTLING_WINS"]=21,
                ["AWD_FMBBETWIN"]=50000,["AWD_FM_DM_TOTALKILLS"]=500,["MPPLY_DM_TOTAL_DEATHS"]=412,["MPPLY_TIMES_FINISH_DM_TOP_3"]=36,
                ["PLAYER_HEADSHOTS"]=623,["AWD_FM_DM_WINS"]=63,["AWD_FM_TDM_WINS"]=13,["AWD_FM_GTA_RACES_WON"]=12,["AWD_FM_GOLF_WON"]=2,
                ["AWD_FM_SHOOTRANG_TG_WON"]=2,["AWD_FM_SHOOTRANG_RT_WON"]=2,["AWD_FM_SHOOTRANG_CT_WON"]=2,["AWD_FM_SHOOTRANG_GRAN_WON"]=2,
                ["AWD_FM_TENNIS_WON"]=2,["MPPLY_TENNIS_MATCHES_WON"]=2,["MPPLY_TOTAL_TDEATHMATCH_WON"]=63,["MPPLY_TOTAL_RACES_WON"]=101,
                ["MPPLY_TOTAL_DEATHMATCH_LOST"]=23,["MPPLY_TOTAL_RACES_LOST"]=36,["AWD_25_KILLS_STICKYBOMBS"]=50,["AWD_50_KILLS_GRENADES"]=50,
                ["GRENADE_ENEMY_KILLS"]=50,["AWD_20_KILLS_MELEE"]=50,["AWD_FMRALLYWONDRIVE"]=2,["AWD_FMWINSEARACE"]=2,["AWD_FMWINAIRRACE"]=2,
                ["NUMBER_TURBO_STARTS_IN_RACE"]=100,["AWD_FM_RACES_FASTEST_LAP"]=101,["NUMBER_SLIPSTREAMS_IN_RACE"]=105,["MPPLY_OVERALL_CHEAT"]=0,
                ["LAP_DANCED_BOUGHT"]=50,["AWD_FMKILLBOUNTY"]=50,["AWD_FMREVENGEKILLSDM"]=60,["AWD_SECURITY_CARS_ROBBED"]=40,["CHAR_KIT_FM_PURCHASE"]=-1,
                ["CHAR_KIT_FM_PURCHASE2"]=-1,["CHAR_KIT_FM_PURCHASE3"]=-1,["CHAR_KIT_FM_PURCHASE4"]=-1,["CHAR_KIT_FM_PURCHASE5"]=-1,
                ["CHAR_KIT_FM_PURCHASE6"]=-1,["CHAR_KIT_FM_PURCHASE7"]=-1,["CHAR_KIT_FM_PURCHASE8"]=-1,["CHAR_KIT_FM_PURCHASE9"]=-1,
                ["CHAR_KIT_FM_PURCHASE10"]=-1,["CHAR_KIT_FM_PURCHASE11"]=-1,["CHAR_KIT_FM_PURCHASE12"]=-1,["CHAR_KIT_1_FM_UNLCK"]=-1,
                ["CHAR_KIT_2_FM_UNLCK"]=-1,["CHAR_KIT_3_FM_UNLCK"]=-1,["CHAR_KIT_4_FM_UNLCK"]=-1,["CHAR_KIT_5_FM_UNLCK"]=-1,["CHAR_KIT_6_FM_UNLCK"]=-1,
                ["CHAR_KIT_7_FM_UNLCK"]=-1,["CHAR_KIT_8_FM_UNLCK"]=-1,["CHAR_KIT_9_FM_UNLCK"]=-1,["CHAR_KIT_10_FM_UNLCK"]=-1,["CHAR_KIT_11_FM_UNLCK"]=-1,
                ["CHAR_KIT_12_FM_UNLCK"]=-1,["races_won"]=100,["number_turbo_starts_in_race"]=100,["usjs_found"]=50,["usjs_completed"]=50,
                ["awd_fmwinairrace"]=50,["awd_fmwinsearace"]=50,["awd_fmrallywonnav"]=50,["awd_fmrallywondrive"]=500,["awd_fm_races_fastest_lap"]=500,
                ["char_fm_carmod_0_unlck"]=-1,["char_fm_carmod_1_unlck"]=-1,["char_fm_carmod_2_unlck"]=-1,["char_fm_carmod_3_unlck"]=-1,
                ["char_fm_carmod_4_unlck"]=-1,["char_fm_carmod_5_unlck"]=-1,["char_fm_carmod_6_unlck"]=-1,["char_fm_carmod_7_unlck"]=-1,
                ["CHAR_FM_VEHICLE_1_UNLCK"]=-1,["CHAR_FM_VEHICLE_2_UNLCK"]=-1,["CHAR_FM_ABILITY_1_UNLCK"]=-1,["CHAR_FM_ABILITY_2_UNLCK"]=-1,
                ["CHAR_FM_ABILITY_3_UNLCK"]=-1,["CHAR_FM_PACKAGE_1_COLLECT"]=-1,["CHAR_FM_PACKAGE_2_COLLECT"]=-1,["CHAR_FM_PACKAGE_3_COLLECT"]=-1,
                ["CHAR_FM_PACKAGE_4_COLLECT"]=-1,["CHAR_FM_PACKAGE_5_COLLECT"]=-1,["CHAR_FM_PACKAGE_6_COLLECT"]=-1,["CHAR_FM_PACKAGE_7_COLLECT"]=-1,
                ["CHAR_FM_PACKAGE_8_COLLECT"]=-1,["CHAR_FM_PACKAGE_9_COLLECT"]=-1,["CHAR_FM_HEALTH_1_UNLCK"]=-1,["CHAR_FM_HEALTH_2_UNLCK"]=-1,
                ["CHEAT_BITSET"]=0,["MPPLY_TIMES_RACE_BEST_LAP"]=120,["MPPLY_REPORT_STRENGTH"]=32,["MPPLY_COMMEND_STRENGTH"]=100,["MPPLY_FRIENDLY"]=100,
                ["MPPLY_HELPFUL"]=100,["MPPLY_GRIEFING"]=0,["MPPLY_OFFENSIVE_LANGUAGE"]=0,["MPPLY_OFFENSIVE_UGC"]=0,["MPPLY_VC_HATE"]=0,
                ["MPPLY_GAME_EXPLOITS"]=0,["MPPLY_ISPUNISHED"]=0
            },
            bools = {
                "AWD_FMPICKUPDLCCRATE1ST","AWD_FMRACEWORLDRECHOLDER","AWD_FMWINALLRACEMODES","AWD_FMWINEVERYGAMEMODE","AWD_FMATTGANGHQ",
                "AWD_FMFULLYMODDEDCAR","AWD_FMMOSTKILLSSURVIVE","AWD_FMKILL3ANDWINGTARACE"
            }
        }

        function tab3.render()
            if ImGui.Button("Unlock LSCarMeet podium prize") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_bool(mpx.."CARMEET_PV_CHLLGE_CMPLT", true)
                    stats.set_bool(mpx.."CARMEET_PV_CLMED", false)
                end)
            end
            yu.rendering.tooltip("Go in LSCarMeet to claim in interaction menu")

            -- if ImGui.Button("LSCarMeet unlocks") then
            --     tasks.addTask(function()
            --         for i = 293419, 293446 do
            --             globals.set_float(i, 100000)
            --         end
            --     end)
            -- end

            if ImGui.Button("Unlock flightschool stuff") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int("MPPLY_NUM_CAPTURES_CREATED", math.max(stats.get_int("MPPLY_NUM_CAPTURES_CREATED") or 0, 100))
                    for i = 0, 9 do
                        stats.set_int("MPPLY_PILOT_SCHOOL_MEDAL_"..i , -1)
                        stats.set_int(mpx.."PILOT_SCHOOL_MEDAL_"..i, -1)
                        stats.set_bool(mpx.."PILOT_ASPASSEDLESSON_"..i, true)
                    end
                end)
            end
            yu.rendering.tooltip("MPPLY_NUM_CAPTURES_CREATED > 100\nMPPLY_PILOT_SCHOOL_MEDAL_[0-9] = -1\n$MPX_PILOT_SCHOOL_MEDAL_[0-9] = -1\n$MPX_PILOT_ASPASSEDLESSON_[0-9] = true")

            if ImGui.Button("Arena wars bools") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    for i = 0, 63 do
                        for j = 0, 8 do
                            stats.set_bool_masked(mpx.."ARENAWARSPSTAT_BOOL"..j, true, i)
                        end
                    end
                end)
            end

            if ImGui.Button("Unlock trade prices for arenawar vehicles") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    for i = 1, 16 do
                        stats.set_bool_masked(mpx.."ARENAWARSPSTAT_BOOL0", true, i)
                    end
                    for i = 11, 19 do
                        stats.set_bool_masked(mpx.."ARENAWARSPSTAT_BOOL2", true, i)
                    end
                end)
            end

            if ImGui.Button("Unlock colored headlights") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    for i = 18, 29 do
                        stats.set_bool_masked(mpx.."ARENAWARSPSTAT_BOOL0", true, i)
                    end
                end)
            end

            if ImGui.Button("CEO & MC money clutter") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    for k, v in pairs({
                        ["LIFETIME_BUY_COMPLETE"]=1000,["LIFETIME_BUY_UNDERTAKEN"]=1000,["LIFETIME_SELL_COMPLETE"]=1000,["LIFETIME_SELL_UNDERTAKEN"]=1000,["LIFETIME_CONTRA_EARNINGS"]=20000000,["LIFETIME_BIKER_BUY_COMPLET"]=1000,
                        ["LIFETIME_BIKER_BUY_UNDERTA"]=1000,["LIFETIME_BIKER_SELL_COMPLET"]=1000,["LIFETIME_BIKER_SELL_UNDERTA"]=1000,["LIFETIME_BIKER_BUY_COMPLET1"]=1000,["LIFETIME_BIKER_BUY_UNDERTA1"]=1000,
                        ["LIFETIME_BIKER_SELL_COMPLET1"]=1000,["LIFETIME_BIKER_SELL_UNDERTA1"]=1000,["LIFETIME_BIKER_BUY_COMPLET2"]=1000,["LIFETIME_BIKER_BUY_UNDERTA2"]=1000,["LIFETIME_BIKER_SELL_COMPLET2"]=1000,
                        ["LIFETIME_BIKER_SELL_UNDERTA2"]=1000,["LIFETIME_BIKER_BUY_COMPLET3"]=1000,["LIFETIME_BIKER_BUY_UNDERTA3"]=1000,["LIFETIME_BIKER_SELL_COMPLET3"]=1000,["LIFETIME_BIKER_SELL_UNDERTA3"]=1000,
                        ["LIFETIME_BIKER_BUY_COMPLET4"]=1000,["LIFETIME_BIKER_BUY_UNDERTA4"]=1000,["LIFETIME_BIKER_SELL_COMPLET4"]=1000,["LIFETIME_BIKER_SELL_UNDERTA4"]=1000,["LIFETIME_BIKER_BUY_COMPLET5"]=1000,
                        ["LIFETIME_BIKER_BUY_UNDERTA5"]=1000,["LIFETIME_BIKER_SELL_COMPLET5"]=1000,["LIFETIME_BIKER_SELL_UNDERTA5"]=1000,["LIFETIME_BKR_SELL_EARNINGS0"]=20000000,["LIFETIME_BKR_SELL_EARNINGS1"]=20000000,
                        ["LIFETIME_BKR_SELL_EARNINGS2"]=20000000,["LIFETIME_BKR_SELL_EARNINGS3"]=20000000,["LIFETIME_BKR_SELL_EARNINGS4"]=20000000,["LIFETIME_BKR_SELL_EARNINGS5"]=20000000,["LFETIME_IE_EXPORT_COMPLETED"]=1000,
                        ["LFETIME_IE_MISSION_EARNINGS"]=20000000,["LFETIME_HANGAR_EARNINGS"]=20000000,["BKR_PROD_STOP_COUT_S1_0"]=500,["BKR_PROD_STOP_COUT_S2_0"]=500,["BKR_PROD_STOP_COUT_S3_0"]=500,
                        ["LIFETIME_BKR_SELL_UNDERTABC"]=500,["LIFETIME_BKR_SELL_COMPLETBC"]=500,["LFETIME_BIKER_BUY_UNDERTA1"]=500,["LFETIME_BIKER_BUY_COMPLET1"]=500,["LFETIME_BIKER_SELL_UNDERTA1"]=500,
                        ["LFETIME_BIKER_SELL_COMPLET1"]=500,["LIFETIME_BKR_SEL_UNDERTABC1"]=500,["LIFETIME_BKR_SEL_COMPLETBC1"]=500,["BKR_PROD_STOP_COUT_S1_1"]=500,["BKR_PROD_STOP_COUT_S2_1"]=500,["BKR_PROD_STOP_COUT_S3_1"]=500,
                        ["LFETIME_BIKER_BUY_UNDERTA2"]=500,["LFETIME_BIKER_BUY_COMPLET2"]=500,["LFETIME_BIKER_SELL_UNDERTA2"]=500,["LFETIME_BIKER_SELL_COMPLET2"]=500,["LIFETIME_BKR_SEL_UNDERTABC2"]=500,
                        ["LIFETIME_BKR_SEL_COMPLETBC2"]=500,["BKR_PROD_STOP_COUT_S1_2"]=500,["BKR_PROD_STOP_COUT_S2_2"]=500,["BKR_PROD_STOP_COUT_S3_2"]=500,["LFETIME_BIKER_BUY_UNDERTA3"]=500,["LFETIME_BIKER_BUY_COMPLET3"]=500,
                        ["LFETIME_BIKER_SELL_UNDERTA3"]=500,["LFETIME_BIKER_SELL_COMPLET3"]=500,["LIFETIME_BKR_SEL_UNDERTABC3"]=500,["LIFETIME_BKR_SEL_COMPLETBC3"]=500,["BKR_PROD_STOP_COUT_S1_3"]=500,["BKR_PROD_STOP_COUT_S2_3"]=500,
                        ["BKR_PROD_STOP_COUT_S3_3"]=500,["LFETIME_BIKER_BUY_UNDERTA4"]=500,["LFETIME_BIKER_BUY_COMPLET4"]=500,["LFETIME_BIKER_SELL_UNDERTA4"]=500,["LFETIME_BIKER_SELL_COMPLET4"]=500,["LIFETIME_BKR_SEL_UNDERTABC4"]=500,
                        ["LIFETIME_BKR_SEL_COMPLETBC4"]=500,["BKR_PROD_STOP_COUT_S1_4"]=500,["BKR_PROD_STOP_COUT_S2_4"]=500,["BKR_PROD_STOP_COUT_S3_4"]=500,["LFETIME_BIKER_BUY_UNDERTA5"]=500,["LFETIME_BIKER_BUY_COMPLET5"]=500,
                        ["LIFETIME_BKR_SEL_UNDERTABC5"]=500,["LIFETIME_BKR_SEL_COMPLETBC5"]=500,["LFETIME_BIKER_SELL_UNDERTA5"]=500,["LFETIME_BIKER_SELL_COMPLET5"]=500,["BUNKER_UNITS_MANUFAC"]=500,["LFETIME_HANGAR_BUY_UNDETAK"]=500,
                        ["LFETIME_HANGAR_BUY_COMPLET"]=500,["LFETIME_HANGAR_SEL_UNDETAK"]=500,["LFETIME_HANGAR_SEL_COMPLET"]=500,["LFETIME_HANGAR_EARN_BONUS"]=1598746,["RIVAL_HANGAR_CRATES_STOLEN"]=500,["LFETIME_IE_STEAL_STARTED"]=500,
                        ["LFETIME_IE_EXPORT_STARTED"]=500,["AT_FLOW_IMPEXP_NUM"]=500
                    }) do
                        stats.set_int(mpx..k, v)
                    end
                end)
            end
            yu.rendering.tooltip("Money on floor")

            if ImGui.Button("Skip Lamar missions") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_bool(mpx.."LOW_FLOW_CS_DRV_SEEN", true)
                    stats.set_bool(mpx.."LOW_FLOW_CS_TRA_SEEN", true)
                    stats.set_bool(mpx.."LOW_FLOW_CS_FUN_SEEN", true)
                    stats.set_bool(mpx.."LOW_FLOW_CS_PHO_SEEN", true)
                    stats.set_bool(mpx.."LOW_FLOW_CS_FIN_SEEN", true)
                    stats.set_bool(mpx.."LOW_BEN_INTRO_CS_SEEN", true)
                    stats.set_int(mpx.."LOWRIDER_FLOW_COMPLETE", 4)
                    stats.set_int(mpx.."LOW_FLOW_CURRENT_PROG", 9)
                    stats.set_int(mpx.."LOW_FLOW_CURRENT_CALL", 9)
                    stats.set_int(mpx.."LOW_FLOW_CS_HELPTEXT", 66)
                end)
            end

            if ImGui.Button("Skip yacht missions") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."YACHT_MISSION_PROG", 0)
                    stats.set_int(mpx.."YACHT_MISSION_FLOW", 21845)
                    stats.set_int(mpx.."CASINO_DECORATION_GIFT_1", -1)
                end)
            end

            if ImGui.Button("Skip ULP missions") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."ULP_MISSION_PROGRESS", 127)
                    stats.set_int(mpx.."ULP_MISSION_CURRENT", 0)
                end)
            end

            if ImGui.Button("Unlock phone contracts") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."FM_ACT_PHN", -1)
                    stats.set_int(mpx.."FM_ACT_PH2", -1)
                    stats.set_int(mpx.."FM_ACT_PH3", -1)
                    stats.set_int(mpx.."FM_ACT_PH4", -1)
                    stats.set_int(mpx.."FM_ACT_PH5", -1)
                    stats.set_int(mpx.."FM_VEH_TX1", -1)
                    stats.set_int(mpx.."FM_ACT_PH6", -1)
                    stats.set_int(mpx.."FM_ACT_PH7", -1)
                    stats.set_int(mpx.."FM_ACT_PH8", -1)
                    stats.set_int(mpx.."FM_ACT_PH9", -1)
                    stats.set_int(mpx.."FM_CUT_DONE", -1)
                    stats.set_int(mpx.."FM_CUT_DONE_2", -1)
                end)
            end

            if ImGui.Button("Unlock bunker research (temp?)") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    for j = 0, 63 do
                        stats.set_bool_masked(mpx.."DLCGUNPSTAT_BOOL0", true, j)
                        stats.set_bool_masked(mpx.."DLCGUNPSTAT_BOOL1", true, j)
                        stats.set_bool_masked(mpx.."DLCGUNPSTAT_BOOL2", true, j)
                        stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL0", true, j)
                        stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL1", true, j)
                        stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL2", true, j)
                        stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL3", true, j)
                        stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL4", true, j)
                        stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL5", true, j)
                    end
                    local bitSize = 8
                    for j = 0, 64 / bitSize - 1 do
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT0", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT1", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT2", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT3", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT4", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT5", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT6", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT7", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT8", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT9", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT10", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT11", -1, j * bitSize, bitSize)
                        stats.set_masked_int(mpx.."GUNRPSTAT_INT12", -1, j * bitSize, bitSize)
                    end
                end)
            end

            if ImGui.Button("Unlock diamond casino heist outfits") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL1", true, 63) -- Refuse Collectors
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 0) -- Undertakers
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 1) -- Valet Outfits
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 3) -- Prison Guards
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 4) -- FIB Suits
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 6) -- Gruppe Sechs Gear
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 7) -- Bugstars Uniforms
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 8) -- Maintenance
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 9) -- Yung Ancestors
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 10) -- Firefighter Gear
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 11) -- Orderly Armor
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 12) -- Upscale Armor
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 13) -- Evening Armor
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 14) -- Reinforced: Padded Combat
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 15) -- Reinforced: Bulk Combat
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 16) -- Reinforced: Compact Combat
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 17) -- Balaclava Crook
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 18) -- Classic Crook
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 19) -- High-end Crook
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 20) -- Infiltration: Upgraded Tech
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 21) -- Infiltration: Advanced Tech
                    stats.set_bool_masked(mpx.."CASINOHSTPSTAT_BOOL2", true, 22) -- Infiltration: Modernized Tech
                end)
            end

            if ImGui.SmallButton("Some cool things yay") then
                tasks.addTask(function()
                    local mpx = yu.mpx()

                    for i = 0, 9 do
                        stats.set_int(mpx.."IAP_INITIALS_"..i, 0)
                        stats.set_int(mpx.."IAP_SCORE_"..i, 0)
                        stats.set_int(mpx.."IAP_SCORE_"..i, 0)
                        stats.set_int(mpx.."SCGW_SCORE_"..i, 0)
                        stats.set_int(mpx.."DG_DEFENDER_INITIALS_"..i, 0)
                        stats.set_int(mpx.."DG_DEFENDER_SCORE_"..i, 0)
                        stats.set_int(mpx.."DG_MONKEY_INITIALS_"..i, 0)
                        stats.set_int(mpx.."DG_MONKEY_SCORE_"..i, 0)
                        stats.set_int(mpx.."DG_PENETRATOR_INITIALS_"..i, 0)
                        stats.set_int(mpx.."DG_PENETRATOR_SCORE_"..i, 0)
                        stats.set_int(mpx.."GGSM_INITIALS_"..i, 0)
                        stats.set_int(mpx.."GGSM_SCORE_"..i, 0)
                        stats.set_int(mpx.."TWR_INITIALS_"..i, 0)
                        stats.set_int(mpx.."TWR_SCORE_"..i, 0)
                    end
                end)
            end

            if ImGui.Button("Very much things") then
                tasks.addTask(function()
                    local mpx = yu.mpx()

                    for k, v in pairs(much.ints) do
                        stats.set_int(yu.shc(k.startswith("MPPLY"), "", mpx)..k, v)
                    end

                    for k, v in pairs(much.bools) do
                        stats.set_bool(mpx..k, true)
                    end

                    yu.notify(1, "Success!")
                end)
            end
        end

        tab2.sub[1] = tab3
    end

    do -- SECTION Ranks
        local tab3 = SussySpt.rendering.newTab("Ranks")

        local a = {
            rank = 0,
            rank_rp = 0,
            rank_min_rp = 0,
            rank_max_rp = 1787576850,

            crank_crew = 1,
            crank_rank = 0,
            crank_min = 0,
            crank_checking = false
        }

        function a.getRankFromRP(rp)
            local rank = 0
            for k, v in pairs(yu.cache.xp_to_rank) do
                if v < rp then
                    rank = k
                else
                    return rank
                end
            end
            return rank
        end

        local function refreshRank()
            local mpx = yu.mpx()
            a.rank_rp = stats.get_int(mpx.."CHAR_XP_FM")
            a.rank = a.getRankFromRP(a.rank_rp)
        end

        local function refreshCrewRank()
            if not a.crank_checking then
                a.crank_checking = true
                tasks.addTask(function()
                    a.crank_rank = a.getRankFromRP(stats.get_int("MPPLY_CREW_LOCAL_XP_"..a.crank_crew))
                    a.crank_min = a.crank_rank
                    a.crank_checking = false
                end)
            end
        end

        local function refresh()
            refreshRank()
            refreshCrewRank()
        end
        yu.rif(refresh)

        function tab3.render()
            do -- ANCHOR Rank
                ImGui.Text("Rank")
                ImGui.SameLine()
                if ImGui.SmallButton("Refresh##rank") then
                    yu.rif(refreshRank)
                end

                ImGui.Text("RP")
                ImGui.SameLine()
                ImGui.PushItemWidth(160)
                a.rank_rp = ImGui.DragInt("##rank_rp", a.rank_rp, .2, a.rank_min_rp, a.rank_max_rp)
                yu.rendering.tooltip("Use the slider below to obtain the rp for a specific rank\nRP for lvl 8000: "..a.rank_max_rp)
                ImGui.PopItemWidth()

                ImGui.SameLine()

                if ImGui.Button("Apply##rank_apply") then
                    tasks.addTask(function()
                        local mpx = yu.mpx()
                        local currentRP = stats.get_int(mpx.."CHAR_XP_FM")
                        local giftAdmin = yu.rendering.isCheckboxChecked("online_unlocks_rank_giftadmin")

                        local goingDown = a.rank_rp < currentRP
                        if not goingDown then
                            stats.set_int("MPPLY_GLOBALXP", a.rank_rp)
                            stats.set_int(mpx.."CHAR_XP_FM", a.rank_rp)
                        elseif not giftAdmin then
                            yu.notify(2, "You will need to enable 'Gift Admin' to go down with your rank / RP", "Online->Unlocks->Ranks")
                        end

                        if giftAdmin then
                            stats.set_int(mpx.."CHAR_SET_RP_GIFT_ADMIN", a.rank_rp)
                            yu.notify(1, "Switch sessions to get your rank set", "Online->Unlocks->Ranks")
                        else
                            yu.notify(1, "You will need to gain RP normally to apply changes", "Online->Unlocks->Ranks")
                        end
                    end)
                end
                yu.rendering.tooltip("Your game can crash from high diffrences. Use 'Gift admin' to bypass")

                ImGui.SameLine()

                if ImGui.Button("Refresh##rank_refresh") then
                    tasks.addTask(function()
                        a.rank_rp = stats.get_int(yu.mpx("CHAR_XP_FM"))
                    end)
                end

                ImGui.Text("Rank")
                ImGui.SameLine()
                ImGui.PushItemWidth(80)
                a.rank = ImGui.DragInt("##rank_rank", a.rank, .2, 0, 8000)
                ImGui.PopItemWidth()

                ImGui.SameLine()

                if ImGui.Button("Get##rank_get") then
                    tasks.addTask(function()
                        if yu.is_num_between(a.rank, 0, 8000) then
                            a.rank_rp = yu.cache.xp_to_rank[a.rank] or a.rank_rp
                        end
                    end)
                end

                yu.rendering.renderCheckbox("Gift admin", "online_unlocks_rank_giftadmin")
                yu.rendering.tooltip("This makes rockstar 'correct' your level when joining a new session")
            end

            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()

            do -- ANCHOR Crew Rank
                ImGui.Text("Crew Rank")
                do
                    local value, changed = ImGui.SliderInt("Crew", a.crank_crew, 0, 4)
                    if changed then
                        a.crank_crew = value
                        refreshCrewRank()
                    end
                    yu.rendering.tooltip("The crew you want to change your rank for.\nFunfact: You can join multiple crews.")
                end

                do
                    local value, changed = ImGui.SliderInt("Rank", a.crank_rank, a.crank_min, 8000)
                    if changed then
                        a.crank_rank = value
                    end
                    yu.rendering.tooltip("You can't go down again! Or can you? o.O")
                end

                if ImGui.Button("Set") then
                    tasks.addTask(function()
                        if a.crank_rank >= a.crank_min then
                            stats.set_int("MPPLY_CREW_LOCAL_XP_"..a.crank_crew, yu.cache.xp_to_rank[a.crank_rank] + 100)
                            yu.notify(2, "You will need to switch sessions to see changes", "Crew rank")
                            yu.notify(1, "Set rank to "..a.crank_rank.."!!!!1 :DDD", "It's fine... No ban!!!11")
                        end
                        refreshCrewRank()
                    end)
                end
            end

        end

        tab2.sub[2] = tab3
    end -- !SECTION

    do -- ANCHOR Player
        local tab3 = SussySpt.rendering.newTab("Player")

        function tab3.render()
            if ImGui.SmallButton("Allow gender change") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("ALLOW_GENDER_CHANGE"), 52)
                end)
            end

            if ImGui.SmallButton("Unlock fast run and reload") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    for i = 1, 3 do
                        stats.set_int(mpx.."CHAR_ABILITY_"..i.."_UNLCK", -1)
                        stats.set_int(mpx.."CHAR_FM_ABILITY_"..i.."_UNLCK", -1)
                    end
                end)
            end
            yu.rendering.tooltip("Makes you run and reload weapons faster")

            if ImGui.SmallButton("Unlock all achievements") then
                tasks.addTask(function()
                    yu.loop(59, function(i)
                        if not PLAYER.HAS_ACHIEVEMENT_BEEN_PASSED(i) then
                            PLAYER.GIVE_ACHIEVEMENT_TO_PLAYER(i)
                        end
                    end)
                    -- for i = 1, 78 do
                    --     globals.set_int(4543283 + 1, i)
                    -- end
                end)
            end

            if ImGui.SmallButton("Unlock shooting range") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."SR_HIGHSCORE_1", 690)
                    stats.set_int(mpx.."SR_HIGHSCORE_2", 1860)
                    stats.set_int(mpx.."SR_HIGHSCORE_3", 2690)
                    stats.set_int(mpx.."SR_HIGHSCORE_4", 2660)
                    stats.set_int(mpx.."SR_HIGHSCORE_5", 2650)
                    stats.set_int(mpx.."SR_HIGHSCORE_6", 450)
                    stats.set_int(mpx.."SR_TARGETS_HIT", 269)
                    stats.set_int(mpx.."SR_WEAPON_BIT_SET", -1)
                    stats.set_bool(mpx.."SR_TIER_1_REWARD", true)
                    stats.set_bool(mpx.."SR_TIER_3_REWARD", true)
                    stats.set_bool(mpx.."SR_INCREASE_THROW_CAP", true)
                end)
            end
            yu.rendering.tooltip("Bunker thingy")

            if ImGui.SmallButton("Unlock all tattos") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."TATTOO_FM_CURRENT_32", -1)
                    for i = 0, 47 do
                        stats.set_int(mpx.."TATTOO_FM_UNLOCKS_"..i, -1)
                    end
                    for i = 0, 63 do
                        for j = 0, 05 do
                            stats.set_bool_masked(mpx.."GUNTATPSTAT_BOOL"..j, true, i)
                        end
                    end
                end)
            end

            if ImGui.SmallButton("Unlock all parachutes") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_bool_masked(mpx.."TUNERPSTAT_BOOL1", true, 20) -- Sprunk Bag
                    stats.set_bool_masked(mpx.."TUNERPSTAT_BOOL1", true, 21) -- eCola Bag
                    stats.set_bool_masked(mpx.."TUNERPSTAT_BOOL1", true, 22) -- Halloween Bag
                    stats.set_bool_masked(mpx.."TUNERPSTAT_BOOL1", true, 23) -- Sprunk Chute
                    stats.set_bool_masked(mpx.."TUNERPSTAT_BOOL1", true, 24) -- eCola Chute
                    stats.set_bool_masked(mpx.."TUNERPSTAT_BOOL1", true, 25) -- Halloween Chute
                    stats.set_bool_masked(mpx.."DLC12022PSTAT_BOOL1", true, 63) -- Junk Energy Drink Bag
                    stats.set_bool_masked(mpx.."DLC12022PSTAT_BOOL2", true, 0) -- Junk Energy Drink Chute
                    stats.set_bool_masked(mpx.."TUPSTAT_BOOL7", true, 50) -- High Flyer Bag
                end)
            end

            if ImGui.SmallButton("Daily objective related") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."COMPLETEDAILYOBJ", 100)
                    stats.set_int(mpx.."COMPLETEDAILYOBJTOTAL", 100)
                    stats.set_int(mpx.."TOTALDAYCOMPLETED", 100)
                    stats.set_int(mpx.."TOTALWEEKCOMPLETED", 400)
                    stats.set_int(mpx.."TOTALMONTHCOMPLETED", 1800)
                    stats.set_int(mpx.."CONSECUTIVEDAYCOMPLETED", 30)
                    stats.set_int(mpx.."CONSECUTIVEWEEKCOMPLETED", 4)
                    stats.set_int(mpx.."CONSECUTIVEMONTHCOMPLETE", 1)
                    stats.set_int(mpx.."COMPLETEDAILYOBJSA", 100)
                    stats.set_int(mpx.."COMPLETEDAILYOBJTOTALSA", 100)
                    stats.set_int(mpx.."TOTALDAYCOMPLETEDSA", 100)
                    stats.set_int(mpx.."TOTALWEEKCOMPLETEDSA", 400)
                    stats.set_int(mpx.."TOTALMONTHCOMPLETEDSA", 1800)
                    stats.set_int(mpx.."CONSECUTIVEDAYCOMPLETEDSA", 30)
                    stats.set_int(mpx.."CONSECUTIVEWEEKCOMPLETEDSA", 4)
                    stats.set_int(mpx.."CONSECUTIVEMONTHCOMPLETESA", 1)
                    stats.set_int(mpx.."AWD_DAILYOBJCOMPLETEDSA", 100)
                    stats.set_int(mpx.."AWD_DAILYOBJCOMPLETED", 100)
                    stats.set_bool(mpx.."AWD_DAILYOBJMONTHBONUS", true)
                    stats.set_bool(mpx.."AWD_DAILYOBJWEEKBONUS", true)
                    stats.set_bool(mpx.."AWD_DAILYOBJWEEKBONUSSA", true)
                    stats.set_bool(mpx.."AWD_DAILYOBJMONTHBONUSSA", true)
                end)
            end

            if ImGui.SmallButton("Engine upgrades") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."USJS_COMPLETED_MASK", 50)
                    stats.set_int(mpx.."USJS_FOUND_MASK", 50)
                    stats.set_int(mpx.."USJS_TOTAL_COMPLETED", 50)
                    stats.set_int(mpx.."USJS_COMPLETED", 50)
                    stats.set_int(mpx.."USJS_FOUND", 50)
                end)
            end
        end

        tab2.sub[3] = tab3
    end

    do -- ANCHOR Weapons
        local tab3 = SussySpt.rendering.newTab("Weapons")

        function tab3.render()
            if ImGui.SmallButton("Unlock guns") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    for i in pairs({
                            "CHAR_WEAP_UNLOCKED","CHAR_WEAP_UNLOCKED2","CHAR_WEAP_UNLOCKED3","CHAR_WEAP_UNLOCKED4","CHAR_WEAP_ADDON_1_UNLCK",
                            "CHAR_WEAP_ADDON_2_UNLCK","CHAR_WEAP_ADDON_3_UNLCK","CHAR_WEAP_ADDON_4_UNLCK","CHAR_WEAP_FREE","CHAR_WEAP_FREE2",
                            "CHAR_FM_WEAP_FREE","CHAR_FM_WEAP_FREE2","CHAR_FM_WEAP_FREE3","CHAR_FM_WEAP_FREE4","CHAR_WEAP_PURCHASED",
                            "CHAR_WEAP_PURCHASED2","WEAPON_PICKUP_BITSET","WEAPON_PICKUP_BITSET2","CHAR_FM_WEAP_UNLOCKED","NO_WEAPONS_UNLOCK",
                            "NO_WEAPON_MODS_UNLOCK","NO_WEAPON_CLR_MOD_UNLOCK","CHAR_FM_WEAP_UNLOCKED2","CHAR_FM_WEAP_UNLOCKED3",
                            "CHAR_FM_WEAP_UNLOCKED4","CHAR_KIT_1_FM_UNLCK","CHAR_KIT_2_FM_UNLCK","CHAR_KIT_3_FM_UNLCK","CHAR_KIT_4_FM_UNLCK",
                            "CHAR_KIT_5_FM_UNLCK","CHAR_KIT_6_FM_UNLCK","CHAR_KIT_7_FM_UNLCK","CHAR_KIT_8_FM_UNLCK","CHAR_KIT_9_FM_UNLCK",
                            "CHAR_KIT_10_FM_UNLCK","CHAR_KIT_11_FM_UNLCK","CHAR_KIT_12_FM_UNLCK","CHAR_KIT_FM_PURCHASE","CHAR_WEAP_FM_PURCHASE",
                            "CHAR_WEAP_FM_PURCHASE2","CHAR_WEAP_FM_PURCHASE3","CHAR_WEAP_FM_PURCHASE4"}) do
                        stats.set_int(mpx..i, -1)
                    end
                    stats.set_int(mpx.."FIREWORK_TYPE_1_WHITE", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_1_RED", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_1_BLUE", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_2_WHITE", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_2_RED", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_2_BLUE", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_3_WHITE", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_3_RED", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_3_BLUE", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_4_WHITE", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_4_RED", 1000)
                    stats.set_int(mpx.."FIREWORK_TYPE_4_BLUE", 1000)
                    stats.set_int(mpx.."WEAP_FM_ADDON_PURCH", -1)
                for i = 2, 19 do
                    stats.set_int(mpx.."WEAP_FM_ADDON_PURCH"..i, -1)
                end
                for i = 1, 19 do
                    stats.set_int(mpx.."CHAR_FM_WEAP_ADDON_"..i.."_UNLCK", -1)
                end
                for i = 1, 41 do
                    stats.set_int(mpx.."CHAR_KIT_"..i.."_FM_UNLCK", -1)
                end
                for i = 2, 41 do
                    stats.set_int(mpx.."CHAR_KIT_FM_PURCHASE"..i, -1)
                end
                end)
            end

            if ImGui.SmallButton("Unlock baseball bat and knife skins in gunvan") then
                tasks.addTask(function()
                    globals.set_int(262145 + 34365, 0)
                    globals.set_int(262145 + 34328 + 9, -1716189206) -- Knife
                    globals.set_int(262145 + 34328 + 10, -1786099057) -- Baseball bat
                end)
            end

            if ImGui.SmallButton("Unlock Double Action Revolver") then
                local mpx = yu.mpx()
                if stats.get_masked_int(mpx.."GANGOPSPSTAT_INT102", 24, 8) < 3 then
                    stats.set_masked_int(mpx.."GANGOPSPSTAT_INT102", 3, 24, 8)
                end
                if stats.get_masked_int(mpx.."GANGOPSPSTAT_INT102", 24, 8) > 3 then
                    stats.set_masked_int(mpx.."GANGOPSPSTAT_INT102", 0, 24, 8)
                end
            end

            if ImGui.SmallButton("Unlock Stone Hatchet") then
                if stats.get_masked_int("MP_NGDLCPSTAT_INT0", 16, 8) < 5 then
                    stats.set_masked_int("MP_NGDLCPSTAT_INT0", 5, 16, 8)
                end
                if stats.get_masked_int("MP_NGDLCPSTAT_INT0", 16, 8) > 5 then
                    stats.set_masked_int("MP_NGDLCPSTAT_INT0", 0, 16, 8)
                end
            end

            if ImGui.SmallButton("Unlock missed gunvan guns") then
                tasks.addTask(function()
                    globals.set_int(262145 + 34328 + 5, -22923932) -- railgun
                    globals.set_int(262145 + 34328 + 6, -1238556825) -- widowmaker
                    globals.set_int(262145 + 34328 + 7, -1355376991) ----- raygun
                    globals.set_int(262145 + 34328 + 8, 1198256469) ----- unholy hellbringer
                    globals.set_int(262145 + 34328 + 9, 350597077) -- tazer
                    globals.set_int(262145 + 34328 + 10, 2138347493) -- firework launcher
                end)
            end
        end

        tab2.sub[4] = tab3
    end

    do -- ANCHOR Vehicles
        local tab3 = SussySpt.rendering.newTab("Vehicles")

        function tab3.render()
            if ImGui.SmallButton("Unlock xmas liveries") then
                tasks.addTask(function()
                    stats.set_int("MPPLY_XMASLIVERIES", -1)
                    for i = 1, 20 do
                        stats.set_int("MPPLY_XMASLIVERIES"..i, -1)
                    end
                end)
            end

            if ImGui.SmallButton("Unlock LSC stuff & paints") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."CHAR_FM_CARMOD_1_UNLCK", -1)
                    stats.set_int(mpx.."CHAR_FM_CARMOD_2_UNLCK", -1)
                    stats.set_int(mpx.."CHAR_FM_CARMOD_3_UNLCK", -1)
                    stats.set_int(mpx.."CHAR_FM_CARMOD_4_UNLCK", -1)
                    stats.set_int(mpx.."CHAR_FM_CARMOD_5_UNLCK", -1)
                    stats.set_int(mpx.."CHAR_FM_CARMOD_6_UNLCK", -1)
                    stats.set_int(mpx.."CHAR_FM_CARMOD_7_UNLCK", -1)
                    stats.set_int(mpx.."AWD_WIN_CAPTURES", 50)
                    stats.set_int(mpx.."AWD_DROPOFF_CAP_PACKAGES", 100)
                    stats.set_int(mpx.."AWD_KILL_CARRIER_CAPTURE", 100)
                    stats.set_int(mpx.."AWD_FINISH_HEISTS", 50)
                    stats.set_int(mpx.."AWD_FINISH_HEIST_SETUP_JOB", 50)
                    stats.set_int(mpx.."AWD_NIGHTVISION_KILLS", 100)
                    stats.set_int(mpx.."AWD_WIN_LAST_TEAM_STANDINGS", 50)
                    stats.set_int(mpx.."AWD_ONLY_PLAYER_ALIVE_LTS", 50)
                    stats.set_int(mpx.."AWD_FMRALLYWONDRIVE", 25)
                    stats.set_int(mpx.."AWD_FMRALLYWONNAV", 25)
                    stats.set_int(mpx.."AWD_FMWINSEARACE", 25)
                    stats.set_int(mpx.."AWD_RACES_WON", 50)
                    stats.set_int(mpx.."MOST_FLIPS_IN_ONE_JUMP", 5)
                    stats.set_int(mpx.."MOST_SPINS_IN_ONE_JUMP", 5)
                    stats.set_int(mpx.."NUMBER_SLIPSTREAMS_IN_RACE", 100)
                    stats.set_int(mpx.."NUMBER_TURBO_STARTS_IN_RACE", 50)
                    stats.set_int(mpx.."RACES_WON", 50)
                    stats.set_int(mpx.."USJS_COMPLETED", 50)
                    stats.set_int(mpx.."AWD_FM_GTA_RACES_WON", 50)
                    stats.set_int(mpx.."AWD_FM_RACE_LAST_FIRST", 25)
                    stats.set_int(mpx.."AWD_FM_RACES_FASTEST_LAP", 50)
                    stats.set_int(mpx.."AWD_FMBASEJMP", 25)
                    stats.set_int(mpx.."AWD_FMWINAIRRACE", 25)
                    stats.set_int("MPPLY_TOTAL_RACES_WON", 50)
                end)
            end

            if ImGui.SmallButton("Unlock all trade prices") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."GANGOPS_FLOW_BITSET_MISS0", -1)
                    stats.set_int(mpx.."LFETIME_HANGAR_BUY_UNDETAK", 42)
                    stats.set_int(mpx.."LFETIME_HANGAR_BUY_COMPLET", 42)
                    stats.set_int(mpx.."AT_FLOW_IMPEXP_NUM", 32)
                    stats.set_int(mpx.."AT_FLOW_VEHICLE_BS", -1)
                    stats.set_int(mpx.."WVM_FLOW_VEHICLE_BS", -1)
                    stats.set_int(mpx.."H3_BOARD_DIALOGUE0", -1)
                    stats.set_int(mpx.."H3_BOARD_DIALOGUE1", -1)
                    stats.set_int(mpx.."H3_BOARD_DIALOGUE2", -1)
                    stats.set_int(mpx.."H3_VEHICLESUSED", -1)
                    stats.set_int(mpx.."WAM_FLOW_VEHICLE_BS", -1)
                    stats.set_bool(mpx.."HELP_VEHUNHEISTISL", true)
                    stats.set_bool(mpx.."HELP_VEHICLESUNLOCK", true)
                    stats.set_bool(mpx.."HELP_VETO", true)
                    stats.set_bool(mpx.."HELP_VETO2", true)
                    stats.set_bool(mpx.."HELP_ITALIRSX", true)
                    stats.set_bool(mpx.."HELP_BRIOSO2", true)
                    stats.set_bool(mpx.."HELP_MANCHEZ2", true)
                    stats.set_bool(mpx.."HELP_SLAMTRUCK", true)
                    stats.set_bool(mpx.."HELP_VETIR", true)
                    stats.set_bool(mpx.."HELP_SQUADDIE", true)
                    stats.set_bool(mpx.."HELP_DINGY5", true)
                    stats.set_bool(mpx.."HELP_VERUS", true)
                    stats.set_bool(mpx.."HELP_WEEVIL", true)
                    stats.set_bool(mpx.."HELP_VEHUNTUNER", true)
                    stats.set_bool(mpx.."FIXER_VEH_HELP", true)
                    stats.set_bool(mpx.."HELP_DOMINATOR7", true)
                    stats.set_bool(mpx.."HELP_JESTER4", true)
                    stats.set_bool(mpx.."HELP_FUTO2", true)
                    stats.set_bool(mpx.."HELP_DOMINATOR8", true)
                    stats.set_bool(mpx.."HELP_PREVION", true)
                    stats.set_bool(mpx.."HELP_GROWLER", true)
                    stats.set_bool(mpx.."HELP_COMET6", true)
                    stats.set_bool(mpx.."HELP_VECTRE", true)
                    stats.set_bool(mpx.."HELP_SULTAN3", true)
                    stats.set_bool(mpx.."HELP_CYPHER", true)
                    stats.set_bool(mpx.."HELP_VEHUNFIXER", true)
                    stats.set_bool(mpx.."COMPLETE_H4_F_USING_VETIR", true)
                    stats.set_bool(mpx.."COMPLETE_H4_F_USING_LONGFIN", true)
                    stats.set_bool(mpx.."COMPLETE_H4_F_USING_ANNIH", true)
                    stats.set_bool(mpx.."COMPLETE_H4_F_USING_ALKONOS", true)
                    stats.set_bool(mpx.."COMPLETE_H4_F_USING_PATROLB", true)
                    if stats.get_masked_int(mpx.."BUSINESSBATPSTAT_INT379", 0, 8) < 5 then
                        stats.set_masked_int(mpx.."BUSINESSBATPSTAT_INT379", 5, 0, 8)
                    end
                    stats.set_masked_int(mpx.."BUSINESSBATPSTAT_INT380", 20, 40, 8)
                    stats.set_masked_int(mpx.."BUSINESSBATPSTAT_INT379", 5, 5, 55)
                end)
            end

            if ImGui.SmallButton("Unlock Ecola and Sprunk plates") then
                tasks.addTask(function()
                    stats.set_int("MPPLY_XMAS23_PLATES0", -1)
                end)
            end
        end

        tab2.sub[5] = tab3
    end

    tab.sub[6] = tab2
end

return exports
