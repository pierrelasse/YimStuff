return {
    g = { -- ANCHOR Globals
        fm = 262145, -- freemode

        agency_payout = 32466, -- CLO_FXM_L_1_0
        agency_instantfinish1 = 38397,
        agency_instantfinish2 = 39772,
        agency_cooldown = 32500, -- CLO_FXM_L_3_5
        agency_maxpayout = 262145 + 32466,

        autoshop_payout1 = 31602,
        autoshop_payout2 = 31610,

        autoshop_instantfinish1 = 48513, -- + 1,
        autoshop_instantfinish2 = 48513 + 1378 + 1,
        apartment_cuts_other = 1928233 + 1,
        apartment_cuts_self = 1930201 + 3008 + 1,
        apartment_replay = 2635522, -- HEIST_REPLAY_FIN

        bullshark_stage = 2672741 + 3694,

        bounty_self_time = 1 + 2359296 + 5150 + 13,

        transaction_base = 4537212
    },
    l = { -- ANCHOR Locals
        apartment_fleeca_hackstage = 11776 + 24,
        apartment_fleeca_drillstage = 10067 + 11,
        apartment_instantfinish1 = 19728,
        apartment_instantfinish2 = 28347 + 1,
        apartment_instantfinish3 = 31603 + 69,

        lucky_wheel_win_state = 278,
        lucky_wheel_prize = 14,
        lucky_wheel_prize_state = 45,

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
            54 -- GGSM_SPRITE_POWER_UP_STUN
        }
    },
    t = { -- ANCHOR Tunables
        salvageyard_week = 488207018
    }
}
