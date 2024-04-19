local tasks = require("./tasks")
local cfg = require("./config")

SussySpt.qa = {}

do -- SECTION Actions
    SussySpt.qa.actions = {
        -- { Func, DisplayName, [Description], [Cond] }
    }

    SussySpt.qa.onlineCond = function()
        return SussySpt.in_online
    end

    SussySpt.qa.actions.heal = { -- ANCHOR heal
        function()
            SussySpt.qa.actions.refillHealth[1]()
            SussySpt.qa.actions.refillArmor[1]()
        end,
        "Heal",
        "Refills your health and armor"
    }

    SussySpt.qa.actions.refillHealth = { -- ANCHOR refillHealth
        function()
            ENTITY.SET_ENTITY_HEALTH(yu.ppid(), PED.GET_PED_MAX_HEALTH(yu.ppid()), 0, 0)
        end,
        "Refill health",
        "Refills your health"
    }

    SussySpt.qa.actions.refillArmor = { -- ANCHOR refillArmor
        function()
            PED.SET_PED_ARMOUR(yu.ppid(), PLAYER.GET_PLAYER_MAX_ARMOUR(yu.pid()))
        end,
        "Refill armor",
        "Refills your armor"
    }

    SussySpt.qa.actions.clearWantedLevel = { -- ANCHOR clearWantedLevel
        function()
            PLAYER.CLEAR_PLAYER_WANTED_LEVEL(yu.pid())
        end,
        "Clear wanted level",
        "Sets your current wanted level to 0"
    }

    SussySpt.qa.actions.ri2 = { -- ANCHOR ri2
        function()
            local ppid = yu.ppid()
            INTERIOR.REFRESH_INTERIOR(INTERIOR.GET_INTERIOR_FROM_ENTITY(ppid))
            local c = yu.coords(ppid)
            PED.SET_PED_COORDS_KEEP_VEHICLE(ppid, c.x, c.y, c.z - 1)
        end,
        "RI2",
        "Refreshes the interior you are currently in\nClears the ped's tasks\n\nThis is good for when you can't see anything"
    }

    SussySpt.qa.actions.skipCutscene = { -- ANCHOR skipCutscene
        function()
            CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
            if NETWORK.NETWORK_IS_IN_MP_CUTSCENE() then
                NETWORK.NETWORK_SET_IN_MP_CUTSCENE(false, true)
            end
        end,
        "Skip cutscene",
        "There are some unskippable \"cutscenes\" where this doesn't work"
    }

    SussySpt.qa.actions.removeBlackscreen = { -- ANCHOR removeBlackscreen
        function()
            CAM.DO_SCREEN_FADE_IN(0)
        end,
        "Remove blackscreen"
    }

    SussySpt.qa.actions.repairVehicle = { -- ANCHOR repairVehicle
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

    SussySpt.qa.actions.stfu = { -- ANCHOR stfu
        function()
            AUDIO.STOP_SCRIPTED_CONVERSATION(false)
        end,
        "Stop conversation",
        "Tries to stop the blah blah from npcs"
    }

    SussySpt.qa.actions.instantBST = { -- ANCHOR instantBST
        function()
            globals.set_int(SussySpt.p.g.bullshark_stage, 1)
        end,
        "Instant BST",
        "You will receive less damage and do more damage while the effect is active",
        SussySpt.qa.onlineCond
    }

    SussySpt.qa.actions.depositWallet = { -- ANCHOR depositWallet
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

    SussySpt.qa.actions.stopPlayerSwitch = { -- ANCHOR stopPlayerSwitch
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
end -- !SECTION

do -- SECTION Config
    SussySpt.qa.config = {
        default = {
            "heal", "refillHealth", "refillArmor", "clearWantedLevel", 0,
            "ri2", "skipCutscene", "removeBlackscreen", 0,
            "repairVehicle", "stfu", 0,
            "instantBST", "depositWallet", "stopPlayerSwitch"
        }
    }

    SussySpt.qa.config.load = function()
        local sort = cfg.get("qa_sort")
        if sort == nil then
            sort = yu.copy_table(SussySpt.qa.config.default)
        end
        SussySpt.qa.config.sort = sort
    end

    SussySpt.qa.config.save = function()
        if type(SussySpt.qa.config.sort) ~= "table" then
            return
        end
        if table.compare(SussySpt.qa.config.default, SussySpt.qa.config.sort) then
            cfg.set("qa_sort", nil)
        else
            cfg.set("qa_sort", SussySpt.qa.config.sort)
        end
        cfg.save()
    end

    SussySpt.qa.config.load()
end -- !SECTION

SussySpt.qa.render = function() -- ANCHOR Render
    if not yu.rendering.isCheckboxChecked("cat_qa") then
        return
    end

    local sameline = false

    if ImGui.Begin("Quick actions") then
        for k, v in pairs(SussySpt.qa.config.sort) do
            if type(v) == "number" then
                if v == 0 then
                    sameline = false
                end

            elseif type(v) == "string" then
                local b = SussySpt.qa.actions[v]
                if b ~= nil then
                    if type(b[4]) ~= "function" or b[4]() ~= false then
                        if sameline then
                            ImGui.SameLine()
                        end
                        sameline = true

                        if ImGui.Button(b[2]) then
                            tasks.addTask(function()
                                b[1]()
                            end)
                        end
                        if b[3] ~= nil and ImGui.IsItemHovered() then
                            ImGui.SetTooltip(b[3])
                        end
                    end
                end
            end
        end
    end
    ImGui.End()
end
