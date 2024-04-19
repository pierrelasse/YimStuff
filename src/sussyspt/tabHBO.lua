local tasks = require("./tasks")
local values = require("./values")

SussySpt.debug("Initializing HBO tab")

local toRender = {}
local function addToRender(id, cb)
    toRender[id] = cb
end

local function addUnknownValue(tbl, v)
    if tbl[v] == nil then
        tbl[v] = "??? ["..(v or "<null>").."]"
    end
end

local function renderCutsSlider(tbl, index)
    local value = tbl[index] or 85
    local text = yu.shc(index == -2, "Non-host self cut", "Player "..index.."'s cut")
    local newValue, changed = ImGui.DragInt(text, value, .2, 0, 250, "%d%%", 5)
    if changed then
        tbl[index] = newValue
    end

    ImGui.SameLine()

    ImGui.PushButtonRepeat(true)

    if ImGui.Button(" - ##cuts_-"..index) then
        tbl[index] = value - 1
    end

    ImGui.SameLine()

    if ImGui.Button(" + ##cuts_+"..index) then
        tbl[index] = value + 1
    end

    ImGui.PopButtonRepeat()
end
SussySpt.renderCutsSlider = renderCutsSlider

local function initCasino()
    local rigSlotMachinesId = "hbo_casinoresort_rsm"

    local luckyWheelPrizes = {
        [0] = "CLOTHING (1)",
        [1] = "2,500 RP",
        [2] = "$20,000",
        [3] = "10,000 Chips",
        [4] = "DISCOUNT %",
        [5] = "5,000 RP",
        [6] = "$30,000",
        [7] = "15,000 Chips",
        [8] = "CLOTHING (2)",
        [9] = "7,500 RP",
        [10] = "20,000 Chips",
        [11] = "MYSTERY",
        [12] = "CLOTHING (3)",
        [13] = "10,000 RP",
        [14] = "$40,000",
        [15] = "25,000 Chips",
        [16] = "CLOTHING (4)",
        [17] = "15,000 RP",
        [18] = "VEHICLE"
    }

    local prize_wheel_win_state = 278
    local prize_wheel_prize = 14
    local prize_wheel_prize_state = 45

    local winPrize = 0
    local winPrizeChanged = false

    local function winLuckyWheel(prize)
        if SussySpt.requireScript("casino_lucky_wheel") and yu.is_num_between(prize, 0, 18) then
            yu.notify(1, "Winning "..luckyWheelPrizes[prize].." from the lucky wheel!", "Diamond Casino & Resort")
            locals.set_int("casino_lucky_wheel", (prize_wheel_win_state) + (prize_wheel_prize), prize)
            locals.set_int("casino_lucky_wheel", prize_wheel_win_state + prize_wheel_prize_state, 11)
        else
            yu.notify(2, "Try going near the lucky wheel", "Diamond Casino & Resort")
        end
    end

    local storyMissions = {
        [1048576] = "Loose Cheng",
        [1310785] = "House Keeping",
        [1310915] = "Strong Arm Tactics",
        [1311175] = "Play to Win",
        [1311695] = "Bad Beat",
        [1312735] = "Cashing Out"
    }
    local storyMissionIds = {
        [1048576] = 0,
        [1310785] = 1,
        [1310915] = 2,
        [1311175] = 3,
        [1311695] = 4,
        [1312735] = 5
    }
    local storyMission
    local function updateStoryMission()
        storyMission = stats.get_int(yu.mpx("VCM_FLOW_PROGRESS"))
        addUnknownValue(storyMissions, storyMission)
    end
    tasks.addTask(updateStoryMission)

    addToRender(3, function()
        if (ImGui.BeginTabItem("Diamond Casino & Resort")) then
            ImGui.BeginGroup()

            yu.rendering.bigText("Slots")

            ImGui.Text("Tip: Enable this, spin, disable, spin, enable, spin and so on to not get blocked.")
            yu.rendering.renderCheckbox("Rig slot machines", rigSlotMachinesId)

            yu.rendering.bigText("Lucky wheel")

            ImGui.PushItemWidth(165)

            local lwpr = yu.rendering.renderList(luckyWheelPrizes, winPrize, "hbo_casinoresort_luckywheel", "Prize")
            if lwpr.changed then
                winPrize = lwpr.key
                winPrizeChanged = true
            end

            ImGui.PopItemWidth()

            ImGui.SameLine()

            if ImGui.Button("Win") then
                if not winPrizeChanged then
                    yu.notify(3, "Please select a prize to win first", "Diamond Casino & Resort")
                else
                    winLuckyWheel(winPrize)
                end
            end

            yu.rendering.bigText("Story Missions")

            local smr = yu.rendering.renderList(storyMissions, storyMission, "hbo_casinoresort_sm", "Story mission")
            if smr.changed then
                storyMission = smr.key
            end

            ImGui.SameLine()

            if ImGui.Button("Apply##sm") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("VCM_STORY_PROGRESS"), storyMissionIds[storyMission])
                    stats.set_int(yu.mpx("VCM_FLOW_PROGRESS"), storyMission)
                end)
            end

            ImGui.EndTabItem()
        end
    end)

    local slots_random_results_table = 1344

    tasks.addTask(function()
        if yu.is_script_running("casino_slots") then
            local needsRun = false

            if yu.rendering.isCheckboxChecked(rigSlotMachinesId) then
                for slots_iter = 3, 195, 1 do
                    if slots_iter ~= 67 and slots_iter ~= 132 then
                        if locals.get_int("casino_slots", (slots_random_results_table) + (slots_iter)) ~= 6 then
                            needsRun = true
                        end
                    end
                end
            else
                local sum = 0
                for slots_iter = 3, 195, 1 do
                    if slots_iter ~= 67 and slots_iter ~= 132 then
                        sum = sum + locals.get_int("casino_slots", (slots_random_results_table) + (slots_iter))
                    end
                end
                needsRun = sum == 1146
            end

            if needsRun then
                for slots_iter = 3, 195, 1 do
                    if slots_iter ~= 67 and slots_iter ~= 132 then
                        local slot_result = 6
                        if yu.rendering.isCheckboxChecked(rigSlotMachinesId) == false then
                            math.randomseed(os.time() + slots_iter)
                            slot_result = math.random(0, 7)
                        end
                        locals.set_int("casino_slots", (slots_random_results_table) + (slots_iter), slot_result)
                    end
                end
            end
        end
    end)
