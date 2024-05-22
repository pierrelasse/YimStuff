local tasks = require("sussyspt/tasks")
local muchrp = require("sussyspt/rendering/tabs/online/players/muchrp")
local doBoatSkinCrash = require("sussyspt/rendering/tabs/online/players/boatskincrash")
local breakhud = require("sussyspt/rendering/tabs/online/players/breakhud")
local money = require("sussyspt/rendering/tabs/online/players/money")

local exports = {}

local includeSelf = true
local friendly_muchRP = false
local friendly_money = false

local function getPlayers()
    local players = {}
    local selfPid
    if not includeSelf then selfPid = yu.pid() end
    for index, player in pairs(SussySpt.players) do
        if not player.noped and player.player ~= selfPid then
            players[index] = player
        end
    end
    return pairs(players)
end

local function doBreakHud()
    for _, player in getPlayers() do breakhud(player) end
end

local function doMuchRP()
    for _, player in getPlayers() do muchrp(player) end
end

local function doMoney()
    for _, player in getPlayers() do money(player) end
end

local function tick()
    playersCache = nil
    local readd

    if friendly_muchRP then
        doMuchRP()
        readd = true
    end

    if friendly_money then
        doMoney()
        readd = true
    end

    if readd == true then
        tasks.tasks.online_players_global = tick
    end
end

function exports.render()
    tasks.tasks.online_players_global = tick

    if ImGui.Button(" <- ") then return true end
    ImGui.SameLine()
    ImGui.Text("Global options")
    ImGui.Spacing()

    local value, used = ImGui.Checkbox("Include self", includeSelf)
    if used then includeSelf = value end
    yu.rendering.tooltip("Also does the things to you")

    if ImGui.TreeNodeEx("Friendly") then
        local value, used = ImGui.Checkbox("Much RP", friendly_muchRP)
        if used then friendly_muchRP = value end
        yu.rendering.tooltip("Gives everyone massive amounts of RP")

        ImGui.SameLine()

        local value, used = ImGui.Checkbox("Money", friendly_money)
        if used then friendly_money = value end
        yu.rendering.tooltip("Gives everyone money and RP. Money cap: $225K/player")

        ImGui.TreePop()
    end

    if ImGui.TreeNodeEx("Toxic") then
        if ImGui.Button("Boat skin crash") then tasks.addTask(doBoatSkinCrash) end
        yu.rendering.tooltip("Crashes the game of all players in your game after a few seconds.\n"
            .."Does not work on some modders")

        ImGui.SameLine()

        if ImGui.Button("Break HUD") then tasks.addTask(doBreakHud) end
        yu.rendering.tooltip(
            "This causes players to have no HUD and hides interior entry points.\n"..
            "They can also not pause, switch weapons, etc.")

        ImGui.TreePop()
    end
end

return exports
