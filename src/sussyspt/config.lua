if io == nil or io.open == nil then
    log.warning("Fatal: Unable to access io.open")
    return
end

local cfg = { file = "sussyspt", changed = false, lastAutosave = os.time() }

function cfg.has(path)
    return cfg.data ~= nil and cfg.data[path] ~= nil
end

function cfg.get(path, default)
    if cfg.data == nil then error("No config data is present") end
    local v = cfg.data[path]
    if v == nil then return default end
    return v
end

function cfg.set(path, value, setchanged)
    if cfg.data == nil then return value end
    if cfg.data[path] ~= value then
        cfg.data[path] = value
        cfg.changed = setchanged ~= false
    end
    return value
end

function cfg.save()
    cfg.changed = false

    local content = yu.json.encode(cfg.data)
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

function cfg.autosave()
    if not cfg.changed or cfg.data == nil then return end

    local time = os.time()
    if time - cfg.lastAutosave <= 2 then return end
    cfg.lastAutosave = time

    if cfg.save() then
        -- SussySpt.debug("Config automaticly saved")
    else
        log.warning("Failed to autosave the config")
    end
end

function cfg.load()
    SussySpt.debug("Loading config system")
    local f = io.open("sussyspt", "r")
    if f ~= nil then
        local content = f:read("*all")
        if type(content) == "string" and (content:startswith("{") or content:startswith("[")) then
            cfg.data = yu.json.decode(content)
            -- SussySpt.debug("Config loaded")
        else
            log.warning("Unable to load config")
        end
    else
        cfg.data = {}
        cfg.save()
    end
end

return cfg