end

local function initApartment()
    local a = {
        heistpointer = 1938365 + 3008 + 1,
        heists = {
            "Fleeca $5M",
            "Fleeca $10M",
            "Fleeca $15M",
            "Prison break $5M",
            "Prison break $10M",
            "Prison break $15M",
            "Humane labs raid $5M",
            "Humane labs raid $10M",
            "Humane labs raid $15M",
            "Series A funding $5M",
            "Series A funding $10M",
            "Series A funding $15M",
            "The pacific standard $5M",
            "The pacific standard $10M",
            "The pacific standard $15M"
        },
        heistsids = {
            [1] = 3500,
            [2] = 7000,
            [3] = 10434,
            [4] = 1000,
            [5] = 2000,
            [6] = 3000,
            [7] = 750,
            [8] = 1482,
            [9] = 2220,
            [10] = 991,
            [11] = 1981,
            [12] = 2970,
            [13] = 400,
            [14] = 800,
            [15] = 1200
        },
        cuts = {}
    }

    local function refresh()
        a.heist = yu.get_key_from_table(a.heistsids, globals.get_int(a.heistpointer), 1)
        a.heistchanged = false
    end
    tasks.addTask(refresh)

    addToRender(5, function()
        if (ImGui.BeginTabItem("Apartment Heists")) then
            ImGui.BeginGroup()

            if ImGui.Button("Refresh") then
                tasks.addTask(refresh)
            end

            yu.rendering.bigText("Preperations")

            local hr = yu.rendering.renderList(a.heists, a.heist, "hbo_apartment_heist", "Heist")
            if hr.changed then
                a.heist = hr.key
                a.heistchanged = true
            end

            if ImGui.Button("Apply") then
                tasks.addTask(function()
                    local changes = 0

                    -- Heist
                    if a.heistchanged then
                        changes = changes + 1
                        globals.set_int(a.heistpointer, a.heistsids[a.heist])
                    end

                    yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied.", "Apartment Heists")
                    for k, v in pairs(a) do
                        if tostring(k):endswith("changed") then
                            a[k] = nil
                        end
                    end
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Complete preps") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx().."HEIST_PLANNING_STAGE", -1)
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Reset preps") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx().."HEIST_PLANNING_STAGE", 0)
                end)
            end

            ImGui.EndGroup()
            ImGui.Separator()
            ImGui.BeginGroup()

            yu.rendering.bigText("Extra")

            ImGui.Text("Fleeca:")

            ImGui.SameLine()

            if ImGui.Button("Skip hack##fleeca") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller") then
                        locals.set_int("fm_mission_controller", 11760 + 24, 7)
                    end
                end)
            end
            yu.rendering.tooltip("When being passenger, you need to play snake.")

            ImGui.SameLine()

            if ImGui.Button("Skip drill##fleeca") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller") then
                        locals.set_float("fm_mission_controller", 10061 + 11, 100)
                    end
                end)
            end
            yu.rendering.tooltip("Skip drilling")

            ImGui.SameLine()

            if ImGui.Button("Instant finish (solo only)##fleeca") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller") then
                        locals.set_int("fm_mission_controller", 19710, 12)
                        locals.set_int("fm_mission_controller", 28331 + 1, 99999)
                        locals.set_int("fm_mission_controller", 31587 + 69, 99999)
                    end
                end)
            end
            yu.rendering.tooltip("Never tested this before")

            ImGui.EndGroup()
            ImGui.Separator()
            ImGui.BeginGroup()

            yu.rendering.bigText("Cuts")

            renderCutsSlider(a.cuts, 1)
            renderCutsSlider(a.cuts, 2)
            renderCutsSlider(a.cuts, 3)
            renderCutsSlider(a.cuts, 4)

            if ImGui.Button("Apply cuts") then
                for k, v in pairs(a.cuts) do
                    if yu.is_num_between(v, 0, 250) then
                        globals.set_int(1937644 + k, v)
                    end
                end
            end

            ImGui.EndGroup()
            ImGui.EndTabItem()
        end
    end)
