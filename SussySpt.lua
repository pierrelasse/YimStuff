--[[ SussySpt ]]
SussySpt = { -- ANCHOR SussySpt
    version = "1.3.17",
    versionid = 3211,
    versiontype = 0--[[VERSIONTYPE]],
    build = 0--[[BUILD]],
    needInit = true
}

function SussySpt:init() -- SECTION SussySpt:init
    if SussySpt.needInit ~= true then
        SussySpt.debug("SussySpt:init() was called after initialization")
        return
    else
        SussySpt.needInit = nil
    end

    do -- SECTION Load yimutils
        local function load()
            yu = require("yimutils")
        end

        local success, result = pcall(load)
        local err
        if not success then
            err = result
        elseif yu == nil then
            err = "The returned value was nil"
        elseif type(yu) ~= "table" then
            err = "The returned value was not a table but from type "..type(yu)
        end
        if err ~= nil then
            log.warning("Error: Could not load yimutils: "..err)
            return
        end
    end -- !SECTION

    if not yu.is_num_between(SussySpt.versiontype, 1, 2) then
        log.warning("Fatal: Could not start due to an invalid version type. Are you using a source file?")
        return
    end

    do -- SECTION Debug
        SussySpt.debugtext = ""

        SussySpt.debug = function(s)
            if type(s) == "string" then
                SussySpt.debugtext = SussySpt.debugtext..(SussySpt.debugtext == "" and "" or "\n")..s
                if yu.rendering.isCheckboxChecked("debug_console") then
                    log.debug(s)
                end
            end
        end

        SussySpt.debug("Initialized debug logger")
    end -- !SECTION

    do -- SECTION Config
        if io == nil or io.open == nil then
            log.warning("Error: Could not access io.open")
            return
        end

        SussySpt.debug("Loading config system")

        SussySpt.cfg = {
            file = "sussyspt",
            changed = false,
            lastAutosave = os.time()
        }

        SussySpt.cfg.has = function(path) -- ANCHOR has
            return SussySpt.cfg.data ~= nil and SussySpt.cfg.data[path] ~= nil
        end

        SussySpt.cfg.get = function(path, default) -- ANCHOR get
            if SussySpt.cfg.data == nil then error("No config data is present") end
            local v = SussySpt.cfg.data[path]
            if v == nil then return default end
            return v
        end

        SussySpt.cfg.set = function(path, value, setchanged) -- ANCHOR set
            if SussySpt.cfg.data == nil then return value end

            if SussySpt.cfg.data[path] ~= value then
                SussySpt.cfg.data[path] = value
                SussySpt.cfg.changed = setchanged ~= false
            end

            return value
        end

        SussySpt.cfg.save = function() -- ANCHOR save
            SussySpt.cfg.changed = false

            local content = yu.json.encode(SussySpt.cfg.data)
            if type(content) ~= "string" then
                log.warning("Could not encode config")
                return false
            end

            local f = io.open("sussyspt", "w")
            if f then
                f:write(content)
                f:flush()
                f:close()
                return true
            else
                log.warning("Failed to open config file")
                return false
            end
        end

        SussySpt.cfg.autosave = function() -- ANCHOR autosave
            if not SussySpt.cfg.changed or SussySpt.cfg.data == nil then
                return
            end

            local time = os.time()
            if time - SussySpt.cfg.lastAutosave <= 2 then
                return
            end
            SussySpt.cfg.lastAutosave = time

            if SussySpt.cfg.save() then
                SussySpt.debug("Config automaticly saved")
            else
                log.warning("Failed to autosave the config")
            end
        end

        local f = io.open("sussyspt", "r")
        if f ~= nil then
            local content = f:read("*all")
            if type(content) == "string" and (content:startswith("{") or content:startswith("[")) then
                SussySpt.cfg.data = yu.json.decode(content)
                SussySpt.debug("Config loaded")
            else
                log.warning("Unable to load config")
            end
        else
            log.info("You can ignore the warning above")
            SussySpt.cfg.data = {}
            SussySpt.cfg.save()
        end
    end -- !SECTION

    yu.rendering.setCheckboxChecked("debug_console", SussySpt.cfg.get("debug_console", false))

    SussySpt.dev = SussySpt.versiontype == 2
    SussySpt.getDev = function()
        return SussySpt.dev
    end

    SussySpt.debug("Loading SussySpt v"..SussySpt.version.." ["..SussySpt.versionid.."] build "..SussySpt.build)

    yu.set_notification_title_prefix("[SussySpt] ")

    SussySpt.tab = gui.get_tab("SussySpt")

    SussySpt.in_online = false

    SussySpt.p = { -- SECTION p
        g = { -- ANCHOR Globals
            fm = 262145, -- freemode

            agency_payout = 32466, -- CLO_FXM_L_1_0
            agency_instantfinish1 = 38397,
            agency_instantfinish2 = 39772,
            agency_cooldown = 32500, -- CLO_FXM_L_3_5

            autoshop_payout1 = 31602,
            autoshop_payout2 = 31610,

            autoshop_instantfinish1 = 48513 + 1,
            autoshop_instantfinish2 = 48513 + 1378 + 1,
            apartment_cuts_other = 1928233 + 1,
            apartment_cuts_self = 1930201 + 3008 + 1,
            apartment_replay = 2635522, -- HEIST_REPLAY_FIN

            bullshark_stage = 2672741 + 3694
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
                54  -- GGSM_SPRITE_POWER_UP_STUN
            }
        },
        t = { -- ANCHOR Tunables
            salvageyard_week = 488207018
        },

        bounty_self_time = 1 + 2359296 + 5150 + 13,

        agency_maxpayout = 262145 + 32466
    } -- !SECTION

    do -- SECTION Rendering
        SussySpt.rendering = {
            tabs = {}
        }

        SussySpt.rendering.themes = { -- SECTION Standard themes
            Nightly = { -- ANCHOR Nightly
                ImGuiCol = {
                    TitleBg         = {9, 27, 46, 255},
                    TitleBgActive   = {9, 27, 46, 255},
                    WindowBg        = {0, 19, 37, 242},
                    Tab             = {10, 30, 46, 255},
                    TabActive       = {14, 60, 90, 255},
                    TabHovered      = {52, 64, 71, 255},
                    Button          = {3, 45, 79, 255},
                    FrameBg         = {35, 38, 53, 255},
                    FrameBgHovered  = {37, 40, 55, 255},
                    FrameBgActive   = {37, 40, 55, 255},
                    HeaderActive    = {54, 55, 66, 255},
                    HeaderHovered   = {62, 63, 73, 255}
                },
                ImGuiStyleVar = {
                    WindowRounding  = {4},
                    FrameRounding   = {2}
                }
            },
            Dark = { -- ANCHOR Dark
                ImGuiCol = {
                    TitleBg         = {18, 18, 18, 247},
                    TitleBgActive   = {21, 21, 22, 247},
                    WindowBg        = {18, 18, 18, 247},
                    Tab             = {42, 42, 42, 204},
                    TabActive       = {134, 134, 134, 255},
                    TabHovered      = {147, 147, 147, 255},
                    Button          = {42, 42, 42, 204},
                    FrameBg         = {32, 32, 32, 255},
                    FrameBgHovered  = {34, 34, 34, 255},
                    FrameBgActive   = {34, 34, 34, 255}
                },
                ImGuiStyleVar = {
                    WindowRounding  = {8},
                    FrameRounding   = {5}
                }
            },
            Purple = { -- ANCHOR Purple
                ImGuiCol = {
                    TitleBg         = {11, 5, 37, 191},
                    TitleBgActive   = {21, 8, 47, 206},
                    WindowBg        = {21, 8, 47, 209},
                    Tab             = {41, 25, 80, 127},
                    TabActive       = {55, 29, 124, 127},
                    TabHovered      = {51, 35, 90, 128},
                    Button          = {94, 57, 186, 76},
                    FrameBg         = {41, 25, 80, 171},
                    FrameBgHovered  = {41, 35, 90, 171},
                    FrameBgActive   = {41, 35, 90, 171}
                },
                ImGuiStyleVar = {
                    WindowRounding  = {16},
                    FrameRounding   = {3}
                }
            },
            Fatality = { -- ANCHOR Fatality
                ImGuiCol = {
                    TitleBg         = {9, 6, 20, 191},
                    TitleBgActive   = {9, 6, 20, 217},
                    WindowBg        = {19, 13, 43, 222},
                    Tab             = {239, 7, 73, 127},
                    TabActive       = {255, 59, 115, 127},
                    TabHovered      = {255, 59, 115, 128},
                    Button          = {239, 7, 73, 76},
                    FrameBg         = {26, 29, 48, 171},
                    FrameBgHovered  = {16, 22, 48, 171},
                    FrameBgActive   = {13, 15, 48, 171},
                    Border          = {32, 20, 60, 193}
                },
                ImGuiStyleVar = {
                    WindowRounding  = {5},
                    FrameRounding   = {2.5}
                }
            },
            FatalityBorderTest = { -- ANCHOR FatalityBorderTest
                parent = "Fatality",
                ImGuiCol = {
                    BorderShadow    = {0, 0, 0, 0}
                },
                ImGuiStyleVar = {
                    FrameBorderSize = {4.05}
                }
            }
        } -- !SECTION
        for k, v in pairs(SussySpt.rendering.themes) do
            if v.ImGuiCol then
                for k, v2 in pairs(v.ImGuiCol) do
                    for k3, v3 in pairs(v2) do
                        v2[k3] = v3 / 255
                    end
                end
            end
        end

        SussySpt.rendering.theme = SussySpt.cfg.get("theme", "Fatality")
        if SussySpt.rendering.themes[SussySpt.rendering.theme] == nil then
            SussySpt.debug("Theme "..SussySpt.rendering.theme.." does not exist. Selecting a different one")
            SussySpt.rendering.theme = next(SussySpt.rendering.themes)
        end

        SussySpt.debug("Using theme '"..SussySpt.rendering.theme.."'")

        SussySpt.rendering.getTheme = function()
            return SussySpt.rendering.themes[SussySpt.rendering.theme] or {}
        end

        do -- ANCHOR Title
            local title = "SussySpt"
            if SussySpt.versiontype == 2 then
                title = title.." vD"..SussySpt.version
                title = title.."["..SussySpt.versionid.."]@"..SussySpt.build
            else
                title = title.." v"..SussySpt.version
            end
            SussySpt.rendering.title = title.."###sussyspt_mainwindow"
        end

        do -- ANCHOR Update
            SussySpt.update = {
                start = 60 * 60 * 24 * 7,
                max = 60 * 60 * 24 * 100
            }

            SussySpt.update.updateAgo = function()
                SussySpt.update.ago = (os.time() - SussySpt.build) - SussySpt.update.start
            end

            SussySpt.update.colors = function()
                if SussySpt.update.ago < 0 then
                    return 255, 255, 255
                end
                return 250, 250 * (1 - SussySpt.update.ago / SussySpt.update.max), 50
            end

            -- SussySpt.update.updateAgo()
        end

        SussySpt.rendering.newTab = function(name, render)
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
                if type(v.render) == "function" then
                    v.render()
                end
                if yu.len(v.sub) > 0 then
                    ImGui.BeginTabBar("##tabbar_"..v.id)
                    for k1, v1 in pairs(v.sub) do
                        renderTab(v1)
                    end
                    ImGui.EndTabBar()
                end
                ImGui.EndTabItem()
            end
        end

        SussySpt.render_pops = {}

        local function renderTabs()
            if ImGui.Begin(SussySpt.rendering.title) then
                if yu.rendering.isCheckboxChecked("dev_times") then
                    ImGui.Text("Times: "
                        .."render_time="..SussySpt.rendering.times.lastrendertime
                        .." highest_render_time="..SussySpt.rendering.times.highestrendertime
                    )
                    ImGui.Separator()
                end

                ImGui.BeginTabBar("##tabbar")
                for k, v in pairs(SussySpt.rendering.tabs) do
                    renderTab(v)
                end
                ImGui.EndTabBar()
            end
            ImGui.End()
            return true
        end

        SussySpt.render = function() -- ANCHOR render
            if SussySpt.rendering.times == nil then
                SussySpt.rendering.times = {}
            end

            SussySpt.rendering.times.starttime = os.clock()

            -- if SussySpt.update.ago > 0 then
            --     SussySpt.update.updateAgo()
            --     local r, g, b = SussySpt.update.colors()
            --     yu.rendering.coloredtext("Your version is "..yu.format_seconds(SussySpt.update.ago).." old. Maybe try updating", r, g, b, 255)
            --     ImGui.Spacing()
            -- end

            for k, v in pairs(SussySpt.rendercb) do
                v()
            end

            SussySpt.qa.render()

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

            local success, result = pcall(renderTabs)
            if not success then
                local err = yu.removeErrorPath(result)
                ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
                ImGui.Text("[RENDER ERROR] Line: "..err[2].." Error: "..err[3])
                log.warning("Error while rendering (line "..err[2].."): "..err[3])
                ImGui.PopStyleColor()
            end

            for k, v in pairs(SussySpt.render_pops) do
                ImGui[k](v)
            end

            do
                ImGui.Text("Categories")

                if SussySpt.in_online then
                    ImGui.PushStyleColor(ImGuiCol.Text, 1, .3, .3, 1)
                    SussySpt.cfg.set("cat_hbo", yu.rendering.renderCheckbox("HBO", "cat_hbo"))
                    yu.rendering.tooltip("Most of the things wont work due to the latest gta update.\nUse with caution")
                    ImGui.PopStyleColor()
                end
                SussySpt.cfg.set("cat_qa", yu.rendering.renderCheckbox("Quick actions", "cat_qa"))
            end

            SussySpt.rendering.times.lastrendertime = os.clock() - SussySpt.rendering.times.starttime
            if SussySpt.rendering.times.lastrendertime > (SussySpt.rendering.times.highestrendertime or 0) then
                SussySpt.rendering.times.highestrendertime = SussySpt.rendering.times.lastrendertime
            end
        end
    end -- !SECTION

    do -- SECTION Tasks
        SussySpt.tasks = {}
        SussySpt.addTask = function(cb)
            local id = #SussySpt.tasks + 1
            SussySpt.tasks[id] = cb
            return id
        end
    end -- !SECTION

    do -- SECTION Disable controls
        SussySpt.disableControls = 0
        SussySpt.pushDisableControls = function(a)
            if a ~= false then
                SussySpt.disableControls = 4
            end
        end
    end -- !SECTION

    SussySpt.mainLoop = function(rs) -- ANCHOR mainLoop
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
                local success, result = pcall(v, rs)
                if not success then
                    log.warning("Error while executing task #'"..k.."': "..result)
                    yu.notify(3, "Error executing task. See console for more details")
                end
                SussySpt.tasks[k] = nil
            end

            SussySpt.cfg.autosave()
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

    do -- SECTION Chatlog
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

                -- SussySpt.cfg.set("chatlog_messages", SussySpt.chatlog.messages, false)

                if yu.rendering.isCheckboxChecked("online_chatlog_console") then
                    log.info("[CHAT] "..name..": "..chat_message)
                end

                SussySpt.chatlog.rebuildLog()
            end
        end)
    end -- !SECTION

    do -- SECTION Define tabs
        do -- SECTION Online
            local tab = SussySpt.rendering.newTab("Online")

            tab.should_display = function()
                return SussySpt.in_online or yu.len(SussySpt.players) >= 2
            end

            local function networkent(ent)
                if type(ent) == "number" and ent ~= 0 and ENTITY.DOES_ENTITY_EXIST(ent) then
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
                    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(id, true)
                    return obj
                end
            end

            local function triggerTransaction(rs, hash, amount)
                local b = 4537212
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
                        modder     = {209, 13, 13},
                        friend     = {103, 246, 92},
                        noped      = {87, 87, 87},
                        dead       = {81, 0, 8},
                        noblip     = {151, 151, 151},
                        ghost      = {201, 201, 201},
                        vehicle    = {201, 247, 255},
                        cutscene   = {83, 75, 115},
                        host       = {255, 181, 101},
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
                        ["metrotrain"] = "Metro",
                        ["tug"] = "Tug"
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
                    local lc = yu.coords(selfppid)

                    local hostIndex = NETWORK.NETWORK_GET_HOST_PLAYER_INDEX()
                    local hostName
                    local fmHostIndex = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("freemode", -1, 0)
                    local fmHostName

                    SussySpt.sortedPlayers = {}

                    for k, v in pairs(SussySpt.players) do
                        local startTime = yu.cputms()

                        table.insert(SussySpt.sortedPlayers, k)

                        if v.ped == selfppid then
                            v.isSelf = true
                        end

                        v.noped = type(v.ped) ~= "number" or v.ped == 0
                        v.tooltip = emptystr

                        v.info = {}

                        if not v.isSelf and NETWORK.NETWORK_IS_PLAYER_TALKING(v.player) then
                            v.info.talking = {
                                "T",
                                "The player is currently screaming or talking in the voicechat"
                            }
                        end

                        if not v.isSelf and network.is_player_friend(v.player) then
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

                        if not v.isSelf and NETWORK.IS_PLAYER_IN_CUTSCENE(v.player) then
                            v.info.cutscene = {
                                "Cs",
                                "A cutscene is currently playing"
                            }
                        end

                        if not v.noped then
                            v.c = yu.coords(v.ped)

                            local distance = MISC.GET_DISTANCE_BETWEEN_COORDS(lc.x, lc.y, lc.z, v.c.x, v.c.y, v.c.z, true)
                            local road = HUD.GET_STREET_NAME_FROM_HASH_KEY(PATHFIND.GET_STREET_NAME_AT_COORD(v.c.x, v.c.y, v.c.z, 0, 0))
                            v.speed = ENTITY.GET_ENTITY_SPEED(v.ped) * 3.6
                            v.wantedLevel = PLAYER.GET_PLAYER_WANTED_LEVEL(v.player)
                            v.blip = HUD.GET_BLIP_FROM_ENTITY(v.ped)

                            v.collisionDisabled = ENTITY.GET_ENTITY_COLLISION_DISABLED(v.ped)
                            v.visible = ENTITY.IS_ENTITY_VISIBLE(v.ped)

                            v.interior = INTERIOR.GET_INTERIOR_AT_COORDS(v.c.x, v.c.y, v.c.z)

                            v.health = ENTITY.GET_ENTITY_HEALTH(v.ped)
                            v.maxhealth = ENTITY.GET_ENTITY_MAX_HEALTH(v.ped)
                            v.armor = PED.GET_PED_ARMOUR(v.ped)

                            v.selectedWeapon = WEAPON.GET_SELECTED_PED_WEAPON(v.ped)
                            v.weapon = WEAPON.GET_WEAPONTYPE_MODEL(v.selectedWeapon)

                            local vehicle = yu.veh(v.ped)
                            if vehicle ~= nil or PED.IS_PED_IN_ANY_VEHICLE(v.ped, false) then
                                v.info.vehicle = {
                                    "V",
                                    "The player is in a vehicle"
                                }

                                local vehicleHash = ENTITY.GET_ENTITY_MODEL(vehicle)
                                if vehicleHash > 0 then
                                    local vehiclePassengers = VEHICLE.GET_VEHICLE_NUMBER_OF_PASSENGERS(vehicle, false, true)
                                    local vehicleMaxPassengers = VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle)

                                    v.info.vehicle[2] = v.info.vehicle[2].."."
                                        .." Type: "..vehicles.get_vehicle_display_name(vehicleHash)

                                    local vehicleClass = yu.cache.vehicle_classes[VEHICLE.GET_VEHICLE_CLASS(vehicle) + 1]
                                    if type(vehicleClass) == "string" then
                                        v.info.vehicle[2] = v.info.vehicle[2].." Class: "..vehicleClass
                                    end

                                    if vehiclePassengers ~= nil and vehicleMaxPassengers ~= nil then
                                        v.info.vehicle[2] = v.info.vehicle[2].." Passengers: "..(vehiclePassengers).."/"..(vehicleMaxPassengers)
                                    end
                                end
                            end

                            if not v.visible then
                                v.info.invisible = {
                                    "I",
                                    "Seems to be invisible"
                                }
                            end

                            if v.collisionDisabled == true and distance < 100 and vehicle == nil then
                                v.info.nocollision = {
                                    "C",
                                    "The player doesn't seem to have collision"
                                }
                            end

                            if not v.isSelf and v.blip == 0 then
                                v.info.noblip = {
                                    "B",
                                    "The player has no blip. In interior/not spawned yet?"
                                }
                            end

                            if ENTITY.IS_ENTITY_DEAD(v.ped, false) or PED.IS_PED_DEAD_OR_DYING(v.ped, true) then
                                v.info.dead = {
                                    "D",
                                    "Player seems to be dead"
                                }
                            end

                            if not v.isSelf and NETWORK.IS_ENTITY_A_GHOST(v.ped) or NETWORK.IS_ENTITY_IN_GHOST_COLLISION(v.ped) then
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

                            if v.weapon > 0 then
                                v.tooltip = v.tooltip.."\nHolding a weapon: "..weapons.get_weapon_display_name(v.selectedWeapon).." ["..v.weapon.."]"
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

                        if v.info.modder ~= nil then
                            local reasons = string.split(network.get_flagged_modder_reason(v.player), ", ")
                            if table.length(reasons) > 0 then
                                v.tooltip = v.tooltip.."\n\nInfractions:"

                                for k2, v2 in pairs(reasons) do
                                    v.tooltip = v.tooltip.."\n  - "..v2
                                end
                            end
                        end

                        v.tooltip = v.tooltip
                            .."\n\nFor nerds:"
                            .."\n  - Player: "..v.player

                        if not v.noped then
                            v.tooltip = v.tooltip.."\n  - Ped: "..v.ped

                            if v.blip ~= 0 then
                                v.tooltip = v.tooltip.."\n  - Blip sprite: "..HUD.GET_BLIP_SPRITE(v.blip)
                            end

                            if v.interior ~= 0 then
                                v.tooltip = v.tooltip.."\n  - The player might be in an interior. Id: "..v.interior
                            end
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

                    local c = yu.coords(ped)
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
                        local success, result = pcall(refreshPlayerlist)
                        if not success then
                            SussySpt.sortedPlayers = {}

                            local err = yu.removeErrorPath(result)
                            log.warning("Error while updating the playerlist(line "..err[2].."): "..err[3])
                        end

                        local isOpen = a.open > 0
                        rs:sleep(isOpen and 250 or 1500)
                        if isOpen then
                            a.open = a.open - 1
                        end
                    end
                end)

                yu.rendering.setCheckboxChecked("online_players_ram_delete")

                tab2.render = function() -- SECTION Render
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

                    do -- ANCHOR Playerlist
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

                                    if ImGui.Selectable(v.displayName, false) then
                                        a.selectedplayer = k
                                    end

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
                                    if ImGui.TreeNodeEx("General") then -- ANCHOR General
                                        if ImGui.SmallButton("Goto") then
                                            SussySpt.addTask(function()
                                                local c = yu.coords(player.ped)
                                                PED.SET_PED_COORDS_KEEP_VEHICLE(yu.ppid(), c.x, c.y, c.z - 1)
                                            end)
                                        end
                                        yu.rendering.tooltip("Teleport yourself to the player")

                                        ImGui.SameLine()

                                        if ImGui.SmallButton("Bring") then
                                            SussySpt.addTask(function()
                                                local c = yu.coords(yu.ppid())
                                                network.set_player_coords(player.player, c.x, c.y, c.z)
                                            end)
                                        end
                                        yu.rendering.tooltip("Bring the player to you")

                                        if player.info.vehicle ~= nil then
                                            ImGui.SameLine()

                                            if ImGui.SmallButton("Tp into vehicle") then
                                                yu.rif(function(rs)
                                                    local veh = yu.veh(player.ped)
                                                    if veh ~= nil then
                                                        local seatIndex = yu.get_free_vehicle_seat(veh)
                                                        if seatIndex ~= nil then
                                                            local c = yu.coords(veh)
                                                            local ped = yu.ppid()
                                                            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, c.x, c.y, c.z - 2, false, false, false)
                                                            rs:yield()
                                                            PED.SET_PED_INTO_VEHICLE(ped, veh, seatIndex)
                                                        end
                                                    end
                                                end)
                                            end
                                        end

                                        if ImGui.SmallButton("Set waypoint") then
                                            SussySpt.addTask(function()
                                                local c = yu.coords(player.ped)
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
                                                            NETWORK.NETWORK_SET_IN_SPECTATOR_MODE_EXTENDED(false, player.ped, true)
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

                                    if ImGui.TreeNodeEx("Trolling") then -- ANCHOR Trolling
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
                                                local c = yu.coords(player.ped)
                                                local veh = yu.create_vehicle(c.x, c.y, c.z, hash, ENTITY.GET_ENTITY_HEADING(player.ped), true)
                                                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
                                                if networkent(veh) then
                                                    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, 255, 0, 192)
                                                    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, 198, 0, 255)
                                                    ENTITY.SET_ENTITY_COLLISION(veh, false, true)
                                                    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(veh)
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
                                                local veh = yu.create_vehicle(c.x, c.y, c.z, hash, ENTITY.GET_ENTITY_HEADING(player.ped))
                                                networkent(veh)
                                                ENTITY.SET_ENTITY_VISIBLE(veh, true, false)
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

                                                local c = yu.coords(player.ped)
                                                c.z = c.z - 2.4

                                                local obj = OBJECT.CREATE_OBJECT(hash, c.x, c.y, c.z, true, true, false)
                                                ENTITY.SET_ENTITY_VISIBLE(obj, true, false)
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
                                                    ENTITY.SET_ENTITY_VISIBLE(objects[i], true, false)
                                                    ENTITY.SET_ENTITY_ALPHA(objects[i], 0, true)
                                                    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(objects[i])
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

                                                local c = yu.coords(player.ped)
                                                local distance = TASK.IS_PED_STILL(player.ped) and 0 or 2.5

                                                local vehicles = {}

                                                for i = 1, 1 do
                                                    local pos = (i == 1) and ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.ped, 0, distance, 2.8) or c
                                                    local heading = (i == 1) and ENTITY.GET_ENTITY_HEADING(player.ped) or 0
                                                    vehicles[i] = networkent(yu.create_vehicle(pos.x, pos.y, pos.z, hash, heading))
                                                end

                                                for k, v in pairs(vehicles) do
                                                    if k ~= 1 and v ~= nil then
                                                        ENTITY.ATTACH_ENTITY_TO_ENTITY(v, vehicles[1], 0, k == 4 and 0 or 3, k >= 3 and 0, 0, 0, 0, k == 2 and -180 or 0, false, false, true, false, 0, true, 1)
                                                    end
                                                    ENTITY.SET_ENTITY_VISIBLE(v, false, false)
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
                                                    local c = yu.coords(player.ped)
                                                    FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 72, 80, false, true, 0, false)
                                                end)
                                            end
                                            yu.rendering.tooltip("\"Random\" death")
                                            ImGui.SameLine()
                                            if ImGui.SmallButton("Normal") then
                                                SussySpt.addTask(function()
                                                    local c = yu.coords(player.ped)
                                                    FIRE.ADD_EXPLOSION(c.x + 1, c.y + 1, c.z + 1, 4, 100, true, false, 0, false)
                                                end)
                                            end
                                            ImGui.SameLine()
                                            if ImGui.SmallButton("Huge") then
                                                SussySpt.addTask(function()
                                                    local c = yu.coords(player.ped)
                                                    FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 82, 80, true, false, 1, false)
                                                end)
                                            end
                                            ImGui.SameLine()
                                            if ImGui.SmallButton("Car") then
                                                SussySpt.addTask(function()
                                                    local c = yu.coords(player.ped)
                                                    FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 7, 1, true, false, 0, false)
                                                end)
                                            end
                                        end

                                        if ImGui.TreeNodeEx("Trap") then
                                            if ImGui.SmallButton("Normal") then
                                                SussySpt.addTask(function()
                                                    local modelHash = joaat("prop_gold_cont_01b")
                                                    local c = yu.coords(player.ped)
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
                                                    local c = yu.coords(player.ped)
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
                                                        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(obj)
                                                    end

                                                    createObject(-1.70, -1.70, -90.0)
                                                    createObject(1.70, 1.70, 90.0)
                                                end)
                                            end

                                            ImGui.SameLine()

                                            if ImGui.SmallButton("Rub Cage") then
                                                SussySpt.addTask(function()
                                                    local hash = joaat("prop_rub_cage01a")
                                                    local c = yu.coords(player.ped)
                                                    for i = 0, 1 do
                                                        local obj = OBJECT.CREATE_OBJECT(hash, c.x, c.y, c.z - 1, true, true, false)
                                                        networkobj(obj)
                                                        ENTITY.SET_ENTITY_ROTATION(obj, 0, 0, yu.shc(i == 0, 0, 90), 2, true)
                                                        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                                        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(obj)
                                                    end
                                                end)
                                            end

                                            if ImGui.SmallButton("Race tube") then
                                                SussySpt.addTask(function()
                                                    local c = yu.coords(player.ped)
                                                    local obj = OBJECT.CREATE_OBJECT(joaat("stt_prop_stunt_tube_crn_5d"), c.x, c.y, c.z, true, true, false)
                                                    networkobj(obj)
                                                    ENTITY.SET_ENTITY_ROTATION(obj, 0, 90, 0, 2, true)
                                                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                                    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(obj)
                                                end)
                                            end
                                            ImGui.SameLine()
                                            if ImGui.SmallButton("Invisible race tube") then
                                                SussySpt.addTask(function()
                                                    local c = yu.coords(player.ped)
                                                    local obj = OBJECT.CREATE_OBJECT(joaat("stt_prop_stunt_tube_crn_5d"), c.x, c.y, c.z, true, true, false)
                                                    networkobj(obj)
                                                    ENTITY.SET_ENTITY_ROTATION(obj, 0, 90, 0, 2, true)
                                                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                                    ENTITY.SET_ENTITY_VISIBLE(obj, false, false)
                                                    ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(obj)
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
                                                        local veh = yu.create_vehicle(c.x, c.y, c.z - 1, hash, ENTITY.GET_ENTITY_HEADING(player.ped), true)
                                                        networkent(veh)
                                                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 1)
                                                        runscript:sleep(100)
                                                        for i = 0, 10 do
                                                            VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 50.0)
                                                            runscript:sleep(100)
                                                        end
                                                        if yu.rendering.isCheckboxChecked("online_players_ram_delete") then
                                                            VEHICLE.DELETE_VEHICLE(veh)
                                                        end
                                                    end
                                                end)
                                            end

                                            ImGui.SameLine()

                                            yu.rendering.renderCheckbox("Delete afterwards", "online_players_ram_delete")
                                        end

                                        if SussySpt.dev then -- Attach
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
                                                            ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, player.ped, 57597, 0, 0, 0, 0, 0, 0, false, false, false, false, 2, true, 1)
                                                            if yu.rendering.isCheckboxChecked("online_players_attach_invis") then
                                                                ENTITY.SET_ENTITY_VISIBLE(obj, false, false)
                                                                ENTITY.SET_ENTITY_ALPHA(obj, 0, true)
                                                            end
                                                            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(obj)
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

                                    if ImGui.TreeNodeEx("Weapons") then -- ANCHOR Weapons
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

                                    if player.info.vehicle ~= nil and ImGui.TreeNodeEx("Vehicle") then -- ANCHOR Vehicle
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

                                        yu.rendering.renderCheckbox("Invisibility", "online_player_vehicleinvis", function(state)
                                            SussySpt.addTask(function()
                                                local veh = yu.veh(player.ped)
                                                if veh ~= nil and entities.take_control_of(veh)  then
                                                    ENTITY.SET_ENTITY_VISIBLE(veh, not state, false)
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
                                                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, false, false)
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
                                        yu.rendering.tooltip("The player will automaticly turn on the engine again so it's kinda useless")

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
                                                    ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 0, 10000, 0, 0, 0, 0, false, true, true, false, true, true)
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

                                    if ImGui.TreeNodeEx("Online") then -- ANCHOR Online
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

                                        if not a.givepickupblocked then
                                            ImGui.SameLine()
                                            if ImGui.Button("Spawn") then
                                                a.givepickupblocked = true
                                                yu.rif(function(rs)
                                                    local value = a.pickupoptions[a.pickupoption]
                                                    if type(value) == "string" then
                                                        local modelHash = joaat(value)
                                                        if STREAMING.IS_MODEL_VALID(modelHash) then
                                                            STREAMING.REQUEST_MODEL(modelHash)
                                                            repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(modelHash)
                                                            local c = yu.coords(player.ped)
                                                            OBJECT.CREATE_AMBIENT_PICKUP(joaat("PICKUP_CUSTOM_SCRIPT"), c.x, c.y, c.z + 1.2, 0, 0, modelHash, true, false)
                                                            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
                                                        end
                                                    end
                                                    a.givepickupblocked = nil
                                                end)
                                            end
                                        end

                                        ImGui.SameLine()

                                        yu.rendering.renderCheckbox("Loop##pickup", "online_players_pickuploop", function(state)
                                            if state then
                                                yu.rif(function(rs)
                                                    local modelHash = joaat(a.pickupoptions[a.pickupoption])
                                                    if STREAMING.IS_MODEL_VALID(modelHash) then
                                                        STREAMING.REQUEST_MODEL(modelHash)
                                                        repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(modelHash)

                                                        while yu.rendering.isCheckboxChecked("online_players_pickuploop") do
                                                            local c = yu.coords(player.ped)
                                                            local pickup = OBJECT.CREATE_AMBIENT_PICKUP(joaat("PICKUP_CUSTOM_SCRIPT"), c.x, c.y, c.z + 1.2, 0, 0, modelHash, true, false)
                                                            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(pickup)
                                                            rs:sleep(100)
                                                        end

                                                        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
                                                    end
                                                end)
                                            end
                                        end)

                                        ImGui.TreePop()
                                    end

                                    if SussySpt.dev and ImGui.TreeNodeEx("Test") then -- ANCHOR Test
                                        if ImGui.SmallButton("Set killer") then
                                            a.killer = key
                                        end

                                        if ImGui.SmallButton("Owned explosion") then
                                            SussySpt.addTask(function()
                                                local c = yu.coords(player.ped)
                                                local killer = SussySpt.players[a.killer]
                                                if killer ~= nil then
                                                    FIRE.ADD_OWNED_EXPLOSION(killer.ped, c.x, c.y, c.z, 6, 1, true, false, 0)
                                                end
                                            end)
                                        end

                                        if ImGui.SmallButton("Explode veh") then
                                            yu.rif(function(rs)
                                                local c = yu.coords(player.ped)

                                                local hash = joaat("adder")
                                                STREAMING.REQUEST_MODEL(hash)
                                                repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(hash)

                                                local veh = yu.create_vehicle(c.x, c.y, c.z + 1.5, hash, 0, true)
                                                ENTITY.FREEZE_ENTITY_POSITION(veh, true)
                                                ENTITY.SET_ENTITY_COLLISION(veh, false, false)
                                                ENTITY.SET_ENTITY_ALPHA(veh, 0, true)
                                                ENTITY.SET_ENTITY_VISIBLE(veh, false, false)

                                                rs:sleep(5)

                                                local killer = SussySpt.players[a.killer]
                                                if killer ~= nil then
                                                    NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, killer.player)
                                                end

                                                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
                                            end)
                                        end

                                        if ImGui.SmallButton("Xmas truck") then
                                            SussySpt.addTask(function()
                                                -- local pickupHash = func_5947(iParam0)
                                                -- local x, y, z = Var0
                                                -- local placeOnGround = true --!func_5946(iParam0, 0)
                                                -- local modelHash = Local_228.f_19.f_5[iParam0 /*13*/].f_2
                                                -- OBJECT.CREATE_PORTABLE_PICKUP(pickupHash, x, y, z, placeOnGround, modelHash)
                                                for i = 0, 10 do
                                                    log.info(tostring(locals.get_int("fm_content_xmas_truck", 228 + 19 + 5 + i + 13 + 2)))
                                                end
                                            end)
                                        end

                                        if (true or not v.isSelf) and ImGui.SmallButton("Gift vehicle") then
                                            SussySpt.addTask(function()
                                                local veh = yu.veh()
                                                if veh == nil then
                                                    yu.notify(3, "You need to be in a vehicle", "Gift vehicle")
                                                    return
                                                end

                                                -- if DECORATOR.DECOR_IS_REGISTERED_AS_TYPE("Player_Vehicle", 3) then
                                                --     if not DECORATOR.DECOR_EXIST_ON(veh, "Player_Vehicle") then
                                                --         local nwhash = NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(yu.pid())
                                                --         log.info("NWHASH: "..tostring(nwhash))
                                                --         local hash = DECORATOR.DECOR_SET_INT(veh, "Player_Vehicle", nwhash)
                                                --         log.info("HASH: "..tostring(hash))
                                                --     end
                                                -- end

                                                local nwhash = NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(PLAYER.PLAYER_ID())
                                                log.info("NWHASH: "..tostring(nwhash))

                                                local function printDecor(decor, a)
                                                    log.info("[GIFT VEHICLE] DECOR: "..decor.."="..DECORATOR.DECOR_GET_INT(veh, decor))
                                                end

                                                printDecor("Player_Vehicle", nwhash)
                                                printDecor("Previous_Owner")
                                                printDecor("PV_Slot")
                                                printDecor("Veh_Modded_By_Player")
                                                printDecor("Not_Allow_As_Saved_Veh")
                                                log.info("[GIFT VEHICLE] DECOR: ".."IgnoredByQuickSave".."="..tostring(DECORATOR.DECOR_GET_BOOL(veh, "IgnoredByQuickSave")))
                                                printDecor("MPBitset")

                                                DECORATOR.DECOR_SET_INT(veh, "Player_Vehicle", -251500684)
                                                DECORATOR.DECOR_SET_INT(veh, "Previous_Owner", -251500684)
                                                DECORATOR.DECOR_SET_INT(veh, "PV_Slot", 47)
                                                DECORATOR.DECOR_SET_INT(veh, "Veh_Modded_By_Player", 0)
                                                DECORATOR.DECOR_SET_INT(veh, "Not_Allow_As_Saved_Veh", 0)
                                                DECORATOR.DECOR_SET_BOOL(veh, "IgnoredByQuickSave", false)
                                                DECORATOR.DECOR_SET_INT(veh, "MPBitset", 16777224)
                                            end)
                                        end

                                        if ImGui.SmallButton("Gooch present thing") then
                                            SussySpt.addTask(function()
                                                local modelHash = joaat("xm3_prop_xm3_present_01a")

                                                STREAMING.REQUEST_MODEL(modelHash)
                                                if (STREAMING.HAS_MODEL_LOADED(modelHash)) then
                                                    local c = yu.coords(player.ped, true)

                                                    local pickup = OBJECT.CREATE_AMBIENT_PICKUP(joaat("PICKUP_PORTABLE_FM_CONTENT_MISSION_ENTITY_SMALL"), c.x, c.y, c.z, 0, 0, modelHash, true, false);
                                                    OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(pickup)
                                                    ENTITY.SET_ENTITY_LOD_DIST(pickup, 1200)
                                                    ENTITY.SET_ENTITY_HEALTH(pickup, 50, 0, 0)
                                                    ENTITY.SET_ENTITY_INVINCIBLE(pickup, true)
                                                    ENTITY.SET_ENTITY_PROOFS(pickup, true, true, false, true, true, true, true, false)
                                                    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(pickup, true, 1)
                                                    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(pickup, true)
                                                    OBJECT.SET_OBJECT_FORCE_VEHICLES_TO_AVOID(pickup, true)
                                                    PHYSICS.ACTIVATE_PHYSICS(pickup)
                                                    OBJECT.SET_ACTIVATE_OBJECT_PHYSICS_AS_SOON_AS_IT_IS_UNFROZEN(pickup, true)
                                                    ENTITY.SET_ENTITY_DYNAMIC(pickup, true)
                                                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(joaat("xm3_prop_xm3_present_01a"))
                                                end
                                            end)
                                        end
                                    end
                                end

                                ImGui.EndListBox()
                            end

                            ImGui.EndGroup()
                        end
                    end
                end -- !SECTION

                tab.sub[1] = tab2
            end -- !SECTION

            do -- SECTION Thing
                local tab2 = SussySpt.rendering.newTab("Thing")

                local function addUnknownValue(tbl, v)
                    if tbl[v] == nil then
                        tbl[v] = "??? ["..(v or "<null>").."]"
                    end
                end

                do -- SECTION Apartment
                    local tab3 = SussySpt.rendering.newTab("Apartment")

                    local a = {
                        cuts15m = {
                            heists = {
                                ["The Freeca Job"] = 7453,
                                ["The Prison Break"] = 2142,
                                ["The Humane Labs Raid"] = 1587,
                                ["The Pacific Standard Job"] = 1000,
                                ["Series A Funding"] = 2121
                            },
                            set = {
                                crew = function(v)
                                    globals.set_int(SussySpt.p.g.apartment_cuts_other + 1, 100 - (v * 4))
                                    globals.set_int(SussySpt.p.g.apartment_cuts_other + 2, v)
                                    globals.set_int(SussySpt.p.g.apartment_cuts_other + 3, v)
                                    globals.set_int(SussySpt.p.g.apartment_cuts_other + 4, v)
                                end,
                                self = function(v)
                                    globals.set_int(SussySpt.p.g.apartment_cuts_self, v)
                                end
                            }
                        }
                    }

                    do -- ANCHOR Preperations
                        local tab4 = SussySpt.rendering.newTab("Preperations")

                        tab4.render = function()
                            if ImGui.Button("Complete preps") then
                                SussySpt.addTask(function()
                                    stats.set_int(yu.mpx("HEIST_PLANNING_STAGE"), -1)
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.Button("Reset preps") then
                                SussySpt.addTask(function()
                                    stats.set_int(yu.mpx("HEIST_PLANNING_STAGE"), 0)
                                end)
                            end
                        end

                        tab3.sub[1] = tab4
                    end

                    do -- ANCHOR Extra
                        local tab4 = SussySpt.rendering.newTab("Extra")

                        tab4.render = function()
                            if ImGui.Button("Unlock replay screen") then
                                SussySpt.addTask(function()
                                    globals.set_int(SussySpt.p.g.apartment_replay, 27)
                                end)
                            end
                            yu.rendering.tooltip("This allows you to play any heist you want and unlocks heist cancellation from Lester")

                            if ImGui.Button("Instant finish (solo)") then
                                SussySpt.addTask(function()
                                    local script = "fm_mission_controller"
                                    if SussySpt.requireScript(script) then
                                        locals.set_int(script, SussySpt.p.l.apartment_instantfinish1, 12)
                                        locals.set_int(script, SussySpt.p.l.apartment_instantfinish2, 99999)
                                        locals.set_int(script, SussySpt.p.l.apartment_instantfinish3, 99999)
                                    end
                                end)
                            end

                            ImGui.Spacing()

                            ImGui.Text("Fleeca")

                            ImGui.SameLine()

                            if ImGui.Button("Skip hack##fleeca") then
                                SussySpt.addTask(function()
                                    if SussySpt.requireScript("fm_mission_controller") then
                                        locals.set_int("fm_mission_controller", SussySpt.p.l.apartment_fleeca_hackstage, 7)
                                    end
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.Button("Skip drill##fleeca") then
                                SussySpt.addTask(function()
                                    if SussySpt.requireScript("fm_mission_controller") then
                                        locals.set_float("fm_mission_controller", SussySpt.p.l.apartment_fleeca_drillstage, 100)
                                    end
                                end)
                            end
                        end

                        tab3.sub[2] = tab4
                    end

                    do -- ANCHOR Cuts
                        local tab4 = SussySpt.rendering.newTab("Cuts")

                        tab4.render = function()
                            ImGui.Text("$15m cuts")
                            ImGui.Text(" > Currently under development. Tutorial coming soon maybe")
                            ImGui.Text(" > Fleeca currently works the best")
                            ImGui.Spacing()

                            if a.cuts15mactive ~= true then
                                for k, v in pairs(a.cuts15m.heists) do
                                    if ImGui.Button(k) then
                                        a.cuts15mactive = true
                                        yu.rif(function(rs)
                                            a.cuts15m.set.crew(v)

                                            a.cuts15m.set.self(v)

                                            a.cuts15mactive = nil
                                        end)
                                    end
                                end
                            else
                                ImGui.Text("Applying. Please wait")
                            end
                        end

                        tab3.sub[3] = tab4
                    end

                    tab2.sub[1] = tab3
                end -- !SECTION

                do -- SECTION Agency
                    local tab3 = SussySpt.rendering.newTab("Agency")

                    do -- ANCHOR Preperations
                        local tab4 = SussySpt.rendering.newTab("Preperations")

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

                        local function refresh()
                            local mpx = yu.mpx()

                            a.vipcontract = stats.get_int(mpx.."FIXER_STORY_BS")
                        end
                        SussySpt.addTask(refresh)

                        tab4.render = function()
                            if ImGui.SmallButton("Refresh") then
                                SussySpt.addTask(refresh)
                            end

                            ImGui.Separator()

                            local re = yu.rendering.renderList(a.vipcontracts, a.vipcontract, "vipcontract", "The Dr. Dre VIP Contract", a.vipcontractssort)
                            if re.changed then
                                a.vipcontract = re.key
                                a.vipcontractchanged = true
                            end

                            ImGui.Spacing()

                            if ImGui.Button("Apply##stats") then
                                SussySpt.addTask(function()
                                    local changes = 0

                                    -- The Dr. Dre VIP Contract
                                    if a.vipcontractchanged then
                                        changes = changes + 1

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

                            if ImGui.Button("Complete preps") then
                                SussySpt.addTask(function()
                                    for k, v in pairs({"FIXER_GENERAL_BS","FIXER_COMPLETED_BS","FIXER_STORY_BS","FIXER_STORY_COOLDOWN"}) do
                                        stats.set_int(yu.mpx(v), -1)
                                    end
                                end)
                            end
                        end

                        tab3.sub[1] = tab4
                    end

                    do -- ANCHOR Extra
                        local tab4 = SussySpt.rendering.newTab("Extra")

                        tab4.render = function()
                            if ImGui.Button("Instant finish (solo)") then
                                SussySpt.addTask(function()
                                    locals.set_int("fm_mission_controller_2020", SussySpt.p.g.agency_instantfinish1, 51338752)
                                    locals.set_int("fm_mission_controller_2020", SussySpt.p.g.agency_instantfinish2, 50)
                                end)
                            end

                            ImGui.Spacing()

                            if ImGui.Button("Remove cooldown") then
                                SussySpt.addTask(function()
                                    globals.set_int(SussySpt.p.g.fm + SussySpt.p.g.agency_cooldown, 0)
                                end)
                            end

                            ImGui.Spacing()

                            yu.rendering.renderCheckbox("$2m finale", "online_thing_agency_2mfinale", function(state)
                                yu.rif(function(rs)
                                    local p = SussySpt.p.g.fm + SussySpt.p.g.agency_payout
                                    if state then
                                        while yu.rendering.isCheckboxChecked("online_thing_agency_2mfinale") do
                                            if SussySpt.in_online then
                                                globals.set_int(p, 2500000)
                                            end
                                            rs:sleep(10)
                                        end
                                    else
                                        globals.set_int(p, 1000000)
                                    end
                                end)
                            end)
                        end

                        tab3.sub[2] = tab4
                    end

                    tab2.sub[2] = tab3
                end -- !SECTION

                do -- SECTION Auto Shop
                    local tab3 = SussySpt.rendering.newTab("Auto Shop")

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
                        },
                        cooldowns = {}
                    }

                    do -- ANCHOR Preperations
                        local tab4 = SussySpt.rendering.newTab("Preperations")

                        local function refresh()
                            local mpx = yu.mpx()

                            a.heist = stats.get_int(mpx.."TUNER_CURRENT")
                            addUnknownValue(a.heists, a.heist)
                        end
                        SussySpt.addTask(refresh)

                        tab4.render = function()
                            if ImGui.SmallButton("Refresh") then
                                SussySpt.addTask(refresh)
                            end

                            ImGui.Separator()

                            ImGui.PushItemWidth(360)
                            local re = yu.rendering.renderList(a.heists, a.heist, "heist", "Heist")
                            if re.changed then
                                a.heist = re.key
                                a.heistchanged = true
                            end
                            ImGui.PopItemWidth()

                            ImGui.Spacing()

                            if ImGui.Button("Apply##stats") then
                                SussySpt.addTask(function()
                                    local changes = 0
                                    local mpx = yu.mpx()

                                    -- Heist
                                    if a.heistchanged then
                                        changes = changes + 1
                                        stats.set_int(mpx.."TUNER_GEN_BS", yu.shc(a.heist == 1, 4351, 12543))
                                        stats.set_int(mpx.."TUNER_CURRENT", a.heist)
                                    end

                                    yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied")
                                    for k, v in pairs(a) do
                                        if tostring(k):endswith("changed") then
                                            a[k] = nil
                                        end
                                    end
                                end)
                            end

                            ImGui.SameLine()

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
                                    local mpx = yu.mpx()
                                    stats.set_int(mpx.."TUNER_GEN_BS", 8371)
                                    stats.set_int(mpx.."TUNER_CURRENT", -1)
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
                                        locals.set_int("fm_mission_controller_2020", SussySpt.p.g.autoshop_instantfinish1, 51338977)
                                        locals.set_int("fm_mission_controller_2020", SussySpt.p.g.autoshop_instantfinish2, 101)
                                    end
                                end)
                            end
                        end

                        tab3.sub[1] = tab4
                    end

                    do -- ANCHOR Cooldowns
                        local tab4 = SussySpt.rendering.newTab("Cooldowns")

                        local function refreshCooldown(mpx, i)
                            local cooldown = math.max(0,
                                stats.get_int(mpx.."TUNER_CONTRACT"..i.."_POSIX") - os.time())

                            a.cooldowns[i] = {
                                a.heists[i],
                                yu.format_seconds(cooldown)
                            }
                        end

                        local function refresh()
                            local mpx = yu.mpx()
                            for i = 0, 7 do
                                refreshCooldown(mpx, i)
                            end
                        end
                        SussySpt.addTask(refresh)

                        tab4.render = function()
                            if ImGui.SmallButton("Refresh") then
                                SussySpt.addTask(refresh)
                            end

                            ImGui.Separator()

                            if ImGui.BeginTable("cooldowns", 3, 3905) then
                                ImGui.TableSetupColumn("Contract")
                                ImGui.TableSetupColumn("Cooldown")
                                ImGui.TableSetupColumn("Actions")
                                ImGui.TableHeadersRow()

                                local row = 0
                                for k, v in pairs(a.cooldowns) do
                                    ImGui.TableNextRow()

                                    ImGui.PushID(row)

                                    ImGui.TableSetColumnIndex(0)
                                    ImGui.Text(v[1])

                                    ImGui.TableSetColumnIndex(1)
                                    ImGui.Text(v[2])

                                    ImGui.TableSetColumnIndex(2)
                                    if ImGui.Button("Clear##row_"..row) then
                                        SussySpt.addTask(function()
                                            stats.set_int(yu.mpx("TUNER_CONTRACT"..k.."_POSIX"), os.time())
                                            refreshCooldown(yu.mpx(), k)
                                        end)
                                    end

                                    ImGui.PopID()
                                    row = row + 1
                                end

                                ImGui.EndTable()
                            end
                        end

                        tab3.sub[2] = tab4
                    end

                    tab2.sub[3] = tab3
                end -- !SECTION

                do -- SECTION Kosatka
                    local tab3 = SussySpt.rendering.newTab("Kosatka")

                    do -- SECTION Heist
                        local tab4 = SussySpt.rendering.newTab("Heist")

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
                        SussySpt.addTask(refreshStats)

                        local function refreshCuts()
                            a.cuts = {}
                        end
                        refreshCuts()

                        local function refreshExtra()
                            -- if yu.is_script_running("fm_mission_controller_2020") then
                            --     a.lifes = locals.get_int("fm_mission_controller_2020", 43059 + 865 + 1)
                            --     a.realtake = locals.get_int("fm_mission_controller_2020", 40004 + 1392 + 53)
                            -- else
                            --     a.lifes = 0
                            --     a.realtake = 289700
                            -- end
                        end
                        -- refreshExtra()

                        local cooldowns = {}
                        local function refreshCooldowns()
                            for k, v in pairs({"H4_TARGET_POSIX", "H4_COOLDOWN", "H4_COOLDOWN_HARD"}) do
                                cooldowns[k] = " "..v..": "..yu.format_seconds(stats.get_int(yu.mpx()..v) - os.time())
                            end
                        end
                        SussySpt.addTask(refreshCooldowns)

                        tab4.render = function()
                            ImGui.BeginGroup()
                            yu.rendering.bigText("Preperations")

                            ImGui.PushItemWidth(360)

                            do
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
                                        changes = changes + 1
                                        stats.set_int(yu.mpx().."H4CNF_TARGET", a.primarytarget)
                                    end

                                    -- Fill Compound Storages
                                    if a.compoundstoragechanged or a.compoundstorageamountchanged then
                                        changes = changes + 1
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
                                        changes = changes + 1
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
                                        changes = changes + 1
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
                                        changes = changes + 1
                                        stats.set_int(yu.mpx().."H4_PROGRESS", a.difficulty)
                                    end

                                    -- Approach
                                    if a.approachchanged then
                                        changes = changes + 1
                                        stats.set_int(yu.mpx().."H4_MISSIONS", a.approach)
                                    end

                                    -- Weapons
                                    if a.weaponchanged then
                                        changes = changes + 1
                                        stats.set_int(yu.mpx().."H4CNF_WEAPONS", a.weapon)
                                    end

                                    -- Truck Location
                                    if a.supplytrucklocationchanged then
                                        changes = changes + 1
                                        stats.set_int(yu.mpx().."H4CNF_TROJAN", a.supplytrucklocation)
                                    end

                                    -- Cutting Powder
                                    if a.cuttingpowderchanged then
                                        changes = changes + 1
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
                            --     if SussySpt.requireScript("heist_island_planning") then
                            --         locals.set_int("heist_island_planning", 1526, 2)
                            --     end
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
                            --     SussySpt.addTask(function()
                            --         globals.set_float(262145 + 29470, -.1)
                            --         globals.set_float(291786, 0)
                            --         globals.set_float(291787, 0)
                            --     end)
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

                            SussySpt.renderCutsSlider(a.cuts, 1)
                            SussySpt.renderCutsSlider(a.cuts, 2)
                            SussySpt.renderCutsSlider(a.cuts, 3)
                            SussySpt.renderCutsSlider(a.cuts, 4)
                            SussySpt.renderCutsSlider(a.cuts, -2)

                            if ImGui.Button("Apply##cuts") then
                            --     for k, v in pairs(a.cuts) do
                            --         if k == -2 then
                            --             globals.set_int(2684820 + 6606, v)
                            --         else
                            --             globals.set_int(1978495 + 825 + 56 + k, v)
                            --         end
                            --     end
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
                                -- SussySpt.addTask(function()
                                --     if locals.get_int("fm_mission_controller", 22032) == 4 then
                                --         locals.set_int("fm_mission_controller", 22032, 5)
                                --     end
                                -- end)
                            end
                            yu.rendering.tooltip("Idfk what this is or what this does")

                            if ImGui.Button("Skip sewer tunnel cut") then
                                -- SussySpt.addTask(function()
                                --     if SussySpt.requireScript("fm_mission_controller_2020")
                                --         and (locals.get_int("fm_mission_controller_2020", 28446) >= 3
                                --             or locals.get_int("fm_mission_controller_2020", 28446) <= 6) then
                                --         locals.set_int("fm_mission_controller_2020", 28446, 6)
                                --         yu.notify("Skipped sewer tunnel cut (or?)", "Cayo Perico Heist")
                                --     end
                                -- end)
                            end

                            ImGui.SameLine()

                            if ImGui.Button("Skip door hack") then
                                -- SussySpt.addTask(function()
                                --     if SussySpt.requireScript("fm_mission_controller_2020")
                                --         and locals.get_int("fm_mission_controller_2020", 54024) ~= 4 then
                                --         locals.set_int("fm_mission_controller_2020", 54024, 5)
                                --         yu.notify("Skipped door hack (or?)", "Cayo Perico Heist")
                                --     end
                                -- end)
                            end

                            if ImGui.Button("Skip fingerprint hack") then
                                -- SussySpt.addTask(function()
                                --     if SussySpt.requireScript("fm_mission_controller_2020")
                                --         and locals.get_int("fm_mission_controller_2020", 23669) == 4 then
                                --         locals.set_int("fm_mission_controller_2020", 23669, 5)
                                --         yu.notify("Skipped fingerprint hack (or?)", "Cayo Perico Heist")
                                --     end
                                -- end)
                            end

                            ImGui.SameLine()

                            if ImGui.Button("Skip plasmacutter cut") then
                                -- SussySpt.addTask(function()
                                --     if SussySpt.requireScript("fm_mission_controller_2020") then
                                --         locals.set_float("fm_mission_controller_2020", 29685 + 3, 100)
                                --         yu.notify("Skipped plasmacutter cut (or?)", "Cayo Perico Heist")
                                --     end
                                -- end)
                            end

                            if ImGui.Button("Obtain the primary target") then
                                -- SussySpt.addTask(function()
                                --     if SussySpt.requireScript("fm_mission_controller_2020") then
                                --         locals.set_int("fm_mission_controller_2020", 29684, 5)
                                --         locals.set_int("fm_mission_controller_2020", 29685, 3)
                                --     end
                                -- end)
                            end
                            yu.rendering.tooltip("It works i guess but the object will not get changed")

                            ImGui.SameLine()

                            if ImGui.Button("Remove the drainage pipe") then
                                SussySpt.addTask(function()
                                    local hash = joaat("prop_chem_grill_bit")
                                    for k, v in pairs(entities.get_all_objects_as_handles()) do
                                        if ENTITY.GET_ENTITY_MODEL(v) == hash then
                                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v, false, false)
                                            ENTITY.DELETE_ENTITY(v)
                                        end
                                    end
                                end)
                            end
                            yu.rendering.tooltip("This is good")

                            if ImGui.Button("Instant finish") then
                                -- SussySpt.addTask(function()
                                --     if SussySpt.requireScript("fm_mission_controller_2020") then
                                --         locals.set_int("fm_mission_controller_2020", 45450, 9)
                                --         locals.set_int("fm_mission_controller_2020", 46829, 50)
                                --         yu.notify("Idk if you should use this but i i capitan", "Cayo Perico Heist")
                                --     end
                                -- end)
                            end
                            yu.rendering.tooltip("This is really weird and only you get money i think")

                            ImGui.Spacing()

                            if ImGui.Button("Refresh##extra") then
                                SussySpt.addTask(refreshExtra)
                            end

                            -- ImGui.PushItemWidth(390)

                            -- local lifesValue, lifesChanged = ImGui.SliderInt("Lifes", a.lifes, 0, 10)
                            -- yu.rendering.tooltip("Only works when you are playing alone (i think)")
                            -- if lifesChanged then
                            --     a.lifes = lifesValue
                            -- end

                            -- ImGui.SameLine()

                            -- if ImGui.Button("Apply##lifes") then
                            --     if SussySpt.requireScript("fm_mission_controller_2020") then
                            --         locals.set_int("fm_mission_controller_2020", 43059 + 865 + 1, a.lifes)
                            --     end
                            -- end

                            -- local realTakeValue, realTakeChanged = ImGui.SliderInt("Real take", a.realtake, 100000, 2897000, yu.format_num(a.realtake))
                            -- yu.rendering.tooltip("Set real take to 2,897,000 for 100% or smth")
                            -- if realTakeChanged then
                            --     a.realtake = realTakeValue
                            -- end

                            -- ImGui.SameLine()

                            -- if ImGui.Button("Apply##realtake") then
                            --     if SussySpt.requireScript("fm_mission_controller_2020") then
                            --         locals.set_int("fm_mission_controller_2020", 40004 + 1392 + 53, a.realtake)
                            --     end
                            -- end

                            -- ImGui.Text("Simulate bag for:")
                            -- for i = 1, 4 do
                            --     ImGui.SameLine()
                            --     if ImGui.Button(i.." Player"..yu.shc(i == 1, "", "s")) then
                            --         SussySpt.addTask(function()
                            --             globals.set_int(292084, 1800 * i)
                            --         end)
                            --     end
                            -- end

                            -- ImGui.PopItemWidth()
                            ImGui.Separator()

                            if ImGui.Button("Refresh##cooldowns") then
                                SussySpt.addTask(refreshCooldowns)
                            end

                            for k, v in pairs(cooldowns) do
                                ImGui.Text(v)
                            end

                            ImGui.EndGroup()
                        end

                        tab3.sub[1] = tab4
                    end -- !SECTION

                    do -- SECTION Kosatka
                        local tab4 = SussySpt.rendering.newTab("Kosatka")

                        tab4.render = function()
                            ImGui.Text("\\/ Placeholder. Does not work")

                            yu.rendering.renderCheckbox("Remove kosatka missle cooldown", "kosatka_nomisslecd", function(state)
                                SussySpt.addTask(function()
                                    -- globals.set_int(292539, yu.shc(state, 0, 60000))
                                end)
                            end)

                            yu.rendering.renderCheckbox("Higher kosatka missle range", "kosatka_longermisslerange", function(state)
                                SussySpt.addTask(function()
                                    -- globals.set_int(292540, yu.shc(state, 4000, 99999))
                                end)
                            end)
                        end

                        tab3.sub[2] = tab4
                    end -- !SECTION

                    tab2.sub[4] = tab3
                end -- !SECTION

                do -- SECTION Salvage Yard
                    local tab3 = SussySpt.rendering.newTab("Salvage Yard")

                    local a = {
                        loaded = false,

                        cooldown = {
                            value = 0,

                            getStatHashForCharStat = function()--Position - 0xD247
                                return STATS.GET_STAT_HASH_FOR_CHARACTER_STAT_(0, 12230, yu.playerindex(2))
                            end,
                            get = function(self)
                                local success, result = STATS.STAT_GET_INT(self.getStatHashForCharStat(), 0, -1)
                                if not success then
                                    return nil
                                end
                                return result - NETWORK.GET_CLOUD_TIME_AS_INT()
                            end,
                            set = function(self, secs)
                                STATS.STAT_SET_INT(self.getStatHashForCharStat(), NETWORK.GET_CLOUD_TIME_AS_INT() + secs, false)
                            end
                        },

                        vehicleSearch = "",
                        vehicles = {"lm87","cinquemila","autarch","tigon","champion","tenf","sm722","omnisegt","growler","deity","italirsx","coquette4",
                            "jubilee","astron","comet7","torero","cheetah2","turismo2","infernus2","stafford","gt500","viseris","mamba","coquette3",
                            "stingergt","ztype","broadway","vigero2","buffalo4","ruston","gauntlet4","dominator8","btype3","swinger","feltzer3","omnis",
                            "tropos","jugular","patriot3","toros","caracara2","sentinel3","weevil","kanjo","eudora","kamacho","hellion","ellie","hermes",
                            "hustler","turismo3","buffalo5","stingertt","virtue","ignus","zentorno","neon","furia","zorrusso","thrax","vagner","panthere",
                            "italigto","s80","tyrant","entity3","torero2","neo","corsita","paragon","btype2","comet4","fr36","everon2","komoda","tailgater2",
                            "jester3","jester4","euros","zr350","cypher","dominator7","baller8","casco","yosemite2","everon","penumbra2","vstr","dominator9",
                            "schlagen","cavalcade3","clique","boor","sugoi","greenwood","brigham","issi8","seminole2","kanjosj","previon"},
                        translatedVehicles = {},

                        slot = 1,
                        robberies = {
                            "The Cargo Ship",
                            "The Gangbanger",
                            "The Duggan",
                            "The Podium",
                            "The McTony"
                        }
                    }

                    for k, v in pairs(a.vehicles) do
                        a.translatedVehicles[k] = vehicles.get_vehicle_display_name(joaat(v))
                    end

                    do -- SECTION Robbery
                        local tab4 = SussySpt.rendering.newTab("Robbery")

                        local function tick() -- ANCHOR tick
                            local mpx = yu.mpx()

                            a.savlv23 = stats.get_int(mpx.."SALV23_GEN_BS")
                            a.canSkipPreps = (a.savlv23 & (1 << 0)) ~= 0
                            a.robbery = tunables.get_int("SALV23_VEHICLE_ROBBERY_"..a.slot)
                            a.vehicle = tunables.get_int("SALV23_VEHICLE_ROBBERY_ID_"..a.slot) - 1
                            a.canKeep = tunables.get_bool("SALV23_VEHICLE_ROBBERY_CAN_KEEP_"..a.slot)

                            a.loaded = nil
                        end

                        tab4.render = function() -- ANCHOR render
                            SussySpt.tasks.thing_salvageyard_robbery_tick = tick

                            if a.loaded == false then
                                return
                            end

                            do
                                ImGui.PushItemWidth(342)
                                local value, changed = ImGui.SliderInt("Slot", a.slot, 1, 3)
                                if changed then
                                    a.slot = value
                                end
                                ImGui.PopItemWidth()
                            end

                            ImGui.BeginGroup()
                            ImGui.Text("Robbery ["..tostring(a.robbery).."]")
                            if ImGui.BeginListBox("##robbery_list", 150, 262) then
                                for k, v in pairs(a.robberies) do
                                    local selected = a.robbery == k
                                    if ImGui.Selectable(v, selected) and not selected then
                                        SussySpt.addTask(function()
                                            tunables.set_int("SALV23_VEHICLE_ROBBERY_"..a.slot, k)
                                        end)
                                    end
                                    yu.rendering.tooltip(k)
                                end

                                ImGui.EndListBox()
                            end
                            ImGui.EndGroup()

                            ImGui.SameLine()

                            ImGui.BeginGroup()
                            ImGui.Text("Vehicle ["..tostring(a.vehicle).."]")

                            ImGui.PushItemWidth(180)
                            do
                                local resp = yu.rendering.input("text", {
                                    label = "##vehicle_search",
                                    hint = "Search...",
                                    text = a.vehicleSearch
                                })
                                SussySpt.pushDisableControls(ImGui.IsItemActive())
                                if resp ~= nil and resp.changed then
                                    a.vehicleSearch = resp.text:lowercase()
                                end
                            end
                            ImGui.PopItemWidth()

                            if ImGui.BeginListBox("##vehicle_list", 180, 224) then
                                for k, v in pairs(a.translatedVehicles) do
                                    if a.vehicles[k]:contains(a.vehicleSearch) or v:lowercase():contains(a.vehicleSearch) then
                                        local selected = a.vehicle == k
                                        if ImGui.Selectable(v, selected) and not selected then
                                            SussySpt.addTask(function()
                                                tunables.set_int("SALV23_VEHICLE_ROBBERY_ID_"..a.slot, k + 1)
                                            end)
                                        end
                                        if ImGui.IsItemHovered() then
                                            ImGui.SetTooltip(a.vehicles[k])
                                        end
                                    end
                                end

                                ImGui.EndListBox()
                            end
                            ImGui.EndGroup()

                            ImGui.SameLine()

                            ImGui.BeginGroup()

                            ImGui.Text("Options")

                            do
                                local state, toggled = ImGui.Checkbox("Can keep", a.canKeep)
                                yu.rendering.tooltip("Allows you to buy the vehicle")
                                if toggled then
                                    tunables.set_bool("SALV23_VEHICLE_ROBBERY_CAN_KEEP_"..a.slot, state)
                                end
                            end

                            ImGui.EndGroup()

                            ImGui.Spacing()

                            ImGui.BeginDisabled(not a.canSkipPreps)
                            if ImGui.Button("Skip preps") then
                                SussySpt.addTask(function()
                                    stats.set_int(yu.mpx("SALV23_FM_PROG"), -1)
                                end)
                            end
                            ImGui.EndDisabled()

                            ImGui.Separator()

                            ImGui.Text("Weekly cooldown")

                            ImGui.SameLine()

                            if ImGui.Button("Remove") then
                                SussySpt.addTask(function()
			                        tunables.set_int(SussySpt.p.t.salvageyard_week, stats.get_int("MPX_SALV23_WEEK_SYNC") + 1)
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.Button("Restore") then
                                SussySpt.addTask(function()
			                        tunables.set_int(SussySpt.p.t.salvageyard_week, stats.get_int("MPX_SALV23_WEEK_SYNC"))
                                end)
                            end

                            ImGui.Spacing()

                            ImGui.Text("Robbery delay")
                            ImGui.SameLine()
                            do
                                ImGui.PushItemWidth(148)
                                local resp = yu.rendering.input("int", {
                                    label = "##cooldown_input",
                                    value = a.cooldown.value
                                })
                                if resp ~= nil and resp.changed then
                                    a.cooldown.value = resp.value
                                end
                                ImGui.PopItemWidth()
                                yu.rendering.tooltip("Sets the cooldown below in seconds.\n'An error has occurred. There is a short delay before you can start another robbery.'")
                            end

                            ImGui.SameLine()

                            if ImGui.Button("Set##cooldown") then
                                SussySpt.addTask(function()
                                    a.cooldown:set(a.cooldown.value)
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.Button("Get##cooldown") then
                                SussySpt.addTask(function()
                                    a.cooldown.value = a.cooldown:get()
                                end)
                            end
                        end

                        tab3.sub[1] = tab4
                    end -- !SECTION

                    tab2.sub[5] = tab3
                end -- !SECTION

                do -- SECTION Motorcycle Club
                    local tab3 = SussySpt.rendering.newTab("Motorcycle Club")

                    tab2.sub[6] = tab3
                end -- !SECTION

                do -- SECTION Organization
                    local tab3 = SussySpt.rendering.newTab("Organization")

                    tab2.sub[7] = tab3
                end -- !SECTION

                do -- SECTION Bunker
                    local tab3 = SussySpt.rendering.newTab("Bunker")

                    tab2.sub[8] = tab3
                end -- !SECTION

                do -- SECTION Arcade
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
                        SussySpt.addTask(refreshStats)

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
                        SussySpt.addTask(updateCooldowns)


                        tab4.render = function()
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
                                SussySpt.addTask(function()
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
                                SussySpt.addTask(refreshStats)
                            end

                            -- ImGui.SameLine()

                            -- if ImGui.Button("Reload planning board") then
                            --     SussySpt.addTask(function()
                            --         local oldBS0 = stats.get_int("H3OPT_BITSET0")
                            --         local oldBS1 = stats.get_int("H3OPT_BITSET1")
                            --         local integerLimit = 2147483647
                            --         stats.set_int("H3OPT_BITSET0", math.random(integerLimit))
                            --         stats.set_int("H3OPT_BITSET1", math.random(integerLimit))
                            --         SussySpt.addTask(function()
                            --             stats.set_int("H3OPT_BITSET0", oldBS0)
                            --             stats.set_int("H3OPT_BITSET1", oldBS1)
                            --         end)
                            --     end)
                            -- end
                            -- yu.rendering.tooltip("I think this only works when opened")

                            if ImGui.Button("Unlock POI & accesspoints") then
                                SussySpt.addTask(function()
                                    local mpx = yu.mpx()
                                    stats.set_int(mpx.."H3OPT_POI", -1)
                                    stats.set_int(mpx.."H3OPT_ACCESSPOINTS", -1)
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.Button("Remove npc cuts") then
                                SussySpt.addTask(function()
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
                                SussySpt.addTask(function()
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
                            --     SussySpt.addTask(refreshCuts)
                            -- end

                            -- ImGui.EndGroup()
                            -- ImGui.Separator()
                            -- ImGui.BeginGroup()

                            -- yu.rendering.bigText("Extra")

                            -- if ImGui.Button("Set all players ready") then
                            --     -- SussySpt.addTask(function()
                            --     --     for i = 0, 3 do
                            --     --         globals.set_int(1974016 + i, -1)
                            --     --     end
                            --     -- end)
                            -- end

                            -- if ImGui.Button("Skip fingerprint hack") then
                            --     -- SussySpt.addTask(function()
                            --     --     if SussySpt.requireScript("fm_mission_controller") and locals.get_int("fm_mission_controller", 52964) == 4 then
                            --     --         locals.set_int("fm_mission_controller", 52964, 5)
                            --     --     end
                            --     -- end)
                            -- end

                            -- ImGui.SameLine()

                            -- if ImGui.Button("Skip keypad hack") then
                            --     -- SussySpt.addTask(function()
                            --     --     if SussySpt.requireScript("fm_mission_controller")
                            --     --         and locals.get_int("fm_mission_controller", 54026) ~= 4 then
                            --     --         locals.set_int("fm_mission_controller", 54026, 5)
                            --     --     end
                            --     -- end)
                            -- end

                            -- ImGui.SameLine()

                            -- if ImGui.Button("Skip vault door drill") then
                            --     -- SussySpt.addTask(function()
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
                            --     SussySpt.addTask(refreshExtra)
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
                            --     SussySpt.addTask(updateCooldowns)
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

                            tab5.getTimePlayed = function()
                                local seconds = MISC.GET_GAME_TIMER() - locals.get_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_stats + SussySpt.p.l.arcadegames_ggsm_playtime)
                                return yu.format_seconds(seconds)
                            end

                            tab5.tick = function()
                                tab5.scriptRunning = yu.is_script_running_hash(tab5.scriptHashed)

                                if tab5.scriptRunning then
                                    tab5.playerShipIndex = 1 + (locals.get_int(tab5.script, 703 + 2680) * 56)

                                    tab5.lives = locals.get_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_playerlives)
                                    tab5.score = locals.get_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_stats + SussySpt.p.l.arcadegames_ggsm_score)
                                    tab5.kills = locals.get_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_stats + SussySpt.p.l.arcadegames_ggsm_kills)
                                    tab5.powerupsCollected = locals.get_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_stats + SussySpt.p.l.arcadegames_ggsm_powerupscollected)
                                    tab5.pos = locals.get_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_entities + tab5.playerShipIndex + SussySpt.p.l.arcadegames_ggsm_position)

                                    tab5.timePlayed = MISC.GET_GAME_TIMER() - locals.get_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_stats + SussySpt.p.l.arcadegames_ggsm_playtime)
                                    tab5.timePlayedFormatted = yu.format_seconds(tab5.timePlayed)

                                    if tab5.godmode then
                                        tab5.heal = true
                                    end

                                    if tab5.heal then
                                        locals.set_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_entities + tab5.playerShipIndex + SussySpt.p.l.arcadegames_ggsm_hp, 4)
                                        tab5.heal = false
                                    end

                                    if tab5.weapon ~= nil then
                                        locals.set_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_entities + tab5.playerShipIndex + SussySpt.p.l.arcadegames_ggsm_weapontype, tab5.weapon + 1)
                                        tab5.weapon = nil
                                    end

                                    if tab5.powerup ~= nil then
                                        locals.set_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_weaponslot + (tab5.powerupSlot + 1), SussySpt.p.l.arcadegames_ggsm_powerups[tab5.powerup + 1])
                                        tab5.powerup = nil
                                    end

                                    if tab5.sector ~= nil then
                                        locals.set_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_stats + SussySpt.p.l.arcadegames_ggsm_sector, tab5.sector)
                                        tab5.sector = nil
                                    end
                                end
                            end

                            tab5.render = function()
                                SussySpt.tasks.thing_arcade_games_ggsm = tab5.tick

                                if not tab5.scriptRunning then
                                    ImGui.Text("The Go Go Space Monkey script is not running")
                                    return
                                end

                                do
                                    local newvalue, changed = ImGui.InputInt("Lives", tab5.lives)
                                    if changed then
                                        local value = math.max(1, math.min(100, newvalue))
                                        locals.set_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_playerlives, value)
                                    end
                                end

                                ImGui.Spacing()

                                do
                                    local newvalue, changed = ImGui.InputInt("Score", tab5.score)
                                    if changed then
                                        local value = math.max(0, math.min(9999999, newvalue))
                                        locals.set_int(tab5.script, SussySpt.p.l.arcadegames_ggsm_data + SussySpt.p.l.arcadegames_ggsm_stats + SussySpt.p.l.arcadegames_ggsm_score, value)
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
                                    SussySpt.addTask(function()
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
                end -- !SECTION

                do -- SECTION Nightclub
                    local tab3 = SussySpt.rendering.newTab("Nightclub")

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
                    SussySpt.addTask(refresh)

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

                    tab3.render = function()
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
                    end

                    tab2.sub[10] = tab3
                end -- !SECTION

                do -- SECTION Casino
                    local tab3 = SussySpt.rendering.newTab("Casino")

                    do -- SECTION Slots
                        local tab4 = SussySpt.rendering.newTab("Slots")

                        tab3.sub[1] = tab4
                    end -- !SECTION

                    do -- SECTION Lucky wheel
                        local tab4 = SussySpt.rendering.newTab("Lucky wheel")

                        tab4.a = {}
                        local a = tab4.a

                        a.script = "casino_lucky_wheel"
                        a.scriptHashed = joaat(a.script)

                        a.prizes = {
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

                        a.tick = function()
                            a.scriptRunning = yu.is_script_running_hash(a.scriptHashed)
                        end

                        a.win = function(prize)
                            if a.scriptRunning then
                                locals.set_int(a.script, SussySpt.p.l.lucky_wheel_win_state + SussySpt.p.l.lucky_wheel_prize, prize)
                                locals.set_int(a.script, SussySpt.p.l.lucky_wheel_win_state + SussySpt.p.l.lucky_wheel_prize_state, 11)
                            end
                            return a.scriptRunning
                        end

                        tab4.render = function()
                            SussySpt.tasks.online_thing_casino_lucky_wheel = a.tick

                            if not a.scriptRunning then
                                ImGui.Text("Please go near the lucky wheel at the Diamond Casino")
                                return
                            end

                            ImGui.Text("Click on a prize to win it")

                            local x, y = ImGui.GetContentRegionAvail()
                            if ImGui.BeginListBox("##prizes", 150, y) then
                                for k, v in pairs(a.prizes) do
                                    if ImGui.Selectable(v, false) then
                                        SussySpt.addTask(function()
                                            a.win(k)
                                        end)
                                    end
                                end
                                ImGui.EndListBox()
                            end
                        end

                        tab3.sub[2] = tab4
                    end -- !SECTION

                    do -- SECTION Story missions
                        local tab4 = SussySpt.rendering.newTab("Story missions")

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
                        SussySpt.addTask(updateStoryMission)

                        tab4.render = function()
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
                        end

                        tab3.sub[3] = tab4
                    end -- !SECTION

                    tab2.sub[11] = tab3
                end -- !SECTION

                tab.sub[2] = tab2
            end -- !SECTION

            do -- SECTION Stats
                local tab2 = SussySpt.rendering.newTab("Stats")

                do -- ANCHOR Other
                    local tab3 = SussySpt.rendering.newTab("Other")

                    local a = {
                        stats = {
                            -- {Stat, Type, Display}
                            {"MPPLY_IS_CHEATER", 1, "Is cheater"},
                            {"MPPLY_ISPUNISHED", 1, "Is punished"},
                            {"MPPLY_IS_HIGH_EARNER", 1, "High earner"},
                            {"MPPLY_WAS_I_BAD_SPORT", 1, "Was i badsport"},
                            {"MPPLY_CHAR_IS_BADSPORT", 1, "Is character badsport"},

                            {"MPPLY_OVERALL_CHEAT", 2, "Overall cheat"},
                            {"MPPLY_OVERALL_BADSPORT", 2, "Overall badsport"},
                            {"MPPLY_PLAYERMADE_TITLE", 2, "Playermade title"},
                            {"MPPLY_PLAYERMADE_DESC", 2, "Playermade description"},

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
                            -- {Display, Getter, Setter, Value, Changed value}
                            {"Stamina", "STAMINA", "SCRIPT_INCREASE_STAM"},
                            {"Strength", "STRENGTH", "SCRIPT_INCREASE_STRN"},
                            {"Shooting", "SHOOTING_ABILITY", "SCRIPT_INCREASE_SHO"},
                            {"Stealth", "STEALTH_ABILITY", "SCRIPT_INCREASE_STL"},
                            {"Flying", "FLYING_ABILITY", "SCRIPT_INCREASE_FLY"},
                            {"Driving", "WHEELIE_ABILITY", "SCRIPT_INCREASE_DRIV"},
                            {"Diving", "LUNG_CAPACITY", "SCRIPT_INCREASE_LUNG"},
                            {"Mental State", "PLAYER_MENTAL_STATE", nil}
                        }
                    }

                    local function refreshStats()
                        local displayAll = yu.rendering.isCheckboxChecked("online_stats_other_stats_all") == true
                        for k, v in pairs(a.stats) do
                            v[4] = nil
                            if v[2] == 1 then
                                local value = stats.get_bool(v[1])
                                if displayAll or value then
                                    v[4] = tostring(value)
                                end
                            elseif v[2] == 2 then
                                local value = stats.get_int(v[1])
                                if displayAll or value ~= 0 then
                                    v[4] = yu.format_num(value)
                                end
                            end
                        end

                        a.ischeater = NETWORK.NETWORK_PLAYER_IS_CHEATER()
                    end

                    local function refreshAbilityValue(mpx, i)
                        local data = a.abilities[i]
                        if data == nil then
                            return
                        end

                        local stat = mpx..data[2]
                        a.abilities[i][4] = i == 8 and stats.get_float(stat) or stats.get_int(stat)
                        a.abilities[i][5] = nil
                    end

                    local function refreshAbilityValues()
                        local mpx = yu.mpx()
                        for k, v in pairs(a.abilities) do
                            refreshAbilityValue(mpx, k)
                        end
                    end

                    local function refresh()
                        refreshStats()
                        refreshAbilityValues()
                    end
                    SussySpt.addTask(refresh)

                    tab3.render = function()
                        if ImGui.SmallButton("Refresh") then
                            SussySpt.addTask(refresh)
                        end

                        if ImGui.TreeNodeEx("Stats") then
                            if ImGui.Button("Refresh##stats") then
                                SussySpt.addTask(refreshStats)
                            end

                            ImGui.SameLine()

                            yu.rendering.renderCheckbox("Show all", "online_stats_other_stats_all", function()
                                SussySpt.addTask(refreshStats)
                            end)

                            if a.ischeater then
                                ImGui.Text("You are marked as a cheater!")
                            end

                            for k, v in pairs(a.stats) do
                                if v[4] ~= nil then
                                    ImGui.Text(v[3]..": "..v[4])
                                end
                            end

                            if SussySpt.dev then
                                ImGui.Spacing()

                                if ImGui.Button("Clear reports (test)") then
                                    SussySpt.addTask(function()
                                        stats.set_int("MPPLY_REPORT_STRENGTH", 0)
                                        stats.set_int("MPPLY_COMMEND_STRENGTH", 0)
                                        stats.set_int("MPPLY_GRIEFING", 0)
                                        stats.set_int("MPPLY_VC_ANNOYINGME", 0)
                                        stats.set_int("MPPLY_VC_HATE", 0)
                                        stats.set_int("MPPLY_TC_ANNOYINGME", 0)
                                        stats.set_int("MPPLY_TC_HATE", 0)
                                        stats.set_int("MPPLY_OFFENSIVE_LANGUAGE", 0)
                                        stats.set_int("MPPLY_OFFENSIVE_TAGPLATE", 0)
                                        stats.set_int("MPPLY_OFFENSIVE_UGC", 0)
                                        stats.set_int("MPPLY_BAD_CREW_NAME", 0)
                                        stats.set_int("MPPLY_BAD_CREW_MOTTO", 0)
                                        stats.set_int("MPPLY_BAD_CREW_STATUS", 0)
                                        stats.set_int("MPPLY_BAD_CREW_EMBLEM", 0)
                                        stats.set_int("MPPLY_GAME_EXPLOITS", 0)
                                        stats.set_int("MPPLY_EXPLOITS", 0)
                                        stats.set_int("MPPLY_BECAME_CHEATER_NUM", 0)
                                        stats.set_int("MPPLY_GAME_EXPLOITS", 0)
                                        stats.set_int("MPPLY_PLAYER_MENTAL_STATE", 0)
                                        stats.set_int("MPPLY_PLAYERMADE_TITLE", 0)
                                        stats.set_int("MPPLY_PLAYERMADE_DESC", 0)
                                        stats.set_int("MPPLY_KILLS_PLAYERS_CHEATER", 0)
                                        stats.set_int("MPPLY_DEATHS_PLAYERS_CHEATER", 0)
                                        stats.set_bool("MPPLY_ISPUNISHED", false)
                                        stats.set_bool("MPPLY_WAS_I_CHEATER", false)
                                        stats.set_int("MPPLY_OVERALL_BADSPORT", 0)
                                        stats.set_int("MPPLY_OVERALL_CHEAT", 0)
                                    end)
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
                                    local value, used
                                    if k == 8 then
                                        value, used = ImGui.DragFloat(v[1], v[5] or v[4], .2, 0, 100)
                                    else
                                        value, used = ImGui.DragInt(v[1], v[5] or v[4], .2, 0, 100)
                                    end

                                    if used then
                                        if value == v[4] then
                                            a.abilities[k][5] = nil
                                        else
                                            a.abilities[k][5] = value
                                        end
                                    end
                                end

                                if v[5] ~= nil then
                                    ImGui.SameLine()

                                    if ImGui.SmallButton("Apply##abilities_"..k) then
                                        SussySpt.addTask(function()
                                            if not yu.is_num_between(v[5], 0, 100) then
                                                return
                                            end

                                            local mpx = yu.mpx()
                                            for i = 2, 3 do
                                                if k == 8 and i == 3 then
                                                    break
                                                end

                                                local stat = mpx..v[i]

                                                local val
                                                if i == 3 then
                                                    val = v[5] - v[4]
                                                else
                                                    val = v[5]
                                                end

                                                if k == 8 then
                                                    if i == 2 then
                                                        stats.set_float(stat, val)
                                                    end
                                                else
                                                    stats.set_int(stat, val)
                                                    -- log.info("SET "..stat.." TO "..val)
                                                end
                                            end

                                            refreshAbilityValue(mpx, k)
                                        end)
                                    end
                                end
                            end
                            ImGui.PopItemWidth()

                            ImGui.TreePop()
                        end

                        if SussySpt.dev and ImGui.TreeNodeEx("Badsport") then
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

                        if SussySpt.dev and ImGui.TreeNodeEx("Bounty") then
                            if ImGui.SmallButton("Remove bounty") then
                                SussySpt.addTask(function()
                                    globals.set_int(SussySpt.p.bounty_self_time, 2880000)
                                end)
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

                tab.sub[3] = tab2
            end -- !SECTION

            do -- ANCHOR Chatlog
                local tab2 = SussySpt.rendering.newTab("Chatlog")

                yu.rendering.setCheckboxChecked("online_chatlog_enabled", SussySpt.cfg.get("chatlog_enabled", true))
                yu.rendering.setCheckboxChecked("online_chatlog_console", SussySpt.cfg.get("chatlog_console", true))
                yu.rendering.setCheckboxChecked("online_chatlog_log_timestamp", SussySpt.cfg.get("chatlog_timestamp", true))

                tab2.render = function()
                    if SussySpt.cfg.set("chatlog_enabled", yu.rendering.renderCheckbox("Enabled", "online_chatlog_enabled")) then
                        ImGui.Spacing()
                        SussySpt.cfg.set("chatlog_console", yu.rendering.renderCheckbox("Log to console", "online_chatlog_console"))
                    end

                    if SussySpt.chatlog.text ~= nil then
                        if ImGui.TreeNodeEx("Logs") then
                            SussySpt.cfg.set("chatlog_timestamp", yu.rendering.renderCheckbox("Timestamp", "online_chatlog_log_timestamp", SussySpt.chatlog.rebuildLog))

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

                tab.sub[4] = tab2
            end

            do -- ANCHOR CMM
                local tab2 = SussySpt.rendering.newTab("CMM")

                local a = {
                    apps = {
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

                tab.sub[5] = tab2
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
                        if ImGui.Button("Unlock LSCarMeet podium prize") then
                            SussySpt.addTask(function()
                                local mpx = yu.mpx()
                                stats.set_bool(mpx.."CARMEET_PV_CHLLGE_CMPLT", true)
                                stats.set_bool(mpx.."CARMEET_PV_CLMED", false)
                            end)
                        end
                        yu.rendering.tooltip("Go in LSCarMeet to claim in interaction menu")

                        -- if ImGui.Button("LSCarMeet unlocks") then
                        --     SussySpt.addTask(function()
                        --         for i = 293419, 293446 do
                        --             globals.set_float(i, 100000)
                        --         end
                        --     end)
                        -- end

                        if ImGui.Button("Unlock flightschool stuff") then
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
                                local mpx = yu.mpx()
                                for i = 0, 63 do
                                    for j = 0, 8 do
                                        stats.set_bool_masked(mpx.."ARENAWARSPSTAT_BOOL"..j, true, i)
                                    end
                                end
                            end)
                        end

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
                                local mpx = yu.mpx()
                                for i = 18, 29 do
                                    stats.set_bool_masked(mpx.."ARENAWARSPSTAT_BOOL0", true, i)
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
                            SussySpt.addTask(function()
                                local mpx = yu.mpx()
                                stats.set_int(mpx.."YACHT_MISSION_PROG", 0)
                                stats.set_int(mpx.."YACHT_MISSION_FLOW", 21845)
                                stats.set_int(mpx.."CASINO_DECORATION_GIFT_1", -1)
                            end)
                        end

                        if ImGui.Button("Skip ULP missions") then
                            SussySpt.addTask(function()
                                local mpx = yu.mpx()
                                stats.set_int(mpx.."ULP_MISSION_PROGRESS", 127)
                                stats.set_int(mpx.."ULP_MISSION_CURRENT", 0)
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

                        if ImGui.SmallButton("Some cool things yay") then
                            SussySpt.addTask(function()
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

                    a.getRankFromRP = function(rp)
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
                                SussySpt.addTask(function()
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

                    tab3.render = function()
                        if ImGui.SmallButton("Allow gender change") then
                            SussySpt.addTask(function()
                                stats.set_int(yu.mpx("ALLOW_GENDER_CHANGE"), 52)
                            end)
                        end

                        if ImGui.SmallButton("Unlock fast run and reload") then
                            SussySpt.addTask(function()
                                local mpx = yu.mpx()
                                for i = 1, 3 do
                                    stats.set_int(mpx.."CHAR_ABILITY_"..i.."_UNLCK", -1)
                                    stats.set_int(mpx.."CHAR_FM_ABILITY_"..i.."_UNLCK", -1)
                                end
                            end)
                        end
                        yu.rendering.tooltip("Makes you run and reload weapons faster")

                        if ImGui.SmallButton("Unlock all achievements") then
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
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
                            SussySpt.addTask(function()
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

                    tab3.render = function()
                        if ImGui.SmallButton("Unlock xmas liveries") then
                            SussySpt.addTask(function()
                                stats.set_int("MPPLY_XMASLIVERIES", -1)
                                for i = 1, 20 do
                                    stats.set_int("MPPLY_XMASLIVERIES"..i, -1)
                                end
                            end)
                        end

                        if ImGui.SmallButton("Unlock LSC stuff & paints") then
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

                        if ImGui.SmallButton("Unlock all trade prices") then
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
                                stats.set_masked_int(mpx.."BUSINESSBATPSTAT_INT379", 5, 5, 55)
                            end)
                        end

                        if ImGui.SmallButton("Unlock Ecola and Sprunk plates") then
                            SussySpt.addTask(function()
                                stats.set_int("MPPLY_XMAS23_PLATES0", -1)
                            end)
                        end
                    end

                    tab2.sub[5] = tab3
                end

                tab.sub[6] = tab2
            end -- !SECTION

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
                    ImGui.Text("This feature is unstable and it is recommended to leave it on the '1M (Juggalo Story Award)'")
                    ImGui.Text("You can do this every second so $1M/1s. Seems to be undetected")
                    ImGui.Spacing()

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

                    ImGui.SameLine()

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
                    yu.rendering.tooltip("You should only use the loop with the '1M (Juggalo Story Award)' transaction")

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
                yu.rendering.setCheckboxChecked("world_objspawner_hashmodel")

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

                            local hash = yu.rendering.isCheckboxChecked("world_objspawner_hashmodel") and joaat(a.model) or tonumber(a.model)

                            if hash == nil or not STREAMING.IS_MODEL_VALID(hash) or not STREAMING.IS_MODEL_A_VEHICLE(hash) then
                                a.invalidmodel = true
                            else
                                STREAMING.REQUEST_MODEL(hash)
                                repeat runscript:yield() until STREAMING.HAS_MODEL_LOADED(hash)

                                if yu.rendering.isCheckboxChecked("world_objspawner_deleteprev") and yu.does_entity_exist(a.entity) then
                                    ENTITY.DELETE_ENTITY(a.entity)
                                end

                                local c = yu.coords(yu.ppid())
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
                        yu.rendering.renderCheckbox("Mission entity", "world_objspawner_missionent")
                        yu.rendering.renderCheckbox("Hash model", "world_objspawner_hashmodel")

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
                    ImGui.Text("This is not finished!")

                    ImGui.Spacing()

                    if ImGui.TreeNodeEx("Door controller") then

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

                        ImGui.TreePop()
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

                            local c = yu.coords(yu.ppid())
                            local x, y, z = c.x, c.y, c.z
                            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(a.effect, x, y, z, 90, -100, 90, 1, true, true, true, false)

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

                yu.rendering.setCheckboxChecked("world_other_blockexplosionshake", SussySpt.cfg.get("world_blockexplosionshake", false))

                yu.rif(function()
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
                        enabled = SussySpt.cfg.set("world_blockexplosionshake", state)

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
                    yu.rendering.tooltip("This prevents the camera from shaking by explosions")
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

        do -- SECTION Quick Actions
            local tab = SussySpt.rendering.newTab("Quick Actions")

            tab.render = function()
                if ImGui.Button("Save") then
                    SussySpt.qa.config.save()
                end

                ImGui.SameLine()

                if ImGui.Button("Reset") then
                    SussySpt.qa.config.sort = yu.copy_table(SussySpt.qa.config.default)
                end

                if ImGui.BeginTable("##actions", 2) then
                    -- ImGui.TableSetupColumn("##1")
                    -- ImGui.TableSetupColumn("##2")
                    ImGui.TableHeadersRow()

                    local row = 0
                    for k, v in pairs(SussySpt.qa.config.sort) do
                        ImGui.TableNextRow()
                        ImGui.PushID(row)
                        ImGui.TableSetColumnIndex(0)

                        local ok = false
                        if type(v) == "number" then
                            if v == 0 then
                                yu.rendering.coloredtext("[Newline]", 106, 106, 106, 255)
                                ok = true
                            end

                        elseif type(v) == "string" then
                            local b = SussySpt.qa.actions[v]
                            if b ~= nil then
                                ImGui.Text(b[2])
                                ok = true
                            end
                        end

                        if not ok then
                            yu.rendering.coloredtext("[Invalid]", 255, 50, 50, 255)
                        end

                        ImGui.TableSetColumnIndex(1)

                        if ImGui.Button("<##"..k) then
                            local newIndex = k - 1
                            if newIndex <= 0 then
                                newIndex = #SussySpt.qa.config.sort
                            end
                            table.swap(SussySpt.qa.config.sort, k, newIndex)
                        end
                        ImGui.SameLine()
                        if ImGui.Button(">##"..k) then
                            local newIndex = k + 1
                            if newIndex > #SussySpt.qa.config.sort then
                                newIndex = 1
                            end
                            table.swap(SussySpt.qa.config.sort, k, newIndex)
                        end
                        ImGui.SameLine()
                        if ImGui.Button("X##"..k) then
                            local tbl = {}
                            local i = 1
                            for k2, v2 in pairs(SussySpt.qa.config.sort) do
                                if k2 ~= k then
                                    tbl[i] = v2
                                    i = i + 1
                                end
                            end
                            SussySpt.qa.config.sort = tbl
                        end

                        ImGui.PopID()
                        row = row + 1
                    end

                    ImGui.EndTable()
                end
            end

            SussySpt.rendering.tabs[4] = tab
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

                    if SussySpt.debugtext ~= "" and ImGui.TreeNodeEx("Debug log") then
                        yu.rendering.renderCheckbox("Log to console", "debug_console", function(state)
                            SussySpt.cfg.set("debug_console", state)
                        end)

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
                        if SussySpt.cfg.data ~= nil then
                            ImGui.Spacing()
                            if ImGui.Button("Unload config") then
                                SussySpt.cfg.save()
                                SussySpt.cfg.data = nil
                            end
                        end

                        ImGui.Spacing()

                        yu.rendering.renderCheckbox("Display times", "dev_times")

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

            do -- ANCHOR Theme
                local tab2 = SussySpt.rendering.newTab("Theme")

                local a = {
                    customthemetext = ""
                }

                tab2.render = function()
                    ImGui.Text("Theme: "..SussySpt.rendering.theme)
                    ImGui.PushItemWidth(265)
                    if ImGui.BeginCombo("Theme", SussySpt.rendering.theme) then
                        for k, v in pairs(SussySpt.rendering.themes) do
                            if ImGui.Selectable(k, false) then
                                SussySpt.rendering.theme = k
                                if k ~= "Custom" then
                                    SussySpt.cfg.set("theme", k)
                                end
                                SussySpt.debug("Set theme to '"..k.."'")
                            end
                        end
                        ImGui.EndCombo()
                    end
                    ImGui.PopItemWidth()

                    ImGui.Separator()

                    if ImGui.TreeNodeEx("Edit theme") then
                        ImGui.Spacing()
                        ImGui.Text("Reload the script to revert changes")

                        ImGui.PushItemWidth(267)
                        local sameLine = false
                        for k, v in pairs(SussySpt.rendering.getTheme()) do
                            if k == "ImGuiCol" and type(v) == "table" then
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

                    if ImGui.TreeNodeEx("Custom theme") then
                        if ImGui.Button("Load") then
                            local success, result = pcall(yu.json.decode, a.customthemetext)
                            if not success then
                                a.message = {"Error: "..yu.removeErrorPath(result)[2], 255, 25, 25}

                            elseif type(result) == "table" then
                                if result.parent == "Custom" then
                                    result.parent = nil
                                end
                                if result.ImGuiCol then
                                    for k, v2 in pairs(result.ImGuiCol) do
                                        for k3, v3 in pairs(v2) do
                                            v2[k3] = v3 / 255
                                        end
                                    end
                                end
                                SussySpt.rendering.themes["Custom"] = result
                                a.message = {"Success! You can now select the 'Custom' theme above", 60, 222, 22}
                            end
                        end

                        ImGui.SameLine()

                        if ImGui.Button("Get") then
                            SussySpt.addTask(function()
                                local data = {
                                    ImGuiCol = {}
                                }

                                for k, v in pairs(ImGuiCol) do
                                    if k ~= "COUNT" then
                                        local r, g, b, a = ImGui.GetStyleColorVec4(v)
                                        data["ImGuiCol"][k] = {math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), a}
                                    end
                                end

                                a.customthemetext = yu.json.encode(data)
                                a.message = {"Success! You can now put the text into a json formatter :D", 60, 222, 22}
                            end)
                        end

                        if a.message ~= nil then
                            yu.rendering.coloredtext(table.unpck(a.message, 4))
                        end

                        do
                            local x, y = ImGui.GetContentRegionAvail()
                            local text, _ = ImGui.InputTextMultiline("##input", a.customthemetext, 2500000, x, y)
                            SussySpt.pushDisableControls(ImGui.IsItemActive())
                            if text ~= a.customthemetext then
                                a.customthemetext = text
                                a.message = nil
                            end
                        end
                        ImGui.TreePop()
                    end
                end

                tab.sub[2] = tab2
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

                tab.sub[3] = tab2
            end

            do -- ANCHOR Invisible
                local tab2 = SussySpt.rendering.newTab("Invisible")

                local a = {
                    key = SussySpt.cfg.get("invisible_key", "L")
                }

                local makingVehicleInivs = false
                SussySpt.ensureVis = function(state, id, veh)
                    if state ~= true and state ~= false then
                        return nil
                    end
                    if id ~= nil and yu.rendering.isCheckboxChecked("invisible_self") then
                        ENTITY.SET_ENTITY_VISIBLE(id, state, false)
                    end
                    if not makingVehicleInivs and yu.rendering.isCheckboxChecked("invisible_vehicle") then
                        SussySpt.addTask(function()
                            makingVehicleInivs = true
                            if veh ~= nil and entities.take_control_of(veh) then
                                ENTITY.SET_ENTITY_VISIBLE(veh, state, false)
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

                yu.rendering.setCheckboxChecked("invisible_hotkey", SussySpt.cfg.get("invisible_hotkey", false))
                yu.rendering.setCheckboxChecked("invisible_log", SussySpt.cfg.get("invisible_log", false))
                yu.rendering.setCheckboxChecked("invisible_self", SussySpt.cfg.get("invisible_self", true))
                yu.rendering.setCheckboxChecked("invisible_vehicle", SussySpt.cfg.get("invisible_vehicle", true))

                tab2.render = function()
                    yu.rendering.renderCheckbox("Enabled", "invisible", function(state)
                        if state then
                            SussySpt.invisible = true
                        else
                            yu.rif(SussySpt.enableVis)
                        end
                    end)

                    ImGui.Spacing()

                    SussySpt.cfg.set("invisible_hotkey", yu.rendering.renderCheckbox("Hotkey enabled", "invisible_hotkey"))
                    SussySpt.cfg.set("invisible_log", yu.rendering.renderCheckbox("Log", "invisible_log"))

                    ImGui.Spacing()

                    SussySpt.cfg.set("invisible_self", yu.rendering.renderCheckbox("Self", "invisible_self"))
                    SussySpt.cfg.set("invisible_vehicle", yu.rendering.renderCheckbox("Vehicle", "invisible_vehicle"))

                    ImGui.Spacing()

                    ImGui.PushItemWidth(140)
                    if ImGui.BeginCombo("Key", a.key) then
                        for k, v in pairs(yu.keys) do
                            if ImGui.Selectable(k, false) then
                                a.key = k
                                bindHotkey(yu.keys[k])
                                SussySpt.cfg.set("invisible_key", k)
                            end
                        end
                        ImGui.EndCombo()
                    end
                    ImGui.PopItemWidth()
                end

                tab.sub[4] = tab2
            end

            SussySpt.rendering.tabs[5] = tab
        end -- !SECTION
    end -- !SECTION

    do -- SECTION Quick Actions
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
                local sort = SussySpt.cfg.get("qa_sort")
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
                    SussySpt.cfg.set("qa_sort", nil)
                else
                    SussySpt.cfg.set("qa_sort", SussySpt.qa.config.sort)
                end
                SussySpt.cfg.save()
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
                                    SussySpt.addTask(function()
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
    end -- !SECTION

    SussySpt.debug("Creating esp thread")
    do -- ANCHOR ESP
        local function drawLine(ped, index1, index2)
            local c1 = PED.GET_PED_BONE_COORDS(ped, index1, 0, 0, 0)
            local c2 = PED.GET_PED_BONE_COORDS(ped, index2, 0, 0, 0)
            GRAPHICS.DRAW_LINE(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 255, 0, 0, 255)
        end

        local amplitude = 127
        local phaseShift = 0
        local counter = 0
        local frequency = .6

        local function rgbGamerColor()
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
                    local lc = yu.coords(yu.ppid())

                    if espEnabled then
                        for k, v in pairs(SussySpt.players) do
                            local ped = v.ped
                            local c = yu.coords(ped)
                            local distance = MISC.GET_DISTANCE_BETWEEN_COORDS(lc.x, lc.y, lc.z, c.x, c.y, c.z, false)
                            if distance < 120 and GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(c.x, c.y, c.z, 0, 0) then
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

    do -- ANCHOR Verify tabs
        local tabSize = 0

        local function countTabs(tbl)
            if type(tbl) ~= "table" then
                return
            end
            for k, v in pairs(tbl) do
                tabSize = tabSize + 1
                if v.sub == tbl then
                    tbl[k] = nil
                    log.warning("Overflow for tab "..v.name)
                else
                    countTabs(v.sub)
                end
            end
        end
        countTabs(SussySpt.rendering.tabs)

        SussySpt.debug("Created "..tabSize.." tabs")
    end

    SussySpt.debug("Registering mainloop")
    yu.rif(SussySpt.mainLoop)

    SussySpt.debug("Adding render callback")
    SussySpt.tab:add_imgui(SussySpt.render)

    SussySpt:initCategories()

    SussySpt.debug("Loaded successfully!")
    yu.notify(1, "Loaded v"..SussySpt.version.." ["..SussySpt.versionid.."]!", "Welcome")
end -- !SECTION

function SussySpt:initCategories() -- SECTION SussySpt:initCategories
    SussySpt.debug("Initializing categories")

    SussySpt:initTabHBO()

    if SussySpt.dev then
        SussySpt:initTabHeist()
    end

    for k, v in pairs({"hbo", "qa"}) do
        yu.rendering.setCheckboxChecked("cat_"..v, SussySpt.cfg.get("cat_"..v, false))
    end
end -- !SECTION

function SussySpt:initTabHBO() -- SECTION SussySpt:initTabHBO
    SussySpt.debug("Calling SussySpt:initTabHBO()")

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
    SussySpt.renderCutsSlider = renderCutsSlider

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
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entity, false, false)
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
        SussySpt.addTask(refreshStats)

        local function refreshCuts()
            a.cuts = {}
        end
        refreshCuts()

        local function refreshExtra()
            -- if yu.is_script_running("fm_mission_controller_2020") then
            --     a.lifes = locals.get_int("fm_mission_controller_2020", 43059 + 865 + 1)
            --     a.realtake = locals.get_int("fm_mission_controller_2020", 40004 + 1392 + 53)
            -- else
            --     a.lifes = 0
            --     a.realtake = 289700
            -- end
        end
        -- refreshExtra()

        local cooldowns = {}
        local function refreshCooldowns()
            for k, v in pairs({"H4_TARGET_POSIX", "H4_COOLDOWN", "H4_COOLDOWN_HARD"}) do
                cooldowns[k] = " "..v..": "..yu.format_seconds(stats.get_int(yu.mpx()..v) - os.time())
            end
        end
        SussySpt.addTask(refreshCooldowns)

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
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H4CNF_TARGET", a.primarytarget)
                        end

                        -- Fill Compound Storages
                        if a.compoundstoragechanged or a.compoundstorageamountchanged then
                            changes = changes + 1
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
                            changes = changes + 1
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
                            changes = changes + 1
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
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H4_PROGRESS", a.difficulty)
                        end

                        -- Approach
                        if a.approachchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H4_MISSIONS", a.approach)
                        end

                        -- Weapons
                        if a.weaponchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H4CNF_WEAPONS", a.weapon)
                        end

                        -- Truck Location
                        if a.supplytrucklocationchanged then
                            changes = changes + 1
                            stats.set_int(yu.mpx().."H4CNF_TROJAN", a.supplytrucklocation)
                        end

                        -- Cutting Powder
                        if a.cuttingpowderchanged then
                            changes = changes + 1
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
                --     if SussySpt.requireScript("heist_island_planning") then
                --         locals.set_int("heist_island_planning", 1526, 2)
                --     end
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
                --     SussySpt.addTask(function()
                --         globals.set_float(262145 + 29470, -.1)
                --         globals.set_float(291786, 0)
                --         globals.set_float(291787, 0)
                --     end)
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
                --     for k, v in pairs(a.cuts) do
                --         if k == -2 then
                --             globals.set_int(2684820 + 6606, v)
                --         else
                --             globals.set_int(1978495 + 825 + 56 + k, v)
                --         end
                --     end
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
                    -- SussySpt.addTask(function()
                    --     if locals.get_int("fm_mission_controller", 22032) == 4 then
                    --         locals.set_int("fm_mission_controller", 22032, 5)
                    --     end
                    -- end)
                end
                yu.rendering.tooltip("Idfk what this is or what this does")

                if ImGui.Button("Skip sewer tunnel cut") then
                    -- SussySpt.addTask(function()
                    --     if SussySpt.requireScript("fm_mission_controller_2020")
                    --         and (locals.get_int("fm_mission_controller_2020", 28446) >= 3
                    --             or locals.get_int("fm_mission_controller_2020", 28446) <= 6) then
                    --         locals.set_int("fm_mission_controller_2020", 28446, 6)
                    --         yu.notify("Skipped sewer tunnel cut (or?)", "Cayo Perico Heist")
                    --     end
                    -- end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip door hack") then
                    -- SussySpt.addTask(function()
                    --     if SussySpt.requireScript("fm_mission_controller_2020")
                    --         and locals.get_int("fm_mission_controller_2020", 54024) ~= 4 then
                    --         locals.set_int("fm_mission_controller_2020", 54024, 5)
                    --         yu.notify("Skipped door hack (or?)", "Cayo Perico Heist")
                    --     end
                    -- end)
                end

                if ImGui.Button("Skip fingerprint hack") then
                    -- SussySpt.addTask(function()
                    --     if SussySpt.requireScript("fm_mission_controller_2020")
                    --         and locals.get_int("fm_mission_controller_2020", 23669) == 4 then
                    --         locals.set_int("fm_mission_controller_2020", 23669, 5)
                    --         yu.notify("Skipped fingerprint hack (or?)", "Cayo Perico Heist")
                    --     end
                    -- end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip plasmacutter cut") then
                    -- SussySpt.addTask(function()
                    --     if SussySpt.requireScript("fm_mission_controller_2020") then
                    --         locals.set_float("fm_mission_controller_2020", 29685 + 3, 100)
                    --         yu.notify("Skipped plasmacutter cut (or?)", "Cayo Perico Heist")
                    --     end
                    -- end)
                end

                if ImGui.Button("Obtain the primary target") then
                    -- SussySpt.addTask(function()
                    --     if SussySpt.requireScript("fm_mission_controller_2020") then
                    --         locals.set_int("fm_mission_controller_2020", 29684, 5)
                    --         locals.set_int("fm_mission_controller_2020", 29685, 3)
                    --     end
                    -- end)
                end
                yu.rendering.tooltip("It works i guess but the object will not get changed")

                ImGui.SameLine()

                if ImGui.Button("Remove the drainage pipe") then
                    SussySpt.addTask(function()
                        local hash = joaat("prop_chem_grill_bit")
                        for k, v in pairs(entities.get_all_objects_as_handles()) do
                            if ENTITY.GET_ENTITY_MODEL(v) == hash then
                                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v, false, false)
                                ENTITY.DELETE_ENTITY(v)
                            end
                        end
                    end)
                end
                yu.rendering.tooltip("This is good")

                if ImGui.Button("Instant finish") then
                    -- SussySpt.addTask(function()
                    --     if SussySpt.requireScript("fm_mission_controller_2020") then
                    --         locals.set_int("fm_mission_controller_2020", 45450, 9)
                    --         locals.set_int("fm_mission_controller_2020", 46829, 50)
                    --         yu.notify("Idk if you should use this but i i capitan", "Cayo Perico Heist")
                    --     end
                    -- end)
                end
                yu.rendering.tooltip("This is really weird and only you get money i think")

                ImGui.Spacing()

                if ImGui.Button("Refresh##extra") then
                    SussySpt.addTask(refreshExtra)
                end

                -- ImGui.PushItemWidth(390)

                -- local lifesValue, lifesChanged = ImGui.SliderInt("Lifes", a.lifes, 0, 10)
                -- yu.rendering.tooltip("Only works when you are playing alone (i think)")
                -- if lifesChanged then
                --     a.lifes = lifesValue
                -- end

                -- ImGui.SameLine()

                -- if ImGui.Button("Apply##lifes") then
                --     if SussySpt.requireScript("fm_mission_controller_2020") then
                --         locals.set_int("fm_mission_controller_2020", 43059 + 865 + 1, a.lifes)
                --     end
                -- end

                -- local realTakeValue, realTakeChanged = ImGui.SliderInt("Real take", a.realtake, 100000, 2897000, yu.format_num(a.realtake))
                -- yu.rendering.tooltip("Set real take to 2,897,000 for 100% or smth")
                -- if realTakeChanged then
                --     a.realtake = realTakeValue
                -- end

                -- ImGui.SameLine()

                -- if ImGui.Button("Apply##realtake") then
                --     if SussySpt.requireScript("fm_mission_controller_2020") then
                --         locals.set_int("fm_mission_controller_2020", 40004 + 1392 + 53, a.realtake)
                --     end
                -- end

                -- ImGui.Text("Simulate bag for:")
                -- for i = 1, 4 do
                --     ImGui.SameLine()
                --     if ImGui.Button(i.." Player"..yu.shc(i == 1, "", "s")) then
                --         SussySpt.addTask(function()
                --             globals.set_int(292084, 1800 * i)
                --         end)
                --     end
                -- end

                -- ImGui.PopItemWidth()
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
        SussySpt.addTask(refreshStats)

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
        SussySpt.addTask(updateCooldowns)

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
                    -- for k, v in pairs(a.cuts) do
                    --     if k == -2 then
                    --         globals.set_int(2691426, v)
                    --     else
                    --         globals.set_int(1963945 + 1497 + 736 + 92 + k, v)
                    --     end
                    -- end
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
                    -- SussySpt.addTask(function()
                    --     for i = 0, 3 do
                    --         globals.set_int(1974016 + i, -1)
                    --     end
                    -- end)
                end

                if ImGui.Button("Skip fingerprint hack") then
                    -- SussySpt.addTask(function()
                    --     if SussySpt.requireScript("fm_mission_controller") and locals.get_int("fm_mission_controller", 52964) == 4 then
                    --         locals.set_int("fm_mission_controller", 52964, 5)
                    --     end
                    -- end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip keypad hack") then
                    -- SussySpt.addTask(function()
                    --     if SussySpt.requireScript("fm_mission_controller")
                    --         and locals.get_int("fm_mission_controller", 54026) ~= 4 then
                    --         locals.set_int("fm_mission_controller", 54026, 5)
                    --     end
                    -- end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip vault door drill") then
                    -- SussySpt.addTask(function()
                    --     if SussySpt.requireScript("fm_mission_controller") then
                    --         locals.set_int(
                    --             "fm_mission_controller",
                    --             10108,
                    --             locals.get_int("fm_mission_controller", 10138)
                    --         )
                    --     end
                    -- end)
                end

                ImGui.Spacing()

                if ImGui.Button("Refresh##extra") then
                    SussySpt.addTask(refreshExtra)
                end

                -- local lifesValue, lifesChanged = ImGui.SliderInt("Lifes", a.lifes, 0, 10)
                -- yu.rendering.tooltip("Not tested")
                -- if lifesChanged then
                --     a.lifes = lifesValue
                -- end

                -- ImGui.SameLine()

                -- if ImGui.Button("Apply##lifes") then
                --     if SussySpt.requireScript("fm_mission_controller") then
                --         locals.set_int("fm_mission_controller", 27400, a.lifes)
                --     end
                -- end

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

        local prize_wheel_win_state = 278
        local prize_wheel_prize = 14
        local prize_wheel_prize_state = 45

        local winPrize = 0
        local winPrizeChanged = false

        local function winLuckyWheel(prize)
            if SussySpt.requireScript("casino_lucky_wheel") and yu.is_num_between(prize, 0, 18) then
                yu.notify(1, "Winning "..luckyWheelPrizes[prize].." from the lucky wheel!", "Diamond Casino & Resort")
                locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize), prize)
                locals.set_int("casino_lucky_wheel", prize_wheel_win_state + prize_wheel_prize_state, 11)
            else
                yu.notify(2, "Try going near the lucky wheel", "Diamond Casino & Resort")
            end
        end

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
        SussySpt.addTask(updateStoryMission)

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
        SussySpt.addTask(refresh)

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
        SussySpt.addTask(refresh)

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
                            changes = changes + 1
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
                            locals.set_float("fm_mission_controller", 10061 + 11, 100)
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
        SussySpt.addTask(refresh)

        local function getBS()
            return yu.shc(a.heist == 1, 4351, 12543)
        end

        local cooldowns = {}
        local function refreshCooldowns()
            for i = 0, 7 do
                cooldowns[i] = "  - "..a.heists[i]..": "..yu.format_seconds(stats.get_int(yu.mpx("TUNER_CONTRACT"..i.."_POSIX")) - os.time())
            end
        end
        SussySpt.addTask(refreshCooldowns)

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
                            changes = changes + 1
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
        SussySpt.addTask(refresh)

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
        SussySpt.addTask(refreshStats)

        SussySpt.addTask(function()
            if yu.rendering.isCheckboxChecked("hbo_agency_smthmfinale") then
                globals.set_int(SussySpt.p.agency_maxpayout, 2000000)
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
                            changes = changes + 1

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
                        globals.set_int(SussySpt.p.agency_maxpayout, 1000000)
                    end
                end)
                yu.rendering.tooltip("This is for the 'Don't Fuck With Dre' VIP Contract")

                ImGui.EndGroup()
                ImGui.EndTabItem()
            end
        end)
    end

    local function initOffice()
        local function getCrates(amount)
            SussySpt.addTask(function()
                if SussySpt.requireScript("gb_contraband_buy") then
                    locals.set_int("gb_contraband_buy", 604, 1)
                    locals.set_int("gb_contraband_buy", 600, amount)
                    locals.set_int("gb_contraband_buy", 790, 6)
                    locals.set_int("gb_contraband_buy", 791, 4)
                end
            end)
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

    -- initCayo()
    -- initCasinoHeist()
    initCasino()
    -- initNightclub()
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

function SussySpt:initTabHeist() -- SECTION SussySpt:initTabHeist
    SussySpt.debug("Calling SussySpt:initTabHeist()")

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
