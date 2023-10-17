yu = require "yimutils"

SussySpt = {
    version = "1.3.5",
    versionid = 1221
}

function SussySpt:new()
    yu.set_notification_title_prefix("[SussySpt] ")

    SussySpt.tab = gui.get_tab("SussySpt")
    local tab = SussySpt.tab

    SussySpt.in_online = false
    SussySpt.rendering = {
        themes = {
            Nightly = {
                ImGuiCol = {
                    TitleBg = {9, 27, 46, 1.0},
                    TitleBgActive = {9, 27, 46, 1.0},
                    WindowBg = {0, 19, 37, .95},
                    Tab = {10, 30, 46, 1.0},
                    TabActive = {14, 60, 90, 1.0},
                    TabHovered = {52, 64, 71, 1.0},
                    Button = {3, 45, 79, 1.0},
                    FrameBg = {35, 38, 53, 1.0},
                    HeaderActive = {54, 55, 66, 1.0},
                    HeaderHovered = {62, 63, 73, 1.0},
                },
                ImGuiStyleVar = {
                    WindowRounding = {4},
                    FrameRounding = {2}
                }
            },
            Kiddions = {
                parent = "Nightly",
                ImGuiCol = {
                    TitleBg = {21, 74, 93, .87},
                    TitleBgActive = {21, 74, 93, .87},
                    WindowBg = {24, 78, 98, .87},
                    Tab = {0, 0, 0, 0.0},
                    TabActive = {243, 212, 109, 1.0},
                    TabHovered = {243, 212, 109, 1.0},
                    Button = {234, 207, 116, .8},
                    FrameBg = {13, 57, 73, 1.0}
                },
                ImGuiStyleVar = {
                    WindowRounding = {0},
                    FrameRounding = {0}
                }
            }
        },
        tabs = {}
    }

    SussySpt.rendering.theme = "Nightly"

    SussySpt.rendering.get_theme = function()
        return SussySpt.rendering.themes[SussySpt.rendering.theme]
    end

    SussySpt.rendering.new_tab = function(name, render)
        return {
            name = name,
            render = render,
            should_display = nil,
            sub = {},
            id = yu.gun()
        }
    end

    SussySpt.rendering.add_tab = function(cb)
        if type(cb) == "function" then
            local data = cb()
            if type(data) == "table" then
                SussySpt.rendering.tabs[#SussySpt.rendering.tabs + 1] = data
            end
        end
    end

    local function render_tab(v)
        if not (type(v.should_display) == "function" and v.should_display() == false) and ImGui.BeginTabItem(v.name) then
            if yu.len(v.sub) > 0 then
                ImGui.BeginTabBar("##tabbar_"..v.id)
                for k1, v1 in pairs(v.sub) do
                    render_tab(v1)
                end
                ImGui.EndTabBar()
            end

            if type(v.render) == "function" then
                v.render()
            end
            ImGui.EndTabItem()
        end
    end

    local function twcr(c)
        return c / 255
    end

    SussySpt.render = function()
        for k, v in pairs(SussySpt.rendercb) do
            v()
        end

        local pops = {}
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
                            ImGui.PushStyleColor(ImGuiCol[k1], twcr(v1[1]), twcr(v1[2]), twcr(v1[3]), v1[4])
                            pops.PopStyleColor = (pops.PopStyleColor or 0) + 1
                        elseif k == "ImGuiStyleVar" then
                            if v1[2] == nil then
                                ImGui.PushStyleVar(ImGuiStyleVar[k1], v1[1])
                            else
                                ImGui.PushStyleVar(ImGuiStyleVar[k1], v1[1], v1[2])
                            end
                            pops.PopStyleVar = (pops.PopStyleVar or 0) + 1
                        end
                    end
                end
            end
        end
        pushTheme(SussySpt.rendering.get_theme())

        if ImGui.Begin("SussySpt v"..SussySpt.version) then
            ImGui.BeginTabBar("##tabbar")
            for k, v in pairs(SussySpt.rendering.tabs) do
                render_tab(v)
            end
            ImGui.EndTabBar()
        end
        ImGui.End()

        for k, v in pairs(pops) do
            ImGui[k](v)
        end
    end

    SussySpt.repeating_tasks = {}

    SussySpt.register_repeating_task = function(cb)
        local id = #SussySpt.repeating_tasks + 1
        SussySpt.repeatingTasks[id] = cb
        return id
    end

    SussySpt.unregister_repeating_task = function(id)
        SussySpt.repeating_tasks[id] = nil
    end

    SussySpt.disable_controls = 0
    SussySpt.push_disable_controls = function(a)
        if a ~= false then
            SussySpt.disable_controls = 20
        end
    end

    SussySpt.tick = function()
        if SussySpt.disable_controls > 0 then
            SussySpt.disable_controls = SussySpt.disable_controls - 1

            for i = 0, 2 do
                for i2 = 0, 360 do
                    PAD.DISABLE_CONTROL_ACTION(i, i2, true)
                end
            end
        end
    end

    SussySpt:initUtils()

    tab:add_text("github.com/pierrelasse/YimStuff")

    SussySpt.rendercb = {}
    SussySpt.add_render = function(cb)
        if cb ~= nil then
            SussySpt.rendercb[yu.gun()] = cb
        end
    end

    SussySpt.repeatingTasks = {}

    SussySpt:initRendering()

    SussySpt:initTabHBO()
    SussySpt:initTabQA()

    SussySpt:initTabSelf()
    SussySpt:initTabHeist()

    SussySpt.chatlog = {
        messages = {},
        rebuildLog = function()
            local text = ""
            local newline = ""
            local doTimestamp = yu.rendering.isCheckboxChecked("online_chatlog_log_timestamp")
            for k, v in pairs(SussySpt.chatlog.messages) do
                local timestamp = ""
                text = text..newline..(doTimestamp and ("["..v[4].."] ") or "")..v[2]..": "..v[3]
                newline = "\n"
            end

            SussySpt.chatlog.text = text
        end
    }
    event.register_handler(menu_event.ChatMessageReceived, function(player_id, chat_message)
        if yu.rendering.isCheckboxChecked("online_chatlog_enabled") then
            local name = PLAYER.GET_PLAYER_NAME(player_id)
            SussySpt.chatlog.messages[yu.gun()] = {
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

    script.register_looped("sussyspt2", function()
        SussySpt.in_online = yu.is_script_running("freemode")

        if SussySpt.invisible == true then
            SussySpt.ensureVis(false, yu.ppid(), yu.veh())
        end
    end)

    SussySpt.rendering.add_tab(function()
        local data = SussySpt.rendering.new_tab("Online")

        data.should_display = function()
            return SussySpt.in_online
        end

        local function networkent(ent)
            NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(ent)
            return ent
        end

        local function networkobj(obj)
            networkent(obj)
            local id = NETWORK.OBJ_TO_NET(obj)
            NETWORK.NETWORK_USE_HIGH_PRECISION_BLENDING(id, true)
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(id, true)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(id)
        end

        data.sub.players = (function()
            local a = {
                playerlistwidth = 187,
                searchtext = "",
                playersmi = {},
                playerelements = {},
                selectedplayer = nil,
                selectedplayerinfo = {},
                refreshtick = 0,
                ramoptions = {
                    ["bus"] = "Bus",
                    ["adder"] = "Adder",
                    ["monster"] = "Monster",
                    ["freight"] = "Train",
                    ["bulldozer"] = "Bulldozer (very cool)",
                    ["dump"] = "Dump (big)",
                    ["cutter"] = "Cutter"
                },
                ramoption = "bus",
                givecustomweaponammo = 999
            }
            SussySpt.online_players_a = a

            local function updatePlayerElements()
                local emptystr = ""
                local selfppid = yu.ppid()
                local lc = ENTITY.GET_ENTITY_COORDS(selfppid)
                for k, v in pairs(a.playersmi) do
                    if type(v.name) == "string" and v.name:lowercase():contains(a.searchtext:lowercase()) then
                        a.playersmi[k].display = true
                        local name = v.name
                        local info =
                            yu.shc(network.is_player_flagged_as_modder(v.player), "M", emptystr)
                            ..yu.shc(v.ped == selfppid, "Y", emptystr)
                        if info ~= emptystr then
                            name = name.." ["..info.."]"
                        end
                        a.playersmi[k].displayname = name

                        local c = ENTITY.GET_ENTITY_COORDS(v.ped)
                        a.playersmi[k].tooltip =
                            "Health: "..ENTITY.GET_ENTITY_HEALTH(v.ped).."/"..ENTITY.GET_ENTITY_MAX_HEALTH(v.ped)
                            .."\n".."Distance: "..MISC.GET_DISTANCE_BETWEEN_COORDS(lc.x, lc.y, lc.z, c.x, c.y, c.z, true)
                            .."\n".."Ped: "..v.ped.." Player: "..v.player
                    else
                        a.playersmi[k].display = false
                    end
                end
            end

            local function refreshPlayerList()
                if DLC.GET_IS_LOADING_SCREEN_ACTIVE() then
                    a.playersmi = {}
                    a.selectedplayer = nil
                    return
                end
                a.playersmi = yu.get_all_players_mi()

                for k, v in pairs(a.playersmi) do
                    local name = PLAYER.GET_PLAYER_NAME(v.player)
                    if name ~= nil and name ~= "**Invalid**" then
                        a.playersmi[k].name = name
                    end
                end

                updatePlayerElements()
            end

            for k, v in pairs({menu_event.PlayerLeave,menu_event.PlayerJoin,menu_event.PlayerMgrShutdown}) do
                event.register_handler(v, function()
                    yu.rif(refreshPlayerList)
                end)
            end
            yu.rif(refreshPlayerList)

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

                local c1 = PED.GET_PED_BONE_COORDS(ped, 39317, 0, 0, 0)
                local c2 = PED.GET_PED_BONE_COORDS(ped, 11816, 0, 0, 0)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
                    c2.x, c2.y, c2.z,
                    c1.x, c1.y, c1.z,
                    damage or 1,
                    true,
                    weaponHash,
                    ped,
                    false,
                    true,
                    speed or 24000
                )
            end

            return SussySpt.rendering.new_tab("Players", function()
                ImGui.BeginGroup()
                ImGui.Text("Players")

                ImGui.PushItemWidth(a.playerlistwidth)
                if ImGui.BeginListBox("##playerlist") then
                    for k, v in pairs(a.playersmi) do
                        if v.display then
                            if ImGui.Selectable(v.displayname, false) then
                                a.selectedplayer = v.name
                            end
                            if v.tooltip ~= nil then
                                yu.rendering.tooltip(v.tooltip)
                            end
                        end
                    end

                    ImGui.EndListBox()
                end
                ImGui.PopItemWidth()

                ImGui.Text("Search")
                ImGui.PushItemWidth(a.playerlistwidth)
                local srtext, srselected = ImGui.InputText("##search", a.searchtext, 32)
                SussySpt.push_disable_controls(ImGui.IsItemActive())
                if a.searchtext ~= srtext then
                    a.searchtext = srtext
                    yu.rif(updatePlayerElements)
                end
                ImGui.PopItemWidth()

                if ImGui.SmallButton("Refresh list") then
                    yu.rif(refreshPlayerList)
                end

                ImGui.EndGroup()

                if a.selectedplayer ~= nil then
                    local player
                    a.splayer = nil
                    for k, v in pairs(a.playersmi) do
                        if v.name == a.selectedplayer then
                            player = v
                            a.splayer = player
                            break
                        end
                    end
                    ImGui.SameLine()

                    ImGui.BeginGroup()

                    ImGui.Text("Selected player: "..player.name)

                    if ImGui.TreeNodeEx("General") then
                        if ImGui.Button("Goto") then
                            yu.rif(function()
                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                PED.SET_PED_COORDS_KEEP_VEHICLE(yu.ppid(), c.x, c.y, c.z)
                            end)
                        end
                        yu.rendering.tooltip("Teleport yourself to the player")

                        ImGui.SameLine()

                        if ImGui.Button("Bring") then
                            yu.rif(function()
                                local c = ENTITY.GET_ENTITY_COORDS(yu.ppid())
                                network.set_player_coords(player.player, c.x, c.y, c.z)
                            end)
                        end

                        ImGui.SameLine()

                        if ImGui.Button("Set waypoint to") then
                            yu.rif(function()
                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                HUD.SET_NEW_WAYPOINT(c.x, c.y)
                            end)
                        end

                        if ImGui.Button("Kill") then
                            yu.rif(function(rs)
                                shootPlayer(rs, player.ped, joaat("WEAPON_HEAVYSNIPER"), 10000)
                            end)
                        end
                        yu.rendering.tooltip("Should super good but sadly it doesn't work well :/")

                        yu.rendering.renderCheckbox("Spectate", "online_players_spectate", function(state)
                            yu.rif(function()
                                for k, v in pairs(a.playersmi) do
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
                        if ImGui.Button("Taze") then
                            yu.rif(function(rs)
                                shootPlayer(rs, player.ped, joaat("WEAPON_STUNGUN"), 2)
                            end)
                        end

                        ImGui.Text("Explode:")
                        ImGui.SameLine()
                        if ImGui.SmallButton("Invisible") then
                            yu.rif(function()
                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 72, 80, false, true, 0)
                            end)
                        end
                        yu.rendering.tooltip("\"Random\" death")
                        ImGui.SameLine()
                        if ImGui.SmallButton("Normal") then
                            yu.rif(function()
                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                FIRE.ADD_EXPLOSION(c.x + 1, c.y + 1, c.z + 1, 4, 100, true, false, 0)
                            end)
                        end
                        ImGui.SameLine()
                        if ImGui.SmallButton("Huge") then
                            yu.rif(function()
                                local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 82, 20, true, false, 1)
                            end)
                        end

                        if ImGui.TreeNodeEx("Trap") then
                            if ImGui.Button("Normal") then
                                yu.rif(function()
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

                            if ImGui.Button("Cage") then
                                yu.rif(function(runscript)
                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                    local x = tonumber(string.format('%.2f', c.x))
                                    local y = tonumber(string.format('%.2f', c.y))
                                    local z = tonumber(string.format('%.2f', c.z))

                                    local modelHash = joaat("prop_fnclink_05crnr1")
                                    STREAMING.REQUEST_MODEL(modelHash)
                                    repeat runscript:yield() until STREAMING.HAS_MODEL_LOADED(modelHash)

                                    local createObject = function(offsetX, offsetY, heading)
                                        local obj = OBJECT.CREATE_OBJECT(modelHash, x + offsetX, y + offsetY, z - 1.0, true, true, true)
                                        networkobj(obj)
                                        ENTITY.SET_ENTITY_HEADING(obj, heading)
                                        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                        ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(obj)
                                    end

                                    createObject(-1.70, -1.70, -90.0)
                                    createObject(1.70, 1.70, 90.0)
                                end)
                            end

                            if ImGui.Button("Race tube") then
                                yu.rif(function()
                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                    local obj = OBJECT.CREATE_OBJECT(joaat("stt_prop_stunt_tube_crn_5d"), c.x, c.y, c.z, true, false, true)
                                    networkobj(obj)
                                    ENTITY.SET_ENTITY_ROTATION(obj, 0, 90, 0, 2, true)
                                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                    ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(obj)
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.Button("Invisible race tube") then
                                yu.rif(function()
                                    local c = ENTITY.GET_ENTITY_COORDS(player.ped)
                                    local obj = OBJECT.CREATE_OBJECT(joaat("stt_prop_stunt_tube_crn_5d"), c.x, c.y, c.z, true, false, true)
                                    networkobj(obj)
                                    ENTITY.SET_ENTITY_ROTATION(obj, 0, 90, 0, 2, true)
                                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                                    ENTITY.SET_ENTITY_VISIBLE(obj, false)
                                    ENTITY.SET_OBJECT_AS_NO_LONGER_NEEDED(obj)
                                end)
                            end

                            ImGui.TreePop()
                        end

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
                                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 1.0)
                                    runscript:sleep(100)
                                    for i = 0, 10 do
                                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 50.0)
                                        runscript:sleep(100)
                                    end
                                    ENTITY.SET_VEHICLE_AS_NO_LONGER_NEEDED(veh)
                                    VEHICLE.DELETE_VEHICLE(veh)
                                end
                            end)
                        end

                        ImGui.TreePop()
                    end

                    if ImGui.TreeNodeEx("Weapons") then
                        if ImGui.Button("Remove all weapons") then
                            yu.rif(function()
                                WEAPON.REMOVE_ALL_PED_WEAPONS(player.ped, true)
                                for k, v in pairs(yu.get_all_weapons()) do
                                    WEAPON.REMOVE_WEAPON_FROM_PED(player.ped, v)
                                end
                            end)
                        end

                        ImGui.Spacing()

                        ImGui.PushItemWidth(120)
                        local gcwr = yu.rendering.input("text", {
                            label = "##gcw",
                            text = a.givecustomweapontext
                        })
                        SussySpt.push_disable_controls(ImGui.IsItemActive())
                        ImGui.PopItemWidth()
                        if gcwr ~= nil and gcwr.changed then
                            a.givecustomweapontext = gcwr.text
                        end

                        ImGui.SameLine()

                        ImGui.PushItemWidth(79)
                        local gcwar = yu.rendering.input("int", {
                            label = "##gcwa",
                            value = a.givecustomweaponammo,
                            min = 0,
                            max = 99999
                        })
                        SussySpt.push_disable_controls(ImGui.IsItemActive())
                        ImGui.PopItemWidth()
                        if gcwar ~= nil and gcwar.changed then
                            a.givecustomweaponammo = gcwar.value
                        end

                        ImGui.SameLine()
                        if ImGui.Button("Give") then
                            yu.rif(function()
                                local hash = weaponFromInput(a.givecustomweapontext)
                                if WEAPON.GET_WEAPONTYPE_MODEL(hash) ~= 0 then
                                    WEAPON.GIVE_WEAPON_TO_PED(player.ped, hash, a.givecustomweaponammo, false, false)
                                end
                            end)
                        end
                        ImGui.SameLine()
                        if ImGui.Button("Remove") then
                            yu.rif(function()
                                local hash = weaponFromInput(a.givecustomweapontext)
                                if WEAPON.GET_WEAPONTYPE_MODEL(hash) ~= 0 then
                                    WEAPON.REMOVE_WEAPON_FROM_PED(player.ped, hash)
                                end
                            end)
                        end

                        ImGui.TreePop()
                    end

                    if ImGui.TreeNodeEx("Vehicle") then
                        yu.rendering.renderCheckbox("Godmode", "online_player_vehiclegod", function(state)
                            yu.rif(function()
                                local veh = yu.veh(player.ped)
                                if veh ~= nil then
                                    ENTITY.SET_ENTITY_INVINCIBLE(veh, state)
                                end
                            end)
                        end)
                        yu.rendering.tooltip("Sets the vehicle in godmode")

                        if ImGui.SmallButton("Repair") then
                            yu.rif(function()
                                if PED.IS_PED_IN_ANY_VEHICLE(player.ped, 0) then
                                    local veh = PED.GET_VEHICLE_PED_IS_IN(player.ped, false)
                                    VEHICLE.SET_VEHICLE_FIXED(veh)
                                    VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, .0)
                                end
                            end)
                        end

                        ImGui.SameLine()

                        if ImGui.SmallButton("Delete") then
                            yu.rif(function()
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

                        ImGui.SameLine()

                        if ImGui.SmallButton("Explode") then
                            yu.rif(function()
                                local veh = yu.veh(player.ped)
                                if veh ~= nil and entities.take_control_of(veh) then
                                    VEHICLE.EXPLODE_VEHICLE(veh, true, false)
                                end
                            end)
                        end

                        if ImGui.SmallButton("Halt") then
                            yu.rif(function()
                                local veh = yu.veh(player.ped)
                                if veh ~= nil and entities.take_control_of(veh) then
                                    VEHICLE.BRING_VEHICLE_TO_HALT(veh, 30, 1, true)
                                end
                            end)
                        end
                        yu.rendering.tooltip("Makes the vehicle halt.\nThe vehicle can start driving right after it.")

                        ImGui.SameLine()

                        if ImGui.SmallButton("Engine off") then
                            yu.rif(function()
                                local veh = yu.veh(player.ped)
                                if veh ~= nil and entities.take_control_of(veh) then
                                    yu.request_entity_control_once(veh)
                                    VEHICLE.SET_VEHICLE_ENGINE_ON(veh, false, true, false)
                                end
                            end)
                        end

                        ImGui.SameLine()

                        if ImGui.SmallButton("Kill engine") then
                            yu.rif(function()
                                local veh = yu.veh(player.ped)
                                if veh ~= nil and entities.take_control_of(veh) then
                                    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, -4000)
                                end
                            end)
                        end

                        if ImGui.SmallButton("Launch") then
                            yu.rif(function()
                                local veh = yu.veh(player.ped)
                                if veh ~= nil and entities.take_control_of(veh) then
                                    ENTITY.APPLY_FORCE_TO_ENTITY(veh, 4, 0, 0, 50000, 0, 0, 0, 0, 0, 1, 1, 0, 1)
                                end
                            end)
                        end

                        ImGui.SameLine()

                        if ImGui.SmallButton("Boost") then
                            yu.rif(function()
                                local veh = yu.veh(player.ped)
                                if veh ~= nil and entities.take_control_of(veh) then
                                    VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 79)
                                    ENTITY.APPLY_FORCE_TO_ENTITY(veh, 4, 10, 0, 0, 2, 0, 0, 0, false, true, true, false, true)
                                end
                            end)
                        end

                        if ImGui.SmallButton("Burst tires") then
                            yu.rif(function()
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
                            yu.rif(function()
                                local veh = yu.veh(player.ped)
                                if veh ~= nil and entities.take_control_of(veh) then
                                    yu.loop(8, function(i)
                                        VEHICLE.SMASH_VEHICLE_WINDOW(veh, i)
                                    end)
                                end
                            end)
                        end

                        if ImGui.TreeNodeEx("Doors") then
                            if ImGui.SmallButton("Unlock (you)") then
                                yu.rif(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil then
                                        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_PLAYER(veh, yu.pid(), false)
                                    end
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.SmallButton("Unlock (all)") then
                                yu.rif(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil then
                                        VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_ALL_PLAYERS(veh, false)
                                    end
                                end)
                            end

                            ImGui.TreePop()
                        end

                        ImGui.TreePop()
                    end

                    ImGui.EndGroup()
                end
            end)
        end)()

        data.sub.chatlog = (function()
            yu.rendering.setCheckboxChecked("online_chatlog_enabled", true)
            yu.rendering.setCheckboxChecked("online_chatlog_console", true)
            yu.rendering.setCheckboxChecked("online_chatlog_log_timestamp", true)

            return SussySpt.rendering.new_tab("Chatlog", function()
                if yu.rendering.renderCheckbox("Enabled", "online_chatlog_enabled") then
                    ImGui.Spacing()
                    yu.rendering.renderCheckbox("Log to console", "online_chatlog_console")
                end

                if SussySpt.chatlog.text ~= nil and ImGui.TreeNodeEx("Logs") then
                    yu.rendering.renderCheckbox("Timestamp", "online_chatlog_log_timestamp", SussySpt.chatlog.rebuildLog)

                    ImGui.InputTextMultiline("##chat_log", SussySpt.chatlog.text, SussySpt.chatlog.text:length(), 500, 140, ImGuiInputTextFlags.ReadOnly)
                    SussySpt.push_disable_controls(ImGui.IsItemActive())

                    ImGui.TreePop()
                end
            end)
        end)()

        return data
    end)

    SussySpt.rendering.add_tab(function()
        local data = SussySpt.rendering.new_tab("World")

        data.sub.objspawner = (function()
            local a = {
                model = "",
                awidth = 195
            }

            yu.rendering.setCheckboxChecked("world_objspawner_deleteprev", true)
            yu.rendering.setCheckboxChecked("world_objspawner_missionent", true)

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

            return SussySpt.rendering.new_tab("Object Spawner", function()
                -- ImGui.BeginGroup()

                -- ImGui.Text("Spawned entities")

                -- ImGui.EndGroup()
                -- ImGui.SameLine()
                ImGui.BeginGroup()

                ImGui.Text("Spawner")

                ImGui.PushItemWidth(a.awidth)

                local model_text, model_selected = ImGui.InputText("Model", a.model, 32)
                SussySpt.push_disable_controls(ImGui.IsItemActive())
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
                        yu.rif(function()
                            if a.entity ~= nil and yu.does_entity_exist(a.entity) then
                                ENTITY.FREEZE_ENTITY_POSITION(a.entity, state)
                            end
                        end)
                    end)

                    yu.rendering.renderCheckbox("Delete previous", "world_objspawner_deleteprev")
                    yu.rendering.renderCheckbox("Place on ground correctly", "world_objspawner_groundplace")
                    yu.rendering.renderCheckbox("Mission entity", "world_objspawner_missionent", function(state)
                        yu.rif(function()
                            if a.entity ~= nil and yu.does_entity_exist(a.entity) then
                                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(a.entity, state)
                            end
                        end)
                    end)

                    ImGui.TreePop()
                end

                ImGui.EndGroup()
            end)
        end)()

        data.sub.vehicles = (function()
            return SussySpt.rendering.new_tab("Nearby vehicles", function()
                ImGui.Text("Coming soon :D")
                ImGui.BeginGroup()
                ImGui.Text("Nearby vehicles")
                ImGui.EndGroup()
                ImGui.SameLine()
                ImGui.Text("Vehicle options")
                ImGui.BeginGroup()
                ImGui.EndGroup()
            end)
        end)()

        return data
    end)

    SussySpt.rendering.add_tab(function()
        local data = SussySpt.rendering.new_tab("Config")

        data.sub.a_info = SussySpt.rendering.new_tab("Info", function()
            ImGui.Text("Made by pierrelasse.")
            ImGui.Text("SussySpt & yimutils download: https://github.com/pierrelasse/yimstuff")
            ImGui.Spacing()
            ImGui.Text("SussySpt version: "..SussySpt.version)
            ImGui.Text("SussySpt version id: "..SussySpt.versionid)
            ImGui.Spacing()
            ImGui.Text("Theme: "..SussySpt.rendering.theme)
        end)

        data.sub.b_theme = SussySpt.rendering.new_tab("Theme", function()
            if ImGui.BeginCombo("Theme", SussySpt.rendering.theme) then
                for k, v in pairs(SussySpt.rendering.themes) do
                    if ImGui.Selectable(k, false) then
                        SussySpt.rendering.theme = k
                    end
                end
                ImGui.EndCombo()
            end
        end)

        data.sub.c_esp = SussySpt.rendering.new_tab("Weird ESP", function()
            yu.rendering.renderCheckbox("Very cool skeleton esp enabled", "config_esp_enabled")
        end)

        return data
    end)

    script.register_looped("sussyspt", SussySpt.tick)
    SussySpt.tab:add_imgui(SussySpt.render)

    yu.rif(function(rs)
        local function drawLine(ped, index1, index2)
            local c1 = PED.GET_PED_BONE_COORDS(ped, index1, 0, 0, 0)
            local c2 = PED.GET_PED_BONE_COORDS(ped, index2, 0, 0, 0)
            GRAPHICS.DRAW_LINE(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 255, 0, 0, 255)
        end

        while not DLC.GET_IS_LOADING_SCREEN_ACTIVE() do
            rs:yield()
            if yu.rendering.isCheckboxChecked("config_esp_enabled") and not DLC.GET_IS_LOADING_SCREEN_ACTIVE() then
                local lc = ENTITY.GET_ENTITY_COORDS(yu.ppid())
                for k, v in pairs(SussySpt.online_players_a.playersmi) do
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
        end
    end)

    yu.notify(1, "Loaded successfully! In freemode: "..yu.boolstring(SussySpt.in_online, "Yep", "fm script no run so no?"), "Loaded!")
