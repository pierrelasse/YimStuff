local values = {}

local fmg = 262145 -- TODO: Hotfix

-- ANCHOR Globals
values.g = {
    fm = fmg, -- freemode

    apartment_cuts_other = 1928233 + 1,
    apartment_cuts_self = 1930201 + 3008 + 1,
    apartment_replay = 2635522,    -- HEIST_REPLAY_FIN
    apartment_jobs_1 = fmg + 9237, -- "ROOT_ID_HASH_THE_FLECCA_JOB"
    apartment_jobs_2 = fmg + 9242, -- "ROOT_ID_HASH_THE_PRISON_BREAK"
    apartment_jobs_3 = fmg + 9249, -- "ROOT_ID_HASH_THE_HUMANE_LABS_RAID"
    apartment_jobs_4 = fmg + 9255, -- "ROOT_ID_HASH_SERIES_A_FUNDING"
    apartment_jobs_5 = fmg + 9261, -- "ROOT_ID_HASH_THE_PACIFIC_STANDARD_JOB"

    agency_payout = 32466,         -- CLO_FXM_L_1_0
    agency_instantfinish1 = 38397,
    agency_instantfinish2 = 39772,
    agency_cooldown = fmg + 294167,
    agency_maxpayout = 262145 + 32466,

    autoshop_payout_1 = 293464,
    autoshop_payout_2 = 293469,
    autoshop_payout_3 = 293476,
    autoshop_instantfinish_1 = 48513,
    autoshop_instantfinish_1_value = 51338977,
    autoshop_instantfinish_2 = 48513 + 1378 + 1,
    autoshop_instantfinish_2_value = 101,

    facility_cuts = 1959865 + 812 + 50,
    facility_cutsSelf = 2685249 + 6615,

    cayo_readyState = function(index)
        return 1971856 + 1 + (index * 27) + 8 + index
    end,

    request_service = 2738587,
    request_service_moc = 930,
    request_service_avenger = 938,
    request_service_terrorbyte = 943,
    request_service_kosatka = 960,
    request_service_acidlab = 944,
    request_service_dingy = 972,
    request_service_motorbike = 994,
    request_service_ballisticArmor = 901,
    request_service_rcBandito = 6880,
    request_service_rcTank = 6894,

    bullshark_stage = 2672741 + 3694,

    bounty_self_time = 1 + 2359296 + 5150 + 13,

    transaction_base = 4537212
}

-- ANCHOR Locals
values.l = {
    apartment_fleeca_hackstage = 11776 + 24,
    apartment_fleeca_drillstage = 10067 + 11,
    apartment_instantfinish1 = 19728,
    apartment_instantfinish2 = 28347 + 1,
    apartment_instantfinish3 = 31603 + 69,

    kosatka_boardStage = 1544,

    warehouse_instant_1 = 606,
    warehouse_instant_1_value = 1,
    warehouse_instant_2 = 602,
    warehouse_instant_3 = 792,
    warehouse_instant_3_value = 6,
    warehouse_instant_4 = 793,
    warehouse_instant_4_value = 4,

    arcadegames_ggsm_data = 703,
    arcadegames_ggsm_stats = 4572,
    arcadegames_ggsm_playtime = 6,
    arcadegames_ggsm_playerlives = 4583,
    arcadegames_ggsm_score = 7,
    arcadegames_ggsm_entities = 484,
    arcadegames_ggsm_hp = 23,
    arcadegames_ggsm_kills = 5,
    arcadegames_ggsm_powerupscollected = 4,
    arcadegames_ggsm_position = 7,
    arcadegames_ggsm_weapontype = 48,
    arcadegames_ggsm_weaponslot = 2811,
    arcadegames_ggsm_powerups = {
        44, -- GGSM_SPRITE_POWER_UP_DECOY
        49, -- GGSM_SPRITE_POWER_UP_NUKE
        50, -- GGSM_SPRITE_POWER_UP_REPULSE
        53, -- GGSM_SPRITE_POWER_UP_SHIELD
        54  -- GGSM_SPRITE_POWER_UP_STUN
    },

    lucky_wheel_win_state = 278,
    lucky_wheel_prize = 14,
    lucky_wheel_prize_state = 45
}

-- ANCHOR Tunables
values.t = {
    salvageyard_week = 488207018
}

return values
