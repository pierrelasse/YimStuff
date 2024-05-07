local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")
-- local cmm = require("sussyspt/util/cmm")

local exports = {
    name = "SecuroServ"
}

function exports.registerWarehouse(parentTab)
    local tab = SussySpt.rendering.newTab("Warehouse")

    local scriptName = "gb_contraband_buy"
    local scriptHash = joaat(scriptName)
    local scriptRunning = false

    local amount = 1
    local amountMin = 1
    local amountMax = 40
    local get = nil

    local function tick()
        scriptRunning = yu.is_script_running_hash(scriptHash)

        if scriptRunning and get ~= nil then
            locals.set_int("gb_contraband_buy", values.l.warehouse_instant_1, values.l.warehouse_instant_1_value)
            locals.set_int("gb_contraband_buy", values.l.warehouse_instant_2, get)
            locals.set_int("gb_contraband_buy", values.l.warehouse_instant_3, values.l.warehouse_instant_3_value)
            locals.set_int("gb_contraband_buy", values.l.warehouse_instant_4, values.l.warehouse_instant_4_value)
            get = nil
        end
    end

    function tab.render()
        tasks.tasks.screen = tick

        -- if ImGui.Button("Open master computer") then
        --     tasks.addTask(function(rs)
        --         cmm.master(rs)
        --     end)
        -- end

        if not scriptRunning then
            ImGui.Text("You need to start a buy mission first")
            return
        end

        ImGui.Text("Get crates instantly")

        ImGui.SetNextItemWidth(150)
        local value, used = ImGui.InputInt("##input", amount, amountMin, amountMax)
        SussySpt.pushDisableControls(ImGui.IsItemActive())
        if used then
            amount = value
        end

        ImGui.SameLine()

        if ImGui.Button("Get") then
            get = amount
        end
    end

    parentTab.sub[1] = tab
end

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("SecuroServ")
    exports.registerWarehouse(tab)
    parentTab.sub[#parentTab.sub + 1] = tab
end

return exports
