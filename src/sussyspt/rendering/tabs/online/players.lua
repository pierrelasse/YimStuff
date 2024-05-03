local tasks = require("sussyspt/tasks")
local networkent = require("sussyspt/util/networkent")
local networkobj = require("sussyspt/util/networkobj")

local exports = {}

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Players")

    local a = {
        playerlistwidth = 211,

        searchtext = "",

        players = {},

        open = 0,

        selectedplayer = nil,
        selectedplayerinfo = {},

        namecolors = require("./players/namecolors"),

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
            ["Action Figure - Alien"] = "vw_prop_vw_colle_alien",
            ["Tresure chest (has delay)"] = "tr_prop_tr_chest_01a",
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

                        v.info.vehicle[2] = v.info.vehicle[2]..".".." Type: "..vehicles.get_vehicle_display_name(vehicleHash)

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
                local function yay()
                    local err = yu.removeErrorPath(result)
                    log.warning("Error while updating the playerlist(line "..err[2].."): "..err[3])
                end
                local success2, result2 = pcall(yay)
                if not success2 then
                    log.warning("Error while error while updaing the playerlist: "..tostring(result2))
                end
            end

            local isOpen = a.open > 0
            rs:sleep(isOpen and 250 or 1500)
            if isOpen then
                a.open = a.open - 1
            end
        end
    end)

    yu.rendering.setCheckboxChecked("online_players_ram_delete")

    function tab.render() -- SECTION Render
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
                                tasks.addTask(function()
                                    local c = yu.coords(player.ped)
                                    PED.SET_PED_COORDS_KEEP_VEHICLE(yu.ppid(), c.x, c.y, c.z - 1)
                                end)
                            end
                            yu.rendering.tooltip("Teleport yourself to the player")

                            ImGui.SameLine()

                            if ImGui.SmallButton("Bring") then
                                tasks.addTask(function()
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
                                tasks.addTask(function()
                                    local c = yu.coords(player.ped)
                                    HUD.SET_NEW_WAYPOINT(c.x, c.y)
                                end)
                            end
                            yu.rendering.tooltip("Sets a waypoint to them")

                            if SussySpt.dev then
                                ImGui.SameLine()

                                if ImGui.SmallButton("Waypoint") then
                                    tasks.addTask(function()
                                        local blip = 8 -- radar_waypoint
                                        if HUD.DOES_BLIP_EXIST(blip) then
                                            local c = HUD.GET_BLIP_COORDS(blip)
                                            network.set_player_coords(player.player, c.x, c.y, c.z)
                                        end
                                    end)
                                end
                                yu.rendering.tooltip("Does not work well / teleports them under the map")
                            end

                            do
                                local text, changed = ImGui.InputTextWithHint("##mark_input", "Reason...", a.markinput or "", 128)
                                SussySpt.pushDisableControls(ImGui.IsItemActive())
                                if changed then a.markinput = text end
                                ImGui.SameLine()
                                if ImGui.Button("Mark") and a.markinput ~= nil then
                                    network.flag_player_as_modder(player.player, infraction.CUSTOM_REASON, a.markinput)
                                    SussySpt.debug("Marked "..player.name.." as a modder for '"..a.markinput.."'")
                                end
                            end

                            yu.rendering.renderCheckbox("Spectate", "online_players_spectate", function(state)
                                tasks.addTask(function()
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
                                tasks.addTask(function()
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
                                tasks.addTask(function()
                                    network.trigger_script_event(1 << player.player, { -13748324, yu.pid(), 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
                                end)
                            end

                            ImGui.Text("Explode:")
                            do
                                ImGui.SameLine()
                                if ImGui.SmallButton("Invisible") then
                                    tasks.addTask(function()
                                        local c = yu.coords(player.ped)
                                        FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 72, 80, false, true, 0, false)
                                    end)
                                end
                                yu.rendering.tooltip("\"Random\" death")
                                ImGui.SameLine()
                                if ImGui.SmallButton("Normal") then
                                    tasks.addTask(function()
                                        local c = yu.coords(player.ped)
                                        FIRE.ADD_EXPLOSION(c.x + 1, c.y + 1, c.z + 1, 4, 100, true, false, 0, false)
                                    end)
                                end
                                ImGui.SameLine()
                                if ImGui.SmallButton("Huge") then
                                    tasks.addTask(function()
                                        local c = yu.coords(player.ped)
                                        FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 82, 80, true, false, 1, false)
                                    end)
                                end
                                ImGui.SameLine()
                                if ImGui.SmallButton("Car") then
                                    tasks.addTask(function()
                                        local c = yu.coords(player.ped)
                                        FIRE.ADD_EXPLOSION(c.x, c.y, c.z, 7, 1, true, false, 0, false)
                                    end)
                                end
                            end

                            if ImGui.TreeNodeEx("Trap") then
                                if ImGui.SmallButton("Normal") then
                                    tasks.addTask(function()
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

                                        local function createObject(offsetX, offsetY, heading)
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
                                    tasks.addTask(function()
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
                                    tasks.addTask(function()
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
                                    tasks.addTask(function()
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
                                tasks.addTask(function()
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
                                tasks.addTask(function()
                                    WEAPON.GIVE_WEAPON_TO_PED(player.ped, joaat("GADGET_PARACHUTE"), 1, false, false)
                                end)
                            end
                            ImGui.SameLine()
                            if ImGui.SmallButton("Remove##remove_parachute") then
                                tasks.addTask(function()
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
                                tasks.addTask(function()
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
                                tasks.addTask(function()
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
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh)  then
                                        ENTITY.SET_ENTITY_INVINCIBLE(veh, state)
                                    end
                                end)
                            end)
                            yu.rendering.tooltip("Sets the vehicle in godmode")

                            ImGui.SameLine()

                            yu.rendering.renderCheckbox("Invisibility", "online_player_vehicleinvis", function(state)
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh)  then
                                        ENTITY.SET_ENTITY_VISIBLE(veh, not state, false)
                                    end
                                end)
                            end)
                            yu.rendering.tooltip("Sets the vehicle in godmode")

                            if ImGui.SmallButton("Repair") then
                                tasks.addTask(function()
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
                                tasks.addTask(function()
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
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh) then
                                        VEHICLE.SET_VEHICLE_MAX_SPEED(veh, .1)
                                    end
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.SmallButton("Engine off") then
                                tasks.addTask(function()
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
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh) then
                                        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, -4000)
                                    end
                                end)
                            end

                            if ImGui.SmallButton("Launch") then
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh) then
                                        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 0, 10000, 0, 0, 0, 0, false, true, true, false, true, true)
                                    end
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.SmallButton("Boost") then
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh) then
                                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, VEHICLE.GET_VEHICLE_ESTIMATED_MAX_SPEED(veh))
                                    end
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.SmallButton("Halt") then
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh) then
                                        VEHICLE.SET_VEHICLE_MAX_SPEED(veh, .1)
                                    end
                                end)
                            end

                            if ImGui.SmallButton("Burst tires") then
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh) then
                                        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, true)
                                        yu.loop(8, function(i)
                                            VEHICLE.SET_VEHICLE_TYRE_BURST(veh, i, true, 1000)
                                        end)
                                    end
                                end)
                            end

                            ImGui.SameLine()

                            if ImGui.SmallButton("Smash windows") then
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh) then
                                        yu.loop(8, function(i)
                                            VEHICLE.SMASH_VEHICLE_WINDOW(veh, i)
                                        end)
                                    end
                                end)
                            end

                            if ImGui.SmallButton("Kick from vehicle") then
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh) then
                                        TASK.TASK_LEAVE_VEHICLE(player.ped, veh, 0)
                                    end
                                end)
                            end
                            yu.rendering.tooltip("Doesn't work well")

                            ImGui.SameLine()

                            if ImGui.SmallButton("Flip") then
                                tasks.addTask(function()
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
                                tasks.addTask(function()
                                    local veh = yu.veh(player.ped)
                                    if veh ~= nil and entities.take_control_of(veh) then
                                        local rot = ENTITY.GET_ENTITY_ROTATION(veh, 2)
                                        rot.z = rot.z + 180
                                        ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z, 2, false)
                                    end
                                end)
                            end

                            if ImGui.SmallButton("Lock them inside") then
                                tasks.addTask(function()
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
                                tasks.addTask(function()
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
                                tasks.addTask(function()
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
                                tasks.addTask(function()
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
                                tasks.addTask(function()
                                    local modelHash = joaat("xm3_prop_xm3_present_01a")

                                    STREAMING.REQUEST_MODEL(modelHash)
                                    if (STREAMING.HAS_MODEL_LOADED(modelHash)) then
                                        local c = yu.coords(player.ped, true)

                                        local pickup = OBJECT.CREATE_AMBIENT_PICKUP(joaat("PICKUP_PORTABLE_FM_CONTENT_MISSION_ENTITY_SMALL"), c.x, c.y, c.z, 0, 0, modelHash, true, false)
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

                            if ImGui.SmallButton("Boat skin crash") then
                                require("sussyspt/rendering/tabs/online/players/boatskincrash")()
                            end
                        end
                    end

                    ImGui.EndListBox()
                end

                ImGui.EndGroup()
            end
        end
    end -- !SECTION

    parentTab.sub[1] = tab
end

return exports
