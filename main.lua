local yu = (function()
    if yu ~= nil then return yu end

    local data = {
        un = 0
    }

    local api = {
        keys = {
            ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182, ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81, ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RCTRL"] = 70, ["D"] = 178, ["D"] = 173, ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DEL"] = 178, ["R"] = 70, ["R"] = 175, ["H"] = 213, ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173, ["T"] = 37, ["T"] = 27, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118, ["MOUSE2"] = 25, ["MOUSE1"] = 24, ["INSERT"] = 121
        }
    }

    local function defineUtils()
        -- Lua related
        api.shc = function(condition, trueValue, falseValue)
            return condition and trueValue or falseValue or true
        end

        api.format_num = function(num)
            if type(num) ~= "number" then
                return tostring(num)
            end
            return tostring(math.floor(num))
                :reverse()
                :gsub("(%d%d%d)", "%1,")
                :reverse()
        end
        
        api.boolstring = function(bool, trueValue, falseValue)
            return bool and trueValue or falseValue
        end

        api.get_between_or_default = function(value, min, max, defaultValue)
            return (value >= min and value <= max) and value or defaultValue
        end

        api.dict_get_or_default = function(dict, key, defaultValue)
            return dict[key] or defaultValue
        end
        
        api.dict_god = function(dict, key, defaultValue)
            return api.dict_get_or_default(dict, key, defaultValue)
        end

        api.get_key_from_dict = function(dict, value)
            for k, v in pairs(dict) do
                if v == value then
                    return k
                end
            end
            return nil
        end

        api.get_or_default = function(get, defaultValue)
            return get or defaultValue
        end

        api.gd = function(get, defaultValue)
            return api.get_or_default(get, defaultValue)
        end

        api.format_seconds = function(s, format)
            local hours = math.floor(s / 3600)
            local minutes = math.floor((s % 3600) / 60)
            local seconds = s % 60
            return string.format(format or "%02dH %02dM %02dS", hours, minutes, seconds)
        end

        -- Menu related
        api.pid = function()
            return PLAYER.PLAYER_ID()
        end

        api.ppid = function()
            return PLAYER.PLAYER_PED_ID()
        end

        api.veh = function()
            if PED.IS_PED_IN_ANY_VEHICLE(api.ppid(), 0) then
                return PED.GET_VEHICLE_PED_IS_IN(api.ppid(), false);
            end
        end

        api.is_script_running_hash = function(hash)
            return SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(hash) ~= 0
        end

        api.is_script_running = function(name)
            return api.is_script_running_hash(joaat(name))
        end

        api.set_default_notification_title = function(title)
            api.set_stat("NOTIFY_DEFTITLE", title)
        end

        api.notify = function(type, message, title)
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
    end

    local function initStats()
        data.stats = {}

        api.set_stat = function(key, value)
            if key == nil or value == nil then
                return nil
            end
            data.stats[key] = value
            return value
        end

        api.get_stat = function(key, default)
            if key == nil then
                return nil
            end
            return data.stats[key] or default
        end

        api.set_default_stat = function(key, value)
            if key == nil or value == nil or data.stats[key] ~= nil then
                return nil
            end
            data.stats[key] = value
        end
    end

    local function defineGetters()
        api.internal_data = function()
            return data
        end

        api.gun = function()
            data.un = data.un + 1
            return data.un
        end

        api.playerindex = function()
            return globals.get_int(1574918)
        end

        api.mpx = function()
            return api.playerindex == 0 and "MP0_" or "MP1_"
        end
    end

    local function initKeyListener()
        local kl = {
            cb = {},
            ks = {}
        }

        local klapi = {}

        klapi.add_callback = function(key, callback, keydown)
            local id = api.gun()
            kl.cb[key] = kl.cb[key] or {}
            kl.cb[key][id] = {
                callback = callback,
                keydown = (keydown == true)
            }
            return id
        end

        klapi.remove_callback = function(id)
            for k, v in pairs(kl.cb) do
                if v[id] then
                    v[id] = nil
                    return true
                end
            end
            return false
        end
        
        kl.tick = function()
            local cb, ks = data.key_listener.cb, data.key_listener.ks
            if cb then
                for k, v in pairs(cb) do
                    local isPressed = PAD.IS_DISABLED_CONTROL_PRESSED(0, k)
                    if (isPressed and not ks[k] and v.keydown) or (not isPressed and not v.keydown) then
                        ks[k] = true
                        v.callback()
                    elseif not isPressed then
                        ks[k] = nil
                    end
                end
            end
        end        

        data.key_listener = kl
        api.key_listener = klapi
    end

    defineUtils()
    initStats()
    defineGetters()

    return api
end)()
