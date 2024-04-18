SussySpt.debug("Creating esp thread")

local function drawLine(ped, index1, index2)
    local c1 = PED.GET_PED_BONE_COORDS(ped, index1, 0, 0, 0)
    local c2 = PED.GET_PED_BONE_COORDS(ped, index2, 0, 0, 0)
    GRAPHICS.DRAW_LINE(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 255, 0, 0, 255)
end

local amplitude = 127
local phaseShift = 0
local counter = 0
local frequency = .6

local function rgbGamerColor()
    counter = counter + 1
    local elapsedTime = counter / 20
    local r = math.sin(frequency * elapsedTime + phaseShift) * amplitude + amplitude
    local g = math.sin(frequency * elapsedTime + 2 * math.pi / 3 + phaseShift) * amplitude + amplitude
    local b = math.sin(frequency * elapsedTime + 4 * math.pi / 3 + phaseShift) * amplitude + amplitude
    return math.floor(r), math.floor(g), math.floor(b)
end

local brightness = 1
local brightnessAdd = .1

yu.rif(function(rs)
    while true do
        rs:yield()

        local espEnabled = yu.rendering.isCheckboxChecked("config_esp_enabled")
        local spotLightEnabled = yu.rendering.isCheckboxChecked("config_esp_spotlight_enabled")

        if (espEnabled or spotLightEnabled) and not DLC.GET_IS_LOADING_SCREEN_ACTIVE() then
            local lc = yu.coords(yu.ppid())

            if espEnabled then
                for k, v in pairs(SussySpt.players) do
                    local ped = v.ped
                    local c = yu.coords(ped)
                    local distance = MISC.GET_DISTANCE_BETWEEN_COORDS(lc.x, lc.y, lc.z, c.x, c.y, c.z, false)
                    if distance < 120 and GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(c.x, c.y, c.z, 0, 0) then
                        -- Head Bones
                        drawLine(ped, 31086, 39317) -- Head, Neck
                        -- Left Arm Bones
                        drawLine(ped, 10706, 45509) -- Left Clavicle, Left Upper Arm
                        drawLine(ped, 45509, 61163) -- Left Upper Arm, Left Forearm
                        drawLine(ped, 61163, 18905) -- Left Forearm, Left Hand
                        -- Right Arm Bones
                        drawLine(ped, 10706, 40269) -- Right Clavicle, Right Upper Arm
                        drawLine(ped, 40269, 28252) -- Right Upper Arm, Right Forearm
                        drawLine(ped, 28252, 57005) -- Right Forearm, Right Hand
                        -- Body Bones
                        drawLine(ped, 11816, 10706) -- Pelvis, Left Clavicle
                        -- Left Leg Bones
                        drawLine(ped, 11816, 58271) -- Pelvis, Left Thigh
                        drawLine(ped, 58271, 63931) -- Left Thigh, Left Calf
                        drawLine(ped, 63931, 14201) -- Left Calf, Left Foot
                        -- Right Leg Bones
                        drawLine(ped, 11816, 51826) -- Pelvis, Right Thigh
                        drawLine(ped, 51826, 36864) -- Right Thigh, Right Calf
                        drawLine(ped, 36864, 52301) -- Right Calf, Right Foot
                    end
                end
            end

            if spotLightEnabled then
                local r, g, b = rgbGamerColor()
                brightness = brightness + brightnessAdd
                if brightness > 40 then
                    brightnessAdd = -.1
                elseif brightness < 20 then
                    brightnessAdd = .1
                end

                GRAPHICS.DRAW_SPOT_LIGHT(lc.x, lc.y, lc.z + 3, 0, 0, -4, r, g, b, 10, brightness, 4, 53, 20)
            end
        end
    end
end)
