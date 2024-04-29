local tasks = require("sussyspt/tasks")

local tab = SussySpt.rendering.newTab("Singleplayer")

tab.should_display = function() return not SussySpt.in_online end

local a = {
    characters = {
        [0] = "Michael",
        [1] = "Franklin",
        [2] = "Trevor"
    },
    cash = {}
}

do -- ANCHOR Cash
    local tab2 = SussySpt.rendering.newTab("Cash")

    local function tick()
        for k, _ in pairs(a.characters) do
            a.cash[k] = stats.get_int("SP"..k.."_TOTAL_CASH")
        end
    end

    function tab2.render()
        tasks.tasks.screen = tick

        for k, v in pairs(a.cash) do
            local resp = yu.rendering.input("int", {
                label = a.characters[k],
                value = v
            })
            if resp ~= nil and resp.changed then
                tasks.addTask(function()
                    stats.set_int("SP"..k.."_TOTAL_CASH", resp.value)
                end)
            end
        end
    end

    tab.sub[1] = tab2
end

SussySpt.rendering.tabs[4] = tab
