(function()
    print = log.info
    SussySpt = {}

    local api = require("./version")

    if require("./yimutilsLoader") ~= true then return end

    if not yu.is_num_between(api.versionType, 1, 2) then
        log.warning("Fatal: Could not start due to an invalid version type. Are you using a source file?")
        return api
    end

    local cfg = require("./config")
    if cfg == nil then return end

    SussySpt.dev = api.versionType == 2
    function SussySpt.getDev() return SussySpt.dev end

    SussySpt.debugtext = ""
    function SussySpt.debug(s)
        if type(s) == "string" then
            SussySpt.debugtext = SussySpt.debugtext..(SussySpt.debugtext == "" and "" or "\n")..s
            if yu.rendering.isCheckboxChecked("debug_console") then
                log.debug(s)
            end
        end
    end

    cfg.load()
    yu.rendering.setCheckboxChecked("debug_console", cfg.get("debug_console", false))

    SussySpt.debug("Loading SussySpt v"..api.version.." ["..api.versionId.."] build "..api.build)

    yu.set_notification_title_prefix("[SussySpt] ")

    SussySpt.tab = gui.get_tab("SussySpt")

    SussySpt.in_online = false

    local renderManager = require("./view/renderManager")

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

    require("./chatlog")

    require("./view/tabs")

    require("./qa")

    -- require("./esptest")

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
    yu.rif(require("./gameloop"))

    SussySpt.debug("Adding render callback")
    SussySpt.tab:add_imgui(renderManager.render)

    require("./categories")

    SussySpt.debug("Loaded successfully!")
    yu.notify(1, "Loaded v"..api.version.." ["..api.versionId.."]!", "Welcome")

    return api
end)()
