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
            cooldowns[i] = "  - "..
            a.heists[i]..": "..yu.format_seconds(stats.get_int(yu.mpx("TUNER_CONTRACT"..i.."_POSIX")) - os.time())
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

initApartment()
initAutoShop()
initDrugWars()

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
