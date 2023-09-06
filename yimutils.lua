-- Made by pierrelasse <:D
return (function()
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
        api.shc = function(condition, trueValue, falseValue)
            return condition and trueValue or falseValue or true
        end

        api.format_num = function(num, separator)
            if type(num) ~= "number" then
                return tostring(num)
            end
            return tostring(math.floor(num))
                :reverse()
                :gsub("(%d%d%d)", "%1"..(separator or ","))
                :reverse()
        end
        
        api.boolstring = function(bool, trueValue, falseValue)
            return bool and (trueValue or "true") or (falseValue or "false")
        end

        api.is_num_between = function(num, min, max)
            return num >= min and num <= max
        end

        api.get_between_or_default = function(num, min, max, defaultValue)
            return api.is_num_between(num, min, max) and num or defaultValue
        end

        api.get_or_default = function(tbl, key, defaultValue)
            return tbl[key] or defaultValue or "<null>"
        end
        
        api.god = function(tbl, key, defaultValue)
            return api.get_or_default(tbl, key, defaultValue)
        end

        api.get_key_from_table = function(tbl, value)
            for k, v in pairs(tbl) do
                if v == value then
                    return k
                end
            end
            return nil
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

        api.copy_table = function(tbl)
            local newTable = {}
            for k, v in pairs(tbl) do
                newTable[k] = v
            end
            return newTable
        end

        api.add = function(num, amount)
            return num + amount
        end

        -- Notifications
        api.set_notification_title_prefix = function(title)
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
    end

    local function defineGetters()
        api.internal_data = function()
            return data
        end

        api.get_unique_number = function()
            data.un = data.un + 1
            return data.un
        end

        api.gun = function()
            return api.get_unique_number()
        end

        api.playerindex = function()
            -- return globals.get_int(1574918)
            return stats.get_int("MPPLY_LAST_MP_CHAR")
        end

        api.mpx = function(t)
            return "MP"..api.shc(api.playerindex() == 0, 0, 1).."_"..(t or "")
        end

        api.pid = function()
            return PLAYER.PLAYER_ID()
        end

        api.ppid = function()
            return PLAYER.PLAYER_PED_ID()
        end

        api.veh = function(pid)
            local pid_ = pid or api.ppid()
            if PED.IS_PED_IN_ANY_VEHICLE(pid_, 0) then
                return PED.GET_VEHICLE_PED_IS_IN(pid_, false);
            end
        end

        api.is_script_running_hash = function(hash)
            return SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(hash) ~= 0
        end

        api.is_script_running = function(name)
            return api.is_script_running_hash(joaat(name))
        end
    end

    local function initKeyListener()
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
    end

    local function initRendering()
        api.rendering = {}
        data.rendering = {
            checkboxstates = {}
        }

        api.rendering.renderList = function(items, key, labelId, name)
            if items == nil or labelId == nil then
                return nil
            end
            local newKey = key
            if ImGui.BeginCombo((name or "").."##"..labelId, items[key]) then
                for k, v in pairs(items) do
                    if (ImGui.Selectable(v, key == v)) then
                        newKey = k
                    end
                end
                ImGui.EndCombo()
            end
            return {
                changed = key ~= newKey,
                oldKey = key,
                key = newKey
            }
        end

        api.rendering.setCheckboxChecked = function(id, value)
            data.rendering.checkboxstates[id] = {
                state = value,
                oldstate = value
            }
        end

        api.rendering.renderCheckbox = function(name, id, callback)
            local d = data.rendering.checkboxstates[id] or { state = false, oldstate = false }
            
            if ImGui.Checkbox(name, d.state) ~= d.oldstate then
                d.state = not d.state
                d.oldstate = d.state
                callback(d.state)
            end
            
            data.rendering.checkboxstates[id] = d
        end
        
        api.rendering.isCheckboxChecked = function(id)
            return (data.rendering.checkboxstates[id] or { oldstate = false }).oldstate
        end

        api.rendering.bigText = function(text)
            ImGui.SetWindowFontScale(1.22)
            ImGui.Text(text)
            ImGui.SetWindowFontScale(1)
        end
    end

    local function initTasks()
        data.tasks = {
            asap = {}
        }

        api.add_task = function(func)
            if func ~= nil then
                local id = api.gun()
                data.tasks.asap[id] = func
                return id
            end
            return nil
        end
    end

    defineUtils()
    initStats()
    defineGetters()
    initKeyListener()
    initRendering()
    initTasks()

    script.register_looped("yimutils", function()
        data.key_listener.tick()

        for k, v in pairs(data.tasks.asap) do
            v()
        end
        data.tasks.asap = {}
    end)

    return api
end)()