end

local function initAutoShop()
    local a = {
        heists = {
            [0] = "Union Depository",
            [1] = "The Superdollar Deal",
            [2] = "The Bank Contract",
            [3] = "The ECU Job",
            [4] = "The Prison Contract",
            [5] = "The Agency Deal",
            [6] = "The Lost Contract",
            [7] = "The Data Contract",
        }
    }

    local function refresh()
        a.heist = stats.get_int(yu.mpx("TUNER_CURRENT"))
        addUnknownValue(a.heists, a.heist)
    end
    tasks.addTask(refresh)

    local function getBS()
        return yu.shc(a.heist == 1, 4351, 12543)
    end

    local cooldowns = {}
    local function refreshCooldowns()
        for i = 0, 7 do
            cooldowns[i] = "  - "..a.heists[i]..": "..yu.format_seconds(stats.get_int(yu.mpx("TUNER_CONTRACT"..i.."_POSIX")) - os.time())
        end
    end
    tasks.addTask(refreshCooldowns)

    addToRender(6, function()
        if (ImGui.BeginTabItem("AutoShop Heists")) then
            ImGui.BeginGroup()

            if ImGui.Button("Refresh") then
                tasks.addTask(refresh)
            end

            yu.rendering.bigText("Preperations")

            ImGui.PushItemWidth(360)

            local hr = yu.rendering.renderList(a.heists, a.heist, "hbo_as_heist", "Heist")
            if hr.changed then
                yu.notify(1, "Set Heist to "..a.heists[hr.key].." ["..hr.key.."]", "AutoShop Heists")
                a.heist = hr.key
                a.heistchanged = true
            end

            ImGui.PopItemWidth()

            ImGui.Spacing()

            if ImGui.Button("Apply##stats") then
                tasks.addTask(function()
                    local changes = 0

                    -- Heist
                    if a.heistchanged then
                        changes = changes + 1
                        stats.set_int(yu.mpx("TUNER_GEN_BS"), getBS())
                        stats.set_int(yu.mpx("TUNER_CURRENT"), a.heist)
                    end

                    yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied", "AutoShop Heists")
                    for k, v in pairs(a) do
                        if tostring(k):endswith("changed") then
                            a[k] = nil
                        end
                    end
                end)
            end

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

            ImGui.SameLine()

            if ImGui.Button("Reset contract") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("TUNER_GEN_BS"), 8371)
                    stats.set_int(yu.mpx("TUNER_CURRENT"), -1)
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

            if ImGui.Button("Instant finish") then
                tasks.addTask(function()
                    if SussySpt.requireScript("fm_mission_controller_2020") then
                        locals.set_int("fm_mission_controller_2020", 45451, 51338977)
                        locals.set_int("fm_mission_controller_2020", 46829, 101)
                    end
                end)
            end
            yu.rendering.tooltip("Idk")

            ImGui.Spacing()

            ImGui.Text("Cooldowns:")

            ImGui.SameLine()

            if ImGui.Button("Refresh##cooldowns") then
                tasks.addTask(refreshCooldowns)
            end

            for k, v in pairs(cooldowns) do
                ImGui.Text(v)
            end

            ImGui.EndGroup()
            ImGui.EndTabItem()
        end
    end)
