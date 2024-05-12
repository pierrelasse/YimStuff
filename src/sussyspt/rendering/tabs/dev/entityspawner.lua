local tasks = require("sussyspt/tasks")

local exports = {}

local selectedEntity
local isNew = true

local entityType = 1
local entityTypes = {
    require("sussyspt/rendering/tabs/dev/entityspawner/object"),
    require("sussyspt/rendering/tabs/dev/entityspawner/vehicle"),
    require("sussyspt/rendering/tabs/dev/entityspawner/particle"),
}
for _, v in ipairs(entityTypes) do v.parent = exports end

local status
local statusColor
function exports.setStatus(statusIn, r, g, b, a)
    status = statusIn
    if statusIn ~= nil and statusColor == nil then
        statusColor = { r / 255, g / 255, b / 255, a and (a / 255) or 1 }
    end
end

exports.spawnAvailable = false
exports.isLocal = false

local function tick()
    if status ~= nil then
        status = nil
        statusColor = nil
    end
    exports.spawnAvailable = false

    entityTypes[entityType].tick()
end

local function renderTypeSelection()
    for index, value in pairs(entityTypes) do
        if index ~= 1 then ImGui.SameLine() end
        if ImGui.RadioButton(value.name, entityType == index) then
            entityType = index
        end
    end
end

local function renderOptions()
    entityTypes[entityType].renderOptions()

    do
        local value, used = ImGui.Checkbox("Is local##isLocal", isLocal)
        yu.rendering.tooltip("If entity is local or networked (visible for other players)")
        if used then
            isLocal = value
        end
    end
end

local function render()
    tasks.tasks.screen = tick

    do
        local _, y = ImGui.GetContentRegionAvail()
        ImGui.SetNextItemWidth(137)
        if ImGui.BeginListBox("##entitylist", 0, y) then
            isNew = selectedEntity == nil
            if ImGui.Selectable("<New>", isNew) and selectedEntity ~= nil then
                selectedEntity = nil
            end

            ImGui.EndListBox()
        end
    end

    ImGui.SameLine()

    ImGui.BeginGroup()

    if isNew then
        renderTypeSelection()
        ImGui.Spacing()
    end

    if status ~= nil then
        ImGui.TextColored(statusColor[1], statusColor[2], statusColor[3], statusColor[4], status)
        ImGui.Spacing()
    end

    renderOptions()
    ImGui.Spacing()

    if isNew then
        ImGui.BeginDisabled(not exports.spawnAvailable)
        if ImGui.Button("Spawn") then tasks.addTask(entityTypes[entityType].spawn) end
        ImGui.EndDisabled()
    else
        ImGui.BeginDisabled()
        ImGui.Button("Delete")
        ImGui.EndDisabled()
    end

    ImGui.EndGroup()
end

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Entity Spawner")
    tab.render = render
    parentTab.sub[#parentTab.sub + 1] = tab
end

return exports
