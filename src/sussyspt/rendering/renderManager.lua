local version = require("../version")
local cfg = require("../config")
local themeManager = require("./themeManager")

local exports = {}

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

local function renderTab(v)
    if not (type(v.should_display) == "function" and v.should_display() == false) and
    ImGui.BeginTabItem(v.name) then
        if type(v.render) == "function" then v.render() end
        if yu.len(v.sub) > 0 then
            ImGui.BeginTabBar("##tabbar_"..v.id)
            for k1, v1 in pairs(v.sub) do renderTab(v1) end
            ImGui.EndTabBar()
        end
        ImGui.EndTabItem()
    end
end

local function renderMainWindow()
    if ImGui.Begin(windowTitle) then
        ImGui.BeginTabBar("##tabbar")
        for k, v in pairs(SussySpt.rendering.tabs) do renderTab(v) end
        ImGui.EndTabBar()
    end
    ImGui.End()
    return true
end

local function renderCategories()
    ImGui.Text("Categories")

    if SussySpt.in_online then
        ImGui.PushStyleColor(ImGuiCol.Text, 1, .3, .3, 1)
        cfg.set("cat_hbo", yu.rendering.renderCheckbox("HBO", "cat_hbo"))
        yu.rendering.tooltip(
            "Most of the things wont work due to the latest gta update.\nUse with caution")
        ImGui.PopStyleColor()
    end
    cfg.set("cat_qa", yu.rendering.renderCheckbox("Quick actions", "cat_qa"))
end

function exports.render() -- ANCHOR render
    for k, v in pairs(SussySpt.rendercb) do v() end

    SussySpt.qa.render()

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

    renderCategories()
end

return exports
