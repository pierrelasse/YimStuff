local values = require("sussyspt/values")
local tasks = require("sussyspt/tasks")
local cmm = require("sussyspt/util/cmm")

local exports = {
    name = "Motorcyle Club"
}

function exports.registerComputer(parentTab)
    local tab = SussySpt.rendering.newTab("Computer")

    function tab.render()
        if ImGui.Button("The Open Road") then tasks.addTask(cmm.biker) end
        if ImGui.Button("Counterfeit Cash factory") then tasks.addTask(cmm.biker_cash) end
        if ImGui.Button("Cocaine Lockup") then tasks.addTask(cmm.biker_cocaine) end
        if ImGui.Button("Meth Lab") then tasks.addTask(cmm.biker_meth) end
        if ImGui.Button("Weed Farm") then tasks.addTask(cmm.biker_weed) end
        if ImGui.Button("Document Forgery Office") then tasks.addTask(cmm.biker_documents) end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.registerSupplies(parentTab)
    local tab = SussySpt.rendering.newTab("Supplies")

    -- ["Acid Lab"] = base + 7

    local base = values.g.resupply_base
    local items = {
        ["Counterfeit Cash Factory"] = base + 1,
        ["Cocaine Lockup"] = base + 2,
        ["Meth Lab"] = base + 3,
        ["Weed Farm"] = base + 4,
        ["Document Forgery Office"] = base + 5,
    }

    function tab.render()
        ImGui.Text("Click to resupply")
        for k, v in pairs(items) do
            if ImGui.Button(k) then
                tasks.addTask(function()
                    globals.set_int(v, 1)
                end)
            end
        end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("MC")
    exports.registerComputer(tab)
    exports.registerSupplies(tab)
    parentTab.sub[#parentTab.sub + 1] = tab
end

return exports
