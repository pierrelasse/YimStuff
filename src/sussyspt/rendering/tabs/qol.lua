local tab = SussySpt.rendering.newTab("QOL")

local blockexplosionshakes = require("sussyspt/rendering/tabs/qol/blockexplosionshakes")
local unlockwebsitecars = require("sussyspt/rendering/tabs/qol/unlockwebsitecars")

-- TODO: add VEHICLE.SET_PLANE_TURBULENCE_MULTIPLIER

function tab.render()
    blockexplosionshakes.render()
    unlockwebsitecars.render()
end

SussySpt.rendering.tabs[3] = tab
