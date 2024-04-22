local tab = SussySpt.rendering.newTab("Online")

function tab.should_display()
    return SussySpt.in_online or yu.len(SussySpt.players) >= 2
end

require("./online/players").register(tab)
require("./online/thing").register(tab)
require("./online/stats").register(tab)
require("./online/chatlog").register(tab)
require("./online/cmm").register(tab)
require("./online/unlocks").register(tab)
require("./online/session").register(tab)
require("./online/money").register(tab)

SussySpt.rendering.tabs[1] = tab
