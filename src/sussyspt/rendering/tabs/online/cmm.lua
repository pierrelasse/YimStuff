local tasks = require("sussyspt/tasks")

local exports = {}

function exports.register(tab)
    local tab2 = SussySpt.rendering.newTab("CMM")

    local a = {
        apps = {
            ["appbusinesshub"] = "Nightclub",
            ["appAvengerOperations"] = "Avenger Operations",
            ["appfixersecurity"] = "Agency",
            ["appinternet"] = "Internet (Phone)",
            ["apparcadebusinesshub"] = "Mastercontrol (Arcade)",
            ["appbunkerbusiness"] = "Bunker Business",
            ["apphackertruck"] = "Terrorbyte",
            ["appbikerbusiness"] = "The Open Road (MC)",
            ["appsmuggler"] = "Free Trade Shipping Co. (Hangar)",
        }
    }

    local function runScript(name)
        yu.rif(function(rs)
            SCRIPT.REQUEST_SCRIPT(name)
            repeat rs:yield() until SCRIPT.HAS_SCRIPT_LOADED(name)
            SYSTEM.START_NEW_SCRIPT(name, 5000)
            SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(name)
        end)
    end

    function tab2.render()
        ImGui.Text("Works best when low ping / session host")

        for k, v in pairs(a.apps) do
            if ImGui.Button(v) then
                tasks.addTask(function()
                    runScript(k)
                end)
            end
        end
    end

    tab.sub[5] = tab2
end

return exports