end

function SussySpt:initRendering()
    local tab = SussySpt.tab
    SussySpt.pushStyle = function()end
    SussySpt.popStyle = function()end

    tab:add_separator()
    tab:add_text("Categories:")
    tab:add_imgui(function()
        ImGui.SameLine()

        if ImGui.Button("Show all") then
            for k, v in pairs({"self", "hbo", "qa", "players"}) do
                yu.rendering.setCheckboxChecked("cat_"..v, true)
            end
        end

        yu.rendering.renderCheckbox("Self", "cat_self")
        if SussySpt.in_online then
            yu.rendering.renderCheckbox("HBO", "cat_hbo")
        end
        yu.rendering.renderCheckbox("Quick actions", "cat_qa")
        if SussySpt.in_online then
            yu.rendering.renderCheckbox("Players", "cat_players")
            yu.rendering.tooltip("This is a beta feature and way not done yet")
        end
    end)
end

function SussySpt:initUtils()
    function requireScript(name)
        if yu.is_script_running(name) == false then
            yu.notify(3, "Script '"..name.."' is not running!", "Script Requirement")
            return false
        end
        return true
    end

    function removeAllCameras()
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

    function deleteEntityByName(name)
        local hash = joaat(name)
        for k, v in pairs(entities.get_all_objects_as_handles()) do
            if ENTITY.GET_ENTITY_MODEL(v) == hash then
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v, true, true)
                ENTITY.DELETE_ENTITY(v)
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
            return tbs.tabs[key] or gui.get_tab("void")
        end
    }
