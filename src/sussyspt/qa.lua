local tasks = require("./tasks")
local cfg = require("./config")

SussySpt.qa = {}

SussySpt.qa.actions = require("sussyspt/qaActions")

SussySpt.qa.config = {
    default = {
        "heal", "refillHealth", "refillArmor", "clearWantedLevel", 0,
        "ri2", "skipCutscene", "removeBlackscreen", 0,
        "repairVehicle", "stfu", 0,
        "instantBST", "depositWallet", "stopPlayerSwitch"
    }
}

function SussySpt.qa.config.load()
    local sort = cfg.get("qa_sort")
    if sort == nil then sort = yu.copy_table(SussySpt.qa.config.default) end
    SussySpt.qa.config.sort = sort
end

function SussySpt.qa.config.save()
    if type(SussySpt.qa.config.sort) ~= "table" then return end
    if table.compare(SussySpt.qa.config.default, SussySpt.qa.config.sort) then
        cfg.set("qa_sort", nil)
    else
        cfg.set("qa_sort", SussySpt.qa.config.sort)
    end
    cfg.save()
end

SussySpt.qa.config.load()

function SussySpt.qa.render()
    if not yu.rendering.isCheckboxChecked("cat_qa") then return end

    if ImGui.Begin("Quick actions") then
        local sameline = false
        for k, v in pairs(SussySpt.qa.config.sort) do
            if type(v) == "number" then
                if v == 0 then sameline = false end
            elseif type(v) == "string" then
                local b = SussySpt.qa.actions[v]
                if b ~= nil then
                    if type(b[4]) ~= "function" or b[4]() ~= false then
                        if sameline then ImGui.SameLine() end
                        sameline = true

                        if ImGui.Button(b[2]) then
                            tasks.addTask(function()
                                b[1]()
                            end)
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
