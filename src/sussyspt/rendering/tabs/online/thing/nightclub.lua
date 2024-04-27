local tasks = require("sussyspt/tasks")

local exports = {}

function exports.register(tab2)
    local tab3 = SussySpt.rendering.newTab("Nightclub")

    local a = {
        storages = {
            [0] = {
                "Cargo and Shipments (CEO Office Special Cargo Warehouse or Smuggler's Hangar)",
                "Cargo and Shipments",
                50
            },
            [1] = {
                "Sporting Goods (Gunrunning Bunker)",
                "Sporting Goods",
                100
            },
            [2] = {
                "South American Imports (M/C Cocaine Lockup)",
                "S. A. Imports",
                10
            },
            [3] = {
                "Pharmaceutical Research (M/C Methamphetamine Lab)",
                "Pharmaceutical Research",
                20
            },
            [4] = {
                "Organic Produce (M/C Weed Farm)",
                "Organic Produce",
                80
            },
            [5] = {
                "Printing & Copying (M/C Document Forgery Office)",
                "Printing & Copying",
                60
            },
            [6] = {
                "Cash Creation (M/C Counterfeit Cash Factory)",
                "Cash Creation",
                40
            },
        },
        storageflags =
            ImGuiTableFlags.BordersV
            + ImGuiTableFlags.BordersOuterH
            + ImGuiTableFlags.RowBg
    }

    local function refresh()
        a.popularity = stats.get_int(yu.mpx().."CLUB_POPULARITY")

        a.storage = {}
        local storageGlob = globals.get_int(286713)
        for k, v in pairs(a.storages) do
            local stock = stats.get_int(yu.mpx("HUB_PROD_TOTAL_"..k))
            a.storage[k] = {
                stock.."/"..v[3],
                "$"..yu.format_num(storageGlob * stock)
            }
        end
    end
    tasks.addTask(refresh)

    local nightclubScript = "am_mp_nightclub"

    local function collectSafeNow()
        locals.set_int(nightclubScript, 732, 1)
    end

    local function ensureScriptAndCollectSafe()
        if yu.is_script_running(nightclubScript) then
            collectSafeNow()
        else
            -- yu.rif(function(fs)
            --     SCRIPT.REQUEST_SCRIPT(nightclubScript)
            --     repeat fs:yield() until SCRIPT.HAS_SCRIPT_LOADED(nightclubScript)
            --     SYSTEM.START_NEW_SCRIPT_WITH_NAME_HASH(joaat(nightclubScript), 3650)
            --     repeat fs:yield() until yu.is_script_running(nightclubScript)
            --     collectSafeNow()
            --     SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(nightclubScript)
            -- end)
            yu.notify(3, "You need to be in your nightclub for this!", "Not implemented yet")
        end
    end

    function tab3.render()
        if ImGui.Button("Refresh") then
            tasks.addTask(refresh)
        end

        ImGui.Separator()

        ImGui.BeginGroup()

        ImGui.PushItemWidth(140)
        local pnv, pc ImGui.InputInt("Popularity", a.popularity, 0, 1000)
        yu.rendering.tooltip("Type number in and then click Set :D")
        ImGui.PopItemWidth()
        if pc then
            a.popularity = pnv
        end

        ImGui.SameLine()

        if ImGui.Button("Set##popularity") then
            tasks.addTask(function()
                stats.set_int(yu.mpx().."CLUB_POPULARITY", a.popularity)
                refresh()
            end)
        end
        yu.rendering.tooltip("Set the popularity to the input field")

        ImGui.SameLine()

        if ImGui.Button("Refill##popularity") then
            tasks.addTask(function()
                stats.set_int(yu.mpx().."CLUB_POPULARITY", 1000)
                a.popularity = 1000
                refresh()
            end)
        end
        yu.rendering.tooltip("Set the popularity to 1000")

        if ImGui.Button("Pay now") then
            tasks.addTask(function()
                stats.set_int(yu.mpx("CLUB_PAY_TIME_LEFT"), -1)
            end)
        end
        yu.rendering.tooltip("This will decrease the popularity by 50 and will put $50k in the safe.")

        ImGui.SameLine()

        if ImGui.Button("Collect money") then
            tasks.addTask(ensureScriptAndCollectSafe)
        end
        yu.rendering.tooltip("Experimental")

        ImGui.EndGroup()
        ImGui.BeginGroup()
        yu.rendering.bigText("Storage")

        if ImGui.BeginTable("##storage_table", 3, 3905) then
            ImGui.TableSetupColumn("Goods")
            ImGui.TableSetupColumn("Stock")
            ImGui.TableSetupColumn("Stock price")
            ImGui.TableSetupColumn("Actions")
            ImGui.TableHeadersRow()

            local row = 0
            for k, v in pairs(a.storages) do
                local storage = a.storage[k]
                if storage ~= nil then
                    ImGui.TableNextRow()
                    ImGui.PushID(row)
                    ImGui.TableSetColumnIndex(0)
                    ImGui.TextWrapped(v[2])
                    yu.rendering.tooltip(v[1])
                    ImGui.TableSetColumnIndex(1)
                    ImGui.Text(storage[1])
                    ImGui.TableSetColumnIndex(2)
                    ImGui.Text(storage[2])
                    ImGui.PopID()
                    row = row + 1
                end
            end

            ImGui.EndTable()
        end

        ImGui.EndGroup()
        ImGui.BeginGroup()
        yu.rendering.bigText("Other")

        yu.rendering.renderCheckbox("Remove Tony's cut", "hbo_nightclub_tony", function(state)
            tasks.addTask(function()
                globals.set_float(286403, yu.shc(state, 0, .025))
            end)
        end)
        yu.rendering.tooltip("Set Tony's cut to 0.\nWhen disabled, the cut will be set back to 0.025.")

        ImGui.EndGroup()
    end

    tab2.sub[10] = tab3
end

return exports
