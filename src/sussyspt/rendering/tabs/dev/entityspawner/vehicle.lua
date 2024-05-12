local exports = {
    name = "Vehicle"
}

local vehicleClass = 8
local vehicleClasses = { -- yu.cache.vehicle_classes
    "Compacts", "Sedans", "SUVs", "Coupes", "Muscle", "Sports Classics",
    "Sports", "Super", "Motorcycles", "Off-road", "Industrial", "Utility",
    "Vans", "Cycles", "Boats", "Helicopters", "Planes", "Service",
    "Emergency", "Military", "Commercial", "Trains"
}

local selectedVehicle
local vehicleHash
local search

local vehicleCache
local function getVehicles()
    if vehicleCache == nil then
        vehicleCache = {}
        for _, vehicleId in pairs(vehicles.get_all_vehicles_by_class(vehicleClasses[vehicleClass])) do
            local vehicleName = vehicles.get_vehicle_display_name(vehicleId)
            if search == nil then
                vehicleCache[vehicleId] = vehicleName
            else
                local lowerSearch = string.lower(search)
                local lowerVehicleName = string.lower(vehicleName)
                if string.contains(lowerVehicleName, lowerSearch) then
                    vehicleCache[vehicleId] = vehicleName
                else
                    local lowerVehicleId = string.lower(vehicleId)
                    if string.contains(lowerVehicleId, lowerSearch) then
                        vehicleCache[vehicleId] = vehicleName
                    end
                end
            end
        end
    end
    return vehicleCache
end

function exports.tick()
    exports.parent.spawnAvailable = false
    if selectedVehicle ~= nil then
        vehicleHash = joaat(selectedVehicle)
        if STREAMING.IS_MODEL_VALID(vehicleHash) then
            exports.parent.spawnAvailable = true
        end
    end
end

function exports.spawn(rs)
    if vehicleHash == nil then return end

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

    STREAMING.REQUEST_MODEL(vehicleHash)
    repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(vehicleHash)

    local vehicle = VEHICLE.CREATE_VEHICLE(vehicleHash, x, y, z, 1, networked, true, true, false)

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicleHash)

    if networked then
        local id = NETWORK.OBJ_TO_NET(vehicle)
        NETWORK.NETWORK_USE_HIGH_PRECISION_BLENDING(id, true)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(id, true)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(id, true)
    end
end

function exports.renderOptions()
    local value, used = ImGui.SliderInt("##vehicle_class", vehicleClass, 1,
                                        #vehicleClasses, vehicleClasses[vehicleClass])
    if used then
        vehicleCache = nil
        vehicleClass = value
        selectedVehicle = nil
        vehicleHash = nil
    end

    local value, used = ImGui.InputTextWithHint("##vehicle_search", "Search...", search or "", 50)
    SussySpt.pushDisableControls(ImGui.IsItemActive())
    if used then
        search = string.len(value) == 0 and nil or value
        vehicleCache = nil
    end

    if ImGui.BeginListBox("##vehicle_list") then
        for vehicleId, vehicleName in pairs(getVehicles()) do
            if ImGui.Selectable(vehicleName, selectedVehicle == vehicleId) and selectedVehicle ~= vehicleId then
                selectedVehicle = vehicleId
            end
            if ImGui.IsItemHovered() then
                ImGui.SetTooltip(vehicleId)
            end
        end
        ImGui.EndListBox()
    end
end

return exports
