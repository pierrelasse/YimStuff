return function(sprite)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(sprite)

    if HUD.DOES_BLIP_EXIST(blip) == false then
        yu.notify(3, "Blip on map not found", "Blip TP")
        return
    end

    local c = HUD.GET_BLIP_COORDS(blip)
    PED.SET_PED_COORDS_KEEP_VEHICLE(yu.ppid(), c.x, c.y, c.z)
end