end

local function initDrugWars()
    local a = {
        productiondelayp = 279721
    }

    local function refresh()
        a.daxcooldown = stats.get_int(yu.mpx("XM22JUGGALOWORKCDTIMER"))
        a.productiondelay = globals.get_int(a.productiondelayp)
    end
    tasks.addTask(refresh)

    addToRender(7, function()
        if (ImGui.BeginTabItem("DrugWars")) then
            ImGui.BeginGroup()

            if ImGui.Button("Refresh") then
                tasks.addTask(refresh)
            end

            ImGui.Spacing()

            ImGui.Text("Cooldown: "..yu.format_seconds(a.daxcooldown))
            if ImGui.Button("Remove Dax cooldown") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("XM22JUGGALOWORKCDTIMER"), os.time() - 17)
                end)
            end

            ImGui.Spacing()

            ImGui.Text("Production delay ["..a.productiondelay.."]:")

            ImGui.SameLine()

            if ImGui.Button("Reset") then
                tasks.addTask(function()
                    globals.set_int(a.productiondelayp, 135000)
                    refresh()
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Set to 1") then
                tasks.addTask(function()
                    globals.set_int(a.productiondelayp, 1)
                    refresh()
                end)
            end

            ImGui.EndGroup()
            ImGui.EndTabItem()
        end
    end)
end

