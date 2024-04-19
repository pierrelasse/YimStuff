local tasks = require("./tasks")
local cfg = require("./config")

return function(rs)
    while true do
        rs:yield()

        SussySpt.in_online = NETWORK.NETWORK_IS_IN_SESSION() == true

        if SussySpt.invisible == true then
            SussySpt.ensureVis(false, yu.ppid(), yu.veh())
        end

        if SussySpt.disableControls > 0 then
            SussySpt.disableControls = SussySpt.disableControls - 1

            for i = 0, 2 do
                for i2 = 0, 360 do
                    PAD.DISABLE_CONTROL_ACTION(i, i2, true)
                end
            end
        end

        tasks.runAll(rs)

        cfg.autosave()
    end
end
