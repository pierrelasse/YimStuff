do
    print = log.info

    if require("sussyspt/yimutilsLoader") ~= true then return end

    local version = require("./version")

    if not yu.is_num_between(version.versionType, 1, 2) then
        log.warning("Fatal: Could not start due to an invalid version type. Are you using a source file?")
        return version
    end

    SussySpt = {}

    local cfg = require("sussyspt/config")
    if cfg == nil then return end

    SussySpt.dev = version.versionType == 2
    function SussySpt.getDev() return SussySpt.dev end

    require("sussyspt/logger")

    cfg.load()
    yu.rendering.setCheckboxChecked("debug_console", cfg.get("debug_console", false))

    log.info("Loading SussySpt v"..version.version.." ["..version.versionId.."] build "..version.build)

    yu.set_notification_title_prefix("[SussySpt] ")

    local tab = require("sussyspt/tab")

    SussySpt.in_online = false

    do -- SECTION Disable controls
        SussySpt.disableControls = 0
        function SussySpt.pushDisableControls(a)
            if a ~= false then
                SussySpt.disableControls = 4
            end
        end
    end -- !SECTION

    function SussySpt.requireScript(name)
        if yu.is_script_running(name) == false then
            yu.notify(3, "Script '"..name.."' is not running!", "Script Requirement")
            return false
        end
        return true
    end

    SussySpt.rendercb = {}
    function SussySpt.add_render(cb)
        if cb ~= nil then
            local id = yu.gun()
            SussySpt.debug("Added render cb with id "..id)
            SussySpt.rendercb[id] = cb
        end
    end

    tab.addTabs()

    SussySpt.debug("Registering mainloop")
    require("sussyspt/gameloop").register()

    tab.addRender()

    require("sussyspt/chatlog").registerListener()

    SussySpt.debug("Loaded successfully!")
    yu.notify(1, "Loaded v"..version.version.." ["..version.versionId.."]!", "Welcome")
end
