local exports = {}

function exports.register(tab)
    local tab2 = SussySpt.rendering.newTab("Thing")

    require("./thing/apartment").register(tab2)
    require("./thing/agency").register(tab2)
    require("./thing/autoshop").register(tab2)
    require("./thing/kosatka").register(tab2)
    require("./thing/salvageyard").register(tab2)
    require("./thing/securoserv").register(tab2)


    -- do -- SECTION Motorcycle Club
    --     local tab3 = SussySpt.rendering.newTab("Motorcycle Club")
    --     tab2.sub[6] = tab3
    -- end -- !SECTION

    -- do -- SECTION Bunker
    --     local tab3 = SussySpt.rendering.newTab("Bunker")
    --     tab2.sub[8] = tab3
    -- end -- !SECTION

    require("./thing/arcade").register(tab2)
    require("./thing/nightclub").register(tab2)
    require("./thing/casino").register(tab2)
    require("./thing/facility").register(tab2)

    tab.sub[2] = tab2
end

return exports
