local tasks = require("./tasks")
local cfg = require("./config")

local quickActions = {}

quickActions.actions = require("sussyspt/qaActions")

quickActions.config = {
    default = {
        "heal", "refillHealth", "refillArmor", "clearWantedLevel", 0,
        "ri2", "skipCutscene", "removeBlackscreen", 0,
        "repairVehicle", "stfu", "masterControl", 0,
        "instantBST", "depositWallet", "stopPlayerSwitch"
    }
}

function quickActions.config.load()
    local sort = cfg.get("qa_sort")
    if sort == nil then sort = yu.copy_table(quickActions.config.default) end
    quickActions.config.sort = sort

    yu.rendering.setCheckboxChecked("cat_qa", cfg.get("cat_qa", false))
end

function quickActions.config.save()
    if type(quickActions.config.sort) ~= "table" then return end
    if table.compare(quickActions.config.default, quickActions.config.sort) then
        cfg.set("qa_sort", nil)
    else
        cfg.set("qa_sort", quickActions.config.sort)
    end
    cfg.save()
end

quickActions.config.load()

function quickActions.render()
    if not yu.rendering.isCheckboxChecked("cat_qa") then return end

    if ImGui.Begin("Quick actions") then
        local sameline = false
        for _, field in pairs(quickActions.config.sort) do
            if type(field) == "number" then
                if field == 0 then sameline = false end
            elseif type(field) == "string" then
                local b = quickActions.actions[field]
                if b ~= nil then
                    if type(b[4]) ~= "function" or b[4]() ~= false then
                        if sameline then ImGui.SameLine() end
                        sameline = true

                        if ImGui.Button(b[2]) then
                            tasks.addTask(b[1])
                        end
                        if b[3] ~= nil and ImGui.IsItemHovered() then
                            ImGui.SetTooltip(b[3])
                        end
                    end
                end
            end
        end
    end
    ImGui.End()
end

return quickActions
