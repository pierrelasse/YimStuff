local values = require("sussyspt/values")

local actions = {
    -- { Func, DisplayName, [Description], [Cond] }
}

function SussySpt.qa.onlineCond() return SussySpt.in_online end

actions.heal = { -- ANCHOR heal
    function()
        actions.refillHealth[1]()
        actions.refillArmor[1]()
    end,
    "Heal",
    "Refills your health and armor"
}

actions.refillHealth = { -- ANCHOR refillHealth
    function()
        ENTITY.SET_ENTITY_HEALTH(yu.ppid(), PED.GET_PED_MAX_HEALTH(yu.ppid()), 0, 0)
    end,
    "Refill health",
    "Refills your health"
}

actions.refillArmor = { -- ANCHOR refillArmor
    function()
        PED.SET_PED_ARMOUR(yu.ppid(), PLAYER.GET_PLAYER_MAX_ARMOUR(yu.pid()))
    end,
    "Refill armor",
    "Refills your armor"
}

actions.clearWantedLevel = { -- ANCHOR clearWantedLevel
    function()
        PLAYER.CLEAR_PLAYER_WANTED_LEVEL(yu.pid())
    end,
    "Clear wanted level",
    "Sets your current wanted level to 0"
}

actions.ri2 = { -- ANCHOR ri2
    function()
        local ppid = yu.ppid()
        INTERIOR.REFRESH_INTERIOR(INTERIOR.GET_INTERIOR_FROM_ENTITY(ppid))
        local c = yu.coords(ppid)
        PED.SET_PED_COORDS_KEEP_VEHICLE(ppid, c.x, c.y, c.z - 1)
    end,
    "RI2",
    "Refreshes the interior you are currently in\nClears the ped's tasks\n\nThis is good for when you can't see anything"
}

actions.skipCutscene = { -- ANCHOR skipCutscene
    function()
        CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
        if NETWORK.NETWORK_IS_IN_MP_CUTSCENE() then
            NETWORK.NETWORK_SET_IN_MP_CUTSCENE(false, true)
        end
    end,
    "Skip cutscene",
    "There are some unskippable \"cutscenes\" where this doesn't work"
}

actions.removeBlackscreen = { -- ANCHOR removeBlackscreen
    function()
        CAM.DO_SCREEN_FADE_IN(0)
    end,
    "Remove blackscreen"
}

actions.repairVehicle = { -- ANCHOR repairVehicle
    function()
        local veh = yu.veh()
        if veh ~= nil and entities.take_control_of(veh) then
            VEHICLE.SET_VEHICLE_FIXED(veh)
            VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, .0)
        end
    end,
    "Repair vehicle",
    "Repairs the vehicle.\nUse with caution because this closes doors and stuff"
}

actions.stfu = { -- ANCHOR stfu
    function()
        AUDIO.STOP_SCRIPTED_CONVERSATION(false)
    end,
    "Stop conversation",
    "Tries to stop the blah blah from npcs"
}

actions.instantBST = { -- ANCHOR instantBST
    function()
        globals.set_int(values.g.bullshark_stage, 1)
    end,
    "Instant BST",
    "You will receive less damage and do more damage while the effect is active",
    SussySpt.qa.onlineCond
}

actions.depositWallet = { -- ANCHOR depositWallet
    function()
        local pi = yu.playerindex()
        local amount = MONEY.NETWORK_GET_VC_WALLET_BALANCE(pi)
        if amount > 0 then
            NETSHOPPING.NET_GAMESERVER_TRANSFER_WALLET_TO_BANK(
                pi,
                amount
            )
        end
    end,
    "Deposit wallet",
    "Puts all your money in the bank",
    SussySpt.qa.onlineCond
}

actions.stopPlayerSwitch = { -- ANCHOR stopPlayerSwitch
    function()
        STREAMING.STOP_PLAYER_SWITCH()
        SCRIPT.SHUTDOWN_LOADING_SCREEN()
        if CAM.IS_SCREEN_FADED_OUT() then
            CAM.DO_SCREEN_FADE_IN(0)
        end
        GRAPHICS.ANIMPOSTFX_STOP_ALL()
        HUD.SET_FRONTEND_ACTIVE(true)
        HUD.CLEAR_HELP(true)
    end,
    "Stop player switch"
}

return actions
