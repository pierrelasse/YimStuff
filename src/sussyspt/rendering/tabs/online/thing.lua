local renderManager = require("sussyspt/rendering/renderManager")

local exports = {}

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Thing")

    local modules = {
        require("./thing/kosatka"),
        require("./thing/casino"),
        require("./thing/apartment"),
        require("./thing/facility"),
        require("./thing/securoserv"),
        require("./thing/agency"),
        require("./thing/salvageyard"),
        require("./thing/mc"),
        require("./thing/autoshop"),
        -- require("./thing/hangar"),
        require("./thing/bunker"),
        require("./thing/arcade"),
        require("./thing/nightclub")
    }

    for _, item in ipairs(modules) do item.stage = false end

    local selected

    function tab.render()
        if selected == nil then
            for index, item in ipairs(modules) do
                if index ~= 1 and index % 4 ~= 1 then ImGui.SameLine() end
                if ImGui.Button(item.name) then selected = item end
            end
        elseif ImGui.Button(" <- ") then
            selected = nil
        else
            ImGui.SameLine()
            ImGui.Text("Viewing: "..selected.name)
            ImGui.Separator()

            if selected.stage == nil then
                local renderFunc = selected.render or function()
                    for _, modTab in pairs(selected.tab.sub) do
                        renderManager.renderTabContent(modTab)
                        break
                    end
                end
                renderFunc()
            else
                if selected.stage == false then
                    selected.stage = true
                    local loadFunc = selected.load or function()
                        selected.tab = { sub = {} }
                        selected.register(selected.tab)
                        selected.stage = nil
                    end
                    loadFunc()
                end
                ImGui.Text("Loading module...")
            end
        end
    end

    parentTab.sub[2] = tab
end

return exports
