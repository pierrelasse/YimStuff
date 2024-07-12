local values = require("sussyspt/values")
local tasks = require("sussyspt/tasks")
local cmm = require("sussyspt/util/cmm")

local exports = {
    name = "Motorcyle Club"
}

function exports.registerManage(parentTab)
    local tab = SussySpt.rendering.newTab("Manage")

    function tab.render()
        ImGui.Text("Computer")
        if ImGui.Button("The Open Road") then tasks.addTask(cmm.biker) end

        ImGui.Separator()

        if ImGui.Button("Raise sell prices [broken]") then
            tasks.addTask(function()
                globals.set_int(262145 + 17629, 30000)  -- Counterfeit Cash factory
                globals.set_int(262145 + 17630, 100000) -- Cocaine Lockup
                globals.set_int(262145 + 17631, 60000)  -- Meth Lab
                globals.set_int(262145 + 17632, 15000)  -- Weed Farm
                globals.set_int(262145 + 17628, 20000)  -- Document Forgery Office
            end)
        end

        ImGui.SameLine()

        if ImGui.Button("Faster production [broken]") then
            tasks.addTask(function()
                globals.set_int(262145 + 17603, 25500) -- Counterfeit Cash factory
                globals.set_int(262145 + 17601, 25500) -- Cocaine Lockup
                globals.set_int(262145 + 17600, 25500) -- Meth Lab
                globals.set_int(262145 + 17599, 25500) -- Weed Farm
                globals.set_int(262145 + 17602, 25500) -- Document Forgery Office
            end)
        end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.registerBusinesses(parentTab)
    local tab = SussySpt.rendering.newTab("Businesses")

    local businesses = {
        "Counterfeit Cash Factory",
        "Cocaine Lockup",
        "Meth Lab",
        "Weed Farm",
        "Document Forgery Office"
    }

    local computers = {
        cmm.biker_cash,
        cmm.biker_cocaine,
        cmm.biker_meth,
        cmm.biker_weed,
        cmm.biker_documents
    }

    local tableFlags =
        ImGuiTableFlags.Resizable
        | ImGuiTableFlags.RowBg
        | ImGuiTableFlags.BordersOuter


    function tab.render()
        if ImGui.BeginTable("##businesses_table", 3, tableFlags) then
            ImGui.TableSetupColumn("Name")
            ImGui.TableSetupColumn("Stats")
            ImGui.TableSetupColumn("Actions")
            ImGui.TableHeadersRow()

            local row = 0
            for businessId, businessName in ipairs(businesses) do
                ImGui.TableNextRow()
                ImGui.PushID(row)

                ImGui.TableSetColumnIndex(0)
                ImGui.TextWrapped(businessName)

                ImGui.TableSetColumnIndex(1)
                ImGui.Text("Coming soon mb")
                yu.rendering.tooltip("R* code very hard to read and unnessary complicated")

                ImGui.TableSetColumnIndex(2)
                if ImGui.SmallButton("Computer") then
                    tasks.addTask(computers[businessId])
                end

                ImGui.SameLine()

                if ImGui.SmallButton("Resupply") then
                    tasks.addTask(function()
                        globals.set_int(values.g.bunker_resupply_base + businessId, 1)
                    end)
                end

                if SussySpt.dev and ImGui.SmallButton("help123456789") then
                    tasks.addTask(function()
                        log.info("Smth2: "..
                            globals.get_int(1845263 + (yu.pid() + 877) + 267 + 195 + (businessId + 13) + 12))
                    end)
                end

                ImGui.PopID()
                row = row + 1
            end
        end

        ImGui.EndTable()
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.register(tab)
    exports.registerManage(tab)
    exports.registerBusinesses(tab)
end

return exports
