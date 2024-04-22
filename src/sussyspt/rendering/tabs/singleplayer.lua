local tasks = require("../../tasks")

local tab = SussySpt.rendering.newTab("Singleplayer")

local a = {
    characters = {
        [0] = "Michael",
        [1] = "Franklin",
        [2] = "Trevor"
    }
}

do -- ANCHOR Cash
    local tab2 = SussySpt.rendering.newTab("Cash")

    local function refresh()
        a.cash = {}
        for k, v in pairs(a.characters) do
            a.cash[k] = stats.get_int("SP"..k.."_TOTAL_CASH")
        end
    end
    yu.rif(refresh)

    function tab2.render()
        for k, v in pairs(a.cash) do
            local resp = yu.rendering.input("int", {
                label = a.characters[k],
                value = v
            })
            if resp ~= nil and resp.changed then
                a.cash[k] = resp.value
            end
        end

        if ImGui.Button("Apply") then
            tasks.addTask(function()
                for k, v in pairs(a.cash) do
                    stats.set_int("SP"..k.."_TOTAL_CASH", v)
                end
                refresh()
            end)
        end
    end

    tab.sub[1] = tab2
end

SussySpt.rendering.tabs[4] = tab
