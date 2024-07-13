local renderManager = require("sussyspt/rendering/renderManager")

local tab = {}

tab.guiTab = gui.get_tab("SussySpt")
SussySpt.tab = tab.guiTab

function tab.addTabs()
    require("sussyspt/rendering/tabs")

    require("sussyspt/quickActions")

    do -- ANCHOR Verify tabs
        local tabSize = 0

        local function countTabs(tbl)
            if type(tbl) ~= "table" then
                return
            end
            for k, v in pairs(tbl) do
                tabSize = tabSize + 1
                if v.sub == tbl then
                    tbl[k] = nil
                    log.warning("Overflow for tab "..v.name)
                else
                    countTabs(v.sub)
                end
            end
        end
        countTabs(SussySpt.rendering.tabs)

        SussySpt.debug("Created "..tabSize.." tabs")
    end
end

function tab.addRender()
    SussySpt.debug("Adding render callback")
    SussySpt.tab:add_imgui(renderManager.render)
end

return tab
