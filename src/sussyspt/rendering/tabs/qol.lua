local cfg = require("sussyspt/config")

local tab = SussySpt.rendering.newTab("QOL")

local blockexplosionshakes = require("sussyspt/rendering/tabs/qol/blockexplosionshakes")
local unlockwebsitecars = require("sussyspt/rendering/tabs/qol/unlockwebsitecars")

function tab.render()
    blockexplosionshakes.render()
    unlockwebsitecars.render()
end

SussySpt.rendering.tabs[3] = tab
