local values = require("sussyspt/values")
local tasks = require("sussyspt/tasks")
local cmm = require("sussyspt/util/cmm")

local exports = {
    name = "Bunker"
}

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Bunker")

    function tab.render()
        if ImGui.Button("Open computer") then
            tasks.addTask(cmm.bunker)
        end

        ImGui.Separator()

        if ImGui.Button("Resupply") then
            tasks.addTask(function()
                globals.set_int(values.g.resupply_base + 6)
            end)
        end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

return exports
