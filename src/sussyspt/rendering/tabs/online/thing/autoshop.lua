local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")
local addUnknownValue = require("./addUnknownValue")

local exports = {}

function exports.registerContracts(parentTab)
    local tab = SussySpt.rendering.newTab("Contracts")

    local contract
    local contractSet
    local contracts = {
        [0] = "Union Depository",
        [1] = "The Superdollar Deal",
        [2] = "The Bank Contract",
        [3] = "The ECU Job",
        [4] = "The Prison Contract",
        [5] = "The Agency Deal",
        [6] = "The Lost Contract",
        [7] = "The Data Contract",
    }

    local scriptName = "fm_mission_controller_2020"
    local scriptHash = joaat(scriptName)
    local scriptRunning = false

    local function tick()
        local mpx = yu.mpx()

        if contractSet ~= nil then
            stats.set_int(mpx.."TUNER_GEN_BS", contractSet == 1 and 4351 or 12543)
            stats.set_int(mpx.."TUNER_CURRENT", contractSet)

            contractSet = nil
        end

        contract = stats.get_int(mpx.."TUNER_CURRENT")
        addUnknownValue(contracts, contract)

        scriptRunning = yu.is_script_running_hash(scriptHash)
    end

    function tab.render()
        tasks.tasks.screen = tick
        if contract == nil then return end

        ImGui.BeginGroup()
        if ImGui.BeginListBox("##contracts_list", 410, 310) then
            for k, v in pairs(contracts) do
                local selected = contract == k
                if ImGui.Selectable(v, selected) and not selected then
                    contractSet = k
                end
            end
            ImGui.EndListBox()
        end
        ImGui.EndGroup()

        ImGui.SameLine()

        ImGui.BeginGroup()

        if ImGui.Button("Complete Preps") then
            tasks.addTask(function()
                stats.set_int(yu.mpx("TUNER_GEN_BS"), -1)
            end)
        end

        ImGui.SameLine()

        if ImGui.Button("Reset Preps") then
            tasks.addTask(function()
                stats.set_int(yu.mpx("TUNER_GEN_BS"), 12467)
            end)
        end

        if ImGui.Button("Reset contract") then
            tasks.addTask(function()
                local mpx = yu.mpx()
                stats.set_int(mpx.."TUNER_GEN_BS", 8371)
                stats.set_int(mpx.."TUNER_CURRENT", -1)
            end)
        end

        ImGui.SameLine()

        if ImGui.Button("Reset stats") then
            tasks.addTask(function()
                stats.set_int(yu.mpx("TUNER_COUNT"), 0)
                stats.set_int(yu.mpx("TUNER_EARNINGS"), 0)
            end)
        end
        yu.rendering.tooltip("This will set how many contracts you've done to 0 and how much you earned from it")

        ImGui.BeginDisabled(not scriptRunning)
        if ImGui.Button("Instant finish (solo)") then
            tasks.addTask(function()
                locals.set_int("fm_mission_controller_2020", values.g.autoshop_instantfinish_1,
                    values.g.autoshop_instantfinish_1_value)
                locals.set_int("fm_mission_controller_2020", values.g.autoshop_instantfinish_2,
                    values.g.autoshop_instantfinish_2_value)
            end)
        end
        ImGui.EndDisabled()

        ImGui.EndGroup()
    end

    parentTab.sub[1] = tab
end

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Auto Shop")

    exports.registerContracts(tab)

    -- local a = {

    --     cooldowns = {}
    -- }

    -- do -- ANCHOR Cooldowns
    --     local tab2 = SussySpt.rendering.newTab("Cooldowns")

    --     local function refreshCooldown(mpx, i)
    --         local cooldown = math.max(0,
    --                                   stats.get_int(mpx.."TUNER_CONTRACT"..i.."_POSIX") - os.time())

    --         a.cooldowns[i] = {
    --             a.heists[i],
    --             yu.format_seconds(cooldown)
    --         }
    --     end

    --     local function refresh()
    --         local mpx = yu.mpx()
    --         for i = 0, 7 do
    --             refreshCooldown(mpx, i)
    --         end
    --     end
    --     tasks.addTask(refresh)

    --     function tab2.render()
    --         if ImGui.SmallButton("Refresh") then
    --             tasks.addTask(refresh)
    --         end

    --         ImGui.Separator()

    --         if ImGui.BeginTable("cooldowns", 3, 3905) then
    --             ImGui.TableSetupColumn("Contract")
    --             ImGui.TableSetupColumn("Cooldown")
    --             ImGui.TableSetupColumn("Actions")
    --             ImGui.TableHeadersRow()

    --             local row = 0
    --             for k, v in pairs(a.cooldowns) do
    --                 ImGui.TableNextRow()

    --                 ImGui.PushID(row)

    --                 ImGui.TableSetColumnIndex(0)
    --                 ImGui.Text(v[1])

    --                 ImGui.TableSetColumnIndex(1)
    --                 ImGui.Text(v[2])

    --                 ImGui.TableSetColumnIndex(2)
    --                 if ImGui.Button("Clear##row_"..row) then
    --                     tasks.addTask(function()
    --                         stats.set_int(yu.mpx("TUNER_CONTRACT"..k.."_POSIX"), os.time())
    --                         refreshCooldown(yu.mpx(), k)
    --                     end)
    --                 end

    --                 ImGui.PopID()
    --                 row = row + 1
    --             end

    --             ImGui.EndTable()
    --         end
    --     end

    --     tab.sub[2] = tab2
    -- end

    parentTab.sub[#parentTab.sub + 1] = tab
end

return exports
