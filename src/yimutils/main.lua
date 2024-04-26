
do
    if yu ~= nil then return yu end

    local data = {}
    local api = {}

    do -- SECTION yimutils
        api.keys = require("./keys")

        api.internal_data = function() -- ANCHOR internal_data
            return data
        end

        api.get_unique_number = function() -- ANCHOR get_unique_number
            data.un = (data.un or 0) + 1
            return data.un
        end
        api.gun = api.get_unique_number
    end -- !SECTION

    do -- SECTION deprecated
        ---@deprecated
        api.add = function(num, amount) -- ANCHOR add
            return num + amount
        end

        ---@deprecated
        api.get_or_default = function(tbl, key, defaultValue)
            return tbl[key] or (defaultValue or "nil")
        end

        ---@deprecated
        api.get_all_players_2 = function()
            local handles = entities.get_all_peds_as_handles()
            if handles ~= nil then
                local players = {}
                for k, v in ipairs(handles) do
                    if k and v and api.does_entity_exist(v) and PED.IS_PED_A_PLAYER(v) then
                        players[k] = {
                            whatever = k,
                            ped = v,
                            player = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(v)
                        }
                    end
                end
                return players
            end
        end

        ---@deprecated
        api.xp_to_rank = function()
            return api.cache.xp_to_rank
        end
    end -- !SECTION

    do -- SECTION Lua - Utils
        api.shc = function(condition, trueValue, falseValue) -- ANCHOR shc
            return condition and trueValue or falseValue or true
        end

        api.format_num = function(num, _) -- ANCHOR format_num
            return string.format("%d", tostring(num))
                :reverse()
                :gsub("(%d%d%d)", "%1,")
                :reverse()
                :gsub("^,", "")
        end

        api.boolstring = function(bool, trueValue, falseValue) -- ANCHOR boolstring
            return bool and (trueValue or "true") or (falseValue or "false")
        end

        api.is_num_between = function(num, min, max) -- ANCHOR is_num_between
            if type(num) == "number" and type(min) == "number" and type(max) == "number" then
                return num >= min and num <= max
            end
            return false
        end

        api.get_between_or_default = function(num, min, max, defaultValue) -- ANCHOR get_between_or_default
            return api.is_num_between(num, min, max) and num or (defaultValue or min)
        end

        api.get_key_from_table = function(tbl, value, defaultValue) -- ANCHOR get_key_from_table
            for k, v in pairs(tbl) do
                if v == value then
                    return k
                end
            end
            return defaultValue
        end

        api.format_seconds = function(seconds, _) -- ANCHOR format_seconds
            if seconds < 0 then
                return -seconds.." ago"
            end

            local days = math.floor(seconds / (24 * 3600))
            local hours = math.floor((seconds % (24 * 3600)) / 3600)
            local minutes = math.floor((seconds % 3600) / 60)
            local secs = seconds % 60

            local t = ""

            if days > 0 then
                t = t..days.."d "
            end
            if hours > 0 then
                t = t..hours.."h "
            end
            if minutes > 0 then
                t = t..minutes.."m "
            end

            return t..secs.."s"
        end

        api.copy_table = function(tbl) -- ANCHOR copy_table
            if type(tbl) ~= "table" then
                return tbl
            end
            local newTable = {}
            for k, v in pairs(tbl) do
                if type(v) == "table" and v ~= tbl then
                    newTable[k] = api.copy_table(v)
                else
                    newTable[k] = v
                end
            end
            return newTable
        end

        api.splitText = function(inputText, delimiter) -- ANCHOR splitText
            return string.split(inputText, delimiter)
        end

        api.loop = function(amount, cb) -- ANCHOR loop
            if type(amount) ~= "number" or type(cb) ~= "function" or amount <= 0 then
                return nil
            end
            local i = 0
            while i < amount do
                i = i + 1
                cb(i)
            end
        end

        api.length = function(obj) -- ANCHOR length
            if type(obj) == "table" then
                local i = 0
                for k, v in pairs(obj) do
                    i = i + 1
                end
                return i
            elseif type(obj) == "string" then
                return string.len(obj)
            end
            return 0
        end
        api.len = api.length

        api.get_random_element_from_table = function(tbl) -- ANCHOR get_random_element_from_table
            if type(tbl) ~= "table" then
                return {}
            end
            local ctbl = {}
            local i = 0
            for k, v in pairs(tbl) do
                i = i + 1
                ctbl[i] = v
            end
            return ctbl[math.random(1, #ctbl)]
        end

        api.table_to_string = function(tbl) -- ANCHOR table_to_string
            if type(tbl) ~= "table" then
                return nil
            end
            local result = "{"
            local first = true
            for k, v in pairs(tbl) do
                if not first then
                    result = result..", "
                end
                if type(k) == "number" or type(k) == "string" then
                    if type(v) == "table" then
                        result = result..k.." = "..api.table_to_string(v)
                    elseif type(v) == "string" then
                        result = result..k..' = "'..v..'"'
                    else
                        result = result..k.." = "..tostring(v)
                    end
                    first = false
                end
            end
            return result.."}"
        end

        api.calculate_percentage = function(a, b) -- ANCHOR calculate_percentage
            if b == 0 then
                return b
            end
            return (a / b) * 100
        end

        api.cputms = function() -- ANCHOR cputms
            return os.clock() * 1000
        end

        api.removeErrorPath = function(s) -- ANCHOR removeErrorPath
            local maxAmount = yu.shc(s:getCharacterAtIndex(2) == ":", 4, 3)
            local values = string.split(s, ":", maxAmount)
            if yu.len(values) < 4 then
                return {
                    s,
                    -1,
                    s
                }
            end
            return {
                s, -- full error
                values[3], -- line
                values[4]:strip() -- error
            }
        end

        api.rgb_to_hex = function(r, g, b) -- ANCHOR rgb_to_hex
            if type(r) == "number" and type(g) == "number" and type(b) == "number" then
                return string.format("%02X%02X%02X", r, g, b)
            end
        end
    end -- !SECTION

    do -- SECTION Lua - Language
        function string.startswith(str, prefix)
            return (str == nil or prefix == nil or prefix == "") or str:sub(1, #prefix) == prefix
        end
        function string.endswith(str, ending)
            return (str == nil or ending == nil or ending == "") or str:sub(-#ending) == ending
        end
        function string.replace(str, what, with)
            if type(str) == "string" and type(what) == "string" and type(with) == "string" then
                return string.gsub(str, what, with)
            end
        end
        function string.uppercase(str)
            if type(str) == "string" then
                return string.upper(str)
            end
        end
        function string.lowercase(str)
            if type(str) == "string" then
                return string.lower(str)
            end
        end
        function string.contains(str, value)
            if type(str) == "string" and type(value) == "string" then
                return string.find(str, value, 1, true) ~= nil
            end
        end
        function string.containsregex(str, pattern)
            if type(str) == "string" then
                return string.match(str, pattern)
            end
        end
        function string.length(str)
            if type(str) == "string" then
                return string.len(str)
            end
        end
        function string.split(str, delimiters, max)
            local result = {} -- [0] = str
            if type(str) == "string" then
                if type(delimiters) == "string" then
                    delimiters = {delimiters}
                end
                if type(delimiters) == "table" then
                    local pattern = "("..table.concat(delimiters, "|")..")"
                    local count = 1
                    local doMax = type(max) == "number" and max > 0
                    for match in (str..table.concat(delimiters, "|")):gmatch("(.-)"..pattern) do
                        table.insert(result, match)
                        count = count + 1
                        if doMax and max and count > max then
                            break
                        end
                    end
                end
            end
            return result
        end
        function string.strip(str)
            if type(str) == "string" then
                return str:gsub("^%s*(.-)%s*$", "%1")
            end
        end
        function string.trim(str)
            if type(str) == "string" then
                return str:gsub("%s+", " ")
            end
        end
        function string.substring(str, startIndex, endIndex)
            if type(str) == "string" then
                return string.sub(str, startIndex, endIndex)
            end
        end
        function string.getCharacterAtIndex(str, index)
            if type(str) == "string" and type(index) == "number" and index >= 1 and index <= #str then
                return str:sub(index, index)
            end
        end

        function table.length(tbl)
            if type(tbl) == "table" then
                local i = 0
                for k, v in pairs(tbl) do
                    i = i + 1
                end
                return i
            end
        end
        function table.unpck(tbl, endIndex, startIndex)
            startIndex = startIndex or 1
            endIndex = endIndex or #tbl
            if startIndex <= endIndex then
                return tbl[startIndex], table.unpck(tbl, endIndex, startIndex + 1)
            end
        end
        function table.join(tbl, delimiter)
            local result = ""
            if type(tbl) == "table" and type(delimiter) == "string" then
                for i, value in ipairs(tbl) do
                    result = result..value
                    if i < #tbl then
                        result = result..delimiter
                    end
                end
            end
            return result
        end
        function table.swap(tbl, index1, index2)
            if type(tbl) == "table" and type(index1) == "number" and type(index2) == "number" then
                tbl[index1], tbl[index2] = tbl[index2], tbl[index1]
                return tbl
            end
        end
        function table.compare(tbl, tbl2)
            if type(tbl) == "table" and type(tbl2) == "table" then
                for k, v in pairs(tbl) do
                    if v ~= tbl2[k] then
                        return false
                    end
                end
                return true
            end
        end
    end -- !SECTION

    do -- SECTION Lua - Math
        api.deg_to_rad = function(deg) -- ANCHOR deg_to_rad
            return (math.pi / 180) * deg
        end

        api.rotation_to_direction = function(rotation) -- ANCHOR rotation_to_direction
            local x = api.deg_to_rad(rotation.x)
            local z = api.deg_to_rad(rotation.z)
            local num = math.abs(math.cos(x))
            return {
                x = -math.sin(z) * num,
                y = math.cos(z) * num,
                z = math.sin(x)
            }
        end
    end -- !SECTION

    do -- SECTION Yim - Utils
        api.set_notification_title_prefix = function(title) -- ANCHOR set_notification_title_prefix
            api.set_stat("NOTIFY_DEFTITLE", title)
        end

        api.notify = function(type, message, title) -- ANCHOR notify
            local finalTitle
            if api.get_stat("NOTIFY_DEFTITLE") ~= nil then
                finalTitle = api.get_stat("NOTIFY_DEFTITLE")..(title or "")
            else
                finalTitle = title or "Some script"
            end

            if type == 1 or type == "info" then
                gui.show_message(finalTitle, message)
            elseif type == 2 or type == "warn" or type == "warning" then
                gui.show_warning(finalTitle, message)
            elseif type == 3 or type == "error" or type == "severe" then
                gui.show_error(finalTitle, message)
            end
        end

        api.get_entity_proofs = function(entity) -- ANCHOR get_entity_proofs
            local s, bp, fp, ep, cp, mp, sp, p7, dp = ENTITY.GET_ENTITY_PROOFS(entity, false, false, false, false, false, false, false, false)
            local data = {
                bullet = bp,
                fire = fp,
                explosion = ep,
                collision = cp,
                melee = mp,
                steam = sp,
                p7 = p7,
                drown = dp,
                anytrue = false
            }

            for k, v in pairs(data) do
                if v then
                    data.anytrue = true
                    break
                end
            end

            data.success = s

            data.translated = {
                ["Bullet"] = bp,
                ["Fire"] = fp,
                ["Explosion"] = ep,
                ["Collision"] = cp,
                ["Melee"] = mp,
                ["Steam"] = sp,
                ["P7"] = p7,
                ["Drown"] = dp
            }

            return data
        end

        api.request_entity_control_once = function(entity) -- ANCHOR request_entity_control_once
            if not NETWORK.NETWORK_IS_IN_SESSION() or NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
                return true
            end
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(entity), true)
            return NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity) == true
        end

        api.raycast = function(ent) -- ANCHOR raycast
            local cam_coords = CAM.GET_GAMEPLAY_CAM_COORD()
            local dir = api.rotation_to_direction(CAM.GET_GAMEPLAY_CAM_ROT(2))
            local ray = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
                cam_coords.x,
                cam_coords.y,
                cam_coords.z,
                cam_coords.x + dir.x * 1000,
                cam_coords.y + dir.y * 1000,
                cam_coords.z + dir.z * 1000,
                -1,
                0,
                7
            )
            local hit, end_coords, surface_normal = SHAPETEST.GET_SHAPE_TEST_RESULT(ray, nil, nil, nil, ent)
            return {
                hit = hit,
                coords = end_coords,
                surface_normal = surface_normal
            }
        end

        api.rif = script.run_in_fiber -- ANCHOR rif

        api.does_entity_exist = function(ent) -- ANCHOR does_entity_exist
            if type(ent) ~= "number" or ent == 0 then
                return false
            end
            return ENTITY.DOES_ENTITY_EXIST(ent)
        end

        api.load_ground_at_coord = function(rs, pos) -- ANCHOR load_ground_at_coord
            local done = false

            for i = 0, 9 do
                for z = 0, 975, 25 do
                    local groundIter = z

                    if i >= 1 and z % 100 == 0 then
                        STREAMING.REQUEST_COLLISION_AT_COORD(pos.x, pos.y, groundIter)
                        rs:yield()
                    end

                    local retval, groundZ = MISC.GET_GROUND_Z_FOR_3D_COORD(pos.x, pos.y, groundIter, false, false)
                    if retval then
                        pos.z = groundZ + 1
                        done = true
                    end
                end

                local height
                if done then
                    local ok, height = WATER.GET_WATER_HEIGHT(pos.x, pos.y, pos.z, height)
                    if ok then
                        pos.z = height + 1
                    end
                end

                if done then
                    return true
                end
            end

            pos.z = 1000

            return false
        end

        api.get_free_vehicle_seat = function(veh) -- ANCHOR get_free_vehicle_seat
            if not ENTITY.IS_ENTITY_A_VEHICLE(veh) then
                return nil
            end
            for i = -1, VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(veh) - 1 do
                if VEHICLE.IS_VEHICLE_SEAT_FREE(veh, i, false) then
                    return i
                end
            end
        end

        api.coords = function(entity, force) -- ANCHOR coords
            if not force and ENTITY.DOES_ENTITY_EXIST(entity) == false then
                return {x = 0, y = 0, z = 0}
            end
            local c = ENTITY.GET_ENTITY_COORDS(entity, false)
            return {x = c.x, y = c.y, z = c.z}
        end

        api.create_vehicle = function(x, y, z, hash, heading, networked) -- ANCHOR create_vehicle
            return VEHICLE.CREATE_VEHICLE(hash, x, y, z, heading, networked == true, networked == true, false)
        end

        api.playerindex = function(method) -- ANCHOR playerindex
            if method == 1 then
                return globals.get_int(1574932)
            elseif method == 2 then
                return globals.get_int(1574925)
            end
            return stats.get_int("MPPLY_LAST_MP_CHAR")
        end

        api.mpx = function(t) -- ANCHOR mpx
            return "MP"..api.shc(api.playerindex() == 0, 0, 1).."_"..(t or "")
        end

        api.pid = function() -- ANCHOR pid
            return PLAYER.PLAYER_ID()
        end

        api.ppid = function() -- ANCHOR ppid
            return PLAYER.PLAYER_PED_ID()
        end

        api.veh = function(ped) -- ANCHOR veh
            local ped_ = ped or api.ppid()
            if PED.IS_PED_IN_ANY_VEHICLE(ped_, false) then
                return PED.GET_VEHICLE_PED_IS_IN(ped_, false)
            end
        end

        api.is_script_running_hash = function(hash) -- ANCHOR is_script_running_hash
            return SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(hash) > 0
        end

        api.is_script_running = function(name) -- ANCHOR is_script_running
            return api.is_script_running_hash(joaat(name))
        end

        api.get_all_players = function() -- ANCHOR get_all_players
            local players = {}
            for i = 0, 31 do
                local name = PLAYER.GET_PLAYER_NAME(i)
                if type(name) == "string" and name ~= "**Invalid**" then
                    players[name:lowercase()] = {
                        player = i,
                        ped = PLAYER.GET_PLAYER_PED(i),
                        name = name
                    }
                end
            end
            return players
        end
    end -- !SECTION

    do -- SECTION GTA Cache
        -- Plz add cache access mr yimmenu

        api.cache = {}

        api.cache.xp_to_rank = require("./xpToRank")

        api.cache.all_weapons = {
            ["dagger"] = 0x92A27487,
            ["bat"] = 0x958A4A8F,
            ["bottle"] = 0xF9E6AA4B,
            ["crowbar"] = 0x84BD7BFD,
            ["flashlight"] = 0x8BB05FD7,
            ["golfclub"] = 0x440E4788,
            ["hammer"] = 0x4E875F73,
            ["hatchet"] = 0xF9DCBF2D,
            ["knuckle"] = 0xD8DF3C3C,
            ["knife"] = 0x99B507EA,
            ["machete"] = 0xDD5DF8D9,
            ["switchblade"] = 0xDFE37640,
            ["nightstick"] = 0x678B81B1,
            ["wrench"] = 0x19044EE0,
            ["battleaxe"] = 0xCD274149,
            ["poolcue"] = 0x94117305,
            ["stone_hatchet"] = 0x3813FC08,
            ["pistol"] = 0x1B06D571,
            ["pistol_mk2"] = 0xBFE256D4,
            ["combatpistol"] = 0x5EF9FEC4,
            ["appistol"] = 0x22D8FE39,
            ["stungun"] = 0x3656C8C1,
            ["pistol50"] = 0x99AEEB3B,
            ["snspistol"] = 0xBFD21232,
            ["snspistol_mk2"] = 0x88374054,
            ["heavypistol"] = 0xD205520E,
            ["vintagepistol"] = 0x83839C4,
            ["flaregun"] = 0x47757124,
            ["marksmanpistol"] = 0xDC4DB296,
            ["revolver"] = 0xC1B3C3D1,
            ["revolver_mk2"] = 0xCB96392F,
            ["doubleaction"] = 0x97EA20B8,
            ["raypistol"] = 0xAF3696A1,
            ["ceramicpistol"] = 0x2B5EF5EC,
            ["navyrevolver"] = 0x917F6C8C,
            ["microsmg"] = 0x13532244,
            ["smg"] = 0x2BE6766B,
            ["smg_mk2"] = 0x78A97CD0,
            ["assaultsmg"] = 0xEFE7E2DF,
            ["combatpdw"] = 0xA3D4D34,
            ["machinepistol"] = 0xDB1AA450,
            ["minismg"] = 0xBD248B55,
            ["raycarbine"] = 0x476BF155,
            ["pumpshotgun"] = 0x1D073A89,
            ["pumpshotgun_mk2"] = 0x555AF99A,
            ["sawnoffshotgun"] = 0x7846A318,
            ["assaultshotgun"] = 0xE284C527,
            ["bullpupshotgun"] = 0x9D61E50F,
            ["musket"] = 0xA89CB99E,
            ["heavyshotgun"] = 0x3AABBBAA,
            ["dbshotgun"] = 0xEF951FBB,
            ["autoshotgun"] = 0x12E82D3D,
            ["assaultrifle"] = 0xBFEFFF6D,
            ["assaultrifle_mk2"] = 0x394F415C,
            ["carbinerifle"] = 0x83BF0278,
            ["carbinerifle_mk2"] = 0xFAD1F1C9,
            ["advancedrifle"] = 0xAF113F99,
            ["specialcarbine"] = 0xC0A3098D,
            ["specialcarbine_mk2"] = 0x969C3D67,
            ["bullpuprifle"] = 0x7F229F94,
            ["bullpuprifle_mk2"] = 0x84D6FAFD,
            ["compactrifle"] = 0x624FE830,
            ["mg"] = 0x9D07F764,
            ["combatmg"] = 0x7FD62962,
            ["combatmg_mk2"] = 0xDBBD7280,
            ["gusenberg"] = 0x61012683,
            ["sniperrifle"] = 0x5FC3C11,
            ["heavysniper"] = 0xC472FE2,
            ["heavysniper_mk2"] = 0xA914799,
            ["marksmanrifle"] = 0xC734385A,
            ["marksmanrifle_mk2"] = 0x6A6C02E0,
            ["rpg"] = 0xB1CA77B1,
            ["grenadelauncher"] = 0xA284510B,
            ["grenadelauncher_smoke"] = 0x4DD2DC56,
            ["minigun"] = 0x42BF8A85,
            ["firework"] = 0x7F7497E5,
            ["railgun"] = 0x6D544C99,
            ["hominglauncher"] = 0x63AB0442,
            ["compactlauncher"] = 0x781FE4A,
            ["rayminigun"] = 0xB62D1F67,
            ["grenade"] = 0x93E220BD,
            ["bzgas"] = 0xA0973D5E,
            ["smokegrenade"] = 0xFDBC8A50,
            ["flare"] = 0x497FACC3,
            ["molotov"] = 0x24B17070,
            ["stickybomb"] = 0x2C3731D9,
            ["proxmine"] = 0xAB564B93,
            ["snowball"] = 0x787F0BB,
            ["pipebomb"] = 0xBA45E8B8,
            ["ball"] = 0x23C9F95C,
            ["petrolcan"] = 0x34A67B97,
            ["fireextinguisher"] = 0x60EC506,
            ["parachute"] = 0xFBAB5776,
            ["electric_fence"] = 0x711D4738,
            ["plunger"] = 0x2D4239F,
            ["cattleprod"] = 0x84D676D4
        }

        api.cache.vehicle_classes = {
            "Compacts", "Sedans", "SUVs", "Coupes", "Muscle", "Sports Classics",
            "Sports", "Super", "Motorcycles", "Off-road", "Industrial", "Utility",
            "Vans", "Cycles", "Boats", "Helicopters", "Planes", "Service",
            "Emergency", "Military", "Commercial", "Trains"
        }
    end -- !SECTION

    do -- SECTION ImGui - Utils
        api.imcolor = function(r, g, b, alpha, max)
            if max == nil then
                max = 255
            end
            if alpha ~= nil then
                alpha = alpha / max
            end
            return (r or max) / max, (g or max) / max, (b or max) / max, alpha or max
        end
    end -- !SECTION

    do -- SECTION Stats
        data.stats = {}

        api.set_stat = function(key, value)
            if key == nil or value == nil then
                return nil
            end
            data.stats[key] = value
            return value
        end

        api.get_stat = function(key, defaultValue)
            if key == nil then
                return nil
            end
            return data.stats[key] or defaultValue
        end

        api.set_default_stat = function(key, value)
            if key == nil or value == nil or data.stats[key] ~= nil then
                return nil
            end
            data.stats[key] = value
            return value
        end

        api.has_stat = function(key)
            if key == nil then
                return nil
            end
            return data.stats[key] ~= nil
        end
    end -- !SECTION

    do -- SECTION Key listener
        data.key_listener = {
            cb = {},
            ks = {}
        }
        api.key_listener = {}

        api.key_listener.add_callback = function(key, callback, keyup)
            if key == nil or callback == nil then
                return nil
            end
            local id = api.gun()
            data.key_listener.cb[key] = data.key_listener.cb[key] or {}
            data.key_listener.cb[key][id] = {
                callback = callback,
                keyup = (keyup == true)
            }
            return id
        end

        api.key_listener.remove_callback = function(id)
            if id == nil then
                return nil
            end
            for k, v in pairs(data.key_listener.cb) do
                if v[id] then
                    v[id] = nil
                    return true
                end
            end
            return false
        end

        data.key_listener.tick = function()
            if data.key_listener.cb and not gui.is_open() then
                for k, v in pairs(data.key_listener.cb) do
                    local isPressed = PAD.IS_DISABLED_CONTROL_PRESSED(0, k)
                    if isPressed ~= (data.key_listener.ks[k] == true) then
                        data.key_listener.ks[k] = isPressed
                        for k1, k2 in pairs(v) do
                            if (isPressed and not k2.keyup) or (not isPressed and k2.keyup) then
                                k2.callback()
                            end
                        end
                    end
                end
            end
        end
    end -- !SECTION

    do -- SECTION Rendering
        api.rendering = {}
        data.rendering = {
            checkboxstates = {}
        }

        local function getOrDefault(tbl, key, defaultValue)
            return tbl[key] or (defaultValue or "nil")
        end

        api.rendering.renderList = function(items, key, labelId, name, sort)
            if items == nil or labelId == nil then
                return {
                    changed = false,
                    oldKey = key,
                    key = key
                }
            end

            local newKey = key
            local newValue = nil
            local label = (name or "").."##"..labelId
            local selectedValue = getOrDefault(items, key, items[next(items)])
            if ImGui.BeginCombo(label, selectedValue) then
                if sort ~= nil then
                    for k, v in pairs(sort) do
                        local v_ = getOrDefault(items, v, next(items))
                        if ImGui.Selectable(v_, false) then
                            newKey = v
                            newValue = v_
                        end
                        api.rendering.tooltip(v)
                    end
                else
                    for k, v in pairs(items) do
                        if ImGui.Selectable(v, false) then
                            newKey = k
                            newValue = v
                        end
                        api.rendering.tooltip(k)
                    end
                end
                ImGui.EndCombo()
            end
            return {
                changed = key ~= newKey,
                oldKey = key,
                key = newKey,
                value = newValue
            }
        end

        api.rendering.setCheckboxChecked = function(id, value)
            if type(value) ~= "boolean" then
                value = true
            end
            data.rendering.checkboxstates[id] = value
        end

        api.rendering.renderCheckbox = function(name, id, callback)
            local enabled, toggled = ImGui.Checkbox(name, data.rendering.checkboxstates[id] == true)
            if toggled then
                data.rendering.checkboxstates[id] = enabled
                if callback ~= nil then
                    callback(enabled)
                end
            end
            return enabled == true
        end

        api.rendering.isCheckboxChecked = function(id)
            return data.rendering.checkboxstates[id] == true
        end

        api.rendering.bigText = function(text)
            local defaultScale = api.get_stat("DEFAULT_WINDOW_FONT_SCALE", 1)
            ImGui.SetWindowFontScale(defaultScale + .22)
            ImGui.Text(text)
            ImGui.SetWindowFontScale(defaultScale)
        end

        api.rendering.tooltip = function(text)
            if ImGui.IsItemHovered() then
                ImGui.SetTooltip(tostring(text))
            end
        end

        api.rendering.coloredtext = function(text, r, g, b, alpha)
            if type(r) == "table" then
                g = r[2] or 0
                b = r[3] or 0
                alpha = r[4] or 255
                r = r[1] or 0
            end
            r, g, b, alpha = api.imcolor(r, g, b, alpha)
            ImGui.TextColored(r, g, b, alpha, text)
        end

        api.rendering.input = function(input_type, data)
            if type(data) ~= "table" then
                return nil
            end

            if input_type == "text" then
                local text, changed
                if type(data.hint) == "string" then
                    text, changed = ImGui.InputTextWithHint(data.label, data.hint, data.text or "", data.maxlength or 32)
                else
                    text, changed = ImGui.InputText(data.label, data.text or "", data.maxlength or 32)
                end
                return {
                    text = text,
                    changed = changed
                }
            elseif input_type == "int" then
                local value, changed = ImGui.InputInt(data.label, data.value or 0, data.step or 0, data.step_fast or 0)
                return {
                    value = value,
                    changed = changed
                }
            end

            return nil
        end
    end -- !SECTION

    do -- SECTION Tasks
        data.tasks = {}

        api.add_task = function(func)
            if func ~= nil then
                local id = api.gun()
                data.tasks[id] = func
                return id
            end
            return nil
        end

        api.has_task = function(id)
            return id ~= nil and data.tasks[id] ~= nil
        end
    end -- !SECTION

    do -- SECTION json
        local encode, decode, parse

        local escape_char_map = {
            ["\\"] = "\\\\",
            ["\""] = "\\\"",
            ["\b"] = "\\b",
            ["\f"] = "\\f",
            ["\n"] = "\\n",
            ["\r"] = "\\r",
            ["\t"] = "\\t"
        }

        local escape_char_map_inv = {["/"] = "/"}
        for k, v in pairs(escape_char_map) do escape_char_map_inv[v] = k end

        local function escape_char(c)
            return escape_char_map[c] or string.format("\\u%04x", c:byte())
        end

        local function encode_nil(val) return "null" end
        local function encode_table(val, stack)
            local res = {}
            stack = stack or {}

            if stack[val] then error("circular reference") end

            stack[val] = true

            if rawget(val, 1) ~= nil or next(val) == nil then
                local n = 0
                for k in pairs(val) do
                    if type(k) ~= "number" then
                        error("invalid table: mixed or invalid key types")
                    end
                    n = n + 1
                end
                if n ~= #val then error("invalid table: sparse array") end

                for i, v in ipairs(val) do
                    table.insert(res, encode(v, stack))
                end
                stack[val] = nil
                return "["..table.concat(res, ",").."]"
            else
                for k, v in pairs(val) do
                    if type(k) ~= "string" then
                        error("invalid table: mixed or invalid key types")
                    end
                    table.insert(res, encode(k, stack)..":"..encode(v, stack))
                end
                stack[val] = nil
                return "{"..table.concat(res, ",").."}"
            end
        end
        local function encode_string(val)
            return '"'..val:gsub('[%z\1-\31\\"]', escape_char)..'"'
        end
        local function encode_number(val)
            if val ~= val or val <= -math.huge or val >= math.huge then
                error("unexpected number value '"..tostring(val).."'")
            end
            return string.format("%.14g", val)
        end

        local type_func_map = {
            ["nil"] = encode_nil,
            ["table"] = encode_table,
            ["string"] = encode_string,
            ["number"] = encode_number,
            ["boolean"] = tostring
        }

        encode = function(val, stack)
            local t = type(val)
            local f = type_func_map[t]
            if f then return f(val, stack) end
            error("unexpected type '"..t.."'")
        end

        local function create_set(...)
            local res = {}
            for i = 1, select("#", ...) do res[select(i, ...)] = true end
            return res
        end

        local space_chars = create_set(" ", "\t", "\r", "\n")
        local delim_chars = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
        local escape_chars = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
        local literals = create_set("true", "false", "null")

        local literal_map = {["true"] = true, ["false"] = false, ["null"] = nil}

        local function next_char(str, idx, set, negate)
            for i = idx, #str do
                if set[str:sub(i, i)] ~= negate then return i end
            end
            return #str + 1
        end

        local function decode_error(str, idx, msg)
            local line_count = 1
            local col_count = 1
            for i = 1, idx - 1 do
                col_count = col_count + 1
                if str:sub(i, i) == "\n" then
                    line_count = line_count + 1
                    col_count = 1
                end
            end
            error(string.format("%s at line %d col %d", msg, line_count, col_count))
        end

        local function codepoint_to_utf8(n)
            local f = math.floor
            if n <= 0x7f then
                return string.char(n)
            elseif n <= 0x7ff then
                return string.char(f(n / 64) + 192, n % 64 + 128)
            elseif n <= 0xffff then
                return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128,
                                n % 64 + 128)
            elseif n <= 0x10ffff then
                return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                                f(n % 4096 / 64) + 128, n % 64 + 128)
            end
            error(string.format("invalid unicode codepoint '%x'", n))
        end

        local function parse_unicode_escape(s)
            local n1 = tonumber(s:sub(1, 4), 16)
            local n2 = tonumber(s:sub(7, 10), 16)

            if n2 then
                return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) +
                                            0x10000)
            else
                return codepoint_to_utf8(n1)
            end
        end
        local function parse_string(str, i)
            local res = ""
            local j = i + 1
            local k = j

            while j <= #str do
                local x = str:byte(j)

                if x < 32 then
                    decode_error(str, j, "control character in string")
                elseif x == 92 then
                    res = res..str:sub(k, j - 1)
                    j = j + 1
                    local c = str:sub(j, j)
                    if c == "u" then
                        local hex =
                            str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1) or
                                str:match("^%x%x%x%x", j + 1) or
                                decode_error(str, j - 1,
                                            "invalid unicode escape in string")
                        res = res..parse_unicode_escape(hex)
                        j = j + #hex
                    else
                        if not escape_chars[c] then
                            decode_error(str, j - 1, "invalid escape char '"..c ..
                                            "' in string")
                        end
                        res = res..escape_char_map_inv[c]
                    end
                    k = j + 1
                elseif x == 34 then
                    res = res..str:sub(k, j - 1)
                    return res, j + 1
                end

                j = j + 1
            end

            decode_error(str, i, "expected closing quote for string")
        end
        local function parse_number(str, i)
            local x = next_char(str, i, delim_chars)
            local s = str:sub(i, x - 1)
            local n = tonumber(s)
            if not n then
                decode_error(str, i, "invalid number '"..s.."'")
            end
            return n, x
        end
        local function parse_literal(str, i)
            local x = next_char(str, i, delim_chars)
            local word = str:sub(i, x - 1)
            if not literals[word] then
                decode_error(str, i, "invalid literal '"..word.."'")
            end
            return literal_map[word], x
        end
        local function parse_array(str, i)
            local res = {}
            local n = 1
            i = i + 1
            while 1 do
                local x
                i = next_char(str, i, space_chars, true)

                if str:sub(i, i) == "]" then
                    i = i + 1
                    break
                end

                x, i = parse(str, i)
                res[n] = x
                n = n + 1

                i = next_char(str, i, space_chars, true)
                local chr = str:sub(i, i)
                i = i + 1
                if chr == "]" then break end
                if chr ~= "," then
                    decode_error(str, i, "expected ']' or ','")
                end
            end
            return res, i
        end
        local function parse_object(str, i)
            local res = {}
            i = i + 1
            while 1 do
                local key, val
                i = next_char(str, i, space_chars, true)

                if str:sub(i, i) == "}" then
                    i = i + 1
                    break
                end

                if str:sub(i, i) ~= '"' then
                    decode_error(str, i, "expected string for key")
                end

                key, i = parse(str, i)

                i = next_char(str, i, space_chars, true)
                if str:sub(i, i) ~= ":" then
                    decode_error(str, i, "expected ':' after key")
                end

                i = next_char(str, i + 1, space_chars, true)

                val, i = parse(str, i)

                res[key] = val

                i = next_char(str, i, space_chars, true)
                local chr = str:sub(i, i)
                i = i + 1
                if chr == "}" then break end
                if chr ~= "," then
                    decode_error(str, i, "expected '}' or ','")
                end
            end
            return res, i
        end

        local char_func_map = {
            ['"'] = parse_string,
            ['0'] = parse_number,
            ['1'] = parse_number,
            ['2'] = parse_number,
            ['3'] = parse_number,
            ['4'] = parse_number,
            ['5'] = parse_number,
            ['6'] = parse_number,
            ['7'] = parse_number,
            ['8'] = parse_number,
            ['9'] = parse_number,
            ['-'] = parse_number,
            ['t'] = parse_literal,
            ['f'] = parse_literal,
            ['n'] = parse_literal,
            ['['] = parse_array,
            ['{'] = parse_object
        }

        parse = function(str, idx)
            local chr = str:sub(idx, idx)
            local f = char_func_map[chr]
            if f then return f(str, idx) end
            decode_error(str, idx, "unexpected character '"..chr.."'")
        end

        decode = function(str)
            if type(str) ~= "string" then
                error("expected argument of type string, got "..type(str))
            end
            local res, idx = parse(str, next_char(str, 1, space_chars, true))
            idx = next_char(str, idx, space_chars, true)
            if idx <= #str then decode_error(str, idx, "trailing garbage") end
            return res
        end

        api.json = {
            encode = encode,
            decode = decode
        }
    end -- !SECTION

    script.register_looped("yimutils", function() -- ANCHOR Loop
        data.key_listener.tick()

        for k, v in pairs(data.tasks) do
            log.warning("yimutils: Tasks are deprecated and will be removed")
            data.tasks = {}
            break
        end
    end)

    yu = api
    return yu
end
