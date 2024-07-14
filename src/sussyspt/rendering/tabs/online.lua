local tab = SussySpt.rendering.newTab("Online")

function tab.should_display()
    return SussySpt.in_online or yu.len(SussySpt.players) >= 2
end

require("sussyspt/rendering/tabs/online/players").register(tab)
require("sussyspt/rendering/tabs/online/thing").register(tab)
require("sussyspt/rendering/tabs/online/stats").register(tab)
require("sussyspt/rendering/tabs/online/chatlog").register(tab)
require("sussyspt/rendering/tabs/online/cmm").register(tab)
require("sussyspt/rendering/tabs/online/unlocks").register(tab)
require("sussyspt/rendering/tabs/online/session").register(tab)
require("sussyspt/rendering/tabs/online/transactions").register(tab)

SussySpt.rendering.tabs[2] = tab
