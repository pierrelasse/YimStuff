local tasks = require("./tasks")
local cfg = require("./config")

local qa = {}

qa.actions = require("sussyspt/qaActions")

qa.config = {
    default = {
        "heal", "refillHealth", "refillArmor", "clearWantedLevel", 0,
        "ri2", "skipCutscene", "removeBlackscreen", 0,
        "repairVehicle", "stfu", "masterControl", 0,
        "instantBST", "depositWallet", "stopPlayerSwitch"
    }
}

function qa.config.load()
    local sort = cfg.get("qa_sort")
    if sort == nil then sort = yu.copy_table(qa.config.default) end
    qa.config.sort = sort
end

function qa.config.save()
    if type(qa.config.sort) ~= "table" then return end
    if table.compare(qa.config.default, qa.config.sort) then
        cfg.set("qa_sort", nil)
    else
        cfg.set("qa_sort", qa.config.sort)
    end
    cfg.save()
end

qa.config.load()

function qa.render()
    if not yu.rendering.isCheckboxChecked("cat_qa") then return end

    if ImGui.Begin("Quick actions") then
        local sameline = false
        for _, field in pairs(qa.config.sort) do
            if type(field) == "number" then
                if field == 0 then sameline = false end
            elseif type(field) == "string" then
                local b = qa.actions[field]
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

return qa
