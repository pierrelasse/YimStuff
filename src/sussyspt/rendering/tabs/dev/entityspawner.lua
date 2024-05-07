local tasks = require("sussyspt/tasks")

local exports = {}

local selectedEntity
local isNew = true

local entityType = 1
local entityTypes = {
    "Object",
    "Vehicle",
    "Particle"
}

local location = 1
-- local locations = {
--     "Player"
--     -- "Custom"
-- }

local object_modelHash
local object_modelInput = ""
local object_modelInputIsHash = false
local object_placeOnGround = false
local object_frozen = true

local status
local statusColor
local function setStatusColor(r, g, b, a)
    if statusColor == nil then
        statusColor = { r / 255, g / 255, b / 255, a and (a / 255) or 1 }
    end
end
local spawnAvailable = false
local isLocal = false

local function tick()
    if status ~= nil then
        status = nil
        statusColor = nil
    end
    spawnAvailable = false

    if entityType == 1 then
        if #object_modelInput == 0 then
            object_modelHash = nil
            return
        elseif object_modelInputIsHash then
            object_modelHash = tonumber(object_modelInput)
            if object_modelHash == nil then
                status = "Could not parse hashed model"
                setStatusColor(255, 0, 0, 255)
                return
            end
        else
            object_modelHash = joaat(object_modelInput)
        end

        if STREAMING.IS_MODEL_VALID(object_modelHash) then
            spawnAvailable = true
        else
            status = "Invalid model hash"
            setStatusColor(255, 0, 0, 255)
            return
        end
    end
end

local function renderTypeSelection()
    for index, name in pairs(entityTypes) do
        if index ~= 1 then ImGui.SameLine() end
        if ImGui.RadioButton(name, entityType == index) then
            entityType = index
        end
    end
end

local function renderOptions()
    if entityType == 1 then
        do
            local hint = object_modelInputIsHash and "1212630005" or "prop_mp_ramp_01_tu"
            ImGui.SetNextItemWidth(260)
            local text, used = ImGui.InputTextWithHint("##object_modelInput", hint, object_modelInput, 100)
            SussySpt.pushDisableControls(ImGui.IsItemActive())
            if used then
                object_modelInput = text
            end
        end
        ImGui.SameLine()
        do
            local value, used = ImGui.Checkbox("Is hash##object_modelInputIsHash", object_modelInputIsHash)
            yu.rendering.tooltip("If the input is a hash or not")
            if used then
                object_modelInputIsHash = value
            end
        end

        do
            local value, used = ImGui.Checkbox("Place on ground properly##object_placeOnGround",
                                               object_placeOnGround)
            if used then
                object_placeOnGround = value
            end
        end

        do
            local value, used = ImGui.Checkbox("Frozen##object_frozen", object_frozen)
            if used then
                object_frozen = value
            end
        end
    end

    do
        local value, used = ImGui.Checkbox("Is local##isLocal", isLocal)
        yu.rendering.tooltip("If entity is local or networked (visible for other players)")
        if used then
            isLocal = value
        end
    end
end

-- local function renderLocation()
--     if ImGui.TreeNodeEx("Location") then
--         for index, name in pairs(locations) do
--             if index ~= 1 then ImGui.SameLine() end
--             if ImGui.RadioButton(name, location == index) then
--                 location = index
--             end
--         end

--         ImGui.TreePop()
--     end
-- end

local function spawn()
    if entityType == 1 then
        if object_modelHash == nil then return end

        local x
        local y
        local z
        do
            local c = ENTITY.GET_ENTITY_COORDS(yu.ppid())
            x = c.x
            y = c.y
            z = c.z
        end

        local object = OBJECT.CREATE_OBJECT_NO_OFFSET(object_modelHash, x, y, z, not isLocal, true, false)

        if not isLocal then
            local id = NETWORK.OBJ_TO_NET(object)
            NETWORK.NETWORK_USE_HIGH_PRECISION_BLENDING(id, true)
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(id, true)
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(id, true)
        end

        ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(object, true, 1)
        ENTITY.SET_ENTITY_LOD_DIST(object, 0xFFFF)

        if object_placeOnGround then OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(object) end
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

    -- renderLocation()

    if isNew then
        ImGui.BeginDisabled(not spawnAvailable)
        if ImGui.Button("Spawn") then tasks.addTask(spawn) end
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