end

function SussySpt:initTabSelf()
    local a = {
        tabBarId = "##self_tabbar",
        spCharacters = {
            [0] = "Michael",
            [1] = "Franklin",
            [2] = "Trevor"
        },
        rpmultiplierp = 262146,
        rank = -1
    }

    local function refresh()
        a.mentalState = stats.get_float("MPPLY_PLAYER_MENTAL_STATE")

        a.badsport = stats.get_bool("MPPLY_CHAR_IS_BADSPORT")

        a.spCash = {}
        for k, v in pairs(a.spCharacters) do
            a.spCash[k] = stats.get_int("SP"..k.."_TOTAL_CASH")
        end

        a.rpmultiplier = globals.get_float(a.rpmultiplierp)
    end

    refresh()

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

    local crew = 1
    local crewRank = 0
    local minCrewRank = 0
    local checkingCrewRank = false

    function getCrewRankByXp(xp)
        local rank = 0
        for k, v in pairs(yu.xp_for_crew_rank()) do
            if v < xp then
                rank = k
            else
                return rank
            end
        end
        return rank
    end

    function updateCrewRank()
        if not checkingCrewRank then
            checkingCrewRank = true
            yu.add_task(function()
                crewRank = getCrewRankByXp(stats.get_int("MPPLY_CREW_LOCAL_XP_"..crew))
                minCrewRank = crewRank
                checkingCrewRank = false
            end)
        end
    end

    yu.add_task(updateCrewRank)

    function renderCrewRank()
        ImGui.Text("Crew rank")

        local crewNewValue, crewChanged = ImGui.SliderInt("Crew", crew, 0, 4)
        if crewChanged then
            crew = crewNewValue
            updateCrewRank()
        end
        yu.rendering.tooltip("The crew you want to change your rank for.\nFunfact: You can join multiple crews.")

        local rankNewValue, rankChanged = ImGui.SliderInt("Rank", crewRank, minCrewRank, 8000)
        if rankChanged then
            crewRank = rankNewValue
        end
        yu.rendering.tooltip("You can't go down again!")

        if ImGui.Button("Set") then
            yu.add_task(function()
                if crewRank >= minCrewRank then
                    stats.set_int("MPPLY_CREW_LOCAL_XP_"..crew, yu.xp_for_crew_rank()[crewRank] + 100)
                    yu.notify(2, "You will need to switch sessions to see changes", "Crew rank")
                    yu.notify(1, "Set rank to "..crewRank.."!!!!1 :DDD", "It's fine... No ban!!!11")
                end
                updateCrewRank()
            end)
        end
    end

    local function renderSPCash(index)
        local value = a.spCash[index] or 0
        local newValue, changed = ImGui.InputInt(a.spCharacters[index].."'s cash", value, 0, 2147483647)
        if changed then
            a.spCash[index] = newValue
        end
    end

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

    local parachuteHash = joaat("GADGET_PARACHUTE")
    SussySpt.register_repeating_task(function()
        if yu.rendering.isCheckboxChecked("self_refillparachute") then
            WEAPON.GIVE_WEAPON_TO_PED(yu.ppid(), parachuteHash, 1, false, true)
        end
    end)

    function run_script(name)
        yu.rif(function(runscript)
            SCRIPT.REQUEST_SCRIPT(name)
            repeat runscript:yield() until SCRIPT.HAS_SCRIPT_LOADED(name)
            SYSTEM.START_NEW_SCRIPT(name, 5000)
            SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(name)
        end)
    end

    SussySpt.add_render(function()
        if yu.rendering.isCheckboxChecked("cat_self") then
            SussySpt.pushStyle()
            if ImGui.Begin("Self") then
                ImGui.BeginTabBar(a.tabBarId)

                if ImGui.BeginTabItem("General") then
                    yu.rendering.renderCheckbox("Invisible (Press 'L' to toggle)", "self_invisible", function(state)
                        if state then
                            SussySpt.invisible = true
                        else
                            SussySpt.enableVis()
                        end
                    end)

                    yu.rendering.renderCheckbox("Refill parachute", "self_refillparachute")

                    ImGui.EndTabItem()
                end

                if SussySpt.in_online then
                    if ImGui.BeginTabItem("Stats") then
                        if ImGui.Button("Refresh") then
                            yu.add_task(refresh)
                        end

                        if ImGui.Button("Reset mental state") then
                            yu.add_task(function()
                                stats.set_float(yu.mpx("PLAYER_MENTAL_STATE"), .0)
                                stats.set_float("MPPLY_PLAYER_MENTAL_STATE", .0)
                                refresh()
                            end)
                        end

                        yu.rendering.renderCheckbox("Badsport", "self_badsporet", function(state)
                            yu.add_task(function()
                                if state then
                                    stats.set_int("MPPLY_BADSPORT_MESSAGE", -1)
                                    stats.set_int("MPPLY_BECAME_BADSPORT_NUM", -1)
                                    stats.set_float("MPPLY_OVERALL_BADSPORT", 60000)
                                    stats.set_bool("MPPLY_CHAR_IS_BADSPORT", true)
                                else
                                    stats.set_int("MPPLY_BADSPORT_MESSAGE", 0)
                                    stats.set_int("MPPLY_BECAME_BADSPORT_NUM", 0)
                                    stats.set_float("MPPLY_OVERALL_BADSPORT", 0)
                                    stats.set_bool("MPPLY_CHAR_IS_BADSPORT", false)
                                end
                            end)
                        end)

                        if ImGui.Button("Remove bounty") then
                            yu.add_task(function()
                                globals.set_int(2364460, 2880000)
                            end)
                        end

                        if ImGui.Button("Remove griefing cooldown for VIP/CEO") then
                            yu.add_task(function()
                                stats.set_int("MPPLY_VIPGAMEPLAYDISABLEDTIMER", 0)
                            end)
                        end

                        local rpmNewValue, rpmChanged = ImGui.InputInt("RP multiplier", a.rpmultiplier, 0, 140)
                        if rpmChanged then
                            a.rpmultiplier = rpmNewValue
                        end
                        yu.rendering.tooltip("Max is 140")

                        ImGui.SameLine()

                        if ImGui.Button("Apply##rpmultiplier") then
                            yu.add_task(function()
                                globals.set_float(a.rpmultiplierp, a.rpmultiplier)
                            end)
                        end

                        -- local rankNewValue, rankChanged = ImGui.InputInt("Rank", a.rank, a.rank, 8000, 8)
                        -- if rankChanged then
                        --     a.rank = rankNewValue
                        -- end

                        -- ImGui.SameLine()

                        -- if ImGui.Button("Apply##rank") then
                        --     yu.add_task(function()
                        --         if a.rank >= 0 and a.rank <= 8000 then
                        --             local newRP = globals.get_int(294329 + a.rank) + 100
                        --             log.info(a.rank..": "..newRP)
                        --             -- stats.set_int("MP"..yu.playerindex(2).."_CHAR_SET_RP_GIFT_ADMIN", newRP)
                        --         else
                        --             yu.notify(3, "Invalid rank ["..a.rank.."] 0-8000", "Rank correction")
                        --         end
                        --     end)
                        -- end

                        -- if ImGui.Button("Give RP") then
                        --     yu.rif(function(runscript)
                        --         -- local oldLvl = PLAYER.GET_PLAYER_WANTED_LEVEL(yu.pid())
                        --         PLAYER.SET_PLAYER_WANTED_LEVEL_NO_DROP(yu.pid(), 5, false)
                        --         -- PLAYER.SET_PLAYER_WANTED_LEVEL_NOW(yu.pid(), true)
                        --         log.info("ok")
                        --         -- runscript:sleep(1000)
                        --         -- PLAYER.SET_PLAYER_WANTED_LEVEL(yu.pid(), oldLvl, false)
                        --     end)
                        -- end

                        ImGui.EndTabItem()
                    end

                    if ImGui.BeginTabItem("Unlocks") then
                        if ImGui.Button("Max all stats") then
                            yu.add_task(function()
                                local mpx = yu.mpx()
                                for k, v in pairs({"SCRIPT_INCREASE_DRIV","SCRIPT_INCREASE_FLY",
                                    "SCRIPT_INCREASE_LUNG","SCRIPT_INCREASE_SHO","SCRIPT_INCREASE_STAM",
                                    "SCRIPT_INCREASE_STL","SCRIPT_INCREASE_STRN"}) do
                                    stats.set_int(mpx..v, 100)
                                end
                            end)
                        end

                        if ImGui.Button("Unlock all achievements") then
                            yu.rif(function()
                                yu.loop(59, function(i)
                                    if not PLAYER.HAS_ACHIEVEMENT_BEEN_PASSED(i) then
                                        PLAYER.GIVE_ACHIEVEMENT_TO_PLAYER(i)
                                    end
                                end)
                            end)
                        end

                        if ImGui.Button("Unlock xmas liveries") then
                            yu.add_task(function()
                                stats.set_int("MPPLY_XMASLIVERIES", -1)
                                for i = 1, 20 do
                                    stats.set_int("MPPLY_XMASLIVERIES" .. i, -1)
                                end
                            end)
                        end

                        if ImGui.Button("Unlock LSCarMeet podium prize") then
                            yu.add_task(function()
                                stats.set_bool(yu.mpx().."CARMEET_PV_CHLLGE_CMPLT", true)
                                stats.set_bool(yu.mpx().."CARMEET_PV_CLMED", false)
                            end)
                        end
                        yu.rendering.tooltip("Go in LSCarMeet to claim in interaction menu")

                        if ImGui.Button("LSCarMeet unlocks") then
                            yu.add_task(function()
                                for i = 293419, 293446 do
                                    globals.set_float(i, 100000)
                                end
                            end)
                        end

                        if ImGui.Button("Unlock flightschool stuff") then
                            yu.add_task(function()
                                stats.set_int("MPPLY_NUM_CAPTURES_CREATED", math.max(stats.get_int("MPPLY_NUM_CAPTURES_CREATED") or 0, 100))
                                for i = 0, 9 do
                                    stats.set_int("MPPLY_PILOT_SCHOOL_MEDAL_" .. i , -1)
                                    stats.set_int(yu.mpx().."PILOT_SCHOOL_MEDAL_" .. i, -1)
                                    stats.set_bool(yu.mpx().."PILOT_ASPASSEDLESSON_" .. i, true)
                                end
                            end)
                        end
                        yu.rendering.tooltip("MPPLY_NUM_CAPTURES_CREATED > 100\nMPPLY_PILOT_SCHOOL_MEDAL_[0-9] = -1\n$MPX_PILOT_SCHOOL_MEDAL_[0-9] = -1\n$MPX_PILOT_ASPASSEDLESSON_[0-9] = true")

                        if ImGui.Button("Unlock shooting range") then
                            yu.add_task(function()
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
                            yu.add_task(function()
                                for i = 1, 16 do
                                    stats.set_bool_masked(yu.mpx().."ARENAWARSPSTAT_BOOL0", true, i)
                                end
                                for i = 11, 19 do
                                    stats.set_bool_masked(yu.mpx().."ARENAWARSPSTAT_BOOL2", true, i)
                                end
                            end)
                        end

                        if ImGui.Button("Unlock colored headlights") then
                            yu.add_task(function()
                                for i = 18, 29 do
                                    stats.set_bool_masked(yu.mpx().."ARENAWARSPSTAT_BOOL0", true, i)
                                end
                            end)
                        end

                        if ImGui.Button("Unlock fast run and reload") then
                            yu.add_task(function()
                                for i = 1, 3 do
                                    stats.set_int(yu.mpx().."CHAR_ABILITY_"..i.."_UNLCK", -1)
                                    stats.set_int(yu.mpx().."CHAR_FM_ABILITY_"..i.."_UNLCK", -1)
                                end
                            end)
                        end
                        yu.rendering.tooltip("Makes you run and reload weapons faster")

                        if ImGui.Button("Unlock baseball bat and knife skins in gunvan") then
                            yu.add_task(function()
                                globals.set_int(262145 + 34131, 0)
                                globals.set_int(262145 + 34094 + 9, -1716189206) -- Knife
                                globals.set_int(262145 + 34094 + 10, -1786099057) -- Baseball bat
                            end)
                        end

                        if ImGui.Button("Unlock all tattos") then
                            yu.add_task(function()
                                local mpx = yu.mpx()
                                stats.set_int(mpx.."TATTOO_FM_CURRENT_32", -1)
                                for i = 0, 47 do
                                    stats.set_int(mpx.."TATTOO_FM_UNLOCKS_"..i, -1)
                                end
                            end)
                        end

                        if ImGui.Button("CEO & MC money clutter") then
                            yu.add_task(function()
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
                            yu.add_task(function()
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
                            yu.add_task(function()
                                stats.set_int(yu.mpx("YACHT_MISSION_PROG"), 0)
                                stats.set_int(yu.mpx("YACHT_MISSION_FLOW"), 21845)
                                stats.set_int(yu.mpx("CASINO_DECORATION_GIFT_1"), -1)
                            end)
                        end

                        if ImGui.Button("Skip ULP missions") then
                            yu.add_task(function()
                                stats.set_int(yu.mpx("ULP_MISSION_PROGRESS"), 127)
                                stats.set_int(yu.mpx("ULP_MISSION_CURRENT"), 0)
                            end)
                        end

                        if ImGui.Button("Unlock LSC stuff & paints") then
                            yu.add_task(function()
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
                            yu.add_task(function()
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
                            yu.add_task(function()
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
                            yu.add_task(function()
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
                            yu.add_task(function()
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

                        if ImGui.Button("Unlock guns") then
                            yu.add_task(function()
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

                        if ImGui.Button("Very much things") then
                            yu.add_task(function()
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

                        if ImGui.Button("Unlock gunvan guns") then
                            yu.add_task(function()
                                globals.set_int(296276, 0)
                                globals.set_int(296242, -22923932) -- Railgun
                                globals.set_int(296243, 1171102963) -- Stungun
                                globals.set_int(296244, -1355376991) -- Up-n-Atomizer
                                globals.set_int(296245, -1238556825) -- Widowmaker
                                globals.set_int(296246, 1198256469) -- Hellbringer
                                globals.set_int(296247, -1786099057) -- Bat
                            end)
                        end

                        ImGui.Separator()

                        renderCrewRank()

                        ImGui.EndTabItem()
                    end

                    if ImGui.BeginTabItem("CMM") then
                        ImGui.Text("Works best when low ping / session host")

                        for k, v in pairs({
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
                        }) do
                            if ImGui.Button(v) then
                                yu.add_task(function()
                                    run_script(k)
                                end)
                            end
                        end

                        ImGui.EndTabItem()
                    end
                end

                if ImGui.BeginTabItem("Misc") then
                    if SussySpt.in_online then
                        yu.rendering.renderCheckbox("Remove kosatka missle cooldown", "misc_kmcd", function(state)
                            globals.set_int(292539, yu.shc(state, 0, 60000))
                        end)

                        yu.rendering.renderCheckbox("Higher kosatka missle range", "misc_hkmr", function(state)
                            globals.set_int(292540, yu.shc(state, 4000, 99999))
                        end)

                        yu.rendering.renderCheckbox("Snow", "misc_snow", function(state)
                            globals.set_int(266897, yu.shc(state, 1, 0))
                        end)
                    end

                    ImGui.Separator()
                    yu.rendering.bigText("Singleplayer")

                    for k, v in pairs(a.spCash) do
                        renderSPCash(k)
                    end

                    if ImGui.Button("Apply cash") then
                        yu.add_task(function()
                            for k, v in pairs(a.spCash) do
                                stats.set_int("SP"..k.."_TOTAL_CASH", v)
                            end
                        end)
                    end

                    ImGui.EndTabItem()
                end

                if SussySpt.in_online and ImGui.BeginTabItem("Money") then
                    local om1sMoneyMade = yu.get_stat("SELF_MONEY_1M1SLOOP_MM", 0)
                    if om1sMoneyMade > 0 then
                        ImGui.Text("Money made: "..yu.format_num(om1sMoneyMade))
                    end
                    yu.rendering.renderCheckbox("$1M/1s loop", "self_money_1m1sloop", function(state)
                        if state then
                            yu.rif(function(runscript)
                                while true do
                                    if not SussySpt.in_online or not yu.rendering.isCheckboxChecked("self_money_1m1sloop") then
                                        log.info("Self->Money: $1M/1s loop was cancelled")
                                        break
                                    end

                                    local i = 4536533
                                    globals.set_int(i + 1, 2147483646)
                                    globals.set_int(i + 7, 2147483647)
                                    globals.set_int(i + 6, 0)
                                    globals.set_int(i + 5, 0)
                                    globals.set_int(i + 3, 0x615762F1)
                                    globals.set_int(i + 2, 1000000)
                                    globals.set_int(i, 1)

                                    yu.set_stat("SELF_MONEY_1M1SLOOP_MM", yu.get_stat("SELF_MONEY_1M1SLOOP_MM", 0) + 1000000)

                                    runscript:sleep(1000)
                                end
                            end)
                        end
                    end)
                    yu.rendering.tooltip("This is a pure copy from SilentNight! DC: silentsalo")

                    ImGui.EndTabItem()
                end

                ImGui.EndTabBar()
            end
            ImGui.End()
            SussySpt.popStyle()
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

    local tab = tbs.getTab(SussySpt.tab, " Stats")

    local function refreshStats()
        tab:clear()

        tab:add_button("Refresh", function()
            refreshStats()
        end)
        tab:add_separator()

        tab:add_imgui(function()
            ImGui.BeginGroup()
        end)
        tab:add_text("Marked as:")
        tab:add_text("  - Is cheater: "..yesNoBool(stats.get_bool("MPPLY_IS_CHEATER")))
        tab:add_text("  - Was i badsport: "..yesNoBool(stats.get_bool("MPPLY_WAS_I_BAD_SPORT")))
        tab:add_text("  - Is high earner: "..yesNoBool(stats.get_bool("MPPLY_IS_HIGH_EARNER")))
        tab:add_imgui(function()
            ImGui.EndGroup()
            ImGui.SameLine()
            ImGui.BeginGroup()
        end)
        tab:add_text("Reports:")
        tab:add_text("  - Griefing: "..stats.get_int("MPPLY_GRIEFING"))
        tab:add_text("  - Exploits: "..stats.get_int("MPPLY_EXPLOITS"))
        tab:add_text("  - Game exploits: "..stats.get_int("MPPLY_GAME_EXPLOITS"))
        tab:add_text("  - Text chat > Annoying me: "..stats.get_int("MPPLY_TC_ANNOYINGME"))
        tab:add_text("  - Text chat > Hate Speech: "..stats.get_int("MPPLY_TC_HATE"))
        tab:add_text("  - Voice chat > Annoying me: "..stats.get_int("MPPLY_VC_ANNOYINGME"))
        tab:add_text("  - Voice chat > Hate Speech: "..stats.get_int("MPPLY_VC_HATE"))
        tab:add_text("  - Offensive language: "..stats.get_int("MPPLY_OFFENSIVE_LANGUAGE"))
        tab:add_text("  - Offensive tagplate: "..stats.get_int("MPPLY_OFFENSIVE_TAGPLATE"))
        tab:add_text("  - Offensive content: "..stats.get_int("MPPLY_OFFENSIVE_UGC"))
        tab:add_text("  - Bad crew name: "..stats.get_int("MPPLY_BAD_CREW_NAME"))
        tab:add_text("  - Bad crew motto: "..stats.get_int("MPPLY_BAD_CREW_MOTTO"))
        tab:add_text("  - Bad crew status: "..stats.get_int("MPPLY_BAD_CREW_STATUS"))
        tab:add_text("  - Bad crew emblem: "..stats.get_int("MPPLY_BAD_CREW_EMBLEM"))
        tab:add_text("  - Friendly: "..stats.get_int("MPPLY_FRIENDLY"))
        tab:add_text("  - Helpful: "..stats.get_int("MPPLY_HELPFUL"))
        tab:add_imgui(function()
            ImGui.EndGroup()
            ImGui.SameLine()
            ImGui.BeginGroup()
        end)
        tab:add_text("Other:")
        tab:add_text("  - Earned Money: "..yu.format_num(stats.get_int("MPPLY_TOTAL_EVC")))
        tab:add_text("  - Spent Money: "..yu.format_num(stats.get_int("MPPLY_TOTAL_SVC")))
        tab:add_text("  - Players Killed: "..stats.get_int("MPPLY_KILLS_PLAYERS"))
        tab:add_text("  - Deatsh per player: "..stats.get_int("MPPLY_DEATHS_PLAYER"))
        tab:add_text("  - PvP K/D Ratio: "..stats.get_int("MPPLY_KILL_DEATH_RATIO"))
        tab:add_text("  - Deathmatches Published: "..stats.get_int("MPPLY_AWD_FM_CR_DM_MADE"))
        tab:add_text("  - Races Published: "..stats.get_int("MPPLY_AWD_FM_CR_RACES_MADE"))
        tab:add_text("  - Screenshots Published: "..stats.get_int("MPPLY_NUM_CAPTURES_CREATED"))
        tab:add_text("  - LTS Published: "..stats.get_int("MPPLY_AWD_FM_CR_RACES_MADE"))
        tab:add_text("  - Persons who have played your misions: "..stats.get_int("MPPLY_AWD_FM_CR_PLAYED_BY_PEEP"))
        tab:add_text("  - Likes to missions: "..stats.get_int("MPPLY_AWD_FM_CR_MISSION_SCORE"))
        tab:add_text("  - Traveled (metters): "..stats.get_int("MPPLY_CHAR_DIST_TRAVELLED"))
        tab:add_text("  - Swiming: "..stats.get_int(yu.mpx().."DIST_SWIMMING"))
        tab:add_text("  - Walking: "..stats.get_int(yu.mpx().."DIST_WALKING"))
        tab:add_text("  - Running: "..stats.get_int(yu.mpx().."DIST_RUNNING"))
        tab:add_text("  - Highest fall without dying: "..stats.get_int(yu.mpx().."LONGEST_SURVIVED_FREEFALL"))
        tab:add_text("  - Driving Cars: "..stats.get_int(yu.mpx().."DIST_CAR"))
        tab:add_text("  - Driving motorbikes: "..stats.get_int(yu.mpx().."DIST_BIKE"))
        tab:add_text("  - Flying Helicopters: "..stats.get_int(yu.mpx().."DIST_HELI"))
        tab:add_text("  - Flying Planes: "..stats.get_int(yu.mpx().."DIST_PLANE"))
        tab:add_text("  - Driving Botes: "..stats.get_int(yu.mpx().."DIST_BOAT"))
        tab:add_text("  - Driving ATVs: "..stats.get_int(yu.mpx().."DIST_QUADBIKE"))
        tab:add_text("  - Driving Bicycles: "..stats.get_int(yu.mpx().."DIST_BICYCLE"))
        tab:add_text("  - Longest Front Willie: "..stats.get_int(yu.mpx().."LONGEST_STOPPIE_DIST"))
        tab:add_text("  - Longest Willie: "..stats.get_int(yu.mpx().."LONGEST_WHEELIE_DIST"))
        tab:add_text("  - Largest driving without crashing: "..stats.get_int(yu.mpx().."LONGEST_DRIVE_NOCRASH"))
        tab:add_text("  - Longest Jump: "..stats.get_int(yu.mpx().."FARTHEST_JUMP_DIST"))
        tab:add_text("  - Longest Jump in Vehicle: "..stats.get_int(yu.mpx().."HIGHEST_JUMP_REACHED"))
        tab:add_text("  - Highest Hidraulic Jump: "..stats.get_int(yu.mpx().."LOW_HYDRAULIC_JUMP"))
        tab:add_imgui(function()
            ImGui.EndGroup()
        end)
    end

    -- refreshStats()
end

function SussySpt:initTabHBO()
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
                yu.rendering.tooltip("Pros don't need this ;)")

                ImGui.PopItemWidth()

                ImGui.Spacing()

                if ImGui.Button("Apply##stats") then
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
                    yu.add_task(refreshStats)
                end

                ImGui.SameLine()

                if ImGui.Button("Reload planning board") then
                    if requireScript("heist_island_planning") then
                        locals.set_int("heist_island_planning", 1526, 2)
                    end
                end

                if ImGui.Button("Unlock accesspoints & approaches") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx().."H4CNF_BS_GEN", -1)
                        stats.set_int(yu.mpx().."H4CNF_BS_ENTR", 63)
                        stats.set_int(yu.mpx().."H4CNF_APPROACH", -1)
                        yu.notify("POI, accesspoints, approaches stuff should be unlocked i think", "Cayo Perico Heist")
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Remove npc cuts") then
                    yu.add_task(function()
                        globals.set_float(291786, 0)
                        globals.set_float(291787, 0)
                    end)
                end
                yu.rendering.tooltip("I think no one wants to add them back...")

                if ImGui.Button("Complete Preps") then
                    yu.add_task(function()
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

                yu.rendering.bigText("Cuts")

                renderCutsSlider(a.cuts, 1)
                renderCutsSlider(a.cuts, 2)
                renderCutsSlider(a.cuts, 3)
                renderCutsSlider(a.cuts, 4)
                renderCutsSlider(a.cuts, -2)

                if ImGui.Button("Apply##cuts") then
                    for k, v in pairs(a.cuts) do
                        if k == -2 then
                            globals.set_int(2722097, v)
                        else
                            globals.set_int(1978495 + 881 + k, v)
                        end
                    end
                end

                ImGui.SameLine()

                if ImGui.Button("Refresh##cuts") then
                    yu.add_task(refreshCuts)
                end

                ImGui.EndGroup()
                ImGui.Separator()
                ImGui.BeginGroup()

                yu.rendering.bigText("Extra")

                if ImGui.Button("Remove all cameras") then
                    yu.add_task(removeAllCameras)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip printing cutscene") then
                    yu.add_task(function()
                        if locals.get_int("fm_mission_controller", 22032) == 4 then
                            locals.set_int("fm_mission_controller", 22032, 5)
                        end
                    end)
                end
                yu.rendering.tooltip("Idfk what this is or what this does")

                if ImGui.Button("Skip sewer tunnel cut") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller_2020")
                            and (locals.get_int("fm_mission_controller_2020", 28446) >= 3
                                or locals.get_int("fm_mission_controller_2020", 28446) <= 6) then
                            locals.set_int("fm_mission_controller_2020", 28446, 6)
                            yu.notify("Skipped sewer tunnel cut (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip door hack") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller_2020")
                            and locals.get_int("fm_mission_controller_2020", 54024) ~= 4 then
                            locals.set_int("fm_mission_controller_2020", 54024, 5)
                            yu.notify("Skipped door hack (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                if ImGui.Button("Skip fingerprint hack") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller_2020")
                            and locals.get_int("fm_mission_controller_2020", 23669) == 4 then
                            locals.set_int("fm_mission_controller_2020", 23669, 5)
                            yu.notify("Skipped fingerprint hack (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip plasmacutter cut") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller_2020") then
                            locals.set_float("fm_mission_controller_2020", 29685 + 3, 100)
                            yu.notify("Skipped plasmacutter cut (or?)", "Cayo Perico Heist")
                        end
                    end)
                end

                if ImGui.Button("Obtain the primary target") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller_2020") then
                            locals.set_int("fm_mission_controller_2020", 29684, 5)
                            locals.set_int("fm_mission_controller_2020", 29685, 3)
                        end
                    end)
                end
                yu.rendering.tooltip("It works i guess but the object will not get changed")

                ImGui.SameLine()

                if ImGui.Button("Remove the drainage pipe") then
                    yu.add_task(function()
                        deleteEntityByName("prop_chem_grill_bit")
                    end)
                end
                yu.rendering.tooltip("This is good")

                if ImGui.Button("Instant finish") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller_2020") then
                            locals.set_int("fm_mission_controller_2020", 45450, 9)
                            locals.set_int("fm_mission_controller_2020", 46829, 50)
                            yu.notify("Idk if you should use this but i i capitan", "Cayo Perico Heist")
                        end
                    end)
                end
                yu.rendering.tooltip("This is really weird and only you get money i think")

                ImGui.Spacing()

                if ImGui.Button("Refresh##extra") then
                    yu.add_task(refreshExtra)
                end

                ImGui.PushItemWidth(390)

                local lifesValue, lifesChanged = ImGui.SliderInt("Lifes", a.lifes, 0, 10)
                yu.rendering.tooltip("Only works when you are playing alone (i think)")
                if lifesChanged then
                    a.lifes = lifesValue
                end

                ImGui.SameLine()

                if ImGui.Button("Apply##lifes") then
                    if requireScript("fm_mission_controller_2020") then
                        locals.set_int("fm_mission_controller_2020", 43059 + 865 + 1, a.lifes)
                    end
                end

                local realTakeValue, realTakeChanged = ImGui.SliderInt("Real take", a.realtake, 100000, 8691000, yu.format_num(a.realtake))
                yu.rendering.tooltip("Set real take to 2,897,000 for 100% or smth")
                if realTakeChanged then
                    a.realtake = realTakeValue
                end

                ImGui.SameLine()

                if ImGui.Button("Apply##realtake") then
                    if requireScript("fm_mission_controller_2020") then
                        locals.set_int("fm_mission_controller_2020", 43152, a.realtake)
                    end
                end

                ImGui.Text("Simulate bag for:")
                for i = 1, 4 do
                    ImGui.SameLine()
                    if ImGui.Button(i.." Player"..yu.shc(i == 1, "", "s")) then
                        yu.add_task(function()
                            globals.set_int(292084, 1800 * i)
                        end)
                    end
                end

                ImGui.PopItemWidth()
                ImGui.Separator()

                if ImGui.Button("Refresh##cooldowns") then
                    yu.add_task(refreshCooldowns)
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
                cooldowns[k] = " "..v..": "..yu.format_seconds(stats.get_int(yu.mpx()..v) - os.time())
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
                    yu.add_task(function()
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
                    yu.add_task(refreshStats)
                end

                ImGui.SameLine()

                if ImGui.Button("Reload planning board") then
                    yu.add_task(function()
                        local oldBS0 = stats.get_int("H3OPT_BITSET0")
                        local oldBS1 = stats.get_int("H3OPT_BITSET1")
                        local integerLimit = 2147483647
                        stats.set_int("H3OPT_BITSET0", math.random(integerLimit))
                        stats.set_int("H3OPT_BITSET1", math.random(integerLimit))
                        yu.add_task(function()
                            stats.set_int("H3OPT_BITSET0", oldBS0)
                            stats.set_int("H3OPT_BITSET1", oldBS1)
                        end)
                    end)
                end
                yu.rendering.tooltip("I think this only works when opened")

                if ImGui.Button("Unlock POI & accesspoints") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx().."H3OPT_POI", -1)
                        stats.set_int(yu.mpx().."H3OPT_ACCESSPOINTS", -1)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Remove npc cuts") then
                    yu.add_task(function()
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
                    yu.add_task(function()
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
                    yu.add_task(function()
                        stats.set_int(yu.mpx().."H4_MISSIONS", 0)
                        stats.set_int(yu.mpx().."H4_PROGRESS", 0)
                        stats.set_int(yu.mpx().."H4CNF_APPROACH", 0)
                        stats.set_int(yu.mpx().."H4CNF_BS_ENTR", 0)
                        stats.set_int(yu.mpx().."H4CNF_BS_GEN", 0)
                        stats.set_int(yu.mpx().."H3OPT_POI", 0)
                        stats.set_int(yu.mpx().."H3OPT_ACCESSPOINTS", 0)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Unlock cancellation") then
                    yu.add_task(function()
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
                            globals.set_int(2722097, v)
                        else
                            globals.set_int(1969064 + k, v)
                        end
                    end
                end

                ImGui.SameLine()

                if ImGui.Button("Refresh##cuts") then
                    yu.add_task(refreshCuts)
                end

                ImGui.EndGroup()
                ImGui.Separator()
                ImGui.BeginGroup()

                yu.rendering.bigText("Extra")

                if ImGui.Button("Set all players ready") then
                    yu.add_task(function()
                        for i = 0, 3 do
                            globals.set_int(1974016 + i, -1)
                        end
                    end)
                end

                if ImGui.Button("Skip fingerprint hack") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller") and locals.get_int("fm_mission_controller", 52964) == 4 then
                            locals.set_int("fm_mission_controller", 52964, 5)
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip keypad hack") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller")
                            and locals.get_int("fm_mission_controller", 54026) ~= 4 then
                            locals.set_int("fm_mission_controller", 54026, 5)
                        end
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Skip vault door drill") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller") then
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
                    yu.add_task(refreshExtra)
                end

                local lifesValue, lifesChanged = ImGui.SliderInt("Lifes", a.lifes, 0, 10)
                yu.rendering.tooltip("Not tested")
                if lifesChanged then
                    a.lifes = lifesValue
                end

                ImGui.SameLine()

                if ImGui.Button("Apply##lifes") then
                    if requireScript("fm_mission_controller") then
                        locals.set_int("fm_mission_controller", 27400, a.lifes)
                    end
                end

                ImGui.Separator()

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
            if requireScript("casino_lucky_wheel") and yu.is_num_between(prize, 0, 18) then
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
                    yu.add_task(function()
                        stats.set_int(yu.mpx("VCM_STORY_PROGRESS"), storyMissionIds[storyMission])
                        stats.set_int(yu.mpx("VCM_FLOW_PROGRESS"), storyMission)
                    end)
                end

                ImGui.EndTabItem()
            end
        end)

        local slots_random_results_table = 1344

        SussySpt.register_repeating_task(function()
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

        local function refillStorage(k)
            yu.add_task(function()
                stats.set_int(yu.mpx("HUB_PROD_TOTAL_"..k), a.storages[k][3])
                refresh()
            end)
        end

        addToRender(4, function()
            if (ImGui.BeginTabItem("Nightclub")) then
                if ImGui.Button("Refresh") then
                    yu.add_task(refresh)
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
                    yu.add_task(function()
                        stats.set_int(yu.mpx().."CLUB_POPULARITY", a.popularity)
                        refresh()
                    end)
                end
                yu.rendering.tooltip("Set the popularity to the input field")

                ImGui.SameLine()

                if ImGui.Button("Refill##popularity") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx().."CLUB_POPULARITY", 1000)
                        a.popularity = 1000
                        refresh()
                    end)
                end
                yu.rendering.tooltip("Set the popularity to 1000")

                if ImGui.Button("Pay now") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx("CLUB_PAY_TIME_LEFT"), -1)
                    end)
                end
                yu.rendering.tooltip("This will decrease the popularity by 50 and will put $50k in the safe.")

                ImGui.SameLine()

                if ImGui.Button("Collect money") then
                    yu.add_task(ensureScriptAndCollectSafe)
                end
                yu.rendering.tooltip("Experimental")

                ImGui.EndGroup()
                ImGui.BeginGroup()
                yu.rendering.bigText("Storage")

                if ImGui.BeginTable("##storage_table", 4, 3905) then
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
                            ImGui.TableSetColumnIndex(3)
                            if ImGui.SmallButton("Refill##storage") then
                                refillStorage(k)
                            end
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
                    yu.add_task(function()
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
            a.heist = yu.get_key_from_table(a.heistsids, globals.get_int(1934636 + 3008 + 1), 1)
            a.heistchanged = false
        end

        refresh()

        addToRender(5, function()
            if (ImGui.BeginTabItem("Apartment Heists")) then
                ImGui.BeginGroup()

                if ImGui.Button("Refresh") then
                    yu.add_task(refresh)
                end

                yu.rendering.bigText("Preperations")

                local hr = yu.rendering.renderList(a.heists, a.heist, "hbo_apartment_heist", "Heist")
                if hr.changed then
                    a.heist = hr.key
                    a.heistchanged = true
                end

                if ImGui.Button("Apply") then
                    yu.add_task(function()
                        local changes = 0

                        -- Heist
                        if a.heistchanged then
                            changes = yu.add(changes, 1)
                            globals.set_int(1934636 + 3008 + 1, a.heistsids[a.heist])
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

                if ImGui.Button("Complete preps") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx().."HEIST_PLANNING_STAGE", -1)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset preps") then
                    yu.add_task(function()
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
                    yu.add_task(function()
                        if requireScript("fm_mission_controller") then
                            locals.set_int("fm_mission_controller", 11760 + 24, 7)
                        end
                    end)
                end
                yu.rendering.tooltip("When being passenger, you need to play snake.")

                ImGui.SameLine()

                if ImGui.Button("Skip drill##fleeca") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller") then
                            locals.set_int("fm_mission_controller", 10061 + 11, 100)
                        end
                    end)
                end
                yu.rendering.tooltip("Skip drilling")

                ImGui.SameLine()

                if ImGui.Button("Instant finish (solo only)##fleeca") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller") then
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

                -- ImGui.SameLine()

                -- if ImGui.Button("$15m fleeca cuts") then
                --     yu.add_task(function()
                --     end)
                -- end

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
                    yu.add_task(refresh)
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
                    yu.add_task(function()
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
                    yu.add_task(function()
                        stats.set_int(yu.mpx("TUNER_GEN_BS"), -1)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset Preps") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx("TUNER_GEN_BS"), 12467)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset contract") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx("TUNER_GEN_BS"), 8371)
                        stats.set_int(yu.mpx("TUNER_CURRENT"), -1)
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Reset stats") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx("TUNER_COUNT"), 0)
                        stats.set_int(yu.mpx("TUNER_EARNINGS"), 0)
                    end)
                end
                yu.rendering.tooltip("This will set how many contracts you've done to 0 and how much you earned from it")

                if ImGui.Button("Instant finish") then
                    yu.add_task(function()
                        if requireScript("fm_mission_controller_2020") then
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
                    yu.add_task(refreshCooldowns)
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
                    yu.add_task(refresh)
                end

                ImGui.Spacing()

                ImGui.Text("Cooldown: "..yu.format_seconds(a.daxcooldown))
                if ImGui.Button("Remove Dax cooldown") then
                    yu.add_task(function()
                        stats.set_int(yu.mpx("XM22JUGGALOWORKCDTIMER"), os.time() - 17)
                    end)
                end

                ImGui.Spacing()

                ImGui.Text("Production delay ["..a.productiondelay.."]:")

                ImGui.SameLine()

                if ImGui.Button("Reset") then
                    yu.add_task(function()
                        globals.set_int(a.productiondelayp, 135000)
                        refresh()
                    end)
                end

                ImGui.SameLine()

                if ImGui.Button("Set to 1") then
                    yu.add_task(function()
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

        SussySpt.register_repeating_task(function()
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
                    yu.add_task(function()
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
                    yu.add_task(refreshStats)
                end

                ImGui.SameLine()

                if ImGui.Button("Complete all missions") then
                    yu.add_task(function()
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
                    yu.add_task(function()
                        globals.set_int(293490, yu.shc(state, 0, 300000))
                    end)
                end)

                yu.rendering.renderCheckbox("Remove security mission cooldown", "hbo_agency_smcd", function(state)
                    yu.add_task(function()
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
            if requireScript("gb_contraband_buy") then
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
            SussySpt.pushStyle()
            if ImGui.Begin("HBO (Heists, Businesses & Other)") then
                ImGui.BeginTabBar(tabBarId)

                for k, v in pairs(toRender) do
                    v()
                end

                ImGui.EndTabBar()
            end
            ImGui.End()
            SussySpt.popStyle()
        end
    end)
end

function SussySpt:initTabQA()
    SussySpt.add_render(function()
        if yu.rendering.isCheckboxChecked("cat_qa") then
            SussySpt.pushStyle()
            if ImGui.Begin("Quick actions") then
                if ImGui.Button("Heal") then
                    yu.add_task(function()
                        ENTITY.SET_ENTITY_HEALTH(yu.ppid(), PED.GET_PED_MAX_HEALTH(yu.ppid()), 0)
			            PED.SET_PED_ARMOUR(yu.ppid(), PLAYER.GET_PLAYER_MAX_ARMOUR(yu.pid()))
                    end)
                end
                yu.rendering.tooltip("Refill health & armor")

                ImGui.SameLine()

                if ImGui.Button("Refill health") then
                    yu.add_task(function()
                        ENTITY.SET_ENTITY_HEALTH(yu.ppid(), PED.GET_PED_MAX_HEALTH(yu.ppid()), 0)
                    end)
                end
                yu.rendering.tooltip("Refill health")

                ImGui.SameLine()

                if ImGui.Button("Refill armor") then
                    yu.add_task(function()
                        PED.SET_PED_ARMOUR(yu.ppid(), PLAYER.GET_PLAYER_MAX_ARMOUR(yu.pid()))
                    end)
                end
                yu.rendering.tooltip("Refill armor")

                ImGui.SameLine()

                if ImGui.Button("Clear wanted level") then
                    yu.add_task(function()
                        PLAYER.CLEAR_PLAYER_WANTED_LEVEL(yu.pid())
                    end)
                end
                yu.rendering.tooltip("CLEAR_PLAYER_WANTED_LEVEL")

                if ImGui.Button("Refresh interior") then
                    yu.add_task(function()
				        INTERIOR.REFRESH_INTERIOR(INTERIOR.GET_INTERIOR_FROM_ENTITY(yu.ppid()))
                    end)
                end
                yu.rendering.tooltip("Refreshes the interior you are currently in.\nGood for when interior is invisible or not rendering correctly.\nMay not always work.")

                ImGui.SameLine()

                if ImGui.Button("Skip cutscene") then
                    yu.add_task(function()
                        CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
                    end)
                end
                yu.rendering.tooltip("There are some unskippable cutscenes where this doesn't work.")

                ImGui.SameLine()

                if ImGui.Button("Remove blackscreen") then
                    yu.add_task(function()
                        CAM.DO_SCREEN_FADE_IN(0)
                    end)
                end
                yu.rendering.tooltip("Remove the blackscreen :D")

                ImGui.SameLine()

                if ImGui.Button("Stop player switch") then
                    yu.add_task(function()
                        STREAMING.STOP_PLAYER_SWITCH()
                        if CAM.IS_SCREEN_FADED_OUT() then
                            CAM.DO_SCREEN_FADE_IN(0)
                        end
                        HUD.CLEAR_HELP(true)
                        HUD.SET_FRONTEND_ACTIVE(true)
                        SCRIPT.SHUTDOWN_LOADING_SCREEN()
                    end)
                end
                yu.rendering.tooltip("Tries to make you able to interact with your surroundings")

                if ImGui.Button("Repair vehicle") then
                    yu.add_task(function()
                        local veh = yu.veh()
                        if veh ~= nil then
                            VEHICLE.SET_VEHICLE_FIXED(veh)
                            VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, .0)
                        end
                    end)
                end
                yu.rendering.tooltip("Repairs the vehicle.\nUse with caution because this closes doors and stuff.")

                ImGui.SameLine()

                if ImGui.Button("Clear ped tasks") then
                    yu.add_task(function()
                        TASK.CLEAR_PED_TASKS_IMMEDIATELY(yu.ppid())
                    end)
                end
                yu.rendering.tooltip("Makes the player stop what it's doing")

                ImGui.SameLine()

                if ImGui.Button("RI2") then
                    yu.rif(function()
				        local c = ENTITY.GET_ENTITY_COORDS(yu.ppid())
                        PED.SET_PED_COORDS_KEEP_VEHICLE(yu.ppid(), c.x, c.y, c.z - 1)
                    end)
                end
                yu.rendering.tooltip("Other way of refreshing the interior")

                if SussySpt.in_online then
                    if ImGui.Button("Instant BST") then
                        globals.set_int(2672524 + 3690, 1)
                    end
                    yu.rendering.tooltip("Give bullshark testosterone.\nYou will receive less damage and do more damage.")

                    ImGui.SameLine()

                    if ImGui.Button("Deposit wallet") then
                        yu.add_task(function()
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
            SussySpt.popStyle()
        end
    end)
end

function SussySpt:initTabHeist()
    local tab = tbs.getTab(SussySpt.tab, " Heists & Stuff idk")
    tab:clear()

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
end

SussySpt:new()
