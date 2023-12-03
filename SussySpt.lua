--[[ SussySpt ]]
SussySpt = {
    version = "1.3.11",
    versionid = 2356,
    versiontype = 0--[[VERSIONTYPE]],
    build = 0--[[BUILD]],
    doInit = true,
    doDebug = false,
    debugtext = "",
    debug = function(s)
        if type(s) == "string" then
            if SussySpt.doDebug then
                log.debug(s)
            end
            SussySpt.debugtext = SussySpt.debugtext..(SussySpt.debugtext == "" and "" or "\n")..s
        end
    end
}

SussySpt.debug("Loading yimutils")
yu = require("yimutils")

function SussySpt:init() -- SECTION SussySpt:init
    if SussySpt.doInit ~= true then
        SussySpt.debug("SussySpt:init() was called after initialization")
        return
    end
    SussySpt.doInit = nil

    if not yu.is_num_between(SussySpt.versiontype, 1, 2) then
        log.warning("Fatal: Could not start due to an invalid version type. Are you using a source file?")
        return
    end

    SussySpt.dev = SussySpt.versiontype == 2
    SussySpt.getDev = function()
        return SussySpt.dev
    end

    SussySpt.debug("Starting SussySpt v"..SussySpt.version.." ["..SussySpt.versionid.."] build "..SussySpt.build)

    yu.set_notification_title_prefix("[SussySpt] ")

    SussySpt.tab = gui.get_tab("SussySpt")

    SussySpt.in_online = false

    -- ANCHOR Define rendering
    SussySpt.rendering = {
        themes = {
            Nightly = {
                ImGuiCol = {
                    TitleBg = {9, 27, 46, 1},
                    TitleBgActive = {9, 27, 46, 1},
                    WindowBg = {0, 19, 37, .95},
                    Tab = {10, 30, 46, 1},
                    TabActive = {14, 60, 90, 1},
                    TabHovered = {52, 64, 71, 1},
                    Button = {3, 45, 79, 1},
                    FrameBg = {35, 38, 53, 1},
                    FrameBgHovered = {37, 40, 55, 1},
                    FrameBgActive = {37, 40, 55, 1},
                    HeaderActive = {54, 55, 66, 1},
                    HeaderHovered = {62, 63, 73, 1},
                },
                ImGuiStyleVar = {
                    WindowRounding = {4},
                    FrameRounding = {2}
                }
            },
            Dark = {
                ImGuiCol = {
                    TitleBg = {18, 18, 18, .97},
                    TitleBgActive = {21, 21, 22, .97},
                    WindowBg = {18, 18, 18, .97},
                    Tab = {42, 42, 42, .8},
                    TabActive = {134, 134, 134, 1},
                    TabHovered = {147, 147, 147, 1},
                    Button = {42, 42, 42, .8},
                    FrameBg = {32, 32, 32, 1},
                    FrameBgHovered = {34, 34, 34, 1},
                    FrameBgActive = {34, 34, 34, 1}
                },
                ImGuiStyleVar = {
                    WindowRounding = {8},
                    FrameRounding = {5}
                }
            },
            Purple = {
                ImGuiCol = {
                    TitleBg = {11, 5, 37, .75},
                    TitleBgActive = {21, 8, 47, .81},
                    WindowBg = {21, 8, 47, .82},
                    Tab = {41, 25, 80, .5},
                    TabActive = {55, 29, 124, .5},
                    TabHovered = {51, 35, 90, .55},
                    Button = {94, 57, 186, .3},
                    FrameBg = {41, 25, 80, .67},
                    FrameBgHovered = {41, 35, 90, .67},
                    FrameBgActive = {41, 35, 90, .67}
                },
                ImGuiStyleVar = {
                    WindowRounding = {16},
                    FrameRounding = {3}
                }
            },
            Fatality = {
                ImGuiCol = {
                    TitleBg = {9, 6, 20, .75},
                    TitleBgActive = {9, 6, 20, .85},
                    WindowBg = {19, 13, 43, .87},
                    Tab = {239, 7, 73, .5},
                    TabActive = {255, 59, 115, .5},
                    TabHovered = {255, 59, 115, .55},
                    Button = {239, 7, 73, .3},
                    FrameBg = {26, 29, 48, .67},
                    FrameBgHovered = {16, 22, 48, .67},
                    FrameBgActive = {13, 15, 48, .67},
                    Border = {32, 20, 60, .76}
                },
                ImGuiStyleVar = {
                    WindowRounding = {5},
                    FrameRounding = {2.5}
                }
            },
            FatalityBorderTest = {
                parent = "Fatality",
                ImGuiCol = {
                    BorderShadow = {0, 0, 0, 0}
                },
                ImGuiStyleVar = {
                    FrameBorderSize = {4.05}
                }
            }
        },
        tabs = {}
    }

    for k, v in pairs(SussySpt.rendering.themes) do
        if v.ImGuiCol then
            for k, v2 in pairs(v.ImGuiCol) do
                for k3, v3 in pairs(v2) do
                    if k3 ~= 4 then v2[k3] = v3 / 255 end
                end
            end
        end
    end

    SussySpt.pointers = {
        bounty_self_value = 1 + 2359296 + 5150 + 14,
        bounty_self_time = 1 + 2359296 + 5150 + 13,
        bounty_other_amount = function(pid)
            return 1 + 1895156 + (pid * 609) + 600
        end,
        bounty_other_by = function(pid)
            return 1 + 1895156 + (pid * 609) + 601
        end,
        tunables_rpmultiplier = 262145 + 1,
        tunables_apmultiplier = 288259,
        halloween_unlock = 2765084 + 591,
        halloween_pumpkin_picked_up = 2765084 + 591
    }

    SussySpt.xp_to_rank = yu.xp_to_rank()

    SussySpt.rendering.theme = "Fatality"
    SussySpt.debug("Using theme '"..SussySpt.rendering.theme.."'")

    SussySpt.rendering.getTheme = function()
        return SussySpt.rendering.themes[SussySpt.rendering.theme] or {}
    end

    do
        local title = "SussySpt"

        if SussySpt.versiontype == 2 then
            title = title.." vD"..SussySpt.version
            title = title.."["..SussySpt.versionid.."]@"..SussySpt.build
        else
            title = title.." v"..SussySpt.version
        end

        SussySpt.rendering.title = title.."###sussyspt_mainwindow"
    end

    SussySpt.rendering.newTab = function(name, render)
        SussySpt.debug("Requested new tab with name '"..name.."'")
        return {
            name = name,
            render = render,
            should_display = nil,
            sub = {},
            id = yu.gun()
        }
    end

    local function renderTab(v)
        if not (type(v.should_display) == "function" and v.should_display() == false) and ImGui.BeginTabItem(v.name) then
            if yu.len(v.sub) > 0 then
                ImGui.BeginTabBar("##tabbar_"..v.id)
                for k1, v1 in pairs(v.sub) do
                    renderTab(v1)
                end
                ImGui.EndTabBar()
            end

            if type(v.render) == "function" then
                v.render()
            end
            ImGui.EndTabItem()
        end
    end

    SussySpt.render_pops = {}
    SussySpt.render = function()
        for k, v in pairs(SussySpt.rendercb) do
            v()
        end

        local function pushTheme(theme)
            if type(theme) ~= "table" then
                return
            end

            if theme.parent ~= nil then
                pushTheme(SussySpt.rendering.themes[theme.parent])
            end

            for k, v in pairs(theme) do
                if type(k) == "string" and type(v) == "table" then
                    for k1, v1 in pairs(v) do
                        if k == "ImGuiCol" then
                            ImGui.PushStyleColor(ImGuiCol[k1], v1[1], v1[2], v1[3], v1[4])
                            SussySpt.render_pops.PopStyleColor = (SussySpt.render_pops.PopStyleColor or 0) + 1
                        elseif k == "ImGuiStyleVar" then
                            if v1[2] == nil then
                                ImGui.PushStyleVar(ImGuiStyleVar[k1], v1[1])
                            else
                                ImGui.PushStyleVar(ImGuiStyleVar[k1], v1[1], v1[2])
                            end
                            SussySpt.render_pops.PopStyleVar = (SussySpt.render_pops.PopStyleVar or 0) + 1
                        end
                    end
                end
            end
        end
        pushTheme(SussySpt.rendering.getTheme())

        if ImGui.Begin(SussySpt.rendering.title) then
            ImGui.BeginTabBar("##tabbar")
            for k, v in pairs(SussySpt.rendering.tabs) do
                renderTab(v)
            end
            ImGui.EndTabBar()
        end
        ImGui.End()

        for k, v in pairs(SussySpt.render_pops) do
            ImGui[k](v)
        end
    end

    SussySpt.tasks = {}
    SussySpt.addTask = function(cb)
        local id = #SussySpt.tasks + 1
        SussySpt.tasks[id] = cb
        return id
    end

    SussySpt.disableControls = 0
    SussySpt.pushDisableControls = function(a)
        if a ~= false then
            SussySpt.disableControls = 4
        end
    end

    SussySpt.mainLoop = function(rs)
        while true do
            rs:yield()

            SussySpt.in_online = NETWORK.NETWORK_IS_IN_SESSION() == true

            if SussySpt.invisible == true then
                SussySpt.ensureVis(false, yu.ppid(), yu.veh())
            end

            if SussySpt.disableControls > 0 then
                SussySpt.disableControls = SussySpt.disableControls - 1

                for i = 0, 2 do
                    for i2 = 0, 360 do
                        PAD.DISABLE_CONTROL_ACTION(i, i2, true)
                    end
                end
            end

            for k, v in pairs(SussySpt.tasks) do
                v()
                SussySpt.tasks[k] = nil
            end
        end
    end

    SussySpt.requireScript = function(name)
        if yu.is_script_running(name) == false then
            yu.notify(3, "Script '"..name.."' is not running!", "Script Requirement")
            return false
        end
        return true
    end

    SussySpt.rendercb = {}
    SussySpt.add_render = function(cb)
        if cb ~= nil then
            local id = yu.gun()
            SussySpt.debug("Added render cb with id "..id)
            SussySpt.rendercb[id] = cb
        end
    end

    SussySpt.debug("Calling SussySpt:initCategories()")
    SussySpt:initCategories()

    SussySpt.debug("Initializing chatlog")
    SussySpt.chatlog = {
        messages = {},
        rebuildLog = function()
            local text = ""
            local newline = ""
            local doTimestamp = yu.rendering.isCheckboxChecked("online_chatlog_log_timestamp")
            for k, v in pairs(SussySpt.chatlog.messages) do
                text = text..newline..(doTimestamp and ("["..v[4].."] ") or "")..v[2]..": "..v[3]
                newline = "\n"
            end

            SussySpt.chatlog.text = text
        end
    }
    event.register_handler(menu_event.ChatMessageReceived, function(player_id, chat_message)
        if yu.rendering.isCheckboxChecked("online_chatlog_enabled") then
            local name = PLAYER.GET_PLAYER_NAME(player_id)
            SussySpt.chatlog.messages[#SussySpt.chatlog.messages + 1] = {
                player_id,
                name,
                chat_message,
                os.date("%H:%M:%S")
            }

            if yu.rendering.isCheckboxChecked("online_chatlog_console") then
                log.info("[CHAT] "..name..": "..chat_message)
            end

            SussySpt.chatlog.rebuildLog()
        end
    end)

    do -- SECTION Define tabs
        do -- SECTION Online
            local tab = SussySpt.rendering.newTab("Online")

            tab.should_display = function()
                return SussySpt.in_online or yu.len(SussySpt.players) >= 2
            end

            local function networkent(ent)
                if ent and ent ~= 0 and yu.does_entity_exist(ent) then
                    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(ent)
                    local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
                    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
                    return ent
                end
            end

            local function networkobj(obj)
                if networkent(obj) ~= nil then
                    local id = NETWORK.OBJ_TO_NET(obj)
                    NETWORK.NETWORK_USE_HIGH_PRECISION_BLENDING(id, true)
                    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(id, true)
                    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(id)
                    return obj
                end
            end

            local function triggerTransaction(rs, hash, amount)
                local b = 4536533
                globals.set_int(b + 1, 2147483646)
                globals.set_int(b + 7, 2147483647)
                globals.set_int(b + 6, 0)
                globals.set_int(b + 5, 0)
                globals.set_int(b + 3, hash)
                globals.set_int(b + 2, amount)
                globals.set_int(b, 2)
                rs:sleep(5)
                globals.set_int(b + 1, 2147483646)
                globals.set_int(b + 7, 2147483647)
                globals.set_int(b + 6, 0)
                globals.set_int(b + 5, 0)
                globals.set_int(b + 3, 0)
                globals.set_int(b + 2, 0)
                globals.set_int(b, 16)
            end

            do -- SECTION Players
                local tab2 = SussySpt.rendering.newTab("Players")

                local a = {
                    playerlistwidth = 211,

                    searchtext = "",

                    players = {},

                    open = 0,

                    selectedplayer = nil,
                    selectedplayerinfo = {},

                    namecolors = {
                        modder = {209, 13, 13},
                        friend = {103, 246, 92},
                        noped = {87, 87, 87},
                        dead = {81, 0, 8},
                        noblip = {151, 151, 151},
                        ghost = {201, 201, 201},
                        vehicle = {201, 247, 255},
                        cutscene = {83, 75, 115},
                        host = {255, 181, 101},
                        scripthost = {255, 226, 171},
                        unknownpos = {227, 223, 237}
                    },

                    ramoptions = {
                        ["bus"] = "Bus",
                        ["adder"] = "Adder",
                        ["monster"] = "Monster",
                        ["freight"] = "Train",
                        ["bulldozer"] = "Bulldozer (very cool)",
                        ["dump"] = "Dump (big)",
                        ["cutter"] = "Cutter",
                        ["firetruk"] = "Firetruk",
                        ["luxor"] = "Luxor",
                        ["blimp"] = "Blimp - Atomic",
                        ["metrotrain"] = "Metro"
                    },
                    ramoption = "bus",

                    givecustomweaponammo = 999,

                    pickupoptions = {
                        ["Casino Playing Card"] = "vw_prop_vw_lux_card_01a",
                        ["Action Figure - Boxeddoll (Not falling)"] = "bkr_prop_coke_boxeddoll",
                        ["Action Figure - Sasquatch"] = "vw_prop_vw_colle_sasquatch",
                        ["Action Figure - Beast"] = "vw_prop_vw_colle_beast",
                        ["Action Figure - Green guy"] = "vw_prop_vw_colle_rsrgeneric",
                        ["Action Figure - Other green guy"] = "vw_prop_vw_colle_rsrcomm",
                        ["Action Figure - Pogo"] = "vw_prop_vw_colle_pogo",
                        ["Action Figure - UWU"] = "vw_prop_vw_colle_prbubble",
                        ["Action Figure - Imporage"] = "vw_prop_vw_colle_imporage",
                        ["Action Figure - Alien"] = "vw_prop_vw_colle_alien"
                    },
                    pickupoption = "Action Figure - UWU",
                    pickupamount = 1,
                    cashamount = 1,
                    cashvalue = 100,

                    attachoptions = {
                        [joaat("prop_beach_fire")] = "Beach fire",
                        [-2007231801] = "Gas pump",
                        [joaat("prop_gas_tank_01a")] = "Gas tank",
                        [joaat("p_spinning_anus_s")] = "Big ufo",
                        [joaat("prop_ld_toilet_01")] = "Toilet",
                        [joaat("prop_ld_farm_couch01")] = "Couch",
                    }
                }
                a.attachoption = next(a.attachoptions)
                SussySpt.online_players_a = a

                local function updatePlayerlistElements()
                    for k, v in pairs(SussySpt.players) do
                        v.display = k:contains(a.searchtext:lowercase())
                    end
                end

                local emptystr = ""

                -- ANCHOR Refresh playerlist
                local function refreshPlayerlist()
                    local allStartTime = yu.cputms()

                    SussySpt.players = yu.get_all_players()

                    local selfppid = yu.ppid()
                    local lc = ENTITY.GET_ENTITY_COORDS(selfppid)

                    local hostIndex = NETWORK.NETWORK_GET_HOST_PLAYER_INDEX()
                    local hostName
                    local fmHostIndex = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("freemode", -1, 0)
                    local fmHostName

                    SussySpt.sortedPlayers = {}

                    for k, v in pairs(SussySpt.players) do
                        local startTime = yu.cputms()

                        table.insert(SussySpt.sortedPlayers, k)

                        local isSelf = v.ped == selfppid

                        v.networkHandle = NETWORK.NETWORK_HANDLE_FROM_PLAYER(v.player, nil, 13)

                        v.noped = type(v.ped) ~= "number" or v.ped == 0
                        v.tooltip = emptystr

                        v.info = {}

                        if not isSelf and NETWORK.NETWORK_IS_PLAYER_TALKING(v.player) then
                            v.info.talking = {
                                "T",
                                "The player is currently screaming or talking in the voicechat"
                            }
                        end

                        if not isSelf and network.is_player_friend(v.player) then
                            v.info.friend = {
                                "F",
                                "This player is your friend in socialclub"
                            }
                        end

                        if network.is_player_flagged_as_modder(v.player) then
                            v.info.modder = {
                                "M",
                                "This player was detected as a modder"
                            }
                        end

                        if hostIndex == v.player then
                            v.info.host = {
                                "H",
                                "Session host"
                            }
                            hostName = v.name
                        end

                        if fmHostIndex == v.player then
                            v.info.scripthost = {
                                "S",
                                "Script host"
                            }
                            fmHostName = v.name
                        end

                        if v.noped then
                            v.info.noped = {
                                "P",
                                "No character (ped) was found"
                            }
                        end

                        if not isSelf and NETWORK.IS_PLAYER_IN_CUTSCENE(v.player) then
                            v.info.cutscene = {
                                "Cs",
                                "A cutscene is currently playing"
                            }
                        end

                        if not v.noped then
                            v.c = ENTITY.GET_ENTITY_COORDS(v.ped)

                            v.collisionDisabled = ENTITY.GET_ENTITY_COLLISION_DISABLED(v.ped)

                            v.interior = INTERIOR.GET_INTERIOR_AT_COORDS(v.c.x, v.c.y, v.c.z)

                            v.health = ENTITY.GET_ENTITY_HEALTH(v.ped)
                            v.maxhealth = ENTITY.GET_ENTITY_MAX_HEALTH(v.ped)
                            v.armor = PED.GET_PED_ARMOUR(v.ped)
                            local distance = MISC.GET_DISTANCE_BETWEEN_COORDS(lc.x, lc.y, lc.z, v.c.x, v.c.y, v.c.z, true)
                            local road = HUD.GET_STREET_NAME_FROM_HASH_KEY(PATHFIND.GET_STREET_NAME_AT_COORD(v.c.x, v.c.y, v.c.z))
                            v.speed = ENTITY.GET_ENTITY_SPEED(v.ped) * 3.6
                            v.wantedLevel = PLAYER.GET_PLAYER_WANTED_LEVEL(v.player)
                            v.blip = HUD.GET_BLIP_FROM_ENTITY(v.ped)

                            local vehicle = yu.veh(v.ped)
                            if vehicle ~= nil or PED.IS_PED_IN_ANY_VEHICLE(v.ped, false) then
                                v.info.vehicle = {
                                    "V",
                                    nil
                                }

                                if vehicle ~= nil then
                                    v.info.vehicle[2] = "The player is in a vehicle. Type: "
                                        ..VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(ENTITY.GET_ENTITY_MODEL(vehicle))
                                else
                                    v.info.vehicle[2] = "The player is in a vehicle"
                                end
                            end

                            v.weapon = WEAPON.GET_SELECTED_PED_WEAPON(v.ped)
                            v.weaponModel = WEAPON.GET_WEAPONTYPE_MODEL(v.weapon)

                            if SussySpt.dev and v.interior ~= 0 then
                                v.info.interior = {
                                    "I",
                                    "The player might be in an interior. Interior id: "..v.interior
                                }
                            end

                            if v.collisionDisabled == true and distance < 100 and vehicle == nil then
                                v.info.nocollision = {
                                    "C",
                                    "The player doesn't seem to have collision"
                                }
                            end

                            if not isSelf and v.blip == 0 then
                                v.info.noblip = {
                                    "B",
                                    "The player has no blip. In interior/not spawned yet?"
                                }
                            end

                            if ENTITY.IS_ENTITY_DEAD(v.ped) or PED.IS_PED_DEAD_OR_DYING(v.ped, 1) then
                                v.info.dead = {
                                    "D",
                                    "Player seems to be dead"
                                }
                            end

                            if not isSelf and NETWORK.IS_ENTITY_A_GHOST(v.ped) or NETWORK.IS_ENTITY_IN_GHOST_COLLISION(v.ped) then
                                v.info.ghost = {
                                    "G",
                                    "The player is a ghost. Passive mode?"
                                }
                            end

                            v.tooltip = v.tooltip.."Health: "..v.health.."/"..v.maxhealth.." "..math.floor(yu.calculate_percentage(v.health, v.maxhealth)).."%"

                            if v.armor > 0 then
                                v.tooltip = v.tooltip.."\nArmor: "..string.format("%.0f", v.armor)
                            end

                            if distance > 0 then
                                v.tooltip = v.tooltip.."\nDistance: "..string.format("%.2f", distance).."m"

                                local distanceAboveGround = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(v.ped)
                                if distanceAboveGround > 1.5 then
                                    v.tooltip = v.tooltip..", "..string.format("%.2f", distanceAboveGround).."m above ground"
                                end

                                v.tooltip = v.tooltip.."\nRoad: "..road
                            end

                            if v.speed > 0 then
                                v.tooltip = v.tooltip.."\nSpeed: "..string.format("%.2f", v.speed).."km/h"
                            end

                            if v.wantedLevel > 0 then
                                v.tooltip = v.tooltip.."\nWanted level: "..v.wantedLevel
                            end

                            v.proofs = yu.get_entity_proofs(v.ped)
                            if v.proofs.success and v.proofs.anytrue then
                                v.tooltip = v.tooltip.."\nProofs: "
                                for k1, v1 in pairs(v.proofs.translated) do
                                    if v1 then
                                        v.tooltip = v.tooltip.." "..k1
                                    end
                                end
                            end
                        end

                        do
                            v.tags = emptystr

                            local header = true
                            for k1, v1 in pairs(v.info) do
                                if header then
                                    if not v.noped then
                                        v.tooltip = v.tooltip.."\n\n"
                                    end
                                    v.tooltip = v.tooltip.."Tags:"
                                    header = false
                                end
                                v.tags = v.tags..v1[1]
                                v.tooltip = v.tooltip.."\n  - "..v1[1]..": "..v1[2]
                            end

                            v.displayName = header and v.name or v.name.." ["..v.tags.."]"
                        end

                        v.tooltip = v.tooltip
                            .."\n\nFor nerds:"
                            .."\n  - Player: "..v.player

                        if not v.noped then
                            v.tooltip = v.tooltip.."\n  - Ped: "..v.ped

                            if v.blip ~= 0 then
                                v.tooltip = v.tooltip.."\n  - Blip sprite: "..HUD.GET_BLIP_SPRITE(v.blip)
                            end

                            v.tooltip = v.tooltip.."\n  - Weapon: "..v.weaponModel
                            v.tooltip = v.tooltip.."\n  - NetworkHandle: "..v.networkHandle
                        end

                        do
                            local namecolor
                            if v.info.friend ~= nil then
                                namecolor = a.namecolors.friend
                            elseif v.info.modder ~= nil then
                                namecolor = a.namecolors.modder
                            elseif v.noped then
                                namecolor = a.namecolors.noped
                            elseif v.info.dead ~= nil then
                                namecolor = a.namecolors.dead
                            elseif v.info.noblip ~= nil then
                                namecolor = a.namecolors.noblip
                            elseif v.info.ghost ~= nil then
                                namecolor = a.namecolors.ghost
                            elseif v.info.vehicle ~= nil then
                                namecolor = a.namecolors.vehicle
                            elseif v.info.cutscene ~= nil then
                                namecolor = a.namecolors.cutscene
                            elseif v.info.host ~= nil then
                                namecolor = a.namecolors.host
                            elseif v.info.scripthost ~= nil then
                                namecolor = a.namecolors.scripthost
                            elseif v.c.z == -50 then
                                namecolor = a.namecolors.unknownpos
                            end

                            if namecolor ~= nil then
                                if v.namecolor == nil then
                                    v.namecolor = {}
                                end
                                for i = 1, 3 do
                                    v.namecolor[i] = namecolor[i] / 255
                                end
                            end

                            local nameColorKey = yu.get_key_from_table(a.namecolors, namecolor, nil)
                            if nameColorKey ~= nil then
                                v.tooltip = v.tooltip.."\n  - Name color: "..nameColorKey
                            end
                        end

                        v.tooltip = v.tooltip.."\n  - Calc time: "..(yu.cputms() - startTime).."ms"
                        v.tooltip = v.tooltip:replace("  ", " ")

                        SussySpt.players[k] = v
                    end

                    do
                        local lines = {}
                        local function append(str)
                            lines[#lines + 1] = str
                        end

                        if hostName ~= nil then
                            append("Host: "..hostName)
                        end

                        if fmHostName ~= nil then
                            append("Script host: "..fmHostName)
                        end

                        append("Calc time: "..(yu.cputms() - allStartTime).."ms")

                        a.playersTooltip = table.join(lines, "\n")
                    end

                    table.sort(SussySpt.sortedPlayers)

                    updatePlayerlistElements()

                end

                local function weaponFromInput(s)
                    if type(s) == "string" then
                        return joaat("WEAPON_"..s:uppercase():replace(" ", "_"))
                    end
                    return nil
                end

                local function shootPlayer(rs, ped, weaponHash, damage, speed)
                    if not WEAPON.IS_WEAPON_VALID(weaponHash) then
                        return
                    end

                    WEAPON.REQUEST_WEAPON_ASSET(weaponHash, 31, 0)
                    repeat rs:yield() until WEAPON.HAS_WEAPON_ASSET_LOADED(weaponHash)

                    local c = ENTITY.GET_ENTITY_COORDS(ped)
                    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
                        c.x, c.y, c.z - .5,
                        c.x, c.y, c.z + .5,
                        damage or 1,
                        true,
                        weaponHash,
                        yu.ppid(),
                        true,
                        false,
                        speed or -1
                    )
                end

                yu.rif(function(rs)
                    while true do
                        refreshPlayerlist()

                        local isOpen = a.open > 0
                        rs:sleep(isOpen and 250 or 1500)
                        if isOpen then
                            a.open = a.open - 1
                        end
                    end
                end)

                -- ANCHOR Render
                tab2.render = function()
                    a.open = 2
                    ImGui.BeginGroup()
                    ImGui.Text("Players ("..yu.len(SussySpt.players)..")")
                    if a.playersTooltip ~= nil then
                        yu.rendering.tooltip(a.playersTooltip)
                    end

                    ImGui.PushItemWidth(a.playerlistwidth)
                    local searchtext, _ = ImGui.InputTextWithHint("##search", "Search...", a.searchtext, 32)
                    SussySpt.pushDisableControls(ImGui.IsItemActive())
                    if a.searchtext ~= searchtext then
                        a.searchtext = searchtext
                        yu.rif(updatePlayerlistElements)
                    end
                    ImGui.PopItemWidth()

                    do
                        ImGui.PushItemWidth(a.playerlistwidth)
                        local _, y = ImGui.GetContentRegionAvail()
                        if ImGui.BeginListBox("##playerlist", 0, y) then
                            for _, k in pairs(SussySpt.sortedPlayers) do
                                v = SussySpt.players[k]
                                if v.display then
                                    local hasNameColor = v.namecolor ~= nil

                                    if hasNameColor then
                                        local r, g, b = v.namecolor[1], v.namecolor[2], v.namecolor[3]
                                        ImGui.PushStyleColor(ImGuiCol.Text, r, g, b, 1)
                                    end

                                    -- local isSelected = a.selectedplayer == k
                                    -- if isSelected then
                                    --     local r, g, b = 1, 0, 0--ImGui.GetStyleColorVec4(ImGuiCol.FrameBgActive)
                                    --     ImGui.PushStyleColor(ImGuiCol.FrameBg, r, g, b, 1)
                                    -- end

                                    if ImGui.Selectable(v.displayName, false) then
                                        a.selectedplayer = k
                                    end

                                    -- if isSelected then
                                    --     ImGui.PopStyleColor()
                                    -- end

                                    if hasNameColor then
                                        ImGui.PopStyleColor()
                                    end

                                    if v.tooltip ~= nil then
                                        yu.rendering.tooltip(v.tooltip)
                                    end
                                end
                            end
                            ImGui.EndListBox()
                        end
                        ImGui.PopItemWidth()
                    end

                    ImGui.EndGroup()

                    if a.selectedplayer ~= nil then
                        local key
                        local player
                        for k, v in pairs(SussySpt.players) do
                            if k == a.selectedplayer then
                                key = k
                                player = v
                                break
                            end
                        end

                        if player ~= nil then
                            ImGui.SameLine()

                            ImGui.BeginGroup()

                            local shouldRender
                            do
                                local x, y = ImGui.GetContentRegionAvail()
                                if x > 0 and y > 0 then
                                    ImGui.PushStyleColor(ImGuiCol.FrameBg, 0, 0, 0, .15)
                                    ImGui.BeginListBox("##selectedplayer", x, y)
                                    ImGui.PopStyleColor()
                                    shouldRender = true
                                else
                                    shouldRender = false
                                end
                            end

                            if shouldRender then
                                do
                                    local text = "Selected player: "..player.name
                                    if player.tags ~= emptystr then
                                        text = text.." - "..player.tags
                                    end
                                    ImGui.Text(text)
                                    yu.rendering.tooltip(player.tooltip)
                                end

                                if not player.noped then
                                    if ImGui.TreeNodeEx("General") then
                                        if ImGui.SmallButton("Goto") then
                                            SussySpt.addTask(function()
                                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                PED.SET_PED_COORDS_KEEP_VEHICLE(yu.ppid(), c.x, c.y, c.z - 1)
                                            end)
                                        end
                                        yu.rendering.tooltip("Teleport yourself to the player")

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Bring") then
                                            SussySpt.addTask(function()
                                                local c = ENTITY.GET_ENTITY_COORDS(yu.ppid())
                                                network.set_player_coords(player.player, c.x, c.y, c.z)
                                            end)
                                        end
                                        yu.rendering.tooltip("Bring the player to you")

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Tp into vehicle") then
                                            yu.rif(function(rs)
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil then
                                                    local seatIndex = yu.get_free_vehicle_seat(veh)
                                                    if seatIndex ~= nil then
                                                        local c = ENTITY.GET_ENTITY_COORDS(veh)
                                                        local ped = yu.ppid()
                                                        ENTITY.SET_ENTITY_COORDS(ped, c.x, c.y, c.z, false, false, false, false)
                                                        rs:yield()
                                                        PED.SET_PED_INTO_VEHICLE(ped, veh, seatIndex)
                                                    end
                                                end
                                            end)
                                        end

                                        if ImGui.SmallButton("Set waypoint") then
                                            SussySpt.addTask(function()
                                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                HUD.SET_NEW_WAYPOINT(c.x, c.y)
                                            end)
                                        end
                                        yu.rendering.tooltip("Sets a waypoint to them")

                                        if SussySpt.dev then
                                            ImGui.SameLine()

                                            if ImGui.SmallButton("Waypoint") then
                                                SussySpt.addTask(function()
                                                    local blip = 8 -- radar_waypoint
                                                    if HUD.DOES_BLIP_EXIST(blip) then
                                                        local c = HUD.GET_BLIP_COORDS(blip)
                                                        network.set_player_coords(player.player, c.x, c.y, c.z)
                                                    end
                                                end)
                                            end
                                            yu.rendering.tooltip("Does not work well / teleports them under the map")
                                        end

                                        if ImGui.SmallButton("Mark as modder") then
                                            network.flag_player_as_modder(player.player, infraction.CUSTOM_REASON, "Marked as modder by the user")
                                        end

                                        yu.rendering.renderCheckbox("Spectate", "online_players_spectate", function(state)
                                            SussySpt.addTask(function()
                                                for k, v in pairs(SussySpt.players) do
                                                    if v.ped ~= player.ped then
                                                        if NETWORK.NETWORK_IS_PLAYER_ACTIVE(v.player) then
                                                            NETWORK.NETWORK_SET_IN_SPECTATOR_MODE_EXTENDED(0, player.ped, 1)
                                                            NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, player.ped)
                                                        end
                                                    end
                                                end
                                                if state then
                                                    NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(true, player.ped)
                                                else
                                                    NETWORK.NETWORK_SET_ACTIVITY_SPECTATOR(false)
                                                end
                                            end)
                                        end)

                                        ImGui.TreePop()
                                    end

                                    if ImGui.TreeNodeEx("Trolling") then
                                        if ImGui.SmallButton("Taze") then
                                            yu.rif(function(rs)
                                                shootPlayer(rs, player.ped, joaat("weapon_stungun"), 0)
                                            end)
                                        end

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Spawn cargoplane") then
                                            yu.rif(function(rs)
                                                local hash = joaat("cargoplane")
                                                STREAMING.REQUEST_MODEL(hash)
                                                repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(hash)
                                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                local veh = VEHICLE.CREATE_VEHICLE(hash, c.x, c.y, c.z, ENTITY.GET_ENTITY_HEADING(player.ped), true, true)
                                                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
                                                if networkent(veh) then
                                                    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, 255, 0, 192)
                                                    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, 198, 0, 255)
                                                    ENTITY.SET_ENTITY_COLLISION(veh, false, true)
                                                    ENTITY.SET_VEHICLE_AS_NO_LONGER_NEEDED(veh)
                                                    rs:sleep(2)
                                                    ENTITY.SET_ENTITY_COLLISION(veh, true, true)
                                                end
                                            end)
                                        end

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Launch") then
                                            yu.rif(function(rs)
                                                local hash = joaat("mule5")
                                                STREAMING.REQUEST_MODEL(hash)
                                                repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(hash)

                                                local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.ped, 0, 1, -3)
                                                local veh = VEHICLE.CREATE_VEHICLE(hash, c.x, c.y, c.z, ENTITY.GET_ENTITY_HEADING(player.ped))
                                                networkent(veh)
                                                ENTITY.SET_ENTITY_VISIBLE(veh, true, 0)
                                                ENTITY.SET_ENTITY_ALPHA(veh, 0, true)
                                                rs:sleep(250)
                                                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 0, 1000, 0, 0, 0, 0, true, true, true, false, true)
                                                rs:sleep(2500)
                                                ENTITY.DELETE_ENTITY(veh)
                                            end)
                                        end

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Stumble") then
                                            yu.rif(function(rs)
                                                local hash = joaat("prop_roofvent_06a")
                                                STREAMING.REQUEST_MODEL(hash)
                                                repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(hash)

                                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                c.z = c.z - 2.4

                                                local obj = OBJECT.CREATE_OBJECT(hash, c.x, c.y, c.z, true, true, false)
                                                ENTITY.SET_ENTITY_VISIBLE(obj, true, 0)
                                                ENTITY.SET_ENTITY_ALPHA(obj, 0, true)

                                                local pos = {
                                                    x = 0,
                                                    y = 0,
                                                    z = 0
                                                }
                                                local objects = {}
                                                for i = 1, 4 do
                                                    local angle = (i / 4) * 360
                                                    pos.z = angle
                                                    pos.x = pos.x * 1.25
                                                    pos.y = pos.y * 1.25
                                                    pos.z = pos.z * 1.25
                                                    pos.x = pos.x + c.x
                                                    pos.y = pos.y + c.y
                                                    pos.z = pos.z + c.z
                                                    objects[i] = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y, pos.z, true, true, false)
                                                    ENTITY.SET_ENTITY_VISIBLE(objects[i], true, 0)
                                                    ENTITY.SET_ENTITY_ALPHA(objects[i], 0, true)
                                                    ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(objects[i])
                                                end
                                            end)
                                        end

                                        if ImGui.SmallButton("Spawn animation") then
                                            SussySpt.addTask(function()
                                                local handle = NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(player.player)
                                                network.trigger_script_event(1 << player.player, {-1604421397, yu.pid(), math.random(0, 114), 4, handle, handle, handle, handle, 1, 1})
                                            end)
                                        end
                                        yu.rendering.tooltip("Gives the player a blackscreen,\nthen after some time, it spawns them at a random location.\nSimilar to when you join a session.")

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Squish") then
                                            yu.rif(function(rs)
                                                local hash = joaat("khanjali")
                                                STREAMING.REQUEST_MODEL(hash)
                                                repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(hash)

                                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                local distance = TASK.IS_PED_STILL(player.ped) and 0 or 2.5

                                                local vehicles = {}

                                                for i = 1, 1 do
                                                    local pos = (i == 1) and ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.ped, 0, distance, 2.8) or c
                                                    local heading = (i == 1) and ENTITY.GET_ENTITY_HEADING(player.ped) or 0
                                                    vehicles[i] = networkent(VEHICLE.CREATE_VEHICLE(hash, pos.x, pos.y, pos.z, heading))
                                                end

                                                for k, v in pairs(vehicles) do
                                                    if k ~= 1 and v ~= nil then
                                                        ENTITY.ATTACH_ENTITY_TO_ENTITY(v, vehicles[1], 0, k == 4 and 0 or 3, k >= 3 and 0, 0, 0, 0, k == 2 and -180 or 0, 0, false, true, false, 0, true)
                                                    end
                                                    ENTITY.SET_ENTITY_VISIBLE(v, false)
                                                    ENTITY.SET_ENTITY_ALPHA(v, 0, true)
                                                end
                                                ENTITY.APPLY_FORCE_TO_ENTITY(vehicles[1], 1, 0, 0, -10, 0, 0, 0, 0, true, true, true, false, true)

                                                rs:sleep(5000)

                                                for k, v in pairs(vehicles) do
                                                    if v ~= nil then
                                                        ENTITY.DELETE_ENTITY(v)
                                                    end
                                                end
                                            end)
                                        end
                                        yu.rendering.tooltip("This even kills godmode players but it requires them\nto have no ragdoll turned off.")

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Disable Passive mode") then
                                            SussySpt.addTask(function()
                                                network.trigger_script_event(1 << player.player, { -13748324, yu.pid(), 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                                            end)
                                        end

                                        ImGui.Text("Explode:")
                                        do
                                            ImGui.SameLine()
                                            if ImGui.SmallButton("Invisible") then
                                                SussySpt.addTask(function()
                                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                    FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 72, 80, false, true, 0)
                                                end)
                                            end
                                            yu.rendering.tooltip("\"Random\" death")
                                            ImGui.SameLine()
                                            if ImGui.SmallButton("Normal") then
                                                SussySpt.addTask(function()
                                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                    FIRE.ADD_EXPLOSION(c.x + 1, c.y + 1, c.z + 1, 4, 100, true, false, 0)
                                                end)
                                            end
                                            ImGui.SameLine()
                                            if ImGui.SmallButton("Huge") then
                                                SussySpt.addTask(function()
                                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                    FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 82, 20, true, false, 1)
                                                end)
                                            end
                                            ImGui.SameLine()
                                            if ImGui.SmallButton("Car") then
                                                SussySpt.addTask(function()
                                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                    FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 7, 1, true, false, 0)
                                                end)
                                            end
                                        end

                                        if ImGui.TreeNodeEx("Trap") then
                                            if ImGui.SmallButton("Normal") then
                                                SussySpt.addTask(function()
                                                    local modelHash = joaat("prop_gold_cont_01b")
                                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                    for i = 0, 1 do
                                                        local obj = OBJECT.CREATE_OBJECT(modelHash, c.x, c.y, c.z - .7, true, false, false)
                                                        networkobj(obj)
                                                        ENTITY.SET_ENTITY_ROTATION(obj, 0, yu.shc(i == 0, 90, -90), 0, 2, true)
                                                        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                                    end
                                                end)
                                            end
                                            ImGui.SameLine()
                                            if ImGui.SmallButton("Cage") then
                                                yu.rif(function(runscript)
                                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                    local x = tonumber(string.format('%.2f', c.x))
                                                    local y = tonumber(string.format('%.2f', c.y))
                                                    local z = tonumber(string.format('%.2f', c.z))

                                                    local modelHash = joaat("prop_fnclink_05crnr1")
                                                    STREAMING.REQUEST_MODEL(modelHash)
                                                    repeat runscript:yield() until STREAMING.HAS_MODEL_LOADED(modelHash)

                                                    local createObject = function(offsetX, offsetY, heading)
                                                        local obj = OBJECT.CREATE_OBJECT(modelHash, x + offsetX, y + offsetY, z - 1, true, true, true)
                                                        networkobj(obj)
                                                        ENTITY.SET_ENTITY_HEADING(obj, heading)
                                                        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                                        ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(obj)
                                                    end

                                                    createObject(-1.70, -1.70, -90.0)
                                                    createObject(1.70, 1.70, 90.0)
                                                end)
                                            end

                                            ImGui.SameLine()

                                            if ImGui.SmallButton("Rub Cage") then
                                                SussySpt.addTask(function()
                                                    local hash = joaat("prop_rub_cage01a")
                                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                    for i = 0, 1 do
                                                        local obj = OBJECT.CREATE_OBJECT(hash, c.x, c.y, c.z - 1, true, true, false)
                                                        networkobj(obj)
                                                        ENTITY.SET_ENTITY_ROTATION(obj, 0, 0, yu.shc(i == 0, 0, 90), 2, true)
                                                        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                                        ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(obj)
                                                    end
                                                end)
                                            end

                                            if ImGui.SmallButton("Race tube") then
                                                SussySpt.addTask(function()
                                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                    local obj = OBJECT.CREATE_OBJECT(joaat("stt_prop_stunt_tube_crn_5d"), c.x, c.y, c.z, true, true, false)
                                                    networkobj(obj)
                                                    ENTITY.SET_ENTITY_ROTATION(obj, 0, 90, 0, 2, true)
                                                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                                    ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(obj)
                                                end)
                                            end
                                            ImGui.SameLine()
                                            if ImGui.SmallButton("Invisible race tube") then
                                                SussySpt.addTask(function()
                                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                    local obj = OBJECT.CREATE_OBJECT(joaat("stt_prop_stunt_tube_crn_5d"), c.x, c.y, c.z, true, true, false)
                                                    networkobj(obj)
                                                    ENTITY.SET_ENTITY_ROTATION(obj, 0, 90, 0, 2, true)
                                                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                                    ENTITY.SET_ENTITY_VISIBLE(obj, false)
                                                    ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(obj)
                                                end)
                                            end

                                            ImGui.TreePop()
                                        end

                                        do -- Ram
                                            ImGui.PushItemWidth(237)
                                            local ror = yu.rendering.renderList(a.ramoptions, a.ramoption, "online_player_ram", "")
                                            if ror.changed then
                                                a.ramoption = ror.key
                                            end
                                            ImGui.PopItemWidth()
                                            ImGui.SameLine()
                                            if ImGui.Button("Ram") then
                                                yu.rif(function(runscript)
                                                    local hash = joaat(a.ramoption)
                                                    if STREAMING.IS_MODEL_VALID(hash) then
                                                        STREAMING.REQUEST_MODEL(hash)
                                                        repeat runscript:yield() until STREAMING.HAS_MODEL_LOADED(hash)
                                                        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.ped, 0, -15.0, 0)
                                                        local veh = VEHICLE.CREATE_VEHICLE(hash, c.x, c.y, c.z - 1, ENTITY.GET_ENTITY_HEADING(player.ped), true, true)
                                                        networkent(veh)
                                                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 1)
                                                        runscript:sleep(100)
                                                        for i = 0, 10 do
                                                            VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 50.0)
                                                            runscript:sleep(100)
                                                        end
                                                        VEHICLE.DELETE_VEHICLE(veh)
                                                    end
                                                end)
                                            end
                                        end

                                        do -- Attach
                                            ImGui.PushItemWidth(237)
                                            local resp = yu.rendering.renderList(a.attachoptions, a.attachoption, "online_player_attach", "")
                                            if resp.changed then
                                                a.attachoption = resp.key
                                            end
                                            ImGui.PopItemWidth()

                                            ImGui.SameLine()

                                            if ImGui.Button("Attach") then
                                                yu.rif(function(rs)
                                                    local hash = a.attachoption

                                                    if STREAMING.IS_MODEL_VALID(hash) then
                                                        STREAMING.REQUEST_MODEL(hash)
                                                        repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(hash)

                                                        local obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, 0, 0, 0, true, true, false)
                                                        if networkobj(obj) ~= nil then
                                                            ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, player.ped, 57597, 0, 0, 0, 0, 0, 0, false, false, false, false, 2, true)
                                                            if yu.rendering.isCheckboxChecked("online_players_attach_invis") then
                                                                ENTITY.SET_ENTITY_VISIBLE(obj, false)
                                                                ENTITY.SET_ENTITY_ALPHA(obj, 0, true)
                                                            end
                                                            ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(obj)
                                                        end

                                                        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
                                                    end
                                                end)
                                            end

                                            ImGui.SameLine()

                                            yu.rendering.renderCheckbox("Invisible##attach_invis", "online_players_attach_invis")
                                        end

                                        ImGui.TreePop()
                                    end

                                    if ImGui.TreeNodeEx("Weapons") then
                                        if ImGui.SmallButton("Remove all weapons") then
                                            SussySpt.addTask(function()
                                                WEAPON.REMOVE_ALL_PED_WEAPONS(player.ped, true)
                                                for k, v in pairs(yu.get_all_weapons()) do
                                                    WEAPON.REMOVE_WEAPON_FROM_PED(player.ped, v)
                                                end
                                            end)
                                        end
                                        yu.rendering.tooltip("Most of them.\nThis will be fixed when yimmenu finally allows access to the cache...")

                                        ImGui.Text("Parachute:")
                                        ImGui.SameLine()
                                        if ImGui.SmallButton("Give##give_parachute") then
                                            SussySpt.addTask(function()
                                                WEAPON.GIVE_WEAPON_TO_PED(player.ped, joaat("GADGET_PARACHUTE"), 1, false, false)
                                            end)
                                        end
                                        ImGui.SameLine()
                                        if ImGui.SmallButton("Remove##remove_parachute") then
                                            SussySpt.addTask(function()
                                                WEAPON.REMOVE_WEAPON_FROM_PED(player.ped, joaat("GADGET_PARACHUTE"))
                                            end)
                                        end

                                        ImGui.Spacing()

                                        ImGui.PushItemWidth(120)
                                        local gcwr = yu.rendering.input("text", {
                                            label = "##gcw",
                                            text = a.givecustomweapontext,
                                            hint = "ex. pistol"
                                        })
                                        SussySpt.pushDisableControls(ImGui.IsItemActive())
                                        ImGui.PopItemWidth()
                                        if gcwr ~= nil and gcwr.changed then
                                            a.givecustomweapontext = gcwr.text
                                            a.weaponinfo = nil
                                        end

                                        ImGui.SameLine()

                                        ImGui.PushItemWidth(79)
                                        local gcwar = yu.rendering.input("int", {
                                            label = "##gcwa",
                                            value = a.givecustomweaponammo,
                                            min = 0,
                                            max = 99999
                                        })
                                        SussySpt.pushDisableControls(ImGui.IsItemActive())
                                        ImGui.PopItemWidth()
                                        if gcwar ~= nil and gcwar.changed then
                                            a.givecustomweaponammo = gcwar.value
                                        end

                                        ImGui.SameLine()
                                        if ImGui.Button("Give") then
                                            SussySpt.addTask(function()
                                                if type(a.givecustomweapontext) ~= "string" or a.givecustomweapontext:len() == 0 then
                                                    a.weaponinfo = 1
                                                else
                                                    local hash = weaponFromInput(a.givecustomweapontext)
                                                    if WEAPON.GET_WEAPONTYPE_MODEL(hash) == 0 then
                                                        a.weaponinfo = 2
                                                    else
                                                        WEAPON.GIVE_WEAPON_TO_PED(player.ped, hash, a.givecustomweaponammo, false, false)
                                                        a.weaponinfo = 3
                                                    end
                                                end
                                            end)
                                        end
                                        ImGui.SameLine()
                                        if ImGui.Button("Remove") then
                                            SussySpt.addTask(function()
                                                if type(a.givecustomweapontext) ~= "string" or a.givecustomweapontext:len() == 0 then
                                                    a.weaponinfo = 1
                                                else
                                                    local hash = weaponFromInput(a.givecustomweapontext)
                                                    if WEAPON.GET_WEAPONTYPE_MODEL(hash) == 0 then
                                                        a.weaponinfo = 2
                                                    else
                                                        WEAPON.REMOVE_WEAPON_FROM_PED(player.ped, hash)
                                                        a.weaponinfo = 4
                                                    end
                                                end
                                            end)
                                        end

                                        if a.weaponinfo ~= nil then
                                            if a.weaponinfo == 1 then
                                                yu.rendering.coloredtext("A weapon id is required", 255, 25, 25)
                                            elseif a.weaponinfo == 2 then
                                                yu.rendering.coloredtext("Invalid weapon id", 255, 25, 25)
                                            elseif a.weaponinfo == 3 then
                                                yu.rendering.coloredtext("Weapon given successfully", 41, 250, 41)
                                            elseif a.weaponinfo == 4 then
                                                yu.rendering.coloredtext("Weapon removed successfully", 41, 250, 41)
                                            end
                                        end

                                        ImGui.TreePop()
                                    end

                                    if ImGui.TreeNodeEx("Vehicle") then
                                        yu.rendering.renderCheckbox("Godmode", "online_player_vehiclegod", function(state)
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh)  then
                                                    ENTITY.SET_ENTITY_INVINCIBLE(veh, state)
                                                end
                                            end)
                                        end)
                                        yu.rendering.tooltip("Sets the vehicle in godmode")

                                        ImGui.SameLine()

                                        yu.rendering.renderCheckbox("Invsisibility", "online_player_vehicleinvis", function(state)
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh)  then
                                                    ENTITY.SET_ENTITY_VISIBLE(veh, not state)
                                                end
                                            end)
                                        end)
                                        yu.rendering.tooltip("Sets the vehicle in godmode")

                                        if ImGui.SmallButton("Repair") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh)  then
                                                    local veh = PED.GET_VEHICLE_PED_IS_IN(player.ped, false)
                                                    VEHICLE.SET_VEHICLE_FIXED(veh)
                                                    VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, .0)
                                                end
                                            end)
                                        end

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Delete") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, false)
                                                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, false)
                                                    VEHICLE.DELETE_VEHICLE(veh)
                                                    if yu.does_entity_exist(veh) then
                                                        ENTITY.DELETE_ENTITY(veh)
                                                    end
                                                end
                                            end)
                                        end

                                        if ImGui.SmallButton("Halt") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    VEHICLE.SET_VEHICLE_MAX_SPEED(veh, .1)
                                                end
                                            end)
                                        end

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Engine off") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    yu.request_entity_control_once(veh)
                                                    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, false, true, false)
                                                end
                                            end)
                                        end

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Kill engine") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, -4000)
                                                end
                                            end)
                                        end

                                        if ImGui.SmallButton("Launch") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 0, 50000, 0, 0, 0, 0, 0, 1, 1, 0, 1)
                                                end
                                            end)
                                        end

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Boost") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(veh))
                                                end
                                            end)
                                        end

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Halt") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    VEHICLE.SET_VEHICLE_MAX_SPEED(veh, .1)
                                                end
                                            end)
                                        end

                                        if ImGui.SmallButton("Burst tires") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, true)
                                                    yu.loop(8, function(i)
                                                        VEHICLE.SET_VEHICLE_TYRE_BURST(veh, i, true, 1000);
                                                    end)
                                                end
                                            end)
                                        end

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Smash windows") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    yu.loop(8, function(i)
                                                        VEHICLE.SMASH_VEHICLE_WINDOW(veh, i)
                                                    end)
                                                end
                                            end)
                                        end

                                        if ImGui.SmallButton("Kick from vehicle") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    TASK.TASK_LEAVE_VEHICLE(player.ped, veh, 0)
                                                end
                                            end)
                                        end
                                        yu.rendering.tooltip("Doesn't work well")

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Flip") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    local rot = ENTITY.GET_ENTITY_ROTATION(veh, 2)
                                                    rot.y = rot.y + 180
                                                    ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z, 2, false)
                                                end
                                            end)
                                        end

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Rotate") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    local rot = ENTITY.GET_ENTITY_ROTATION(veh, 2)
                                                    rot.z = rot.z + 180
                                                    ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z, 2, false)
                                                end
                                            end)
                                        end

                                        if ImGui.SmallButton("Lock them inside") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh) then
                                                    VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 4)
                                                end
                                            end)
                                        end

                                        ImGui.TreePop()
                                    end

                                    if ImGui.TreeNodeEx("Online") then
                                        ImGui.PushItemWidth(243)
                                        if ImGui.BeginCombo("##online_player_pickups", a.pickupoption) then
                                            for k, v in pairs(a.pickupoptions) do
                                                if ImGui.Selectable(k, false) then
                                                    a.pickupoption = k
                                                end
                                                yu.rendering.tooltip(v)
                                            end
                                            ImGui.EndCombo()
                                        end
                                        ImGui.PopItemWidth()

                                        ImGui.SameLine()

                                        ImGui.PushItemWidth(35)
                                        local par = yu.rendering.input("int", {
                                            label = "##pa",
                                            value = a.pickupamount
                                        })
                                        yu.rendering.tooltip("How many times the pickup should get spawned")
                                        SussySpt.pushDisableControls(ImGui.IsItemActive())
                                        ImGui.PopItemWidth()
                                        if par ~= nil and par.changed then
                                            a.pickupamount = par.value
                                        end

                                        if not a.givepickupblocked then
                                            ImGui.SameLine()
                                            if ImGui.Button("Give pickup") then
                                                a.givepickupblocked = true
                                                yu.rif(function(rs)
                                                    local value = a.pickupoptions[a.pickupoption]
                                                    if yu.is_num_between(a.pickupamount, 0, 20) and type(value) == "string" then
                                                        local hash = joaat(value)
                                                        if STREAMING.IS_MODEL_VALID(hash) then
                                                            STREAMING.REQUEST_MODEL(hash)
                                                            repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(hash)
                                                            yu.loop(a.pickupamount, function()
                                                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                                OBJECT.CREATE_AMBIENT_PICKUP(joaat("PICKUP_CUSTOM_SCRIPT"), c.x, c.y, c.z + 1.5, 0, 0, hash, true, false)
                                                                rs:sleep(4)
                                                            end)
                                                        end
                                                    end
                                                    a.givepickupblocked = nil
                                                end)
                                            end
                                        end

                                        ImGui.PushItemWidth(78)

                                        local car = yu.rendering.input("int", {
                                            label = "##ca",
                                            value = a.cashamount
                                        })
                                        yu.rendering.tooltip("How much cash to spawn")
                                        SussySpt.pushDisableControls(ImGui.IsItemActive())
                                        if car ~= nil and car.changed then
                                            a.cashamount = car.value
                                        end

                                        ImGui.SameLine()

                                        local cvr = yu.rendering.input("int", {
                                            label = "##cv",
                                            value = a.cashvalue
                                        })
                                        yu.rendering.tooltip("How much money per cash")
                                        SussySpt.pushDisableControls(ImGui.IsItemActive())
                                        if cvr ~= nil and cvr.changed then
                                            a.cashvalue = cvr.value
                                        end

                                        ImGui.PopItemWidth()

                                        ImGui.SameLine()

                                        if ImGui.Button("Spawn cash") then
                                            SussySpt.addTask(function()
                                                if yu.is_num_between(a.cashamount, 0, 10000) then
                                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                    OBJECT.CREATE_MONEY_PICKUPS(c.x, c.y, c.z, a.cashvalue, a.cashamount, 2628187989)
                                                end
                                            end)
                                        end

                                        ImGui.TreePop()
                                    end

                                    if SussySpt.dev and ImGui.TreeNodeEx("Test") then
                                        if ImGui.SmallButton("Set killer") then
                                            a.killer = key
                                        end

                                        if ImGui.SmallButton("Owned explosion") then
                                            SussySpt.addTask(function()
                                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                                local killer = SussySpt.players[a.killer]
                                                if killer ~= nil then
                                                    FIRE.ADD_OWNED_EXPLOSION(killer.ped, c.x, c.y, c.z, 6, 1, true, false, 0)
                                                end
                                            end)
                                        end

                                        if ImGui.SmallButton("Explode veh") then
                                            yu.rif(function(rs)
                                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)

                                                local hash = joaat("adder")
                                                STREAMING.REQUEST_MODEL(hash)
                                                repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(hash)

                                                local veh = VEHICLE.CREATE_VEHICLE(hash, c.x, c.y, c.z + 1.5, 0, true, true)
                                                ENTITY.FREEZE_ENTITY_POSITION(veh, true)
                                                ENTITY.SET_ENTITY_COLLISION(veh, false, false)
                                                ENTITY.SET_ENTITY_ALPHA(veh, 0, true)
                                                ENTITY.SET_ENTITY_VISIBLE(veh, false)

                                                rs:sleep(5)

                                                local killer = SussySpt.players[a.killer]
                                                if killer ~= nil then
                                                    NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, killer.player)
                                                end

                                                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
                                            end)
                                        end
                                    end
                                end

                                ImGui.EndListBox()
                            end

                            ImGui.EndGroup()
                        end
                    end
                end

                tab.sub[1] = tab2
            end -- !SECTION

            do -- SECTION Stats
                local tab2 = SussySpt.rendering.newTab("Stats")

                do -- ANCHOR Other
                    local tab3 = SussySpt.rendering.newTab("Other")

                    local a = {
                        stats = {
                            {"MPPLY_IS_CHEATER", 1, "Cheater"},
                            {"MPPLY_WAS_I_BAD_SPORT", 1, "Was i badsport"},
                            {"MPPLY_IS_HIGH_EARNER", 1, "High earner"},
                            {"MPPLY_GRIEFING", 2, "Reports -> Griefing"},
                            {"MPPLY_EXPLOITS", 2, "Reports -> Exploits"},
                            {"MPPLY_GAME_EXPLOITS", 2, "Reports -> Game exploits"},
                            {"MPPLY_TC_ANNOYINGME", 2, "Reports -> Text chat -> Annoying me"},
                            {"MPPLY_TC_HATE", 2, "Reports -> Text chat -> Hate Speech"},
                            {"MPPLY_VC_ANNOYINGME", 2, "Reports -> Voice chat > Annoying me"},
                            {"MPPLY_VC_HATE", 2, "Reports -> Voice chat > Hate Speech"},
                            {"MPPLY_OFFENSIVE_LANGUAGE", 2, "Reports -> Offensive language"},
                            {"MPPLY_OFFENSIVE_TAGPLATE", 2, "Reports -> Offensive tagplate"},
                            {"MPPLY_OFFENSIVE_UGC", 2, "Reports -> Offensive content"},
                            {"MPPLY_BAD_CREW_NAME", 2, "Reports -> Bad crew name"},
                            {"MPPLY_BAD_CREW_MOTTO", 2, "Reports -> Bad crew motto"},
                            {"MPPLY_BAD_CREW_STATUS", 2, "Reports -> Bad crew status"},
                            {"MPPLY_BAD_CREW_EMBLEM", 2, "Reports -> Bad crew emblem"},
                            {"MPPLY_FRIENDLY", 2, "Commend -> Friendly"},
                            {"MPPLY_HELPFUL", 2, "Commend -> Helpful"},
                        },
                        abilities = {
                            "Stamina", "Strength", "Shooting",
                            "Stealth", "Flying", "Driving",
                            "Diving", "Mental State"
                        },
                        abilitystats = {
                            {"STAMINA", "SCRIPT_INCREASE_STAM"},
                            {"STRENGTH", "SCRIPT_INCREASE_STRN"},
                            {"SHOOTING_ABILITY", "SCRIPT_INCREASE_SHO"},
                            {"STEALTH_ABILITY", "SCRIPT_INCREASE_STL"},
                            {"FLYING_ABILITY", "SCRIPT_INCREASE_FLY"},
                            {"WHEELIE_ABILITY", "SCRIPT_INCREASE_DRIV"},
                            {"LUNG_CAPACITY", "SCRIPT_INCREASE_LUNG"},
                            {"PLAYER_MENTAL_STATE"}
                        }
                    }

                    local function refreshStats()
                        for k, v in pairs(a.stats) do
                            if v[2] == 1 then
                                v[4] = tostring(stats.get_bool(v[1]))
                            elseif v[2] == 2 then
                                local value = stats.get_int(v[1])
                                if value ~= 0 then
                                    v[4] = yu.format_num(value)
                                end
                            end
                        end
                    end

                    local function refreshAbilityValues()
                        local mpx = yu.mpx()
                        a.abilityvalues = {}
                        a.abilitynewvalues = {}
                        for k, v in pairs(a.abilitystats) do
                            local stat = mpx..v[1]
                            if k == 8 then
                                a.abilityvalues[k] = stats.get_float(stat)
                            else
                                a.abilityvalues[k] = stats.get_int(stat)
                            end
                        end
                    end

                    local function refresh()
                        refreshStats()
                        refreshAbilityValues()
                    end
                    yu.rif(refresh)

                    tab3.render = function()
                        if ImGui.SmallButton("Refresh") then
                            yu.rif(refresh)
                        end

                        if ImGui.TreeNodeEx("Stats") then
                            if ImGui.SmallButton("Refresh##stats") then
                                yu.rif(refreshStats)
                            end

                            for k, v in pairs(a.stats) do
                                if v[4] ~= nil then
                                    ImGui.Text(v[3]..": "..v[4])
                                end
                            end

                            ImGui.TreePop()
                        end

                        if ImGui.TreeNodeEx("Abilities") then
                            if ImGui.SmallButton("Refresh##abilities") then
                                yu.rif(refreshAbilityValues)
                            end

                            ImGui.Spacing()

                            ImGui.PushItemWidth(331)
                            for k, v in pairs(a.abilities) do
                                do
                                    local value, changed = ImGui.DragInt(v, a.abilitynewvalues[k] or a.abilityvalues[k], .2, 0, 100, "%d", 5)
                                    if changed then
                                        a.abilitynewvalues[k] = value
                                    end
                                end

                                local value = a.abilitynewvalues[k]
                                if value ~= nil then
                                    ImGui.SameLine()

                                    if ImGui.SmallButton("Apply##abilities_"..k) then
                                        SussySpt.addTask(function()
                                            if yu.is_num_between(value, 0, 100) then
                                                for k1, v2 in pairs(a.abilitystats[k]) do
                                                    local stat = yu.mpx(v2)
                                                    if k == 8 then
                                                        stats.set_float(stat, value)
                                                    else
                                                        stats.set_int(stat, value)
                                                    end
                                                    refreshAbilityValues()
                                                end
                                            end
                                        end)
                                    end
                                end
                            end
                            ImGui.PopItemWidth()

                            ImGui.TreePop()
                        end

                        if ImGui.TreeNodeEx("Badsport") then
                            if ImGui.SmallButton("Add##badsport") then
                                SussySpt.addTask(function()
                                    stats.set_int("MPPLY_BADSPORT_MESSAGE", -1)
                                    stats.set_int("MPPLY_BECAME_BADSPORT_NUM", -1)
                                    stats.set_float("MPPLY_OVERALL_BADSPORT", 60000)
                                    stats.set_bool("MPPLY_CHAR_IS_BADSPORT", true)
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.SmallButton("Remove##badsport") then
                                SussySpt.addTask(function()
                                    stats.set_int("MPPLY_BADSPORT_MESSAGE", 0)
                                    stats.set_int("MPPLY_BECAME_BADSPORT_NUM", 0)
                                    stats.set_float("MPPLY_OVERALL_BADSPORT", 0)
                                    stats.set_bool("MPPLY_CHAR_IS_BADSPORT", false)
                                end)
                            end

                            ImGui.TreePop()
                        end

                        if ImGui.TreeNodeEx("Bounty") then
                            if ImGui.SmallButton("Remove bounty") then
                                SussySpt.addTask(function()
                                    globals.set_int(SussySpt.pointers.bounty_self_time, 2880000)
                                end)
                            end

                            ImGui.TreePop()
                        end

                        if ImGui.TreeNodeEx("Jack O' Lantern") then
                            if ImGui.SmallButton("Unlock Mask") then
                                SussySpt.addTask(function()
                                    globals.set_int(SussySpt.pointers.halloween_unlock, 9)
                                end)
                            end

                            if ImGui.SmallButton("Unlock T-Shirt") then
                                SussySpt.addTask(function()
                                    globals.set_int(SussySpt.pointers.halloween_unlock, 199)
                                end)
                            end

                            ImGui.Spacing()

                            do
                                ImGui.PushItemWidth(150)
                                local resp = yu.rendering.input("int", {
                                    label = "##pumpkin",
                                    value = a.pumpkinspickedup or 1
                                })
                                ImGui.PopItemWidth()
                                if resp ~= nil and resp.changed then
                                    a.pumpkinspickedup = resp.value
                                end

                                ImGui.SameLine()

                                if ImGui.Button("Set") then
                                    SussySpt.addTask(function()
                                        if yu.is_num_between(a.pumpkinspickedup, 0, 199) then
                                            globals.set_int(SussySpt.pointers.halloween_pumpkin_picked_up, a.pumpkinspickedup)
                                        else
                                            yu.notify(3, "Invalid number! Number must be between 0 and 199", "Online->Stats")
                                        end
                                    end)
                                end
                            end

                            ImGui.TreePop()
                        end
                    end

                    tab2.sub[1] = tab3
                end

                do -- ANCHOR Loader
                    local tab3 = SussySpt.rendering.newTab("Loader")

                    local a = {
                        input = "# This is a comment\nbool SOME_STAT 0\nbool MPX_SOME_STAT 1\nbool SOME_STAT true\nbool MPX_SOME_STAT false\nint SOME_STAT 1\nfloat MPX_SOME_STAT 1.23",
                        types = {
                            "bool",
                            "int",
                            "float"
                        }
                    }

                    -- TODO Support for masked, globals?

                    local function load()
                        if type(a.input) ~= "string" then
                            return
                        end

                        local tokens = {}
                        local mpx = yu.mpx()

                        local lines = string.split(a.input, "\n")
                        for k, v in pairs(lines) do
                            local text = v:strip()
                            if text:len() ~= 0 and not text:startswith("#") then
                                text = text:split("#")[1]
                                local parts = text:split(" ")

                                local type = parts[1]
                                local stat = parts[2]
                                local value = parts[3]

                                if type == nil then
                                    lines[k] = "#"..v.." # Could not read type"
                                elseif stat == nil then
                                    lines[k] = "#"..v.." # Could not read stat"
                                elseif value == nil then
                                    lines[k] = "#"..v.." # Could not read value"
                                else
                                    type = yu.get_key_from_table(a.types, type, nil)
                                    if type == nil then
                                        lines[k] = "#"..v.." # Invalid type"
                                        goto continue
                                    end

                                    if stat:startswith("MPX_") then
                                        stat = mpx..stat:sub(5)
                                    end

                                    if type == 1 then
                                        if value == "false" or value == "0" then
                                            value = false
                                        elseif value == "true" or value == "1" then
                                            value = true
                                        else
                                            lines[k] = "#"..v.." # Invalid value for bool type"
                                            goto continue
                                        end
                                    elseif type == 2 then
                                        if string.contains(value, ".") then
                                            lines[k] = "#"..v.." # An integer as value is required"
                                            goto continue
                                        end
                                        value = tonumber(value)
                                        if value == nil then
                                            lines[k] = "#"..v.." # Invalid value for int type"
                                            goto continue
                                        end
                                    elseif type == 3 then
                                        value = tonumber(value)
                                        if value == nil then
                                            lines[k] = "#"..v.." # Invalid value for float type"
                                            goto continue
                                        end
                                    end

                                    table.insert(tokens, {type, stat, value})
                                end
                            end
                            ::continue::
                        end
                        a.input = table.join(lines, "\n")
                        a.tokens = tokens
                        a.tokenlength = yu.len(tokens).." stat/s loaded"
                    end

                    local function apply()
                        local applied = 0

                        for k, v in pairs(a.tokens) do
                            local type = v[1]
                            local stat = v[2]
                            local value = v[3]

                            if type == 1 then
                                stats.set_bool(stat, value)
                                applied = applied + 1
                            elseif type == 2 then
                                stats.set_int(stat, value)
                                applied = applied + 1
                            elseif type == 3 then
                                stats.set_float(stat, value)
                                applied = applied + 1
                            end
                        end

                        yu.notify(1, applied.." stat/s where applied", "Online->Stats->Loader")
                    end

                    tab3.render = function()
                        if ImGui.Button("Load") then
                            yu.rif(load)
                        end

                        if a.tokens ~= nil then
                            ImGui.SameLine()

                            if ImGui.Button("Apply") then
                                yu.rif(apply)
                            end

                            if SussySpt.dev then
                                ImGui.SameLine()

                                if ImGui.Button("Dump tokens") then
                                    SussySpt.addTask(function()
                                        log.info("===[ TOKEN DUMP ]===")

                                        for k, v in pairs(a.tokens) do
                                            local type = v[1]
                                            local stat = v[2]
                                            local value = tostring(v[3])
                                            log.info(k..": {type="..a.types[type].."["..type.."],stat="..stat..",value="..value.."}")
                                        end

                                        log.info("====================")
                                    end)
                                end
                            end
                        end

                        if a.tokenlength ~= nil then
                            ImGui.Text(a.tokenlength)
                        end

                        do
                            local x, y = ImGui.GetContentRegionAvail()
                            local text, _ = ImGui.InputTextMultiline("##input", a.input, 2500000, x, y)
                            if a.input ~= text then
                                a.input = text
                                a.tokens = nil
                                a.tokenlength = nil
                            end
                        end
                        SussySpt.pushDisableControls(ImGui.IsItemActive())
                    end

                    tab2.sub[2] = tab3
                end

                tab.sub[2] = tab2
            end -- !SECTION

            do -- ANCHOR Chatlog
                local tab2 = SussySpt.rendering.newTab("Chatlog")

                yu.rendering.setCheckboxChecked("online_chatlog_enabled")
                yu.rendering.setCheckboxChecked("online_chatlog_console")
                yu.rendering.setCheckboxChecked("online_chatlog_log_timestamp")

                tab2.render = function()
                    if yu.rendering.renderCheckbox("Enabled", "online_chatlog_enabled") then
                        ImGui.Spacing()
                        yu.rendering.renderCheckbox("Log to console", "online_chatlog_console")
                    end

                    if SussySpt.chatlog.text ~= nil then
                        if ImGui.TreeNodeEx("Logs") then
                            yu.rendering.renderCheckbox("Timestamp", "online_chatlog_log_timestamp", SussySpt.chatlog.rebuildLog)

                            do
                                local x, y = ImGui.GetContentRegionAvail()
                                ImGui.InputTextMultiline("##chat_log", SussySpt.chatlog.text, SussySpt.chatlog.text:length(), x, math.min(140, y), ImGuiInputTextFlags.ReadOnly)
                            end
                            SussySpt.pushDisableControls(ImGui.IsItemActive())

                            ImGui.TreePop()
                        end
                    else
                        ImGui.Spacing()
                        ImGui.Text("Nothing to show yet")
                    end
                end

                tab.sub[3] = tab2
            end

            do -- ANCHOR CMM
                local tab2 = SussySpt.rendering.newTab("CMM")

                local a = {
                    apps = {
                        ["appsecuroserv"] = "SecuroServ (Office)",
                        ["appbusinesshub"] = "Nightclub",
                        ["appAvengerOperations"] = "Avenger Operations",
                        ["appfixersecurity"] = "Agency",
                        ["appinternet"] = "Internet (Phone)",
                        ["apparcadebusinesshub"] = "Mastercontrol (Arcade)",
                        ["appbunkerbusiness"] = "Bunker Business",
                        ["apphackertruck"] = "Terrorbyte",
                        ["appbikerbusiness"] = "The Open Road (MC)",
                        ["appsmuggler"] = "Free Trade Shipping Co. (Hangar)",
                    }
                }

                local function runScript(name)
                    yu.rif(function(rs)
                        SCRIPT.REQUEST_SCRIPT(name)
                        repeat rs:yield() until SCRIPT.HAS_SCRIPT_LOADED(name)
                        SYSTEM.START_NEW_SCRIPT(name, 5000)
                        SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(name)
                    end)
                end

                tab2.render = function()
                    ImGui.Text("Works best when low ping / session host")

                    for k, v in pairs(a.apps) do
                        if ImGui.Button(v) then
                            SussySpt.addTask(function()
                                runScript(k)
                            end)
                        end
                    end
                end

                tab.sub[4] = tab2
            end

            do -- SECTION Unlocks
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

                    tab3.render = function()
                        if ImGui.Button("Unlock all achievements") then
                            SussySpt.addTask(function()
                                yu.loop(59, function(i)
                                    if not PLAYER.HAS_ACHIEVEMENT_BEEN_PASSED(i) then
                                        PLAYER.GIVE_ACHIEVEMENT_TO_PLAYER(i)
                                    end
                                end)
                                for i = 1, 78 do
                                    globals.set_int(4542602 + 1, i)
                                end
                            end)
                        end

                        if ImGui.Button("Unlock xmas liveries") then
                            SussySpt.addTask(function()
                                stats.set_int("MPPLY_XMASLIVERIES", -1)
                                for i = 1, 20 do
                                    stats.set_int("MPPLY_XMASLIVERIES"..i, -1)
                                end
                            end)
                        end

                        if ImGui.Button("Unlock LSCarMeet podium prize") then
                            SussySpt.addTask(function()
                                stats.set_bool(yu.mpx().."CARMEET_PV_CHLLGE_CMPLT", true)
                                stats.set_bool(yu.mpx().."CARMEET_PV_CLMED", false)
                            end)
                        end
                        yu.rendering.tooltip("Go in LSCarMeet to claim in interaction menu")

                        if ImGui.Button("LSCarMeet unlocks") then
                            SussySpt.addTask(function()
                                for i = 293419, 293446 do
                                    globals.set_float(i, 100000)
                                end
                            end)
                        end

                        if ImGui.Button("Unlock flightschool stuff") then
                            SussySpt.addTask(function()
                                stats.set_int("MPPLY_NUM_CAPTURES_CREATED", math.max(stats.get_int("MPPLY_NUM_CAPTURES_CREATED") or 0, 100))
                                for i = 0, 9 do
                                    stats.set_int("MPPLY_PILOT_SCHOOL_MEDAL_"..i , -1)
                                    stats.set_int(yu.mpx().."PILOT_SCHOOL_MEDAL_"..i, -1)
                                    stats.set_bool(yu.mpx().."PILOT_ASPASSEDLESSON_"..i, true)
                                end
                            end)
                        end
                        yu.rendering.tooltip("MPPLY_NUM_CAPTURES_CREATED > 100\nMPPLY_PILOT_SCHOOL_MEDAL_[0-9] = -1\n$MPX_PILOT_SCHOOL_MEDAL_[0-9] = -1\n$MPX_PILOT_ASPASSEDLESSON_[0-9] = true")

                        if ImGui.Button("Unlock shooting range") then
                            SussySpt.addTask(function()
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
                        end
                        yu.rendering.tooltip("Bunker thingy")

                        if ImGui.Button("Unlock trade prices for arenawar vehicles") then
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
                                for i = 18, 29 do
                                    stats.set_bool_masked(yu.mpx().."ARENAWARSPSTAT_BOOL0", true, i)
                                end
                            end)
                        end

                        if ImGui.Button("Unlock fast run and reload") then
                            SussySpt.addTask(function()
                                for i = 1, 3 do
                                    stats.set_int(yu.mpx().."CHAR_ABILITY_"..i.."_UNLCK", -1)
                                    stats.set_int(yu.mpx().."CHAR_FM_ABILITY_"..i.."_UNLCK", -1)
                                end
                            end)
                        end
                        yu.rendering.tooltip("Makes you run and reload weapons faster")

                        if ImGui.Button("Unlock all tattos") then
                            SussySpt.addTask(function()
                                local mpx = yu.mpx()
                                stats.set_int(mpx.."TATTOO_FM_CURRENT_32", -1)
                                for i = 0, 47 do
                                    stats.set_int(mpx.."TATTOO_FM_UNLOCKS_"..i, -1)
                                end
                            end)
                        end

                        if ImGui.Button("CEO & MC money clutter") then
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
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
                        end

                        if ImGui.Button("Skip yacht missions") then
                            SussySpt.addTask(function()
                                stats.set_int(yu.mpx("YACHT_MISSION_PROG"), 0)
                                stats.set_int(yu.mpx("YACHT_MISSION_FLOW"), 21845)
                                stats.set_int(yu.mpx("CASINO_DECORATION_GIFT_1"), -1)
                            end)
                        end

                        if ImGui.Button("Skip ULP missions") then
                            SussySpt.addTask(function()
                                stats.set_int(yu.mpx("ULP_MISSION_PROGRESS"), 127)
                                stats.set_int(yu.mpx("ULP_MISSION_CURRENT"), 0)
                            end)
                        end

                        if ImGui.Button("Unlock LSC stuff & paints") then
                            SussySpt.addTask(function()
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

                        if ImGui.Button("Unlock phone contracts") then
                            SussySpt.addTask(function()
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

                        if ImGui.Button("Unlock all trade prices") then
                            SussySpt.addTask(function()
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
                            end)
                        end

                        if ImGui.Button("Unlock bunker research (temp?)") then
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
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

                        if ImGui.Button("Very much things") then
                            SussySpt.addTask(function()
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

                        if ImGui.Button("Allow gender change") then
                            SussySpt.addTask(function()
                                stats.set_int(yu.mpx("ALLOW_GENDER_CHANGE"), 52)
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
                        for k, v in pairs(SussySpt.xp_to_rank) do
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

                    function refreshCrewRank()
                        if not a.crank_checking then
                            a.crank_checking = true
                            SussySpt.addTask(function()
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

                    tab3.render = function()
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
                                SussySpt.addTask(function()
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
                                SussySpt.addTask(function()
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
                                SussySpt.addTask(function()
                                    if yu.is_num_between(a.rank, 0, 8000) then
                                        a.rank_rp = SussySpt.xp_to_rank[a.rank] or a.rank_rp
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
                                SussySpt.addTask(function()
                                    if a.crank_rank >= a.crank_min then
                                        stats.set_int("MPPLY_CREW_LOCAL_XP_"..a.crank_crew, SussySpt.xp_to_rank[a.crank_rank] + 100)
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

                do -- ANCHOR Weapons
                    local tab3 = SussySpt.rendering.newTab("Weapons")

                    tab3.render = function()
                        if ImGui.SmallButton("Unlock guns") then
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
                                globals.set_int(262145 + 34131, 0)
                                globals.set_int(262145 + 34094 + 9, -1716189206) -- Knife
                                globals.set_int(262145 + 34094 + 10, -1786099057) -- Baseball bat
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

                        if ImGui.SmallButton("Unlock gunvan guns") then
                            SussySpt.addTask(function()
                                globals.set_int(296276, 0)
                                globals.set_int(296242, -22923932) -- Railgun
                                globals.set_int(296243, 1171102963) -- Stungun
                                globals.set_int(296244, -1355376991) -- Up-n-Atomizer
                                globals.set_int(296245, -1238556825) -- Widowmaker
                                globals.set_int(296246, 1198256469) -- Hellbringer
                                globals.set_int(296247, -1786099057) -- Bat
                            end)
                        end
                    end

                    tab2.sub[3] = tab3
                end

                tab.sub[5] = tab2
            end -- !SECTION

            do -- ANCHOR Tunables
                local tab2 = SussySpt.rendering.newTab("Tunables")

                local a = {}

                local function refreshRPMultiplier()
                    a.rpmultiplier = globals.get_float(SussySpt.pointers.tunables_rpmultiplier)
                end

                local function refresh()
                    refreshRPMultiplier()
                end
                yu.rif(refresh)

                tab2.render = function()
                    do -- RP Multiplier
                        ImGui.Text("RP Multiplier")

                        ImGui.SameLine()

                        ImGui.PushItemWidth(100)
                        local resp = yu.rendering.input("int", {
                            label = "##rp_multiplier",
                            value = a.rpmultiplier
                        })
                        ImGui.PopItemWidth()
                        if resp ~= nil and resp.changed then
                            a.rpmultiplier = resp.value
                        end
                        yu.rendering.tooltip("Max is 140 for some reason")

                        ImGui.SameLine()

                        if ImGui.Button("Apply##rpmultiplier") then
                            SussySpt.addTask(function()
                                globals.set_float(SussySpt.pointers.tunables_rpmultiplier, a.rpmultiplier)
                                refreshRPMultiplier()
                            end)
                        end
                    end
                end

                tab.sub[6] = tab2
            end

            do -- ANCHOR Misc
                local tab2 = SussySpt.rendering.newTab("Misc")

                tab2.render = function()
                    yu.rendering.renderCheckbox("Remove kosatka missle cooldown", "misc_kmcd", function(state)
                        SussySpt.addTask(function()
                            globals.set_int(292539, yu.shc(state, 0, 60000))
                        end)
                    end)

                    yu.rendering.renderCheckbox("Higher kosatka missle range", "misc_hkmr", function(state)
                        SussySpt.addTask(function()
                            globals.set_int(292540, yu.shc(state, 4000, 99999))
                        end)
                    end)
                end

                tab.sub[7] = tab2
            end

            do -- ANCHOR Session
                local tab2 = SussySpt.rendering.newTab("Session")

                tab2.should_display = SussySpt.getDev

                tab2.render = function()
                    yu.rendering.renderCheckbox("Create ghost session", "online_session_ghostsess", function(state)
                        if state then
                            NETWORK.NETWORK_START_SOLO_TUTORIAL_SESSION()
                        else
                            NETWORK.NETWORK_END_TUTORIAL_SESSION()
                        end
                        yu.notify(1, "Ghost session "..(state and "en" or "dis").."abled!", "Online->Session")
                    end)
                    yu.rendering.tooltip("This really just puts the players client-side under the map")
                end

                tab.sub[8] = tab2
            end

            do -- ANCHOR Money
                local tab2 = SussySpt.rendering.newTab("Money")

                local a = {
                    transactions = {
                        {"15M (Bend Job)", 0x176D9D54, 15000000},
                        {"15M (Bend Bonus)", 0xA174F633, 15000000},
                        {"15M (Criminal Mastermind)", 0x3EBB7442, 15000000},
                        {"15M (Gangpos Mastermind)", 0x23F59C7C, 15000000},
                        {"7M (Gang)", 0xED97AFC1, 7000000},
                        {"3.6M (Casino Heist)", 0xB703ED29, 3619000},
                        {"3M (Agency Story)", 0xBD0D94E3, 3000000},
                        {"3M (Gangpos Mastermind)", 0x370A42A5, 3000000},
                        {"2.5M (Gang)", 0x46521174, 2550000},
                        {"2.5M (Island Heist)", 0xDBF39508, 2550000},
                        {"2M (Gangpos Award Order)", 0x32537662, 2000000},
                        {"2M (Heist Awards)", 0x8107BB89, 2000000},
                        {"2M (Tuner Robbery)", 0x921FCF3C, 2000000},
                        {"2M (Business Hub)", 0x4B6A869C, 2000000},
                        {"1.5M (Gangpos Loyal Award)", 0x33E1D8F6, 1500000},
                        {"1.2M (Boss Agency)", 0xCCFA52D, 1200000},
                        {"1M (Music Trip)", 0xDF314B5A, 1000000},
                        {"1M (Daily Objective Event)", 0x314FB8B0, 1000000},
                        {"1M (Daily Objective)", 0xBFCBE6B6, 1000000},
                        {"1M (Juggalo Story Award)", 0x615762F1, 1000000},
                        {"700K (Gangpos Loyal Award)", 0xED74CC1D, 700000},
                        {"680K (Betting)", 0xACA75AAE, 680000},
                        {"620K (Vehicle Export)", 0xEE884170, 620000},
                        {"500K (Casino Straight Flush)", 0x059E889DD, 500000},
                        {"500K (Juggalo Story)", 0x05F2B7EE, 500000},
                        {"400K (Cayo Heist Award Professional)", 0xAC7144BC, 400000},
                        {"400K (Cayo Heist Award Cat Burglar)", 0xB4CA7969, 400000},
                        {"400K (Cayo Heist Award Elite Thief)", 0xF5AAD2DE, 400000},
                        {"400K (Cayo Heist Award Island Thief)", 0x1868FE18, 400000},
                        {"350K (Casino Heist Award Elite Thief)", 0x7954FD0F, 350000},
                        {"300K (Casino Heist Award All Rounder)", 0x234B8864, 300000},
                        {"300K (Casino Heist Award Pro Thief)", 0x2EC48716, 300000},
                        {"300K (Ambient Job Blast)", 0xC94D30CC, 300000},
                        {"300K (Premium Job)", 0xFD2A7DE7, 300000},
                        {"270K (Smuggler Agency)", 0x1B9AFE05, 270000},
                        {"250K (Casino Heist Award Professional)", 0x5D7FD908, 250000},
                        {"250K (Fixer Award Agency Story)", 0x87356274, 250000},
                        {"200K (DoomsDay Finale Bonus)", 0x9145F938, 200000},
                        {"200K (Action Figures)", 0xCDCF2380, 200000},
                        {"190K (Vehicle Sales)", 0xFD389995, 190000},
                        {"180K (Jobs)", -0x3D3A1CC7, 180000}
                    },
                    transaction = 20,
                    moneyMade = 0
                }

                tab2.render = function()
                    if a.moneyMade > 0 then
                        ImGui.Text("Money made: "..yu.format_num(a.moneyMade))
                    end

                    ImGui.PushItemWidth(340)
                    if ImGui.BeginCombo("Transaction", a.transactions[a.transaction][1]) then
                        for k, v in pairs(a.transactions) do
                            if ImGui.Selectable(v[1], false) then
                                a.transaction = k
                            end
                        end
                        ImGui.EndCombo()
                    end
                    ImGui.PopItemWidth()

                    if ImGui.Button("Trigger transaction") then
                        yu.rif(function(rs)
                            local data = a.transactions[a.transaction]
                            if type(data) == "table" then
                                triggerTransaction(rs, data[2], data[3])
                                a.moneyMade = a.moneyMade + data[3]
                            end
                        end)
                    end

                    yu.rendering.renderCheckbox("Loop", "online_money_loop", function(state)
                        if state then
                            yu.rif(function(rs)
                                local data = a.transactions[a.transaction]
                                if type(data) == "table" then
                                    while yu.rendering.isCheckboxChecked("online_money_loop") and not a.loop do
                                        a.loop = true

                                        triggerTransaction(rs, data[2], data[3])
                                        a.moneyMade = a.moneyMade + data[3]

                                        rs:sleep(1000)

                                        a.loop = nil
                                    end
                                end
                            end)
                        end
                    end)

                    if SussySpt.dev and ImGui.Button("Dump globals") then
                        SussySpt.addTask(function()
                            local b = 4536533
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

                tab.sub[9] = tab2
            end

            SussySpt.rendering.tabs[1] = tab
        end -- !SECTION

        do -- SECTION World
            local tab = SussySpt.rendering.newTab("World")

            do -- ANCHOR Object Spawner
                local tab2 = SussySpt.rendering.newTab("Object Spawner")

                local a = {
                    model = "",
                    awidth = 195
                }

                yu.rendering.setCheckboxChecked("world_objspawner_deleteprev")
                yu.rendering.setCheckboxChecked("world_objspawner_missionent")

                local function temp_text(infotext, duration)
                    yu.rif(function(runscript)
                        a.infotext = infotext
                        local id = yu.gun()
                        a.infotextid = id
                        runscript:sleep(duration)
                        if a.infotextid == id then
                            a.infotext = nil
                        end
                    end)
                end

                tab2.render = function()
                    ImGui.BeginGroup()

                    ImGui.Text("Spawner")

                    ImGui.PushItemWidth(a.awidth)

                    local model_text, _ = ImGui.InputTextWithHint("Model", "ex. stt_prop_stunt_bowling_pin", a.model, 32)
                    SussySpt.pushDisableControls(ImGui.IsItemActive())
                    if a.model ~= model_text then
                        a.model = model_text
                        a.invalidmodel = nil
                    end

                    if a.invalidmodel then
                        yu.rendering.coloredtext("Invalid model!", 255, 25, 25)
                    elseif a.blocked then
                        yu.rendering.coloredtext("Spawning...", 108, 149, 218)
                    end

                    if a.infotext ~= nil then
                        yu.rendering.coloredtext(a.infotext[1], a.infotext[2], a.infotext[3], a.infotext[4])
                    end

                    ImGui.PopItemWidth()

                    if not a.blocked and ImGui.Button("Spawn") then
                        yu.rif(function(runscript)
                            a.blocked = true

                            local hash = joaat(a.model)

                            if not STREAMING.IS_MODEL_VALID(hash) then
                                a.invalidmodel = true
                            else
                                STREAMING.REQUEST_MODEL(hash)
                                repeat runscript:yield() until STREAMING.HAS_MODEL_LOADED(hash)

                                if yu.rendering.isCheckboxChecked("world_objspawner_deleteprev") and yu.does_entity_exist(a.entity) then
                                    ENTITY.DELETE_ENTITY(a.entity)
                                end

                                local c = ENTITY.GET_ENTITY_COORDS(yu.ppid())
                                a.entity = OBJECT.CREATE_OBJECT_NO_OFFSET(
                                    hash,
                                    c.x,
                                    c.y,
                                    c.z,
                                    true,
                                    yu.rendering.isCheckboxChecked("world_objspawner_missionent") ~= false,
                                    true
                                )

                                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

                                if a.entity then
                                    ENTITY.SET_ENTITY_LOD_DIST(a.entity, 0xFFFF)
                                    ENTITY.FREEZE_ENTITY_POSITION(a.entity, yu.rendering.isCheckboxChecked("world_objspawner_freeze"))
                                    if yu.rendering.isCheckboxChecked("world_objspawner_groundplace") then
                                        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(a.entity)
                                    end
                                else
                                    temp_text({"Error while spawning entity", 255, 0, 0}, 2500)
                                end
                            end

                            a.blocked = nil
                        end)
                    end

                    if a.entity ~= nil then
                        ImGui.SameLine()

                        if ImGui.Button("Delete##last_spawned") then
                            yu.rif(function(runscript)
                                if yu.does_entity_exist(a.entity) then
                                    ENTITY.DELETE_ENTITY(a.entity)
                                end
                            end)
                        end
                    end

                    ImGui.EndGroup()
                    ImGui.SameLine()
                    ImGui.BeginGroup()

                    ImGui.Text("Options")

                    if ImGui.TreeNodeEx("Spawn options") then
                        yu.rendering.renderCheckbox("Frozen", "world_objspawner_freeze", function(state)
                            SussySpt.addTask(function()
                                if a.entity ~= nil and yu.does_entity_exist(a.entity) then
                                    ENTITY.FREEZE_ENTITY_POSITION(a.entity, state)
                                end
                            end)
                        end)

                        yu.rendering.renderCheckbox("Delete previous", "world_objspawner_deleteprev")
                        yu.rendering.renderCheckbox("Place on ground correctly", "world_objspawner_groundplace")
                        yu.rendering.renderCheckbox("Mission entity", "world_objspawner_missionent", function(state)
                            SussySpt.addTask(function()
                                if a.entity ~= nil and yu.does_entity_exist(a.entity) then
                                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(a.entity, state)
                                end
                            end)
                        end)

                        ImGui.TreePop()
                    end

                    ImGui.EndGroup()
                end

                tab.sub[1] = tab2
            end

            do -- ANCHOR Entities
                local tab2 = SussySpt.rendering.newTab("Entities")

                tab2.should_display = SussySpt.getDev

                tab2.render = function()
                    ImGui.Text("Door controller")

                    for i = 0, 10 do
                        ImGui.Text(i..":")
                        ImGui.SameLine()
                        if ImGui.SmallButton("Open##"..i) then
                            SussySpt.addTask(function()
                                local veh = yu.veh(yu.ppid())
                                if veh ~= nil then
                                    VEHICLE.SET_VEHICLE_DOOR_OPEN(veh, i, false, true)
                                end
                            end)
                        end
                        ImGui.SameLine()
                        if ImGui.SmallButton("Closed##"..i) then
                            SussySpt.addTask(function()
                                local veh = yu.veh(yu.ppid())
                                if veh ~= nil then
                                    VEHICLE.SET_VEHICLE_DOOR_SHUT(veh, i, true)
                                end
                            end)
                        end
                    end
                end

                tab.sub[2] = tab2
            end

            do -- ANCHOR Particle Spawner
                local tab2 = SussySpt.rendering.newTab("Particle Spawner")

                local a = {
                    awidth = 280,
                    dict = "core",
                    effect = "ent_sht_petrol_fire"
                }

                tab2.render = function()
                    ImGui.PushItemWidth(a.awidth)

                    local dict, _ = ImGui.InputTextWithHint("Dict", "ex. core", a.dict, 32)
                    SussySpt.pushDisableControls(ImGui.IsItemActive())
                    if a.dict ~= dict then
                        a.dict = dict
                    end

                    local effect, _ = ImGui.InputTextWithHint("Effect", "ex. ent_sht_petrol_fire", a.effect, 32)
                    SussySpt.pushDisableControls(ImGui.IsItemActive())
                    if a.effect ~= effect then
                        a.effect = effect
                    end

                    ImGui.PopItemWidth()

                    if a.blocked ~= true and ImGui.Button("Spawn") then
                        yu.rif(function(rs)
                            a.blocked = true

                            STREAMING.REQUEST_NAMED_PTFX_ASSET(a.dict)
                            repeat rs:yield() until STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(a.dict)
                            GRAPHICS.USE_PARTICLE_FX_ASSET(a.dict)

                            local c = ENTITY.GET_ENTITY_COORDS(yu.ppid())
                            local x, y, z = c.x, c.y, c.z
                            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(a.effect, x, y, z, 90, -100, 90, 1, 1, 1, 1)

                            STREAMING.REMOVE_PTFX_ASSET()

                            a.blocked = nil
                        end)
                    end
                end

                tab.sub[3] = tab2
            end

            do -- ANCHOR Peds
                local tab2 = SussySpt.rendering.newTab("Peds")

                tab2.should_display = SussySpt.getDev

                yu.rif(function(rs)
                    while true do
                        if yu.rendering.isCheckboxChecked("world_peds_pedsblind") then
                            for k, v in pairs(entities.get_all_peds_as_handles()) do
                                PED.SET_PED_SEEING_RANGE(v, 0)
                            end
                        end
                        rs:yield()
                    end
                end)

                tab2.render = function()
                    yu.rendering.renderCheckbox("Make enemies blind", "world_peds_pedsblind")
                end

                tab.sub[4] = tab2
            end

            do -- ANCHOR Other
                local tab2 = SussySpt.rendering.newTab("Other")

                local a = {
                    blockexplosionshake = {
                        pattern = "4C 8B 0D ? ? ? ? 44 ? ? 05 ? ? ? ? 48 8D 15",
                        m_name = 0x0,
                        m_cam_shake_name = 0x7c,
                        struct_size = 0x88,
                        patch_registry = {}
                    }
                }

                script.run_in_fiber(function(rs)
                    CExplosionInfoManager = memory.scan_pattern(a.blockexplosionshake.pattern):add(3):rip()
                    exp_list_base = CExplosionInfoManager:deref()
                    exp_count = CExplosionInfoManager:add(0x8):get_word()

                    local enabled = yu.rendering.isCheckboxChecked("world_other_blockexplosionshake")

                    for i = 0, exp_count - 1 do
                        local exp_base = exp_list_base:add(a.blockexplosionshake.struct_size * i)
                        local p = exp_base:add(a.blockexplosionshake.m_cam_shake_name):patch_dword(0)
                        if enabled then
                            p:apply()
                        end
                        table.insert(a.blockexplosionshake.patch_registry, p)
                    end
                    SussySpt.debug((enabled and "Blocked " or "Found ")..tostring(exp_count).." explosion shakes")
                end)

                tab2.render = function()
                    yu.rendering.renderCheckbox("Block explosion shake", "world_other_blockexplosionshake", function(state)
                        enabled = state

                        local i = 0
                        for k, v in ipairs(a.blockexplosionshake.patch_registry) do
                            if state then
                                v:apply()
                            else
                                v:restore()
                            end
                            i = i + 1
                        end
                        SussySpt.debug((state and "Block" or "Restor").."ed "..i.." explosion shakes")
                    end)
                end

                tab.sub[5] = tab2
            end

            SussySpt.rendering.tabs[2] = tab
        end -- !SECTION

        do -- SECTION Singleplayer
            local tab = SussySpt.rendering.newTab("Singleplayer")

            local a = {
                characters = {
                    [0] = "Michael",
                    [1] = "Franklin",
                    [2] = "Trevor"
                }
            }

            do -- ANCHOR Cash
                local tab2 = SussySpt.rendering.newTab("Cash")

                local function refresh()
                    a.cash = {}
                    for k, v in pairs(a.characters) do
                        a.cash[k] = stats.get_int("SP"..k.."_TOTAL_CASH")
                    end
                end
                yu.rif(refresh)

                tab2.render = function()
                    for k, v in pairs(a.cash) do
                        local resp = yu.rendering.input("int", {
                            label = a.characters[k],
                            value = v
                        })
                        if resp ~= nil and resp.changed then
                            a.cash[k] = resp.value
                        end
                    end

                    if ImGui.Button("Apply") then
                        SussySpt.addTask(function()
                            for k, v in pairs(a.cash) do
                                stats.set_int("SP"..k.."_TOTAL_CASH", v)
                            end
                            refresh()
                        end)
                    end
                end

                tab.sub[1] = tab2
            end

            SussySpt.rendering.tabs[3] = tab
        end -- !SECTION

        do -- SECTION Config
            local tab = SussySpt.rendering.newTab("Config")

            do -- ANCHOR Info
                local tab2 = SussySpt.rendering.newTab("Info")

                yu.rendering.setCheckboxChecked("dev", SussySpt.dev)

                tab2.render = function()
                    ImGui.Text("Made by pierrelasse.")
                    ImGui.Text("SussySpt & yimutils download: https://github.com/pierrelasse/YimStuff")

                    ImGui.Separator()

                    ImGui.Text("Version: "..SussySpt.version)
                    ImGui.Text("Version id: "..SussySpt.versionid)
                    ImGui.Text("Version type: "..SussySpt.versiontype)
                    ImGui.Text("Build: "..SussySpt.build)

                    ImGui.Separator()

                    ImGui.Text("Theme: "..SussySpt.rendering.theme)
                    ImGui.PushItemWidth(265)
                    if ImGui.BeginCombo("Theme", SussySpt.rendering.theme) then
                        for k, v in pairs(SussySpt.rendering.themes) do
                            if ImGui.Selectable(k, false) then
                                SussySpt.rendering.theme = k
                                SussySpt.debug("Set theme to '"..k.."'")
                            end
                        end
                        ImGui.EndCombo()
                    end
                    ImGui.PopItemWidth()

                    if ImGui.TreeNodeEx("Edit theme") then
                        ImGui.Spacing()
                        ImGui.Text("Reload the script to revert changes")

                        ImGui.PushItemWidth(267)
                        local sameLine = false
                        for k, v in pairs(SussySpt.rendering.getTheme()) do
                            if k == "ImGuiCol" then
                                for k1, k2 in pairs(v) do
                                    if sameLine then
                                        ImGui.SameLine()
                                    end
                                    sameLine = not sameLine
                                    local col, used = ImGui.ColorPicker4(k1, k2)
                                    if used then
                                        v[k1] = col
                                    end
                                end
                            end
                        end
                        ImGui.PopItemWidth()

                        ImGui.TreePop()
                    end

                    ImGui.Separator()

                    if SussySpt.debugtext ~= "" and ImGui.TreeNodeEx("Debug log") then
                        local x, y = ImGui.GetContentRegionAvail()
                        ImGui.InputTextMultiline("##debug_log", SussySpt.debugtext, SussySpt.debugtext:length(), x, math.min(140, y), ImGuiInputTextFlags.ReadOnly)
                        ImGui.TreePop()
                    end

                    ImGui.Separator()

                    yu.rendering.renderCheckbox("Dev mode", "dev", function(state)
                        SussySpt.dev = state
                        SussySpt.debug(yu.shc(state, "En", "Dis").."abled dev mode")
                    end)
                    yu.rendering.tooltip("This just enables testing and not serious things")

                    if SussySpt.dev then
                        ImGui.Spacing()

                        if ImGui.Button("Go airplane mode :)") then
                            SussySpt.addTask(function()
                                STREAMING.REQUEST_ANIM_DICT("missfbi1")
                                TASK.TASK_PLAY_ANIM(yu.ppid(), "missfbi1", "ledge_loop", 2.0, 2.0, -1, 51, 0, false, false, false)
                            end)
                        end
                    end
                end

                tab.sub[1] = tab2
            end

            do -- ANCHOR Weird ESP
                local tab2 = SussySpt.rendering.newTab("Weird ESP")

                tab2.render = function()
                    ImGui.Text("This was just a test and is for now nothing real.")
                    ImGui.Text("And yes it is working but there is currently no way to render it above things using natives.")
                    ImGui.Spacing()
                    yu.rendering.renderCheckbox("Very cool skeleton esp enabled", "config_esp_enabled")
                    ImGui.Spacing()
                    ImGui.Spacing()
                    yu.rendering.renderCheckbox("Super cool rgb gamer spotlight", "config_esp_spotlight_enabled")
                end

                tab.sub[2] = tab2
            end

            do -- ANCHOR Invisible
                local tab2 = SussySpt.rendering.newTab("Invisible")

                local a = {
                    key = "L"
                }

                yu.rendering.setCheckboxChecked("invisible_hotkey")

                local makingVehicleInivs = false
                SussySpt.ensureVis = function(state, id, veh)
                    if state ~= true and state ~= false then
                        return nil
                    end
                    if id ~= nil and yu.rendering.isCheckboxChecked("invisible_self") then
                        ENTITY.SET_ENTITY_VISIBLE(id, state, 0)
                    end
                    if not makingVehicleInivs and yu.rendering.isCheckboxChecked("invisible_vehicle") then
                        SussySpt.addTask(function()
                            makingVehicleInivs = true
                            if veh ~= nil and entities.take_control_of(veh) then
                                ENTITY.SET_ENTITY_VISIBLE(veh, state, 0)
                            end
                            makingVehicleInivs = false
                        end)
                    end
                end

                SussySpt.enableVis = function()
                    SussySpt.invisible = nil
                    SussySpt.ensureVis(true, yu.ppid(), yu.veh())
                end

                local function bindHotkey(key)
                    if key == nil then
                        return
                    end
                    yu.key_listener.remove_callback(a.callback)
                    a.callback = yu.key_listener.add_callback(key, function()
                        if yu.rendering.isCheckboxChecked("invisible_hotkey") and not HUD.IS_PAUSE_MENU_ACTIVE() then
                            if SussySpt.invisible == true then
                                SussySpt.enableVis()
                            else
                                SussySpt.invisible = true
                            end
                            if yu.rendering.isCheckboxChecked("invisible_log") then
                                log.info("You are now "..yu.shc(SussySpt.invisible, "invisible", "visible").."!")
                            end
                        end
                    end)
                end
                bindHotkey(yu.keys[a.key])

                yu.rendering.setCheckboxChecked("invisible_self")
                yu.rendering.setCheckboxChecked("invisible_vehicle")

                tab2.render = function()
                    yu.rendering.renderCheckbox("Enabled", "invisible", function(state)
                        if state then
                            SussySpt.invisible = true
                        else
                            yu.rif(SussySpt.enableVis)
                        end
                    end)

                    ImGui.Spacing()

                    yu.rendering.renderCheckbox("Hotkey enabled", "invisible_hotkey")
                    yu.rendering.renderCheckbox("Log", "invisible_log")

                    ImGui.Spacing()

                    yu.rendering.renderCheckbox("Self", "invisible_self")
                    yu.rendering.renderCheckbox("Vehicle", "invisible_vehicle")

                    ImGui.Spacing()

                    ImGui.PushItemWidth(140)
                    if ImGui.BeginCombo("Key", a.key) then
                        for k, v in pairs(yu.keys) do
                            if ImGui.Selectable(k, false) then
                                a.key = k
                                bindHotkey(yu.keys[k])
                            end
                        end
                        ImGui.EndCombo()
                    end
                    ImGui.PopItemWidth()
                end

                tab.sub[3] = tab2
            end

            SussySpt.rendering.tabs[4] = tab
        end -- !SECTION
    end -- !SECTION

    SussySpt.debug("Registering mainloop")
    yu.rif(SussySpt.mainLoop)
    SussySpt.debug("Adding render callback ")
    SussySpt.tab:add_imgui(SussySpt.render)

    SussySpt.debug("Creating esp thread")
    -- ANCHOR ESP
    do
        local function drawLine(ped, index1, index2)
            local c1 = PED.GET_PED_BONE_COORDS(ped, index1, 0, 0, 0)
            local c2 = PED.GET_PED_BONE_COORDS(ped, index2, 0, 0, 0)
            GRAPHICS.DRAW_LINE(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 255, 0, 0, 255)
        end

        local amplitude = 127
        local phaseShift = 0
        local counter = 0
        local frequency = .6

        function rgbGamerColor()
            counter = counter + 1
            local elapsedTime = counter / 20
            local r = math.sin(frequency * elapsedTime + phaseShift) * amplitude + amplitude
            local g = math.sin(frequency * elapsedTime + 2 * math.pi / 3 + phaseShift) * amplitude + amplitude
            local b = math.sin(frequency * elapsedTime + 4 * math.pi / 3 + phaseShift) * amplitude + amplitude
            return math.floor(r), math.floor(g), math.floor(b)
        end

        local brightness = 1
        local brightnessAdd = .1

        yu.rif(function(rs)
            while true do
                rs:yield()

                local espEnabled = yu.rendering.isCheckboxChecked("config_esp_enabled")
                local spotLightEnabled = yu.rendering.isCheckboxChecked("config_esp_spotlight_enabled")

                if (espEnabled or spotLightEnabled) and not DLC.GET_IS_LOADING_SCREEN_ACTIVE() then
                    local lc = ENTITY.GET_ENTITY_COORDS(yu.ppid())

                    if espEnabled then
                        for k, v in pairs(SussySpt.players) do
                            local ped = v.ped
                            local c = ENTITY.GET_ENTITY_COORDS(ped)
                            local distance = MISC.GET_DISTANCE_BETWEEN_COORDS(lc.x, lc.y, lc.z, c.x, c.y, c.z, false)
                            if distance < 120 and GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(c.x, c.y, c.z) then
                                -- Head Bones
                                drawLine(ped, 31086, 39317) -- Head, Neck
                                -- Left Arm Bones
                                drawLine(ped, 10706, 45509) -- Left Clavicle, Left Upper Arm
                                drawLine(ped, 45509, 61163) -- Left Upper Arm, Left Forearm
                                drawLine(ped, 61163, 18905) -- Left Forearm, Left Hand
                                -- Right Arm Bones
                                drawLine(ped, 10706, 40269) -- Right Clavicle, Right Upper Arm
                                drawLine(ped, 40269, 28252) -- Right Upper Arm, Right Forearm
                                drawLine(ped, 28252, 57005) -- Right Forearm, Right Hand
                                -- Body Bones
                                drawLine(ped, 11816, 10706) -- Pelvis, Left Clavicle
                                -- Left Leg Bones
                                drawLine(ped, 11816, 58271) -- Pelvis, Left Thigh
                                drawLine(ped, 58271, 63931) -- Left Thigh, Left Calf
                                drawLine(ped, 63931, 14201) -- Left Calf, Left Foot
                                -- Right Leg Bones
                                drawLine(ped, 11816, 51826) -- Pelvis, Right Thigh
                                drawLine(ped, 51826, 36864) -- Right Thigh, Right Calf
                                drawLine(ped, 36864, 52301) -- Right Calf, Right Foot
                            end
                        end
                    end

                    if spotLightEnabled then
                        local r, g, b = rgbGamerColor()
                        brightness = brightness + brightnessAdd
                        if brightness > 40 then
                            brightnessAdd = -.1
                        elseif brightness < 20 then
                            brightnessAdd = .1
                        end

                        GRAPHICS.DRAW_SPOT_LIGHT(lc.x, lc.y, lc.z + 3, 0, 0, -4, r, g, b, 10, brightness, 4, 53, 20)
                    end
                end
            end
        end)
    end

    SussySpt.debug("Loaded successfully!")
    yu.notify(1, "Loaded! v"..SussySpt.version.." ["..SussySpt.versionid.."]", "Loaded!")
end -- !SECTION

function SussySpt:initCategories() -- SECTION SussySpt:initCategories
    local tab = SussySpt.tab

    SussySpt.debug("Calling SussySpt:initTabHBO()")
    SussySpt:initTabHBO()
    SussySpt.debug("Calling SussySpt:initTabQA()")
    SussySpt:initTabQA()

    if SussySpt.dev then
        SussySpt.debug("Calling SussySpt:initTabHeist()")
        SussySpt:initTabHeist()
    end

    tab:add_text("Categories")
    tab:add_imgui(function()
        ImGui.SameLine()

        if ImGui.SmallButton("Show all") then
            for k, v in pairs({"hbo", "qa"}) do
                yu.rendering.setCheckboxChecked("cat_"..v)
            end
        end

        if SussySpt.in_online then
            yu.rendering.renderCheckbox("HBO", "cat_hbo")
        end
        yu.rendering.renderCheckbox("Quick actions", "cat_qa")
    end)
end -- !SECTION

function SussySpt:initTabHBO() -- SECTION SussySpt:initTabHBO
    local toRender = {}
    local function addToRender(id, cb)
        toRender[id] = cb
    end

    local function addUnknownValue(tbl, v)
        if tbl[v] == nil then
            tbl[v] = "??? ["..(v or "<null>").."]"
        end
    end

    local function renderCutsSlider(tbl, index)
        local value = tbl[index] or 85
        local text = yu.shc(index == -2, "Non-host self cut", "Player "..index.."'s cut")
        local newValue, changed = ImGui.DragInt(text, value, .2, 0, 250, "%d%%", 5)
        if changed then
            tbl[index] = newValue
        end

        ImGui.SameLine()

        ImGui.PushButtonRepeat(true)

        if ImGui.Button(" - ##cuts_-"..index) then
            tbl[index] = value - 1
        end

        ImGui.SameLine()

        if ImGui.Button(" + ##cuts_+"..index) then
            tbl[index] = value + 1
        end

        ImGui.PopButtonRepeat()
    end

    local function removeAllCameras()
        for k, entity in pairs(entities.get_all_objects_as_handles()) do
            for k1, hash in pairs({
                joaat("prop_cctv_cam_01a"), joaat("prop_cctv_cam_01b"),
                joaat("prop_cctv_cam_02a"), joaat("prop_cctv_cam_03a"),
                joaat("prop_cctv_cam_04a"), joaat("prop_cctv_cam_04c"),
                joaat("prop_cctv_cam_05a"), joaat("prop_cctv_cam_06a"),
                joaat("prop_cctv_cam_07a"), joaat("prop_cs_cctv"),
                joaat("p_cctv_s"), joaat("hei_prop_bank_cctv_01"),
                joaat("hei_prop_bank_cctv_02"), joaat("ch_prop_ch_cctv_cam_02a"),
                joaat("xm_prop_x17_server_farm_cctv_01")}) do
                if ENTITY.GET_ENTITY_MODEL(entity) == hash then
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entity, true, true)
                    ENTITY.DELETE_ENTITY(entity)
                end
            end
        end
    end

    local function initCayo()
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
        refreshStats()

        local function refreshCuts()
            a.cuts = {}
        end
        refreshCuts()

        local function refreshExtra()
            if yu.is_script_running("fm_mission_controller_2020") then
                a.lifes = locals.get_int("fm_mission_controller_2020", 43059 + 865 + 1)
                a.realtake = locals.get_int("fm_mission_controller_2020", 40004 + 1392 + 53)
            else
                a.lifes = 0
                a.realtake = 289700
            end

        end
        refreshExtra()

        local cooldowns = {}
        local function refreshCooldowns()
            for k, v in pairs({"H4_TARGET_POSIX", "H4_COOLDOWN", "H4_COOLDOWN_HARD"}) do
                cooldowns[k] = " "..v..": "..yu.format_seconds(stats.get_int(yu.mpx()..v) - os.time())
            end
        end
        refreshCooldowns()

        addToRender(1, function()
            if (ImGui.BeginTabItem("Cayo Perico Heist")) then
                ImGui.BeginGroup()
                yu.rendering.bigText("Preperations")

                ImGui.PushItemWidth(360)

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

                yu.rendering.renderCheckbox("Cutting powder", "hbo_cayo_cuttingpowder", function(state)
                    a.cuttingpowderchanged = true
                end)
                yu.rendering.tooltip("Guards will have reduced firing accuracy during the finale mission")

                ImGui.PopItemWidth()

                ImGui.Spacing()

                if ImGui.Button("Apply##stats") then
                    SussySpt.addTask(function()
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
                        if a.paintingschanged then
                            changes = yu.add(changes, 1)
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
                        for k, v in pairs(a) do
                            if tostring(k):endswith("changed") then
                                a[k] = nil
                            end
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Refresh##stats") then
                    SussySpt.addTask(refreshStats)
                end

                ImGui.SameLine()

                if ImGui.Button("Reload planning board") then
                    if SussySpt.requireScript("heist_island_planning") then
                        locals.set_int("heist_island_planning", 1526, 2)
                    end
                end

                if ImGui.Button("Unlock accesspoints & approaches") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx().."H4CNF_BS_GEN", -1)
                        stats.set_int(yu.mpx().."H4CNF_BS_ENTR", 63)
                        stats.set_int(yu.mpx().."H4CNF_APPROACH", -1)
                        yu.notify("POI, accesspoints, approaches stuff should be unlocked i think", "Cayo Perico Heist")
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Remove fencing fee & pavel cut") then
                    SussySpt.addTask(function()
                        globals.set_float(262145 + 29470, -.1)
                        globals.set_float(291786, 0)
                        globals.set_float(291787, 0)
                    end)
                end
                yu.rendering.tooltip("I think no one wants to add them back...")

                if ImGui.Button("Complete Preps") then
                    SussySpt.addTask(function()
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
                    SussySpt.addTask(function()
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

                renderCutsSlider(a.cuts, 1)
                renderCutsSlider(a.cuts, 2)
                renderCutsSlider(a.cuts, 3)
                renderCutsSlider(a.cuts, 4)
                renderCutsSlider(a.cuts, -2)

                if ImGui.Button("Apply##cuts") then
                    for k, v in pairs(a.cuts) do
                        if k == -2 then
                            globals.set_int(2684820 + 6606, v)
                        else
                            globals.set_int(1978495 + 825 + 56 + k, v)
                        end
                    end
                end

                ImGui.SameLine()

                if ImGui.Button("Refresh##cuts") then
                    SussySpt.addTask(refreshCuts)
                end

                ImGui.EndGroup()
                ImGui.Separator()
                ImGui.BeginGroup()

                yu.rendering.bigText("Extra")

                if ImGui.Button("Remove all cameras") then
                    SussySpt.addTask(removeAllCameras)
                end
                yu.rendering.tooltip("This can make your game crash. Be careful")

                ImGui.SameLine()

                if ImGui.Button("Skip printing cutscene") then
                    SussySpt.addTask(function()
                        if locals.get_int("fm_mission_controller", 22032) == 4 then
                            locals.set_int("fm_mission_controller", 22032, 5)
                        end
                    end)
                end
                yu.rendering.tooltip("Idfk what this is or what this does")

                if ImGui.Button("Skip sewer tunnel cut") then
                    SussySpt.addTask(function()
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
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020")
                            and locals.get_int("fm_mission_controller_2020", 54024) ~= 4 then
                            locals.set_int("fm_mission_controller_2020", 54024, 5)
                            yu.notify("Skipped door hack (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                if ImGui.Button("Skip fingerprint hack") then
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020")
                            and locals.get_int("fm_mission_controller_2020", 23669) == 4 then
                            locals.set_int("fm_mission_controller_2020", 23669, 5)
                            yu.notify("Skipped fingerprint hack (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip plasmacutter cut") then
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020") then
                            locals.set_float("fm_mission_controller_2020", 29685 + 3, 100)
                            yu.notify("Skipped plasmacutter cut (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                if ImGui.Button("Obtain the primary target") then
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020") then
                            locals.set_int("fm_mission_controller_2020", 29684, 5)
                            locals.set_int("fm_mission_controller_2020", 29685, 3)
                        end
                    end)
                end
                yu.rendering.tooltip("It works i guess but the object will not get changed")

                ImGui.SameLine()

                if ImGui.Button("Remove the drainage pipe") then
                    SussySpt.addTask(function()
                        local hash = joaat("prop_chem_grill_bit")
                        for k, v in pairs(entities.get_all_objects_as_handles()) do
                            if ENTITY.GET_ENTITY_MODEL(v) == hash then
                                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v, true, true)
                                ENTITY.DELETE_ENTITY(v)
                            end
                        end
                    end)
                end
                yu.rendering.tooltip("This is good")

                if ImGui.Button("Instant finish") then
                    SussySpt.addTask(function()
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
                    SussySpt.addTask(refreshExtra)
                end

                ImGui.PushItemWidth(390)

                local lifesValue, lifesChanged = ImGui.SliderInt("Lifes", a.lifes, 0, 10)
                yu.rendering.tooltip("Only works when you are playing alone (i think)")
                if lifesChanged then
                    a.lifes = lifesValue
                end

                ImGui.SameLine()

                if ImGui.Button("Apply##lifes") then
                    if SussySpt.requireScript("fm_mission_controller_2020") then
                        locals.set_int("fm_mission_controller_2020", 43059 + 865 + 1, a.lifes)
                    end
                end

                local realTakeValue, realTakeChanged = ImGui.SliderInt("Real take", a.realtake, 100000, 2897000, yu.format_num(a.realtake))
                yu.rendering.tooltip("Set real take to 2,897,000 for 100% or smth")
                if realTakeChanged then
                    a.realtake = realTakeValue
                end

                ImGui.SameLine()

                if ImGui.Button("Apply##realtake") then
                    if SussySpt.requireScript("fm_mission_controller_2020") then
                        locals.set_int("fm_mission_controller_2020", 40004 + 1392 + 53, a.realtake)
                    end
                end

                ImGui.Text("Simulate bag for:")
                for i = 1, 4 do
                    ImGui.SameLine()
                    if ImGui.Button(i.." Player"..yu.shc(i == 1, "", "s")) then
                        SussySpt.addTask(function()
                            globals.set_int(292084, 1800 * i)
                        end)
                    end
                end

                ImGui.PopItemWidth()
                ImGui.Separator()

                if ImGui.Button("Refresh##cooldowns") then
                    SussySpt.addTask(refreshCooldowns)
                end

                for k, v in pairs(cooldowns) do
                    ImGui.Text(v)
                end

                ImGui.EndGroup()
                ImGui.EndTabItem()
            end
        end)
    end

    local function initCasinoHeist()
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
        refreshStats()

        local function refreshCuts()
            a.cuts = {}
        end
        refreshCuts()

        local function refreshExtra()
            if yu.is_script_running("fm_mission_controller") then
                a.lifes = locals.get_int("fm_mission_controller", 27400)
            else
                a.lifes = 0
            end

        end
        refreshExtra()

        local cooldowns = {}
        local function updateCooldowns()
            for k, v in pairs({"H3_COMPLETEDPOSIX", "MPPLY_H3_COOLDOWN"}) do
                cooldowns[k] = " "..v..": "..yu.format_seconds(stats.get_int(yu.mpx(v)) - os.time())
            end
        end
        updateCooldowns()

        addToRender(2, function()
            if (ImGui.BeginTabItem("Diamond Casino Heist")) then
                ImGui.BeginGroup()
                yu.rendering.bigText("Preperations")

                ImGui.PushItemWidth(360)

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

                ImGui.PopItemWidth()

                ImGui.Spacing()

                if ImGui.Button("Apply") then
                    SussySpt.addTask(function()
                        local changes = 0

                        -- Approach
                        if a.approachchanged then
                            changes = yu.add(changes, 1)
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
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx("H3OPT_TARGET"), a.target)
                        end

                        -- Gunman
                        if a.gunmanchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx("H3OPT_CREWWEAP"), a.gunman)
                        end

                        -- Weapon variation
                        if a.weaponvariationchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx("H3OPT_WEAPS"), a.weaponvariation)
                        end

                        -- Driver
                        if a.driverchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx().."H3OPT_CREWDRIVER", a.driver)
                        end

                        -- Vehicle variation
                        if a.vehiclevariationchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx("H3OPT_VEHS"), a.vehiclevariation)
                        end

                        -- Hacker
                        if a.hackerchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx().."H3OPT_CREWHACKER", a.hacker)
                        end

                        -- Mask
                        if a.maskchanged then
                            changes = yu.add(changes, 1)
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
                    SussySpt.addTask(refreshStats)
                end

                ImGui.SameLine()

                if ImGui.Button("Reload planning board") then
                    SussySpt.addTask(function()
                        local oldBS0 = stats.get_int("H3OPT_BITSET0")
                        local oldBS1 = stats.get_int("H3OPT_BITSET1")
                        local integerLimit = 2147483647
                        stats.set_int("H3OPT_BITSET0", math.random(integerLimit))
                        stats.set_int("H3OPT_BITSET1", math.random(integerLimit))
                        SussySpt.addTask(function()
                            stats.set_int("H3OPT_BITSET0", oldBS0)
                            stats.set_int("H3OPT_BITSET1", oldBS1)
                        end)
                    end)
                end
                yu.rendering.tooltip("I think this only works when opened")

                if ImGui.Button("Unlock POI & accesspoints") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx().."H3OPT_POI", -1)
                        stats.set_int(yu.mpx().."H3OPT_ACCESSPOINTS", -1)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Remove npc cuts") then
                    SussySpt.addTask(function()
                        local tuneable = 262145

                        -- Lester
                        globals.set_int(tuneable + 28998, 0)

                        -- Gunman, Driver, and Hacker
                        for k, v in ipairs({29024, 29029, 29035}) do
                            for i = 0, 4 do
                                globals.set_int(tuneable + v + i, 0)
                            end
                        end
                    end)
                end

                if ImGui.Button("Complete Preps") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx().."H3OPT_DISRUPTSHIP", a.guardstrength)
                        stats.set_int(yu.mpx().."H3OPT_KEYLEVELS", a.splvl)
                        stats.set_int(yu.mpx().."H3OPT_VEHS", 3)
                        stats.set_int(yu.mpx().."H3OPT_WEAPS", a.weaponvariation)
                        stats.set_int(yu.mpx().."H3OPT_BITSET0", -1)
                        stats.set_int(yu.mpx().."H3OPT_BITSET1", -1)
                        stats.set_int(yu.mpx().."H3OPT_COMPLETEDPOSIX", -1)
                        yu.notify(1, "You will need to wait some time for the heist to be ready", "Diamond Casino Heist")
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset heist") then
                    SussySpt.addTask(function()
                        local mpx = yu.mpx()
                        stats.set_int(mpx.."H3OPT_BITSET1", 0)
                        stats.set_int(mpx.."H3OPT_BITSET0", 0)
                        stats.set_int(mpx.."H3OPT_POI", 0)
                        stats.set_int(mpx.."H3OPT_ACCESSPOINTS", 0)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Unlock cancellation") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx().."CAS_HEIST_NOTS", -1)
                        stats.set_int(yu.mpx().."CAS_HEIST_FLOW", -1)
                    end)
                end

                ImGui.EndGroup()
                ImGui.Separator()
                ImGui.BeginGroup()

                yu.rendering.bigText("Cuts")

                renderCutsSlider(a.cuts, 1)
                renderCutsSlider(a.cuts, 2)
                renderCutsSlider(a.cuts, 3)
                renderCutsSlider(a.cuts, 4)
                renderCutsSlider(a.cuts, -2)

                if ImGui.Button("Apply##cuts") then
                    for k, v in pairs(a.cuts) do
                        if k == -2 then
                            globals.set_int(2691426, v)
                        else
                            globals.set_int(1974021 + k, v)
                        end
                    end
                end

                ImGui.SameLine()

                if ImGui.Button("Refresh##cuts") then
                    SussySpt.addTask(refreshCuts)
                end

                ImGui.EndGroup()
                ImGui.Separator()
                ImGui.BeginGroup()

                yu.rendering.bigText("Extra")

                if ImGui.Button("Set all players ready") then
                    SussySpt.addTask(function()
                        for i = 0, 3 do
                            globals.set_int(1974016 + i, -1)
                        end
                    end)
                end

                if ImGui.Button("Skip fingerprint hack") then
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller") and locals.get_int("fm_mission_controller", 52964) == 4 then
                            locals.set_int("fm_mission_controller", 52964, 5)
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip keypad hack") then
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller")
                            and locals.get_int("fm_mission_controller", 54026) ~= 4 then
                            locals.set_int("fm_mission_controller", 54026, 5)
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip vault door drill") then
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller") then
                            locals.set_int(
                                "fm_mission_controller",
                                10108,
                                locals.get_int("fm_mission_controller", 10138)
                            )
                        end
                    end)
                end

                ImGui.Spacing()

                if ImGui.Button("Refresh##extra") then
                    SussySpt.addTask(refreshExtra)
                end

                local lifesValue, lifesChanged = ImGui.SliderInt("Lifes", a.lifes, 0, 10)
                yu.rendering.tooltip("Not tested")
                if lifesChanged then
                    a.lifes = lifesValue
                end

                ImGui.SameLine()

                if ImGui.Button("Apply##lifes") then
                    if SussySpt.requireScript("fm_mission_controller") then
                        locals.set_int("fm_mission_controller", 27400, a.lifes)
                    end
                end

                ImGui.Separator()

                if ImGui.Button("Refresh cooldowns") then
                    SussySpt.addTask(updateCooldowns)
                end

                for k, v in pairs(cooldowns) do
                    ImGui.Text(v)
                end

                ImGui.EndGroup()

                ImGui.EndTabItem()
            end
        end)
    end

    local function initCasino()
        local rigSlotMachinesId = "hbo_casinoresort_rsm"
        -- local rigSlotMachinesSmartId = "hbo_casinoresort_rsms"

        local luckyWheelPrizes = {
            [0] = "CLOTHING (1)",
            [1] = "2,500 RP",
            [2] = "$20,000",
            [3] = "10,000 Chips",
            [4] = "DISCOUNT %",
            [5] = "5,000 RP",
            [6] = "$30,000",
            [7] = "15,000 Chips",
            [8] = "CLOTHING (2)",
            [9] = "7,500 RP",
            [10] = "20,000 Chips",
            [11] = "MYSTERY",
            [12] = "CLOTHING (3)",
            [13] = "10,000 RP",
            [14] = "$40,000",
            [15] = "25,000 Chips",
            [16] = "CLOTHING (4)",
            [17] = "15,000 RP",
            [18] = "VEHICLE"
        }

        local prize_wheel_win_state = 276
        local prize_wheel_prize = 14
        local prize_wheel_prize_state = 45

        local winPrize = 0
        local winPrizeChanged = false

        function winLuckyWheel(prize)
            if SussySpt.requireScript("casino_lucky_wheel") and yu.is_num_between(prize, 0, 18) then
                yu.notify(1, "Winning "..luckyWheelPrizes[prize].." from the lucky wheel!", "Diamond Casino & Resort")
                locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize), prize)
                locals.set_int("casino_lucky_wheel", prize_wheel_win_state + prize_wheel_prize_state, 11)
            else
                yu.notify(2, "Try going near the lucky wheel", "Diamond Casino & Resort")
            end
        end

        yu.set_default_stat("RIGSLOTMACHINES_LAST", false)

        local storyMissions = {
            [1048576] = "Loose Cheng",
            [1310785] = "House Keeping",
            [1310915] = "Strong Arm Tactics",
            [1311175] = "Play to Win",
            [1311695] = "Bad Beat",
            [1312735] = "Cashing Out"
        }
        local storyMissionIds = {
            [1048576] = 0,
            [1310785] = 1,
            [1310915] = 2,
            [1311175] = 3,
            [1311695] = 4,
            [1312735] = 5
        }
        local storyMission
        local function updateStoryMission()
            storyMission = stats.get_int(yu.mpx("VCM_FLOW_PROGRESS"))
            addUnknownValue(storyMissions, storyMission)
        end
        updateStoryMission()

        addToRender(3, function()
            if (ImGui.BeginTabItem("Diamond Casino & Resort")) then
                ImGui.BeginGroup()

                yu.rendering.bigText("Slots")

                ImGui.Text("Tip: Enable this, spin, disable, spin, enable, spin and so on to not get blocked.")
                yu.rendering.renderCheckbox("Rig slot machines", rigSlotMachinesId)

                yu.rendering.bigText("Lucky wheel")

                ImGui.PushItemWidth(165)

                local lwpr = yu.rendering.renderList(luckyWheelPrizes, winPrize, "hbo_casinoresort_luckywheel", "Prize")
                if lwpr.changed then
                    winPrize = lwpr.key
                    winPrizeChanged = true
                end

                ImGui.PopItemWidth()

                ImGui.SameLine()

                if ImGui.Button("Win") then
                    if not winPrizeChanged then
                        yu.notify(3, "Please select a prize to win first", "Diamond Casino & Resort")
                    else
                        winLuckyWheel(winPrize)
                    end
                end

                yu.rendering.bigText("Story Missions")

                local smr = yu.rendering.renderList(storyMissions, storyMission, "hbo_casinoresort_sm", "Story mission")
                if smr.changed then
                    storyMission = smr.key
                end

                ImGui.SameLine()

                if ImGui.Button("Apply##sm") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx("VCM_STORY_PROGRESS"), storyMissionIds[storyMission])
                        stats.set_int(yu.mpx("VCM_FLOW_PROGRESS"), storyMission)
                    end)
                end

                ImGui.EndTabItem()
            end
        end)

        local slots_random_results_table = 1344

        SussySpt.addTask(function()
            if yu.is_script_running("casino_slots") then
                local needsRun = false

                if yu.rendering.isCheckboxChecked(rigSlotMachinesId) then
                    for slots_iter = 3, 195, 1 do
                        if slots_iter ~= 67 and slots_iter ~= 132 then
                            if locals.get_int("casino_slots", (slots_random_results_table) + (slots_iter)) ~= 6 then
                                needsRun = true
                            end
                        end
                    end
                else
                    local sum = 0
                    for slots_iter = 3, 195, 1 do
                        if slots_iter ~= 67 and slots_iter ~= 132 then
                            sum = sum + locals.get_int("casino_slots", (slots_random_results_table) + (slots_iter))
                        end
                    end
                    needsRun = sum == 1146
                end

                if needsRun then
                    for slots_iter = 3, 195, 1 do
                        if slots_iter ~= 67 and slots_iter ~= 132 then
                            local slot_result = 6
                            if yu.rendering.isCheckboxChecked(rigSlotMachinesId) == false then
                                math.randomseed(os.time() + slots_iter)
                                slot_result = math.random(0, 7)
                            end
                            locals.set_int("casino_slots", (slots_random_results_table) + (slots_iter), slot_result)
                        end
                    end
                end
            end
        end)
    end

    local function initNightclub()
        local a = {
            storages = {
                [0] = {
                    "Cargo and Shipments (CEO Office Special Cargo Warehouse or Smuggler's Hangar)",
                    "Cargo and Shipments",
                    50
                },
                [1] = {
                    "Sporting Goods (Gunrunning Bunker)",
                    "Sporting Goods",
                    100
                },
                [2] = {
                    "South American Imports (M/C Cocaine Lockup)",
                    "S. A. Imports",
                    10
                },
                [3] = {
                    "Pharmaceutical Research (M/C Methamphetamine Lab)",
                    "Pharmaceutical Research",
                    20
                },
                [4] = {
                    "Organic Produce (M/C Weed Farm)",
                    "Organic Produce",
                    80
                },
                [5] = {
                    "Printing & Copying (M/C Document Forgery Office)",
                    "Printing & Copying",
                    60
                },
                [6] = {
                    "Cash Creation (M/C Counterfeit Cash Factory)",
                    "Cash Creation",
                    40
                },
            },
            storageflags =
                ImGuiTableFlags.BordersV
                + ImGuiTableFlags.BordersOuterH
                + ImGuiTableFlags.RowBg
        }

        local function refresh()
            a.popularity = stats.get_int(yu.mpx().."CLUB_POPULARITY")

            a.storage = {}
            local storageGlob = globals.get_int(286713)
            for k, v in pairs(a.storages) do
                local stock = stats.get_int(yu.mpx("HUB_PROD_TOTAL_"..k))
                a.storage[k] = {
                    stock.."/"..v[3],
                    "$"..yu.format_num(storageGlob * stock)
                }
            end
        end

        refresh()

        local nightclubScript = "am_mp_nightclub"

        local function collectSafeNow()
            locals.set_int(nightclubScript, 732, 1)
        end

        local function ensureScriptAndCollectSafe()
            if yu.is_script_running(nightclubScript) then
                collectSafeNow()
            else
                -- yu.rif(function(fs)
                --     SCRIPT.REQUEST_SCRIPT(nightclubScript)
                --     repeat fs:yield() until SCRIPT.HAS_SCRIPT_LOADED(nightclubScript)
                --     SYSTEM.START_NEW_SCRIPT_WITH_NAME_HASH(joaat(nightclubScript), 3650)
                --     repeat fs:yield() until yu.is_script_running(nightclubScript)
                --     collectSafeNow()
                --     SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(nightclubScript)
                -- end)
                yu.notify(3, "You need to be in your nightclub for this!", "Not implemented yet")
            end
        end

        addToRender(4, function()
            if (ImGui.BeginTabItem("Nightclub")) then
                if ImGui.Button("Refresh") then
                    SussySpt.addTask(refresh)
                end

                ImGui.Separator()

                ImGui.BeginGroup()

                ImGui.PushItemWidth(140)
                local pnv, pc ImGui.InputInt("Popularity", a.popularity, 0, 1000)
                yu.rendering.tooltip("Type number in and then click Set :D")
                ImGui.PopItemWidth()
                if pc then
                    a.popularity = pnv
                end

                ImGui.SameLine()

                if ImGui.Button("Set##popularity") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx().."CLUB_POPULARITY", a.popularity)
                        refresh()
                    end)
                end
                yu.rendering.tooltip("Set the popularity to the input field")

                ImGui.SameLine()

                if ImGui.Button("Refill##popularity") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx().."CLUB_POPULARITY", 1000)
                        a.popularity = 1000
                        refresh()
                    end)
                end
                yu.rendering.tooltip("Set the popularity to 1000")

                if ImGui.Button("Pay now") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx("CLUB_PAY_TIME_LEFT"), -1)
                    end)
                end
                yu.rendering.tooltip("This will decrease the popularity by 50 and will put $50k in the safe.")

                ImGui.SameLine()

                if ImGui.Button("Collect money") then
                    SussySpt.addTask(ensureScriptAndCollectSafe)
                end
                yu.rendering.tooltip("Experimental")

                ImGui.EndGroup()
                ImGui.BeginGroup()
                yu.rendering.bigText("Storage")

                if ImGui.BeginTable("##storage_table", 3, 3905) then
                    ImGui.TableSetupColumn("Goods")
                    ImGui.TableSetupColumn("Stock")
                    ImGui.TableSetupColumn("Stock price")
                    ImGui.TableSetupColumn("Actions")
                    ImGui.TableHeadersRow()

                    local row = 0
                    for k, v in pairs(a.storages) do
                        local storage = a.storage[k]
                        if storage ~= nil then
                            ImGui.TableNextRow()
                            ImGui.PushID(row)
                            ImGui.TableSetColumnIndex(0)
                            ImGui.TextWrapped(v[2])
                            yu.rendering.tooltip(v[1])
                            ImGui.TableSetColumnIndex(1)
                            ImGui.Text(storage[1])
                            ImGui.TableSetColumnIndex(2)
                            ImGui.Text(storage[2])
                            ImGui.PopID()
                            row = row + 1
                        end
                    end

                    ImGui.EndTable()
                end

                ImGui.EndGroup()
                ImGui.BeginGroup()
                yu.rendering.bigText("Other")

                yu.rendering.renderCheckbox("Remove Tony's cut", "hbo_nightclub_tony", function(state)
                    SussySpt.addTask(function()
                        globals.set_float(286403, yu.shc(state, 0, .025))
                    end)
                end)
                yu.rendering.tooltip("Set Tony's cut to 0.\nWhen disabled, the cut will be set back to 0.025.")

                ImGui.EndGroup()
                ImGui.EndTabItem()
            end
        end)
    end

    local function initApartment()
        local a = {
            heistpointer = 1938365 + 3008 + 1,
            heists = {
                "Fleeca $5M",
                "Fleeca $10M",
                "Fleeca $15M",
                "Prison break $5M",
                "Prison break $10M",
                "Prison break $15M",
                "Humane labs raid $5M",
                "Humane labs raid $10M",
                "Humane labs raid $15M",
                "Series A funding $5M",
                "Series A funding $10M",
                "Series A funding $15M",
                "The pacific standard $5M",
                "The pacific standard $10M",
                "The pacific standard $15M"
            },
            heistsids = {
                [1] = 3500,
                [2] = 7000,
                [3] = 10434,
                [4] = 1000,
                [5] = 2000,
                [6] = 3000,
                [7] = 750,
                [8] = 1482,
                [9] = 2220,
                [10] = 991,
                [11] = 1981,
                [12] = 2970,
                [13] = 400,
                [14] = 800,
                [15] = 1200
            },
            cuts = {}
        }

        local function refresh()
            a.heist = yu.get_key_from_table(a.heistsids, globals.get_int(a.heistpointer), 1)
            a.heistchanged = false
        end

        refresh()

        addToRender(5, function()
            if (ImGui.BeginTabItem("Apartment Heists")) then
                ImGui.BeginGroup()

                if ImGui.Button("Refresh") then
                    SussySpt.addTask(refresh)
                end

                yu.rendering.bigText("Preperations")

                local hr = yu.rendering.renderList(a.heists, a.heist, "hbo_apartment_heist", "Heist")
                if hr.changed then
                    a.heist = hr.key
                    a.heistchanged = true
                end

                if ImGui.Button("Apply") then
                    SussySpt.addTask(function()
                        local changes = 0

                        -- Heist
                        if a.heistchanged then
                            changes = yu.add(changes, 1)
                            globals.set_int(a.heistpointer, a.heistsids[a.heist])
                        end

                        yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied.", "Apartment Heists")
                        for k, v in pairs(a) do
                            if tostring(k):endswith("changed") then
                                a[k] = nil
                            end
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Complete preps") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx().."HEIST_PLANNING_STAGE", -1)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset preps") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx().."HEIST_PLANNING_STAGE", 0)
                    end)
                end

                ImGui.EndGroup()
                ImGui.Separator()
                ImGui.BeginGroup()

                yu.rendering.bigText("Extra")

                ImGui.Text("Fleeca:")

                ImGui.SameLine()

                if ImGui.Button("Skip hack##fleeca") then
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller") then
                            locals.set_int("fm_mission_controller", 11760 + 24, 7)
                        end
                    end)
                end
                yu.rendering.tooltip("When being passenger, you need to play snake.")

                ImGui.SameLine()

                if ImGui.Button("Skip drill##fleeca") then
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller") then
                            locals.set_int("fm_mission_controller", 10072, 100)
                        end
                    end)
                end
                yu.rendering.tooltip("Skip drilling")

                ImGui.SameLine()

                if ImGui.Button("Instant finish (solo only)##fleeca") then
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller") then
                            locals.set_int("fm_mission_controller", 19710, 12)
                            locals.set_int("fm_mission_controller", 28331 + 1, 99999)
                            locals.set_int("fm_mission_controller", 31587 + 69, 99999)
                        end
                    end)
                end
                yu.rendering.tooltip("Never tested this before")

                ImGui.EndGroup()
                ImGui.Separator()
                ImGui.BeginGroup()

                yu.rendering.bigText("Cuts")

                renderCutsSlider(a.cuts, 1)
                renderCutsSlider(a.cuts, 2)
                renderCutsSlider(a.cuts, 3)
                renderCutsSlider(a.cuts, 4)

                if ImGui.Button("Apply cuts") then
                    for k, v in pairs(a.cuts) do
                        if yu.is_num_between(v, 0, 250) then
                            globals.set_int(1937644 + k, v)
                        end
                    end
                end

                if SussySpt.dev and ImGui.Button("15m Test") then
                    SussySpt.addTask(function()
                        globals.set_int(1936397 + 1 + 1, 7453)
                        globals.set_int(1936397 + 1 + 1 + 1, 7453)
                        globals.set_int(1936397 + 1 + 1 + 1 + 1, 100 - (7453 * 2))
                        globals.set_int(1938365 + 3008 + 1, 7453)
                    end)
                end

                ImGui.EndGroup()
                ImGui.EndTabItem()
            end
        end)
    end

    local function initAutoShop()
        local a = {
            heists = {
                [0] = "Union Depository",
                [1] = "The Superdollar Deal",
                [2] = "The Bank Contract",
                [3] = "The ECU Job",
                [4] = "The Prison Contract",
                [5] = "The Agency Deal",
                [6] = "The Lost Contract",
                [7] = "The Data Contract",
            }
        }

        local function refresh()
            a.heist = stats.get_int(yu.mpx("TUNER_CURRENT"))
            addUnknownValue(a.heists, a.heist)
        end

        refresh()

        local function getBS()
            return yu.shc(a.heist == 1, 4351, 12543)
        end

        local cooldowns = {}
        local function refreshCooldowns()
            for i = 0, 7 do
                cooldowns[i] = "  - "..a.heists[i]..": "..yu.format_seconds(stats.get_int(yu.mpx("TUNER_CONTRACT"..i.."_POSIX")) - os.time())
            end
        end
        refreshCooldowns()

        addToRender(6, function()
            if (ImGui.BeginTabItem("AutoShop Heists")) then
                ImGui.BeginGroup()

                if ImGui.Button("Refresh") then
                    SussySpt.addTask(refresh)
                end

                yu.rendering.bigText("Preperations")

                ImGui.PushItemWidth(360)

                local hr = yu.rendering.renderList(a.heists, a.heist, "hbo_as_heist", "Heist")
                if hr.changed then
                    yu.notify(1, "Set Heist to "..a.heists[hr.key].." ["..hr.key.."]", "AutoShop Heists")
                    a.heist = hr.key
                    a.heistchanged = true
                end

                ImGui.PopItemWidth()

                ImGui.Spacing()

                if ImGui.Button("Apply##stats") then
                    SussySpt.addTask(function()
                        local changes = 0

                        -- Heist
                        if a.heistchanged then
                            changes = yu.add(changes, 1)
                            stats.set_int(yu.mpx("TUNER_GEN_BS"), getBS())
                            stats.set_int(yu.mpx("TUNER_CURRENT"), a.heist)
                        end

                        yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied", "AutoShop Heists")
                        for k, v in pairs(a) do
                            if tostring(k):endswith("changed") then
                                a[k] = nil
                            end
                        end
                    end)
                end

                if ImGui.Button("Complete Preps") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx("TUNER_GEN_BS"), -1)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset Preps") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx("TUNER_GEN_BS"), 12467)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset contract") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx("TUNER_GEN_BS"), 8371)
                        stats.set_int(yu.mpx("TUNER_CURRENT"), -1)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset stats") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx("TUNER_COUNT"), 0)
                        stats.set_int(yu.mpx("TUNER_EARNINGS"), 0)
                    end)
                end
                yu.rendering.tooltip("This will set how many contracts you've done to 0 and how much you earned from it")

                if ImGui.Button("Instant finish") then
                    SussySpt.addTask(function()
                        if SussySpt.requireScript("fm_mission_controller_2020") then
                            locals.set_int("fm_mission_controller_2020", 45451, 51338977)
                            locals.set_int("fm_mission_controller_2020", 46829, 101)
                        end
                    end)
                end
                yu.rendering.tooltip("Idk")

                ImGui.Spacing()

                ImGui.Text("Cooldowns:")

                ImGui.SameLine()

                if ImGui.Button("Refresh##cooldowns") then
                    SussySpt.addTask(refreshCooldowns)
                end

                for k, v in pairs(cooldowns) do
                    ImGui.Text(v)
                end

                ImGui.EndGroup()
                ImGui.EndTabItem()
            end
        end)
    end

    local function initDrugWars()
        local a = {
            productiondelayp = 279721
        }

        local function refresh()
            a.daxcooldown = stats.get_int(yu.mpx("XM22JUGGALOWORKCDTIMER"))
            a.productiondelay = globals.get_int(a.productiondelayp)
        end
        refresh()

        addToRender(7, function()
            if (ImGui.BeginTabItem("DrugWars")) then
                ImGui.BeginGroup()

                if ImGui.Button("Refresh") then
                    SussySpt.addTask(refresh)
                end

                ImGui.Spacing()

                ImGui.Text("Cooldown: "..yu.format_seconds(a.daxcooldown))
                if ImGui.Button("Remove Dax cooldown") then
                    SussySpt.addTask(function()
                        stats.set_int(yu.mpx("XM22JUGGALOWORKCDTIMER"), os.time() - 17)
                    end)
                end

                ImGui.Spacing()

                ImGui.Text("Production delay ["..a.productiondelay.."]:")

                ImGui.SameLine()

                if ImGui.Button("Reset") then
                    SussySpt.addTask(function()
                        globals.set_int(a.productiondelayp, 135000)
                        refresh()
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Set to 1") then
                    SussySpt.addTask(function()
                        globals.set_int(a.productiondelayp, 1)
                        refresh()
                    end)
                end

                ImGui.EndGroup()
                ImGui.EndTabItem()
            end
        end)
    end

    local function initAgency()
        local a = {
            vipcontracts = {
                [3] = "Nightlife Leak -> Investigation: The Nightclub",
                [4] = "Nightlife Leak -> Investigation: The Marina",
                [12] = "Nightlife Leak -> Nightlife Leak/Finale",
                [28] = "High Society Leak -> Investigation: The Country Club",
                [60] = "High Society Leak -> Investigation: Guest List",
                [124] = "High Society Leak -> High Society Leak/Finale",
                [252] = "South Central Leak -> Investigation: Davis",
                [508] = "South Central Leak -> Investigation: The Ballas",
                [2044] = "South Central Leak -> South Central Leak/Finale",
                [-1] = "Studio Time",
                [4092] = "Don't Fuck With Dre"
            },
            vipcontractssort = {
                [1] = 3,
                [2] = 4,
                [3] = 12,
                [4] = 28,
                [5] = 60,
                [6] = 124,
                [7] = 252,
                [8] = 508,
                [9] = 2044,
                [10] = -1,
                [11] = 4092
            }
        }

        local function refreshStats()
            a.vipcontract = stats.get_int(yu.mpx("FIXER_STORY_BS"))
            addUnknownValue(a.vipcontracts, a.vipcontract)
        end
        refreshStats()

        SussySpt.addTask(function()
            if yu.rendering.isCheckboxChecked("hbo_agency_smthmfinale") then
                globals.set_int(294496, 2000000)
            end
        end)

        addToRender(8, function()
            if (ImGui.BeginTabItem("Agency")) then
                ImGui.BeginGroup()
                yu.rendering.bigText("Preperations")

                local dlr = yu.rendering.renderList(a.vipcontracts, a.vipcontract, "hbo_agency_dl", "The Dr. Dre VIP Contract", a.vipcontractssort)
                if dlr.changed then
                    yu.notify(1, "Set The Dr. Dre VIP Contract to "..a.vipcontracts[dlr.key].." ["..dlr.key.."]", "Agency")
                    a.vipcontract = dlr.key
                    a.vipcontractchanged = true
                end

                ImGui.Spacing()

                if ImGui.Button("Apply##stats") then
                    SussySpt.addTask(function()
                        local changes = 0

                        -- The Dr. Dre VIP Contract
                        if a.vipcontractchanged then
                            changes = yu.add(changes, 1)

                            stats.set_int(yu.mpx("FIXER_STORY_BS"), a.vipcontract)

                            for k, v in pairs({"FIXER_GENERAL_BS","FIXER_COMPLETED_BS","FIXER_STORY_STRAND","FIXER_STORY_COOLDOWN"}) do
                                stats.set_int(yu.mpx(v), -1)
                            end

                            if a.vipcontract == -1 then
                                stats.set_int(yu.mpx("FIXER_STORY_STRAND"), -1)
                            end
                        end

                        yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied.", "Agency")
                        for k, v in pairs(a) do
                            if tostring(k):endswith("changed") then
                                a[k] = nil
                            end
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Refresh##stats") then
                    SussySpt.addTask(refreshStats)
                end

                ImGui.SameLine()

                if ImGui.Button("Complete all missions") then
                    SussySpt.addTask(function()
                        for k, v in pairs({"FIXER_GENERAL_BS","FIXER_COMPLETED_BS","FIXER_STORY_BS","FIXER_STORY_COOLDOWN"}) do
                            stats.set_int(yu.mpx(v), -1)
                        end
                    end)
                end

                ImGui.EndGroup()
                ImGui.Separator()
                ImGui.BeginGroup()

                yu.rendering.bigText("Extra")

                yu.rendering.renderCheckbox("$2M finale", "hbo_agency_smthmfinale", function(state)
                    if not state then
                        globals.set_int(294496, 1000000)
                    end
                end)
                yu.rendering.tooltip("This is for the 'Don't Fuck With Dre' VIP Contract")

                yu.rendering.renderCheckbox("Remove contracts & payphone hits cooldown", "hbo_agency_cphcd", function(state)
                    SussySpt.addTask(function()
                        globals.set_int(293490, yu.shc(state, 0, 300000))
                    end)
                end)

                yu.rendering.renderCheckbox("Remove security mission cooldown", "hbo_agency_smcd", function(state)
                    SussySpt.addTask(function()
                        globals.set_int(294134, yu.shc(state, 0, 1200000))
                    end)
                end)

                ImGui.EndGroup()
                ImGui.EndTabItem()
            end
        end)
    end

    local function initOffice()
        local function getCrates(amount)
            if SussySpt.requireScript("gb_contraband_buy") then
                locals.set_int("gb_contraband_buy", 604, 1)
                locals.set_int("gb_contraband_buy", 600, amount)
                locals.set_int("gb_contraband_buy", 790, 6)
                locals.set_int("gb_contraband_buy", 791, 4)
            end
        end

        addToRender(9, function()
            if (ImGui.BeginTabItem("Office")) then
                yu.rendering.bigText("Warehouse")

                ImGui.Text("Get warehouse crate instantly:")
                for _, i in ipairs({1, 2, 3, 5, 10, 15, 20, 25, 30, 35}) do
                    ImGui.SameLine()
                    if ImGui.Button(tostring(i)) then
                        getCrates(i)
                    end
                end

                ImGui.EndTabItem()
            end
        end)
    end

    initCayo()
    initCasinoHeist()
    initCasino()
    initNightclub()
    initApartment()
    initAutoShop()
    initDrugWars()
    initAgency()
    initOffice()

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
end -- !SECTION

function SussySpt:initTabQA() -- SECTION SussySpt:initTabQA
    SussySpt.add_render(function()
        if yu.rendering.isCheckboxChecked("cat_qa") then
            if ImGui.Begin("Quick actions") then
                if ImGui.Button("Heal") then
                    SussySpt.addTask(function()
                        ENTITY.SET_ENTITY_HEALTH(yu.ppid(), PED.GET_PED_MAX_HEALTH(yu.ppid()), 0)
			            PED.SET_PED_ARMOUR(yu.ppid(), PLAYER.GET_PLAYER_MAX_ARMOUR(yu.pid()))
                    end)
                end
                yu.rendering.tooltip("Refill health & armor")

                ImGui.SameLine()

                if ImGui.Button("Refill health") then
                    SussySpt.addTask(function()
                        ENTITY.SET_ENTITY_HEALTH(yu.ppid(), PED.GET_PED_MAX_HEALTH(yu.ppid()), 0)
                    end)
                end
                yu.rendering.tooltip("Refill health")

                ImGui.SameLine()

                if ImGui.Button("Refill armor") then
                    SussySpt.addTask(function()
                        PED.SET_PED_ARMOUR(yu.ppid(), PLAYER.GET_PLAYER_MAX_ARMOUR(yu.pid()))
                    end)
                end
                yu.rendering.tooltip("Refill armor")

                ImGui.SameLine()

                if ImGui.Button("Clear wanted level") then
                    SussySpt.addTask(function()
                        PLAYER.CLEAR_PLAYER_WANTED_LEVEL(yu.pid())
                    end)
                end
                yu.rendering.tooltip("CLEAR_PLAYER_WANTED_LEVEL")

                if ImGui.Button("Refresh interior") then
                    SussySpt.addTask(function()
				        INTERIOR.REFRESH_INTERIOR(INTERIOR.GET_INTERIOR_FROM_ENTITY(yu.ppid()))
                    end)
                end
                yu.rendering.tooltip("Refreshes the interior you are currently in.\nGood for when interior is invisible or not rendering correctly.\nMay not always work.")

                ImGui.SameLine()

                if ImGui.Button("Skip cutscene") then
                    SussySpt.addTask(function()
                        CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
                        if NETWORK.NETWORK_IS_IN_MP_CUTSCENE() then
                            NETWORK.NETWORK_SET_IN_MP_CUTSCENE(false, true)
                        end
                    end)
                end
                yu.rendering.tooltip("There are some unskippable cutscenes where this doesn't work.")

                ImGui.SameLine()

                if ImGui.Button("Remove blackscreen") then
                    SussySpt.addTask(function()
                        CAM.DO_SCREEN_FADE_IN(0)
                    end)
                end
                yu.rendering.tooltip("Remove the blackscreen :D")

                if ImGui.Button("Repair vehicle") then
                    SussySpt.addTask(function()
                        local veh = yu.veh()
                        if veh ~= nil and entities.take_control_of(veh) then
                            VEHICLE.SET_VEHICLE_FIXED(veh)
                            VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, .0)
                        end
                    end)
                end
                yu.rendering.tooltip("Repairs the vehicle.\nUse with caution because this closes doors and stuff.")

                ImGui.SameLine()

                if ImGui.Button("Clear ped tasks") then
                    SussySpt.addTask(function()
                        TASK.CLEAR_PED_TASKS_IMMEDIATELY(yu.ppid())
                    end)
                end
                yu.rendering.tooltip("Makes the player stop what it's doing")

                ImGui.SameLine()

                if ImGui.Button("RI2") then
                    SussySpt.addTask(function()
				        local c = ENTITY.GET_ENTITY_COORDS(yu.ppid())
                        PED.SET_PED_COORDS_KEEP_VEHICLE(yu.ppid(), c.x, c.y, c.z - 1)
                    end)
                end
                yu.rendering.tooltip("Other way of refreshing the interior")

                ImGui.SameLine()

                if ImGui.Button("Stop conversation") then
                    SussySpt.addTask(function()
                        AUDIO.STOP_SCRIPTED_CONVERSATION(false)
                    end)
                end
                yu.rendering.tooltip("Tries to stop the blah blah from npcs")

                if ImGui.Button("Stop player switch") then
                    SussySpt.addTask(function()
                        if STREAMING.IS_PLAYER_SWITCH_IN_PROGRESS() then
                            STREAMING.STOP_PLAYER_SWITCH()
                            if CAM.IS_SCREEN_FADED_OUT() then
                                CAM.DO_SCREEN_FADE_IN(0)
                            end
                            HUD.CLEAR_HELP(true)
                            HUD.SET_FRONTEND_ACTIVE(true)
                            SCRIPT.SHUTDOWN_LOADING_SCREEN()
                            GRAPHICS.ANIMPOSTFX_STOP_ALL()
                        end
                    end)
                end
                yu.rendering.tooltip("Tries to make you able to interact with your surroundings")

                if SussySpt.in_online then
                    ImGui.SameLine()

                    if ImGui.Button("Instant BST") then
                        globals.set_int(2672524 + 3690, 1)
                    end
                    yu.rendering.tooltip("Give bullshark testosterone.\nYou will receive less damage and do more damage.")

                    ImGui.SameLine()

                    if ImGui.Button("Deposit wallet") then
                        SussySpt.addTask(function()
                            local ch = yu.playerindex()
                            local amount = MONEY.NETWORK_GET_VC_WALLET_BALANCE(ch)
                            if amount > 0 then
                                NETSHOPPING.NET_GAMESERVER_TRANSFER_WALLET_TO_BANK(
                                    ch,
                                    amount
                                )
                            end
                        end)
                    end
                    yu.rendering.tooltip("Puts all your money in the bank")
                end
            end
            ImGui.End()
        end
    end)
end -- !SECTION

function SussySpt:initTabHeist() -- SECTION SussySpt:initTabHeist
    local tab = SussySpt.tab:add_tab(" Heists & Stuff idk")
    tab:clear()

    local function initTabDDay()
        local ddayTab = tab:add_tab("  Doomsday", "heists")
        ddayTab:clear()

        local function initTabPreps()
            local prepsTab = ddayTab:add_tab("   Preps", "dday")
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
            for k, v in pairs({"Data Breaches","Bogdan Problem","Doomsday Scenario"}) do
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

    initTabDDay()
end -- !SECTION

SussySpt:init()

-- ANCHOR EOF
