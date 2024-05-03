local tasks = require("sussyspt/tasks")
local values = require("sussyspt/values")
local removeAllCameras = require("sussyspt/util/removeAllCameras")
local addUnknownValue = require("./addUnknownValue")

local exports = {}

function exports.registerHeist(parentTab)
    local tab = SussySpt.rendering.newTab("Heist")

    local function renderCutsSlider(tbl, index, callback)
        local value = tbl[index] or 85
        local text = yu.shc((index == 0), "Non-host self cut", "Player "..index.."'s cut")
        local newValue, changed = ImGui.DragInt(text, value, .2, 0, 250, "%d%%", 5)
        SussySpt.pushDisableControls(ImGui.IsItemActive())
        if changed then
            callback(index, newValue)
        end
        ImGui.SameLine()
        ImGui.PushButtonRepeat(true)
        if ImGui.Button(" - ##cuts_-"..index) then
            callback(index, value - 1)
        end
        ImGui.SameLine()
        if ImGui.Button(" + ##cuts_+"..index) then
            callback(index, value + 1)
        end
        ImGui.PopButtonRepeat()
    end

    local planningShown = false

    local primaryTarget
    local primaryTargets = {
        [0] = "Sinsimito Tequila [ $630K|$693K ]",
        [1] = "Ruby Necklace [ $700K|$770K ]",
        [2] = "Bearer Bonds [ $770K|$847 ]",
        [4] = "Minimadrazzo Files [ $1,1M|1,21M ]",
        [3] = "Pink Diamond [ $1,3M|1,43M ]",
        [5] = "Panther Statue [ $1,9M|2,09M ]",
    }

    local storageTypes = {
        [1] = "None",
        [2] = "Cash",
        [3] = "Weed",
        [4] = "Coke",
        [5] = "Gold",
    }
    local storageItemTypeIds = {
        [2] = "CASH",
        [3] = "WEED",
        [4] = "COKE",
        [5] = "GOLD"
    }
    local compoundStorageType = 1
    local compoundStorageTypeOverride
    local compountStorageAmount = 0
    local compoundStorageAmounts = {
        [0] = 0,
        [1] = 64,
        [2] = 128,
        [3] = 196,
        [4] = 204,
        [5] = 220,
        [6] = 252,
        [7] = 253,
        [8] = 255
    }
    local islandStorageType = 1
    local islandStorageTypeOverride
    local islandStorageAmount = 0
    local islandStorageAmounts = {
        [0] = 0,
        [1] = 8388608,
        [2] = 12582912,
        [3] = 12845056,
        [4] = 12976128,
        [5] = 13500416,
        [6] = 14548992,
        [7] = 16646144,
        [8] = 16711680,
        [9] = 16744448,
        [10] = 16760832,
        [11] = 16769024,
        [12] = 16769536,
        [13] = 16770560,
        [14] = 16770816,
        [15] = 16770880,
        [16] = 16771008,
        [17] = 16773056,
        [18] = 16777152,
        [19] = 16777184,
        [20] = 16777200,
        [21] = 16777202,
        [22] = 16777203,
        [23] = 16777211,
        [24] = 16777215
    }

    local hasPaintings

    local difficulty
    local difficulties = {
        [126823] = "Normal",
        [131055] = "Hard",
    }

    local approach
    local approaches = {
        [65283] = "Kosatka",
        [65413] = "Alkonost",
        [65289] = "Velum",
        [65425] = "Stealth Annihilator",
        [65313] = "Patrol Boat",
        [65345] = "Longfin",
        [65535] = "*All*",
    }

    local weapon
    local weapons = {
        "Aggressor",
        "Conspirator",
        "Crackshot",
        "Saboteur",
        "Marksman",
    }
    local weaponContents = {
        "Assault SG + Machine Pistol + Machete + Grenade",
        "Military Rifle + AP + Knuckles + Stickies",
        "Sniper + AP + Knife + Molotov",
        "SMG Mk2 + SNS Pistol + Knife + Pipe Bomb",
        "AK-47? + Pistol .50? + Machete + Pipe Bomb"
    }

    local supplyTruckLocation
    local supplyTruckLocations = {
        "Airport",
        "North Dock",
        "Main Dock - East",
        "Main Dock - West",
        "Inside Compound",
    }

    local function getStorage(storageType, default)
        local mpx = yu.mpx()
        if stats.get_int(mpx.."H4LOOT_CASH_"..storageType) > 0 then
            return 2
        elseif stats.get_int(mpx.."H4LOOT_WEED_"..storageType) > 0 then
            return 3
        elseif stats.get_int(mpx.."H4LOOT_COKE_"..storageType) > 0 then
            return 4
        elseif stats.get_int(mpx.."H4LOOT_GOLD_"..storageType) > 0 then
            return 5
        else
            return default or 1
        end
    end

    local function getStorageAmount(type)
        local itemTypeId = type == "C" and compoundStorageType or islandStorageType
        if itemTypeId == 1 then return 0 end
        local itemType = storageItemTypeIds[itemTypeId]

        local mpx = yu.mpx()
        local value = stats.get_int(mpx.."H4LOOT_"..itemType.."_"..type.."_SCOPED")

        local storageAmounts = type == "C" and compoundStorageAmounts or islandStorageAmounts
        local out = 0
        for k, v in pairs(storageAmounts) do
            if value == v then
                out = k
            end
        end
        return out
    end

    local function applyStorageAmount(type, itemType, amount)
        local cash = 0
        local weed = 0
        local coke = 0
        local gold = 0

        local storageAmounts = type == "C" and compoundStorageAmounts or islandStorageAmounts
        if itemType == 2 then
            cash = storageAmounts[amount]
        elseif itemType == 3 then
            weed = storageAmounts[amount]
        elseif itemType == 4 then
            coke = storageAmounts[amount]
        elseif itemType == 5 then
            gold = storageAmounts[amount]
        end

        local mpx = yu.mpx()
        stats.set_int(mpx.."H4LOOT_CASH_"..type, cash)
        stats.set_int(mpx.."H4LOOT_CASH_"..type.."_SCOPED", cash)
        stats.set_int(mpx.."H4LOOT_WEED_"..type, weed)
        stats.set_int(mpx.."H4LOOT_WEED_"..type.."_SCOPED", weed)
        stats.set_int(mpx.."H4LOOT_COKE_"..type, coke)
        stats.set_int(mpx.."H4LOOT_COKE_"..type.."_SCOPED", coke)
        stats.set_int(mpx.."H4LOOT_GOLD_"..type, gold)
        stats.set_int(mpx.."H4LOOT_GOLD_"..type.."_SCOPED", gold)

        if amount > 0 then
            if type == "C" then
                compoundStorageTypeOverride = nil
            else
                islandStorageTypeOverride = nil
            end
        end
    end

    local poiUnlocked = false
    local prepsCompleted = false
    local planningBoardReloaded = true


    local startingShown = false
    local allReady = false
    local cuts = {}
    local function cutsCallback(index, newValue)
        if index == 0 then
            cuts[index] = globals.set_int(2685249 + 6615, newValue)
        else
            globals.set_int(1970744 + 831 + 56 + index, newValue)
        end
    end

    local function tick()
        local mpx = yu.mpx()

        if planningShown then
            difficulty = stats.get_int(mpx.."H4_PROGRESS")
            addUnknownValue(difficulties, difficulty)

            primaryTarget = stats.get_int(mpx.."H4CNF_TARGET")
            addUnknownValue(primaryTargets, primaryTarget)

            weapon = stats.get_int(mpx.."H4CNF_WEAPONS")
            addUnknownValue(weapons, weapon)

            approach = stats.get_int(mpx.."H4_MISSIONS")
            addUnknownValue(approaches, approach)

            compoundStorageType = getStorage("C", compoundStorageTypeOverride)
            addUnknownValue(storageTypes, compoundStorageType)
            compountStorageAmount = getStorageAmount("C")

            islandStorageType = getStorage("I", islandStorageTypeOverride)
            addUnknownValue(storageTypes, islandStorageType)
            islandStorageAmount = getStorageAmount("I")

            hasPaintings = stats.get_int(mpx.."H4LOOT_PAINT_SCOPED") > 0
            yu.rendering.setCheckboxChecked("cayo_heist_hasPaintings", hasPaintings)

            supplyTruckLocation = stats.get_int(mpx.."H4CNF_TROJAN")
            addUnknownValue(supplyTruckLocations, supplyTruckLocation)

            local cuttingPowder = stats.get_int(mpx.."H4CNF_TARGET") == 3
            yu.rendering.setCheckboxChecked("cayo_heist_cuttingPowder", cuttingPowder)

            local H4CNF_BS_GEN = stats.get_int(mpx.."H4CNF_BS_GEN")
            local H4CNF_APPROACH = stats.get_int(mpx.."H4CNF_APPROACH")
            local H4CNF_BS_ENTR = stats.get_int(mpx.."H4CNF_BS_ENTR")
            poiUnlocked =
                H4CNF_BS_GEN == -1
                and H4CNF_BS_ENTR == 63
                and H4CNF_APPROACH == -1

            prepsCompleted =
                stats.get_int(mpx.."H4CNF_UNIFORM") == -1
                and stats.get_int(mpx.."H4CNF_GRAPPEL") == -1
                -- and stats.get_int(mpx.."H4CNF_TROJAN") == 5
                and stats.get_int(mpx.."H4CNF_WEP_DISRP") == 3
                and stats.get_int(mpx.."H4CNF_ARM_DISRP") == 3
                and stats.get_int(mpx.."H4CNF_HEL_DISRP") == 3

            planningBoardReloaded =
                not yu.is_script_running("heist_island_planning")
                or locals.get_int("heist_island_planning", values.l.kosatka_boardStage) == 2

            hasHeist =
                approach ~= 0
                or difficulty ~= 0
                or H4CNF_APPROACH ~= 0
                or H4CNF_BS_ENTR ~= 0
                or H4CNF_BS_GEN ~= 0
        end

        if startingShown then
            allReady =
                globals.get_int(values.g.cayo_readyState(1)) == 1
                and globals.get_int(values.g.cayo_readyState(2)) == 1
                and globals.get_int(values.g.cayo_readyState(3)) == 1

            for i = 0, 4 do
                if i == 0 then
                    cuts[i] = globals.get_int(2685249 + 6615)
                else
                    cuts[i] = globals.get_int(1970744 + 831 + 56 + i)
                end
            end
        end
    end

    -- Cooldowns { "H4_TARGET_POSIX", "H4_COOLDOWN", "H4_COOLDOWN_HARD" }

    function tab.render()
        tasks.tasks.screen = tick

        planningShown = ImGui.TreeNodeEx("Planning")
        if planningShown then
            ImGui.Text("Difficulty")
            for k, v in pairs(difficulties) do
                if k ~= 126823 then ImGui.SameLine() end
                if ImGui.RadioButton(v, difficulty == k) then
                    tasks.addTask(function()
                        stats.set_int(yu.mpx().."H4_PROGRESS", k)
                    end)
                end
            end

            local row1Y = 28.5 * 8

            ImGui.BeginGroup()
            ImGui.Text("Approach")
            if ImGui.BeginListBox("##approachList", 165, row1Y) then
                for k, v in pairs(approaches) do
                    local selected = approach == k
                    if ImGui.Selectable(v, selected) and not selected then
                        tasks.addTask(function()
                            stats.set_int(yu.mpx().."H4_MISSIONS", k)
                        end)
                    end
                end
                ImGui.EndListBox()
            end
            ImGui.EndGroup()

            ImGui.SameLine()

            ImGui.BeginGroup()
            ImGui.Text("Primary Target")
            if ImGui.BeginListBox("##primaryTargetList", 290, row1Y) then
                for k, v in pairs(primaryTargets) do
                    local selected = primaryTarget == k
                    if ImGui.Selectable(v, selected) and not selected then
                        tasks.addTask(function()
                            stats.set_int(yu.mpx().."H4CNF_TARGET", k)
                        end)
                    end
                end
                ImGui.EndListBox()
            end
            ImGui.EndGroup()

            ImGui.SameLine()

            ImGui.BeginGroup()
            ImGui.Text("Weapon")
            if ImGui.BeginListBox("##weaponList", 120, row1Y) then
                for k, v in pairs(weapons) do
                    local selected = weapon == k
                    if ImGui.Selectable(v, selected) and not selected then
                        tasks.addTask(function()
                            stats.set_int(yu.mpx().."H4CNF_WEAPONS", k)
                        end)
                    end
                    if weaponContents[k] ~= nil and ImGui.IsItemHovered() then
                        ImGui.SetTooltip(weaponContents[k])
                    end
                end
                ImGui.EndListBox()
            end
            ImGui.EndGroup()

            do
                ImGui.Text("Compound storage")

                for k, v in ipairs(storageTypes) do
                    if k ~= 1 then ImGui.SameLine() end
                    if ImGui.RadioButton(v.."##compound", compoundStorageType == k) then
                        tasks.addTask(function()
                            if k == 1 then
                                applyStorageAmount("C", 1, 0)
                            elseif compountStorageAmount == 0 then
                                compoundStorageTypeOverride = k
                                applyStorageAmount("C", k, compountStorageAmount)
                            else
                                applyStorageAmount("C", k, compountStorageAmount)
                            end
                        end)
                    end
                end

                if compoundStorageType ~= 1 then
                    ImGui.SetNextItemWidth(350)
                    local value, used = ImGui.SliderInt("##compountStorageAmount", compountStorageAmount, 0,
                                                        #compoundStorageAmounts)
                    if used then
                        tasks.addTask(function()
                            applyStorageAmount("C", compoundStorageType, value)
                        end)
                    end
                end
            end

            do
                ImGui.Text("Island storage")

                for k, v in ipairs(storageTypes) do
                    if k ~= 1 then ImGui.SameLine() end
                    if ImGui.RadioButton(v.."##island", islandStorageType == k) then
                        tasks.addTask(function()
                            if k == 1 then
                                islandStorageTypeOverride = 1
                                applyStorageAmount("I", 1, 0)
                            elseif islandStorageAmount == 0 then
                                islandStorageTypeOverride = k
                                applyStorageAmount("I", k, islandStorageAmount)
                            else
                                islandStorageTypeOverride = 1
                                applyStorageAmount("I", k, islandStorageAmount)
                            end
                        end)
                    end
                end

                if islandStorageType ~= 1 then
                    ImGui.SetNextItemWidth(350)
                    local value, used = ImGui.SliderInt("##islandStorageAmount", islandStorageAmount, 0,
                                                        #islandStorageAmounts)
                    if used then
                        tasks.addTask(function()
                            applyStorageAmount("I", islandStorageType, value)
                        end)
                    end
                end
            end

            yu.rendering.renderCheckbox("Add paintings", "cayo_heist_hasPaintings", function(state)
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    local value = state and 127 or 0
                    stats.set_int(mpx.."H4LOOT_PAINT", value)
                    stats.set_int(mpx.."H4LOOT_PAINT_SCOPED", value)
                end)
            end)

            ImGui.Text("Supply Truck location")
            for k, v in pairs(supplyTruckLocations) do
                if k ~= 1 then ImGui.SameLine() end
                if ImGui.RadioButton(v, supplyTruckLocation == k) then
                    tasks.addTask(function()
                        stats.set_int(yu.mpx().."H4CNF_TROJAN", k)
                    end)
                end
            end

            yu.rendering.renderCheckbox("Cutting powder", "cayo_heist_cuttingPowder", function(state)
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."H4CNF_TARGET", state and 3 or 2)
                end)
            end)

            ImGui.BeginDisabled(poiUnlocked)
            if ImGui.Button("Unlock POI") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."H4CNF_BS_GEN", -1)
                    stats.set_int(mpx.."H4CNF_BS_ENTR", 63)
                    stats.set_int(mpx.."H4CNF_APPROACH", -1)
                end)
            end
            if not poiUnlocked then
                yu.rendering.tooltip("Unlocks accesspoints and approaches")
            end
            ImGui.EndDisabled()

            ImGui.SameLine()

            ImGui.BeginDisabled(prepsCompleted)
            if ImGui.Button("Complete preperations") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."H4CNF_UNIFORM", -1)
                    stats.set_int(mpx.."H4CNF_GRAPPEL", -1)
                    stats.set_int(mpx.."H4CNF_TROJAN", 5)
                    stats.set_int(mpx.."H4CNF_WEP_DISRP", 3)
                    stats.set_int(mpx.."H4CNF_ARM_DISRP", 3)
                    stats.set_int(mpx.."H4CNF_HEL_DISRP", 3)
                end)
            end
            if not prepsCompleted then
                yu.rendering.tooltip("Completes all preperation missions")
            end
            ImGui.EndDisabled()

            ImGui.SameLine()

            ImGui.BeginDisabled(planningBoardReloaded)
            if ImGui.Button("Reload planning board") then
                tasks.addTask(function()
                    if SussySpt.requireScript("heist_island_planning") then
                        locals.set_int("heist_island_planning", 1544, 2)
                    end
                end)
            end
            if not planningBoardReloaded then
                yu.rendering.tooltip("Reloads the planning board inside the kosatka")
            end
            ImGui.EndDisabled()

            ImGui.SameLine()

            ImGui.BeginDisabled(not hasHeist)
            if ImGui.Button("Reset heist") then
                tasks.addTask(function()
                    local mpx = yu.mpx()
                    stats.set_int(mpx.."H4_MISSIONS", 0)
                    stats.set_int(mpx.."H4_PROGRESS", 0)
                    stats.set_int(mpx.."H4CNF_APPROACH", 0)
                    stats.set_int(mpx.."H4CNF_BS_ENTR", 0)
                    stats.set_int(mpx.."H4CNF_BS_GEN", 0)
                    applyStorageAmount("C", 1, 0)
                    applyStorageAmount("I", 1, 0)
                end)
            end
            if hasHeist then
                yu.rendering.tooltip("Resets all progress for preperations and planning")
            end
            ImGui.EndDisabled()

            ImGui.TreePop()
        end

        startingShown = ImGui.TreeNodeEx("Starting")
        if startingShown then
            ImGui.BeginDisabled(allReady)
            if ImGui.Button("All ready") then
                tasks.addTask(function()
                    for i = 1, 3 do
                        globals.set_int(values.g.cayo_readyState(i), 1)
                    end
                end)
            end
            if not allReady then
                yu.rendering.tooltip("Forces everyone to be ready")
            end
            ImGui.EndDisabled()

            ImGui.Separator()

            ImGui.Text("Cuts")
            renderCutsSlider(cuts, 0, cutsCallback)
            renderCutsSlider(cuts, 1, cutsCallback)
            renderCutsSlider(cuts, 2, cutsCallback)
            renderCutsSlider(cuts, 3, cutsCallback)
            renderCutsSlider(cuts, 4, cutsCallback)

            ImGui.TreePop()
        end

        if ImGui.TreeNodeEx("In heist") then
            if ImGui.Button("Remove all cameras") then
                tasks.addTask(removeAllCameras)
            end

            if ImGui.Button("Skip sewer tunnel cut") then
                tasks.addTask(function()
                    local scriptName = "fm_mission_controller_2020"

                    if SussySpt.requireScript(scriptName) and (locals.get_int(scriptName, 29118) >= 4 or locals.get_int(scriptName, 28446) <= 6) then
                        locals.set_int(scriptName, 29118, 6)
                    end
                end)
            end

            if ImGui.Button("Skip door hack") then
                tasks.addTask(function()
                    local scriptName = "fm_mission_controller_2020"
                    if SussySpt.requireScript(scriptName) and locals.get_int(scriptName, 24333) ~= 4 then
                        locals.set_int(scriptName, 24333, 5)
                    end
                end)
            end

            if ImGui.Button("Skip fingerprint hack") then
                tasks.addTask(function()
                    if  SussySpt.requireScript("fm_mission_controller_2020")
                    and locals.get_int("fm_mission_controller_2020", 24333) == 4 then
                        locals.set_int("fm_mission_controller_2020", 24333, 5)
                        yu.notify("Skipped fingerprint hack (or?)", "Cayo Perico Heist")
                    end
                end)
            end

            if ImGui.Button("Skip plasmacutter cut") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller_2020") then
                        locals.set_float("fm_mission_controller_2020", 30357 + 3, 100)
                        yu.notify("Skipped plasmacutter cut (or?)", "Cayo Perico Heist")
                    end
                end)
            end

            if ImGui.Button("Obtain the primary target") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller_2020") then
                        locals.set_int("fm_mission_controller_2020", 29684, 5)
                        locals.set_int("fm_mission_controller_2020", 29685, 3)
                    end
                end)
            end

            if ImGui.Button("Remove the drainage pipe") then
                tasks.addTask(function()
                    local hash = joaat("prop_chem_grill_bit")
                    for k, v in pairs(entities.get_all_objects_as_handles()) do
                        if ENTITY.GET_ENTITY_MODEL(v) == hash then
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(v, false, false)
                            ENTITY.DELETE_ENTITY(v)
                        end
                    end
                end)
            end

            if ImGui.Button("Instant finish") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller_2020") then
                        locals.set_int("fm_mission_controller_2020", 45450, 9)
                        locals.set_int("fm_mission_controller_2020", 46829, 50)
                    end
                end)
            end

            ImGui.TreePop()
        end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.registerMissiles(parentTab)
    local tab = SussySpt.rendering.newTab("Missiles")

    function tab.render()
        ImGui.Text("Currently not working")

        yu.rendering.renderCheckbox("No cooldown", "kosatka_nomisslecd", function(state)
            tasks.addTask(function()
                -- globals.set_int(292539, yu.shc(state, 0, 60000))
            end)
        end)

        yu.rendering.renderCheckbox("Higher range", "kosatka_longermisslerange", function(state)
            tasks.addTask(function()
                -- globals.set_int(292540, yu.shc(state, 4000, 99999))
            end)
        end)
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.registerManage(parentTab)
    local tab = SussySpt.rendering.newTab("Manage")

    function tab.render()
        if ImGui.Button("Request Kosatka") then
            tasks.addTask(function()
                globals.set_int(values.g.request_service + values.g.request_service_kosatka, 1)
            end)
        end

        -- if ImGui.Button("Request Sparrow") then
        --     tasks.addTask(function()
        --         -- globals.set_int(values.g.request_service + values.g.request_service_sparrow, 1)
        --     end)
        -- end

        -- ImGui.SameLine()

        -- if ImGui.Button("Request Avisa") then
        --     tasks.addTask(function()
        --         -- globals.set_int(values.g.request_service + values.g.request_service_avisa, 1)
        --     end)
        -- end

        if ImGui.Button("Request Dinghy") then
            tasks.addTask(function()
                globals.set_int(values.g.request_service + values.g.request_service_dingy, 1)
            end)
        end
    end

    parentTab.sub[#parentTab.sub + 1] = tab
end

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Kosatka")
    exports.registerHeist(tab)
    exports.registerMissiles(tab)
    exports.registerManage(tab)
    parentTab.sub[4] = tab
end

return exports
