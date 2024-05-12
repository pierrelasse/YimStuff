local exports = {
    name = "Object"
}

local object_modelHash
local object_modelInput = ""
local object_modelInputIsHash = false
local object_placeOnGround = false
local object_frozen = true

function exports.tick()
    if #object_modelInput == 0 then
        object_modelHash = nil
        return
    elseif object_modelInputIsHash then
        object_modelHash = tonumber(object_modelInput)
        if object_modelHash == nil then
            exports.parent.setStatus("Could not parse hashed model", 255, 0, 0, 255)
            return
        end
    else
        object_modelHash = joaat(object_modelInput)
    end

    if STREAMING.IS_MODEL_VALID(object_modelHash) then
        exports.parent.spawnAvailable = true
    else
        exports.parent.setStatus("Invalid model hash", 255, 0, 0, 255)
        return
    end
end

function exports.spawn()
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

    local networked = not exports.parent.isLocal

    local object = OBJECT.CREATE_OBJECT_NO_OFFSET(object_modelHash, x, y, z, networked, true, false)

    if networked then
        local id = NETWORK.OBJ_TO_NET(object)
        NETWORK.NETWORK_USE_HIGH_PRECISION_BLENDING(id, true)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(id, true)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(id, true)
    end

    ENTITY.SET_ENTITY_LOAD_COLLISION_FLAG(object, true, 1)
    ENTITY.SET_ENTITY_LOD_DIST(object, 0xFFFF)

    if object_placeOnGround then OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(object) end
end

function exports.renderOptions()
    do
        local hint = object_modelInputIsHash and "1212630005" or "prop_mp_ramp_01_tu"
        ImGui.SetNextItemWidth(260)
        local text, used = ImGui.InputTextWithHint("##object_modelInput", hint, object_modelInput, 100)
        if used then object_modelInput = text end
        SussySpt.pushDisableControls(ImGui.IsItemActive())
    end

    ImGui.SameLine()

    local value, used = ImGui.Checkbox("Is hash##object_modelInputIsHash", object_modelInputIsHash)
    if used then object_modelInputIsHash = value end
    yu.rendering.tooltip("If the input is a hash or not")

    local value, used = ImGui.Checkbox("Place on ground properly##object_placeOnGround", object_placeOnGround)
    if used then object_placeOnGround = value end

    local value, used = ImGui.Checkbox("Frozen##object_frozen", object_frozen)
    if used then object_frozen = value end
end

return exports
