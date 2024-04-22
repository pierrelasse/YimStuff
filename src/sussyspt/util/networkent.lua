return function(ent)
    if type(ent) == "number" and ent ~= 0 and ENTITY.DOES_ENTITY_EXIST(ent) then
        NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(ent)
        local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
        return ent
    end
end
