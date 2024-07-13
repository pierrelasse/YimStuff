local tasks = require("./tasks")
local cfg = require("./config")

local gameloop = {}

local function updateInOnline()
    SussySpt.in_online = NETWORK.NETWORK_IS_IN_SESSION() == true
end

local function tickDisableControls()
    if SussySpt.disableControls > 0 then
        SussySpt.disableControls = SussySpt.disableControls - 1
        for i = 0, 2 do
            for i2 = 0, 360 do
                PAD.DISABLE_CONTROL_ACTION(i, i2, true)
            end
        end
    end
end

local function loop(rs)
    while true do
        rs:yield()
        updateInOnline()

        if SussySpt.invisible == true then
            SussySpt.ensureVis(false, yu.ppid(), yu.veh())
        end

        tickDisableControls()

        tasks.runAll(rs)

        cfg.autosave()
    end
end

function gameloop.register()
    gameloop.register = nil
    yu.rif(loop)
end

return gameloop
