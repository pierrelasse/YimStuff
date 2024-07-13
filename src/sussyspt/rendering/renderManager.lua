local version = require("sussyspt/version")
local cfg = require("sussyspt/config")
local themeManager = require("sussyspt/rendering/themeManager")
local qa = require("sussyspt/quickActions")

local renderManager = {}

SussySpt.rendering = { tabs = {} }

SussySpt.rendering.themes = themeManager.themes
for k, v in pairs(SussySpt.rendering.themes) do
    if v.ImGuiCol then
        for k, v2 in pairs(v.ImGuiCol) do
            for k3, v3 in pairs(v2) do v2[k3] = v3 / 255 end
        end
    end
end

SussySpt.rendering.theme = cfg.get("theme", "Fatality")
if SussySpt.rendering.themes[SussySpt.rendering.theme] == nil then
    SussySpt.debug("Theme "..SussySpt.rendering.theme..
        " does not exist. Selecting a different one")
    SussySpt.rendering.theme = next(SussySpt.rendering.themes)
end

SussySpt.debug("Using theme '"..SussySpt.rendering.theme.."'")

function SussySpt.rendering.getTheme()
    return SussySpt.rendering.themes[SussySpt.rendering.theme] or {}
end

local windowTitle
local function updateTitle()
    local title = "SussySpt"
    if version.versionType == 2 then
        title = title.." vD"..version.version
        title = title.."["..version.versionId.."]@"..version.build
    else
        title = title.." v"..version.version
    end
    windowTitle = title.."###sussyspt_mainwindow"
end
updateTitle()

function SussySpt.rendering.newTab(name, render)
    return {
        name = name,
        render = render,
        should_display = nil,
        sub = {},
        id = yu.gun()
    }
end

function renderManager.renderTab(v)
    if not (type(v.should_display) == "function" and v.should_display() == false) and
    ImGui.BeginTabItem(v.name) then
        renderManager.renderTabContent(v)
        ImGui.EndTabItem()
    end
end

function renderManager.renderTabContent(v)
    if type(v.render) == "function" then v.render() end
    if yu.len(v.sub) > 0 then
        ImGui.BeginTabBar("##tabbar_"..v.id)
        for _, v1 in pairs(v.sub) do renderManager.renderTab(v1) end
        ImGui.EndTabBar()
    end
end

local function renderMainWindow()
    if ImGui.Begin(windowTitle) then
        ImGui.BeginTabBar("##tabbar")
        for k, v in pairs(SussySpt.rendering.tabs) do renderManager.renderTab(v) end
        ImGui.EndTabBar()
    end
    ImGui.End()
    return true
end

function renderManager.render() -- ANCHOR render
    for k, v in pairs(SussySpt.rendercb) do v() end

    qa.render()

    themeManager.pushTheme(SussySpt.rendering.getTheme())

    local success, result = pcall(renderMainWindow)
    if not success then
        local err = yu.removeErrorPath(result)
        ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
        ImGui.Text("[RENDER ERROR] Line: "..err[2].." Error: "..err[3])
        log.warning("Error while rendering (line "..err[2].."): "..err[3])
        ImGui.PopStyleColor()
    end

    themeManager.popTheme()
end

return renderManager
