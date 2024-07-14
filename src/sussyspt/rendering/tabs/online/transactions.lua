local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")
local triggerTransaction = require("sussyspt/util/triggerTransaction")

local exports = {}

local transactions = {
    -- { DisplayName, Hash, Value }
    { "15m (JOB_BONUS)",                              joaat("SERVICE_EARN_JOB_BONUS"),                             15000000 },
    { "15m (BEND_JOB)",                               joaat("SERVICE_EARN_BEND_JOB"),                              15000000 },
    { "15m (GANGOPS_AWARD_MASTERMIND_4)",             joaat("SERVICE_EARN_GANGOPS_AWARD_MASTERMIND_4"),            15000000 },
    { "15m (JOB_BONUS_CRIMINAL_MASTERMIND)",          joaat("SERVICE_EARN_JOB_BONUS_CRIMINAL_MASTERMIND"),         15000000 },
    { "7m (GANGOPS_AWARD_MASTERMIND_3)",              joaat("SERVICE_EARN_GANGOPS_AWARD_MASTERMIND_3"),            7000000 },
    { "3.6m (CASINO_HEIST_FINALE)",                   joaat("SERVICE_EARN_CASINO_HEIST_FINALE"),                   3619000 },
    { "3m (AGENCY_STORY_FINALE)",                     joaat("SERVICE_EARN_AGENCY_STORY_FINALE"),                   3000000 },
    { "3m (GANGOPS_AWARD_MASTERMIND_2)",              joaat("SERVICE_EARN_GANGOPS_AWARD_MASTERMIND_2"),            3000000 },
    { "2.5m (ISLAND_HEIST_FINALE)",                   joaat("SERVICE_EARN_ISLAND_HEIST_FINALE"),                   2550000 },
    { "2.5m (GANGOPS_FINALE)",                        joaat("SERVICE_EARN_GANGOPS_FINALE"),                        2550000 },
    { "2m (JOB_BONUS_HEIST_AWARD)",                   joaat("SERVICE_EARN_JOB_BONUS_HEIST_AWARD"),                 2000000 },
    { "2m (TUNER_ROBBERY_FINALE)",                    joaat("SERVICE_EARN_TUNER_ROBBERY_FINALE"),                  2000000 },
    { "2m (GANGOPS_AWARD_ORDER)",                     joaat("SERVICE_EARN_GANGOPS_AWARD_ORDER"),                   2000000 },
    { "2m (FROM_BUSINESS_HUB_SELL)",                  joaat("SERVICE_EARN_FROM_BUSINESS_HUB_SELL"),                2000000 },
    { "1.5m (GANGOPS_AWARD_LOYALTY_AWARD_4)",         joaat("SERVICE_EARN_GANGOPS_AWARD_LOYALTY_AWARD_4"),         1500000 },
    { "1.2m (BOSS_AGENCY)",                           joaat("SERVICE_EARN_BOSS_AGENCY"),                           1200000 },
    { "1m (DAILY_OBJECTIVES)",                        joaat("SERVICE_EARN_DAILY_OBJECTIVES"),                      1000000 },
    { "1m (MUSIC_STUDIO_SHORT_TRIP)",                 joaat("SERVICE_EARN_MUSIC_STUDIO_SHORT_TRIP"),               1000000 },
    { "1m (DAILY_OBJECTIVE_EVENT)",                   joaat("SERVICE_EARN_DAILY_OBJECTIVE_EVENT"),                 1000000 },
    { "1m (JUGGALO_STORY_MISSION)",                   joaat("SERVICE_EARN_JUGGALO_STORY_MISSION"),                 1000000 },
    { "700k (GANGOPS_AWARD_LOYALTY_AWARD_3)",         joaat("SERVICE_EARN_GANGOPS_AWARD_LOYALTY_AWARD_3"),         700000 },
    { "680k (BETTING)",                               joaat("SERVICE_EARN_BETTING"),                               680000 },
    { "620k (FROM_VEHICLE_EXPORT)",                   joaat("SERVICE_EARN_FROM_VEHICLE_EXPORT"),                   620000 },
    { "500k (ISLAND_HEIST_AWARD_MIXING_IT_UP)",       joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_MIXING_IT_UP"),       500000 },
    { "500k (WINTER_22_AWARD_JUGGALO_STORY)",         joaat("SERVICE_EARN_WINTER_22_AWARD_JUGGALO_STORY"),         500000 },
    { "500k (CASINO_AWARD_STRAIGHT_FLUSH)",           joaat("SERVICE_EARN_CASINO_AWARD_STRAIGHT_FLUSH"),           500000 },
    { "400k (ISLAND_HEIST_AWARD_PROFESSIONAL)",       joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_PROFESSIONAL"),       400000 },
    { "400k (ISLAND_HEIST_AWARD_CAT_BURGLAR)",        joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_CAT_BURGLAR"),        400000 },
    { "400k (ISLAND_HEIST_AWARD_ELITE_THIEF)",        joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_ELITE_THIEF"),        400000 },
    { "400k (ISLAND_HEIST_AWARD_THE_ISLAND_HEIST)",   joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_THE_ISLAND_HEIST"),   400000 },
    { "350k (CASINO_HEIST_AWARD_ELITE_THIEF)",        joaat("SERVICE_EARN_CASINO_HEIST_AWARD_ELITE_THIEF"),        350000 },
    { "300k (AMBIENT_JOB_BLAST)",                     joaat("SERVICE_EARN_AMBIENT_JOB_BLAST"),                     300000 },
    { "300k (PREMIUM_JOB)",                           joaat("SERVICE_EARN_PREMIUM_JOB"),                           300000 },
    { "300k (GANGOPS_AWARD_LOYALTY_AWARD_2)",         joaat("SERVICE_EARN_GANGOPS_AWARD_LOYALTY_AWARD_2"),         300000 },
    { "300k (CASINO_HEIST_AWARD_ALL_ROUNDER)",        joaat("SERVICE_EARN_CASINO_HEIST_AWARD_ALL_ROUNDER"),        300000 },
    { "300k (ISLAND_HEIST_AWARD_PRO_THIEF)",          joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_PRO_THIEF"),          300000 },
    { "300k (YOHAN_SOURCE_GOODS)",                    joaat("SERVICE_EARN_YOHAN_SOURCE_GOODS"),                    300000 },
    { "270k (SMUGGLER_AGENCY)",                       joaat("SERVICE_EARN_SMUGGLER_AGENCY"),                       270000 },
    { "250k (FIXER_AWARD_AGENCY_STORY)",              joaat("SERVICE_EARN_FIXER_AWARD_AGENCY_STORY"),              250000 },
    { "250k (CASINO_HEIST_AWARD_PROFESSIONAL)",       joaat("SERVICE_EARN_CASINO_HEIST_AWARD_PROFESSIONAL"),       250000 },
    { "200k (GANGOPS_AWARD_SUPPORTING)",              joaat("SERVICE_EARN_GANGOPS_AWARD_SUPPORTING"),              200000 },
    { "200k (COLLECTABLES_ACTION_FIGURES)",           joaat("SERVICE_EARN_COLLECTABLES_ACTION_FIGURES"),           200000 },
    { "200k (ISLAND_HEIST_AWARD_GOING_ALONE)",        joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_GOING_ALONE"),        200000 },
    { "200k (JOB_BONUS_FIRST_TIME_BONUS)",            joaat("SERVICE_EARN_JOB_BONUS_FIRST_TIME_BONUS"),            200000 },
    { "200k (GANGOPS_AWARD_FIRST_TIME_XM_SILO)",      joaat("SERVICE_EARN_GANGOPS_AWARD_FIRST_TIME_XM_SILO"),      200000 },
    { "200k (DOOMSDAY_FINALE_BONUS)",                 joaat("SERVICE_EARN_DOOMSDAY_FINALE_BONUS"),                 200000 },
    { "200k (GANGOPS_AWARD_FIRST_TIME_XM_BASE)",      joaat("SERVICE_EARN_GANGOPS_AWARD_FIRST_TIME_XM_BASE"),      200000 },
    { "200k (COLLECTABLE_COMPLETED_COLLECTION)",      joaat("SERVICE_EARN_COLLECTABLE_COMPLETED_COLLECTION"),      200000 },
    { "200k (ISLAND_HEIST_ELITE_CHALLENGE)",          joaat("SERVICE_EARN_ISLAND_HEIST_ELITE_CHALLENGE"),          200000 },
    { "200k (AMBIENT_JOB_CHECKPOINT_COLLECTION)",     joaat("SERVICE_EARN_AMBIENT_JOB_CHECKPOINT_COLLECTION"),     200000 },
    { "200k (GANGOPS_AWARD_FIRST_TIME_XM_SUBMARINE)", joaat("SERVICE_EARN_GANGOPS_AWARD_FIRST_TIME_XM_SUBMARINE"), 200000 },
    { "200k (ISLAND_HEIST_AWARD_TEAM_WORK)",          joaat("SERVICE_EARN_ISLAND_HEIST_AWARD_TEAM_WORK"),          200000 },
    { "200k (CASINO_HEIST_ELITE_DIRECT)",             joaat("SERVICE_EARN_CASINO_HEIST_ELITE_DIRECT"),             200000 },
    { "200k (CASINO_HEIST_ELITE_STEALTH)",            joaat("SERVICE_EARN_CASINO_HEIST_ELITE_STEALTH"),            200000 },
    { "200k (AMBIENT_JOB_TIME_TRIAL)",                joaat("SERVICE_EARN_AMBIENT_JOB_TIME_TRIAL"),                200000 },
    { "200k (CASINO_HEIST_AWARD_UNDETECTED)",         joaat("SERVICE_EARN_CASINO_HEIST_AWARD_UNDETECTED"),         200000 },
    { "200k (CASINO_HEIST_ELITE_SUBTERFUGE)",         joaat("SERVICE_EARN_CASINO_HEIST_ELITE_SUBTERFUGE"),         200000 },
    { "200k (GANGOPS_ELITE_XM_SILO)",                 joaat("SERVICE_EARN_GANGOPS_ELITE_XM_SILO"),                 200000 },
    { "190k (VEHICLE_SALES)",                         joaat("SERVICE_EARN_VEHICLE_SALES"),                         190000 },
    { "180k (JOBS)",                                  joaat("SERVICE_EARN_JOBS"),                                  180000 },
    { "165k (AMBIENT_JOB_RC_TIME_TRIAL)",             joaat("SERVICE_EARN_AMBIENT_JOB_RC_TIME_TRIAL"),             165000 },
    { "150k (AMBIENT_JOB_BEAST)",                     joaat("SERVICE_EARN_AMBIENT_JOB_BEAST"),                     150000 },
    { "150k (CASINO_HEIST_AWARD_IN_PLAIN_SIGHT)",     joaat("SERVICE_EARN_CASINO_HEIST_AWARD_IN_PLAIN_SIGHT"),     150000 },
    { "150k (AMBIENT_JOB_SOURCE_RESEARCH)",           joaat("SERVICE_EARN_AMBIENT_JOB_SOURCE_RESEARCH"),           150000 },
    { "150k (GANGOPS_ELITE_XM_SUBMARINE)",            joaat("SERVICE_EARN_GANGOPS_ELITE_XM_SUBMARINE"),            150000 },
    { "120k (AMBIENT_JOB_KING)",                      joaat("SERVICE_EARN_AMBIENT_JOB_KING"),                      120000 },
    { "120k (AMBIENT_JOB_PENNED_IN)",                 joaat("SERVICE_EARN_AMBIENT_JOB_PENNED_IN"),                 120000 },
    { "115k (SIGHTSEEING_REWARD)",                    joaat("SERVICE_EARN_SIGHTSEEING_REWARD"),                    115000 },
    { "100k (CASINO_AWARD_HIGH_ROLLER_PLATINUM)",     joaat("SERVICE_EARN_CASINO_AWARD_HIGH_ROLLER_PLATINUM"),     100000 },
    { "100k (TUNER_AWARD_BOLINGBROKE_ASS)",           joaat("SERVICE_EARN_TUNER_AWARD_BOLINGBROKE_ASS"),           100000 },
    { "100k (CASINO_AWARD_FULL_HOUSE)",               joaat("SERVICE_EARN_CASINO_AWARD_FULL_HOUSE"),               100000 },
    { "100k (AGENCY_SECURITY_CONTRACT)",              joaat("SERVICE_EARN_AGENCY_SECURITY_CONTRACT"),              100000 },
    { "100k (DAILY_STASH_HOUSE_COMPLETED)",           joaat("SERVICE_EARN_DAILY_STASH_HOUSE_COMPLETED"),           100000 },
    { "100k (CASINO_AWARD_MISSION_SIX_FIRST_TIME)",   joaat("SERVICE_EARN_CASINO_AWARD_MISSION_SIX_FIRST_TIME"),   100000 },
    { "100k (AMBIENT_JOB_CHALLENGES)",                joaat("SERVICE_EARN_AMBIENT_JOB_CHALLENGES"),                100000 },
    { "100k (AMBIENT_JOB_METAL_DETECTOR)",            joaat("SERVICE_EARN_AMBIENT_JOB_METAL_DETECTOR"),            100000 },
    { "100k (AMBIENT_JOB_HOT_PROPERTY)",              joaat("SERVICE_EARN_AMBIENT_JOB_HOT_PROPERTY"),              100000 },
    { "100k (AMBIENT_JOB_CLUBHOUSE_CONTRACT)",        joaat("SERVICE_EARN_AMBIENT_JOB_CLUBHOUSE_CONTRACT"),        100000 },
    { "100k (TUNER_AWARD_FLEECA_BANK)",               joaat("SERVICE_EARN_TUNER_AWARD_FLEECA_BANK"),               100000 },
    { "100k (AMBIENT_JOB_SMUGGLER_PLANE)",            joaat("SERVICE_EARN_AMBIENT_JOB_SMUGGLER_PLANE"),            100000 },
    { "100k (FIXER_AWARD_SHORT_TRIP)",                joaat("SERVICE_EARN_FIXER_AWARD_SHORT_TRIP"),                100000 },
    { "100k (AMBIENT_JOB_SMUGGLER_TRAIL)",            joaat("SERVICE_EARN_AMBIENT_JOB_SMUGGLER_TRAIL"),            100000 },
    { "100k (TUNER_AWARD_METH_JOB)",                  joaat("SERVICE_EARN_TUNER_AWARD_METH_JOB"),                  100000 },
    { "100k (CASINO_HEIST_AWARD_SMASH_N_GRAB)",       joaat("SERVICE_EARN_CASINO_HEIST_AWARD_SMASH_N_GRAB"),       100000 },
    { "100k (AGENCY_STORY_PREP)",                     joaat("SERVICE_EARN_AGENCY_STORY_PREP"),                     100000 },
    { "100k (WINTER_22_AWARD_DAILY_STASH)",           joaat("SERVICE_EARN_WINTER_22_AWARD_DAILY_STASH"),           100000 },
    { "100k (JUGGALO_PHONE_MISSION)",                 joaat("SERVICE_EARN_JUGGALO_PHONE_MISSION"),                 100000 },
    { "100k (AMBIENT_JOB_GOLDEN_GUN)",                joaat("SERVICE_EARN_AMBIENT_JOB_GOLDEN_GUN"),                100000 },
    { "100k (AMBIENT_JOB_URBAN_WARFARE)",             joaat("SERVICE_EARN_AMBIENT_JOB_URBAN_WARFARE"),             100000 },
    { "100k (AGENCY_PAYPHONE_HIT)",                   joaat("SERVICE_EARN_AGENCY_PAYPHONE_HIT"),                   100000 },
    { "100k (TUNER_AWARD_FREIGHT_TRAIN)",             joaat("SERVICE_EARN_TUNER_AWARD_FREIGHT_TRAIN"),             100000 },
    { "100k (WINTER_22_AWARD_DEAD_DROP)",             joaat("SERVICE_EARN_WINTER_22_AWARD_DEAD_DROP"),             100000 },
    { "100k (CLUBHOUSE_DUFFLE_BAG)",                  joaat("SERVICE_EARN_CLUBHOUSE_DUFFLE_BAG"),                  100000 },
    { "100k (WINTER_22_AWARD_RANDOM_EVENT)",          joaat("SERVICE_EARN_WINTER_22_AWARD_RANDOM_EVENT"),          100000 },
    { "100k (TUNER_AWARD_MILITARY_CONVOY)",           joaat("SERVICE_EARN_TUNER_AWARD_MILITARY_CONVOY"),           100000 },
    { "100k (JUGGALO_STORY_MISSION_PARTICIPATION)",   joaat("SERVICE_EARN_JUGGALO_STORY_MISSION_PARTICIPATION"),   100000 },
    { "100k (AMBIENT_JOB_CRIME_SCENE)",               joaat("SERVICE_EARN_AMBIENT_JOB_CRIME_SCENE"),               100000 },
    { "100k (TUNER_AWARD_IAA_RAID)",                  joaat("SERVICE_EARN_TUNER_AWARD_IAA_RAID"),                  100000 },
    { "100k (ARENA_CAREER_TIER_PROGRESSION_4)",       joaat("SERVICE_EARN_ARENA_CAREER_TIER_PROGRESSION_4"),       100000 },
    { "100k (AUTO_SHOP_DELIVERY_AWARD)",              joaat("SERVICE_EARN_AUTO_SHOP_DELIVERY_AWARD"),              100000 },
    { "100k (CASINO_AWARD_TOP_PAIR)",                 joaat("SERVICE_EARN_CASINO_AWARD_TOP_PAIR"),                 100000 },
    { "100k (TUNER_AWARD_UNION_DEPOSITORY)",          joaat("SERVICE_EARN_TUNER_AWARD_UNION_DEPOSITORY"),          100000 },
    { "100k (AMBIENT_JOB_UNDERWATER_CARGO)",          joaat("SERVICE_EARN_AMBIENT_JOB_UNDERWATER_CARGO"),          100000 },
    { "100k (COLLECTABLE_ITEM)",                      joaat("SERVICE_EARN_COLLECTABLE_ITEM"),                      100000 },
    { "100k (WINTER_22_AWARD_ACID_LAB)",              joaat("SERVICE_EARN_WINTER_22_AWARD_ACID_LAB"),              100000 },
    { "100k (AMBIENT_JOB_MAZE_BANK)",                 joaat("SERVICE_EARN_AMBIENT_JOB_MAZE_BANK"),                 100000 },
    { "100k (GANGOPS_ELITE_XM_BASE)",                 joaat("SERVICE_EARN_GANGOPS_ELITE_XM_BASE"),                 100000 },
    { "100k (WINTER_22_AWARD_TAXI)",                  joaat("SERVICE_EARN_WINTER_22_AWARD_TAXI"),                  100000 },
    { "100k (TUNER_DAILY_VEHICLE_BONUS)",             joaat("SERVICE_EARN_TUNER_DAILY_VEHICLE_BONUS"),             100000 },
    { "100k (TUNER_AWARD_BUNKER_RAID)",               joaat("SERVICE_EARN_TUNER_AWARD_BUNKER_RAID"),               100000 },
    { "100k (AMBIENT_JOB_AMMUNATION_DELIVERY)",       joaat("SERVICE_EARN_AMBIENT_JOB_AMMUNATION_DELIVERY"),       100000 },
    { "90k (GANGOPS_SETUP)",                          joaat("SERVICE_EARN_GANGOPS_SETUP"),                         90000 },
    { "80k (AMBIENT_JOB_DEAD_DROP)",                  joaat("SERVICE_EARN_AMBIENT_JOB_DEAD_DROP"),                 80000 },
    { "80k (AMBIENT_JOB_HOT_TARGET_DELIVER)",         joaat("SERVICE_EARN_AMBIENT_JOB_HOT_TARGET_DELIVER"),        80000 },
    { "75k (ARENA_CAREER_TIER_PROGRESSION_3)",        joaat("SERVICE_EARN_ARENA_CAREER_TIER_PROGRESSION_3"),       75000 },
    { "70k (AMBIENT_JOB_XMAS_MUGGER)",                joaat("SERVICE_EARN_AMBIENT_JOB_XMAS_MUGGER"),               70000 },
    { "65k (IMPORT_EXPORT)",                          joaat("SERVICE_EARN_IMPORT_EXPORT"),                         65000 },
    { "60k (FROM_CLUB_MANAGEMENT_PARTICIPATION)",     joaat("SERVICE_EARN_FROM_CLUB_MANAGEMENT_PARTICIPATION"),    60000 },
    { "60k (NIGHTCLUB_DANCING_AWARD)",                joaat("SERVICE_EARN_NIGHTCLUB_DANCING_AWARD"),               60000 },
    { "55k (ARENA_CAREER_TIER_PROGRESSION_2)",        joaat("SERVICE_EARN_ARENA_CAREER_TIER_PROGRESSION_2"),       55000 },
    { "50k (FROM_BUSINESS_BATTLE)",                   joaat("SERVICE_EARN_FROM_BUSINESS_BATTLE"),                  50000 },
    { "50k (ISLAND_HEIST_DJ_MISSION)",                joaat("SERVICE_EARN_ISLAND_HEIST_DJ_MISSION"),               50000 },
    { "50k (ARENA_SKILL_LVL_AWARD)",                  joaat("SERVICE_EARN_ARENA_SKILL_LVL_AWARD"),                 50000 },
    { "50k (AMBIENT_JOB_GANG_CONVOY)",                joaat("SERVICE_EARN_AMBIENT_JOB_GANG_CONVOY"),               50000 },
    { "50k (COLLECTABLES_SIGNAL_JAMMERS_COMPLETE)",   joaat("SERVICE_EARN_COLLECTABLES_SIGNAL_JAMMERS_COMPLETE"),  50000 },
    { "50k (AMBIENT_JOB_HELI_HOT_TARGET)",            joaat("SERVICE_EARN_AMBIENT_JOB_HELI_HOT_TARGET"),           50000 },
    { "50k (ACID_LAB_SELL_PARTICIPATION)",            joaat("SERVICE_EARN_ACID_LAB_SELL_PARTICIPATION"),           50000 },
    { "50k (FROM_CONTRABAND)",                        joaat("SERVICE_EARN_FROM_CONTRABAND"),                       50000 },
    { "50k (CASINO_AWARD_HIGH_ROLLER_GOLD)",          joaat("SERVICE_EARN_CASINO_AWARD_HIGH_ROLLER_GOLD"),         50000 },
    { "50k (CASINO_AWARD_MISSION_THREE_FIRST_TIME)",  joaat("SERVICE_EARN_CASINO_AWARD_MISSION_THREE_FIRST_TIME"), 50000 },
    { "50k (GOON)",                                   joaat("SERVICE_EARN_GOON"),                                  50000 },
    { "50k (FIXER_AWARD_PHONE_HIT)",                  joaat("SERVICE_EARN_FIXER_AWARD_PHONE_HIT"),                 50000 },
    { "50k (CASINO_AWARD_MISSION_FOUR_FIRST_TIME)",   joaat("SERVICE_EARN_CASINO_AWARD_MISSION_FOUR_FIRST_TIME"),  50000 },
    { "50k (TAXI_JOB)",                               joaat("SERVICE_EARN_TAXI_JOB"),                              50000 },
    { "50k (CASINO_AWARD_MISSION_ONE_FIRST_TIME)",    joaat("SERVICE_EARN_CASINO_AWARD_MISSION_ONE_FIRST_TIME"),   50000 },
    { "50k (AMBIENT_JOB_SHOP_ROBBERY)",               joaat("SERVICE_EARN_AMBIENT_JOB_SHOP_ROBBERY"),              50000 },
    { "50k (ARENA_WAR)",                              joaat("SERVICE_EARN_ARENA_WAR"),                             50000 },
    { "50k (CASINO_AWARD_MISSION_FIVE_FIRST_TIME)",   joaat("SERVICE_EARN_CASINO_AWARD_MISSION_FIVE_FIRST_TIME"),  50000 },
    { "50k (CASINO_AWARD_LUCKY_LUCKY)",               joaat("SERVICE_EARN_CASINO_AWARD_LUCKY_LUCKY"),              50000 },
    { "50k (AMBIENT_JOB_PASS_PARCEL)",                joaat("SERVICE_EARN_AMBIENT_JOB_PASS_PARCEL"),               50000 },
    { "50k (TUNER_CAR_CLUB_MEMBERSHIP)",              joaat("SERVICE_EARN_TUNER_CAR_CLUB_MEMBERSHIP"),             50000 },
    { "50k (CASINO_AWARD_MISSION_TWO_FIRST_TIME)",    joaat("SERVICE_EARN_CASINO_AWARD_MISSION_TWO_FIRST_TIME"),   50000 },
    { "50k (AMBIENT_JOB_HOT_TARGET_KILL)",            joaat("SERVICE_EARN_AMBIENT_JOB_HOT_TARGET_KILL"),           50000 },
    { "50k (AMBIENT_JOB_HOT_TARGET_KILL)",            joaat("SERVICE_SPEND_PAY_BOSS"),                             21474836 }
}
local transaction = 20


function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Transactions")

    function tab.render()
        ImGui.Text("Some transactions have a cooldown up to ~15 minutes.")
        ImGui.Text("That's why you sometimes don't receive money.")
        ImGui.Spacing()

        ImGui.PushItemWidth(340)
        if ImGui.BeginCombo("Transaction", transactions[transaction][1]) then
            for id, data in pairs(transactions) do
                if ImGui.Selectable(data[1], false) then
                    transaction = id
                end
            end
            ImGui.EndCombo()
        end
        ImGui.PopItemWidth()

        if ImGui.Button("Trigger transaction") then
            yu.rif(function(rs)
                local data = transactions[transaction]
                if type(data) == "table" then
                    triggerTransaction(rs, data[2], data[3])
                end
            end)
        end

        ImGui.SameLine()

        yu.rendering.renderCheckbox("Loop", "online_money_loop", function(state)
            if state then
                yu.rif(function(rs)
                    local data = transactions[transaction]
                    if type(data) == "table" then
                        while yu.rendering.isCheckboxChecked("online_money_loop") and not loop do
                            loop = true
                            triggerTransaction(rs, data[2], data[3])
                            rs:sleep(1000)
                            loop = nil
                        end
                    end
                end)
            end
        end)

        if SussySpt.dev and ImGui.Button("Dump globals") then
            tasks.addTask(function()
                local b = values.g.transaction_base
                log.info("====[ Start ]====")
                log.info((b + 1)..": "..globals.get_int(b + 1).." = 2147483646")
                log.info((b + 7)..": "..globals.get_int(b + 7).." = 2147483647")
                log.info((b + 6)..": "..globals.get_int(b + 6).." = 0")
                log.info((b + 5)..": "..globals.get_int(b + 5).." = 0")
                log.info((b + 3)..": "..globals.get_int(b + 3).." = <hash>")
                log.info((b + 2)..": "..globals.get_int(b + 2).." = <amount>")
                log.info(b..": "..globals.get_int(b).." = 2")
                log.info("=====[ End ]=====")
            end)
        end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

return exports
