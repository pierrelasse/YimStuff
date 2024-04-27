return function()
    script.run_in_fiber(function(rs)
        local pid = yu.pid()
        local ppid = yu.ppid()

        PED.SET_PED_COORDS_KEEP_VEHICLE(ppid, -74.94, -818.58, 327)

        local pos = ENTITY.GET_ENTITY_COORDS(ppid, true)

        local hash = joaat("prop_byard_rowboat4")

        STREAMING.REQUEST_MODEL(hash)
        repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(hash)

        for i = 0, 5 do
            PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(pid, hash)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ppid, 0, 0, 500, false, true, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(ppid, 0xFBAB5776, 1000, false)

            rs:sleep(1000)

            for _ = 0, 20 do
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 144, 1.0)
                PED.FORCE_PED_TO_OPEN_PARACHUTE(ppid)
            end

            rs:sleep(1000)

            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ppid, pos.x, pos.y, pos.z, false, true, true)

            STREAMING.REQUEST_MODEL(hash)
            repeat rs:yield() until STREAMING.HAS_MODEL_LOADED(hash)

            PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(pid, hash)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ppid, 0, 0, 500, false, false, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(ppid, 0xFBAB5776, 1000, false)

            rs:sleep(1000)

            for _ = 0, 20 do
                PED.FORCE_PED_TO_OPEN_PARACHUTE(ppid)
                PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 144, 1.0)
            end

            rs:sleep(1000)

            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ppid, pos.x, pos.y, pos.z, false, true, true)

            yu.notify(1, i.."/5 done", "Boat Skin Crash")
        end
    end)
end
