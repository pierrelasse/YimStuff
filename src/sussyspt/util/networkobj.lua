local networkent = require("./networkent")

return function(obj)
    if networkent(obj) ~= nil then
        local id = NETWORK.OBJ_TO_NET(obj)
        NETWORK.NETWORK_USE_HIGH_PRECISION_BLENDING(id, true)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(id, true)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(id, true)
        return obj
    end
end
