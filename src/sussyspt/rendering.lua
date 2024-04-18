local version = require("./version")

SussySpt.rendering = { tabs = {} }

SussySpt.rendering.themes = require("./themes")
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
    if version.versiontype == 2 then
        title = title.." vD"..version.version
        title = title.."["..version.versionid.."]@"..version.build
    else
        title = title.." v"..version.version
    end
    SussySpt.rendering.title = title.."###sussyspt_mainwindow"
end

do -- ANCHOR Update
    SussySpt.update = {
        start = 60 * 60 * 24 * 7,
        max = 60 * 60 * 24 * 100
    }

    SussySpt.update.updateAgo = function()
        SussySpt.update.ago = (os.time() - version.build) - SussySpt.update.start
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