local function initAgency()
    local a = {
        vipcontracts = {
            [3] = "Nightlife Leak -> Investigation: The Nightclub",
            [4] = "Nightlife Leak -> Investigation: The Marina",
            [12] = "Nightlife Leak -> Nightlife Leak/Finale",
            [28] = "High Society Leak -> Investigation: The Country Club",
            [60] = "High Society Leak -> Investigation: Guest List",
            [124] = "High Society Leak -> High Society Leak/Finale",
            [252] = "South Central Leak -> Investigation: Davis",
            [508] = "South Central Leak -> Investigation: The Ballas",
            [2044] = "South Central Leak -> South Central Leak/Finale",
            [-1] = "Studio Time",
            [4092] = "Don't Fuck With Dre"
        },
        vipcontractssort = {
            [1] = 3,
            [2] = 4,
            [3] = 12,
            [4] = 28,
            [5] = 60,
            [6] = 124,
            [7] = 252,
            [8] = 508,
            [9] = 2044,
            [10] = -1,
            [11] = 4092
        }
    }

    local function refreshStats()
        a.vipcontract = stats.get_int(yu.mpx("FIXER_STORY_BS"))
        addUnknownValue(a.vipcontracts, a.vipcontract)
    end
    tasks.addTask(refreshStats)

    tasks.addTask(function()
        if yu.rendering.isCheckboxChecked("hbo_agency_smthmfinale") then
            globals.set_int(values.g.agency_maxpayout, 2000000)
        end
    end)

    addToRender(8, function()
        if (ImGui.BeginTabItem("Agency")) then
            ImGui.BeginGroup()
            yu.rendering.bigText("Preperations")

            local dlr = yu.rendering.renderList(a.vipcontracts, a.vipcontract, "hbo_agency_dl", "The Dr. Dre VIP Contract", a.vipcontractssort)
            if dlr.changed then
                yu.notify(1, "Set The Dr. Dre VIP Contract to "..a.vipcontracts[dlr.key].." ["..dlr.key.."]", "Agency")
                a.vipcontract = dlr.key
                a.vipcontractchanged = true
            end

            ImGui.Spacing()

            if ImGui.Button("Apply##stats") then
                tasks.addTask(function()
                    local changes = 0

                    -- The Dr. Dre VIP Contract
                    if a.vipcontractchanged then
                        changes = changes + 1

                        stats.set_int(yu.mpx("FIXER_STORY_BS"), a.vipcontract)

                        for k, v in pairs({"FIXER_GENERAL_BS","FIXER_COMPLETED_BS","FIXER_STORY_STRAND","FIXER_STORY_COOLDOWN"}) do
                            stats.set_int(yu.mpx(v), -1)
                        end

                        if a.vipcontract == -1 then
                            stats.set_int(yu.mpx("FIXER_STORY_STRAND"), -1)
                        end
                    end

                    yu.notify(1, changes.." change"..yu.shc(changes == 1, "", "s").." applied.", "Agency")
                    for k, v in pairs(a) do
                        if tostring(k):endswith("changed") then
                            a[k] = nil
                        end
                    end
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Refresh##stats") then
                tasks.addTask(refreshStats)
            end

            ImGui.SameLine()

            if ImGui.Button("Complete all missions") then
                tasks.addTask(function()
                    for k, v in pairs({"FIXER_GENERAL_BS","FIXER_COMPLETED_BS","FIXER_STORY_BS","FIXER_STORY_COOLDOWN"}) do
                        stats.set_int(yu.mpx(v), -1)
                    end
                end)
            end

            ImGui.EndGroup()
            ImGui.Separator()
            ImGui.BeginGroup()

            yu.rendering.bigText("Extra")

            yu.rendering.renderCheckbox("$2M finale", "hbo_agency_smthmfinale", function(state)
                if not state then
                    globals.set_int(values.g.agency_maxpayout, 1000000)
                end
            end)
            yu.rendering.tooltip("This is for the 'Don't Fuck With Dre' VIP Contract")

            ImGui.EndGroup()
            ImGui.EndTabItem()
        end
    end)
end

local function initOffice()
    local function getCrates(amount)
        tasks.addTask(function()
            if SussySpt.requireScript("gb_contraband_buy") then
                locals.set_int("gb_contraband_buy", 604, 1)
                locals.set_int("gb_contraband_buy", 600, amount)
                locals.set_int("gb_contraband_buy", 790, 6)
                locals.set_int("gb_contraband_buy", 791, 4)
            end
        end)
    end

    addToRender(9, function()
        if (ImGui.BeginTabItem("Office")) then
            yu.rendering.bigText("Warehouse")

            ImGui.Text("Get warehouse crate instantly:")
            for _, i in ipairs({1, 2, 3, 5, 10, 15, 20, 25, 30, 35}) do
                ImGui.SameLine()
                if ImGui.Button(tostring(i)) then
                    getCrates(i)
                end
            end

            ImGui.EndTabItem()
        end
    end)
end

initCasino()
initApartment()
initAutoShop()
initDrugWars()
initAgency()
initOffice()

local tabBarId = "##cat_hbo"
SussySpt.add_render(function()
    if SussySpt.in_online and yu.rendering.isCheckboxChecked("cat_hbo") then
        if ImGui.Begin("HBO (Heists, Businesses & Other)") then
            ImGui.BeginTabBar(tabBarId)

            for k, v in pairs(toRender) do
                v()
            end

            ImGui.EndTabBar()
        end
        ImGui.End()
    end
end)
