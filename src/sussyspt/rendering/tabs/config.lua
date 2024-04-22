local tasks = require("../../tasks")
local version = require("../../version")
local cfg = require("../../config")

local tab = SussySpt.rendering.newTab("Config")

do -- ANCHOR Info
    local tab2 = SussySpt.rendering.newTab("Info")

    yu.rendering.setCheckboxChecked("dev", SussySpt.dev)

    function tab2.render()
        ImGui.Text("Made by pierrelasse.")
        ImGui.Text("SussySpt & yimutils download: https://github.com/pierrelasse/YimStuff")

        ImGui.Separator()

        ImGui.Text("Version: "..version.version)
        ImGui.Text("Version id: "..version.versionId)
        ImGui.Text("Version type: "..version.versionType)
        ImGui.Text("Build: "..version.build)

        ImGui.Separator()

        if SussySpt.debugtext ~= "" and ImGui.TreeNodeEx("Debug log") then
            yu.rendering.renderCheckbox("Log to console", "debug_console", function(state)
                cfg.set("debug_console", state)
            end)

            local x, y = ImGui.GetContentRegionAvail()
            ImGui.InputTextMultiline("##debug_log", SussySpt.debugtext, SussySpt.debugtext:length(), x, math.min(140, y), ImGuiInputTextFlags.ReadOnly)
            ImGui.TreePop()
        end

        ImGui.Separator()

        yu.rendering.renderCheckbox("Dev mode", "dev", function(state)
            SussySpt.dev = state
            SussySpt.debug(yu.shc(state, "En", "Dis").."abled dev mode")
        end)
        yu.rendering.tooltip("This just enables testing and not serious things")

        if SussySpt.dev then
            if cfg.data ~= nil then
                ImGui.Spacing()
                if ImGui.Button("Unload config") then
                    cfg.save()
                    cfg.data = nil
                end
            end

            ImGui.Spacing()

            if ImGui.Button("Go airplane mode :)") then
                tasks.addTask(function()
                    STREAMING.REQUEST_ANIM_DICT("missfbi1")
                    TASK.TASK_PLAY_ANIM(yu.ppid(), "missfbi1", "ledge_loop", 2.0, 2.0, -1, 51, 0, false, false, false)
                end)
            end
        end
    end

    tab.sub[1] = tab2
end

do -- ANCHOR Theme
    local tab2 = SussySpt.rendering.newTab("Theme")

    local a = {
        customthemetext = ""
    }

    function tab2.render()
        ImGui.Text("Theme: "..SussySpt.rendering.theme)
        ImGui.PushItemWidth(265)
        if ImGui.BeginCombo("Theme", SussySpt.rendering.theme) then
            for k, v in pairs(SussySpt.rendering.themes) do
                if ImGui.Selectable(k, false) then
                    SussySpt.rendering.theme = k
                    if k ~= "Custom" then
                        cfg.set("theme", k)
                    end
                    SussySpt.debug("Set theme to '"..k.."'")
                end
            end
            ImGui.EndCombo()
        end
        ImGui.PopItemWidth()

        ImGui.Separator()

        if ImGui.TreeNodeEx("Edit theme") then
            ImGui.Spacing()
            ImGui.Text("Reload the script to revert changes")

            ImGui.PushItemWidth(267)
            local sameLine = false
            for k, v in pairs(SussySpt.rendering.getTheme()) do
                if k == "ImGuiCol" and type(v) == "table" then
                    for k1, k2 in pairs(v) do
                        if sameLine then
                            ImGui.SameLine()
                        end
                        sameLine = not sameLine
                        local col, used = ImGui.ColorPicker4(k1, k2)
                        if used then
                            v[k1] = col
                        end
                    end
                end
            end
            ImGui.PopItemWidth()

            ImGui.TreePop()
        end

        ImGui.Separator()

        if ImGui.TreeNodeEx("Custom theme") then
            if ImGui.Button("Load") then
                local success, result = pcall(yu.json.decode, a.customthemetext)
                if not success then
                    a.message = {"Error: "..yu.removeErrorPath(result)[2], 255, 25, 25}

                elseif type(result) == "table" then
                    if result.parent == "Custom" then
                        result.parent = nil
                    end
                    if result.ImGuiCol then
                        for k, v2 in pairs(result.ImGuiCol) do
                            for k3, v3 in pairs(v2) do
                                v2[k3] = v3 / 255
                            end
                        end
                    end
                    SussySpt.rendering.themes["Custom"] = result
                    a.message = {"Success! You can now select the 'Custom' theme above", 60, 222, 22}
                end
            end

            ImGui.SameLine()

            if ImGui.Button("Get") then
                tasks.addTask(function()
                    local data = {
                        ImGuiCol = {}
                    }

                    for k, v in pairs(ImGuiCol) do
                        if k ~= "COUNT" then
                            local r, g, b, a = ImGui.GetStyleColorVec4(v)
                            data["ImGuiCol"][k] = {math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), a}
                        end
                    end

                    a.customthemetext = yu.json.encode(data)
                    a.message = {"Success! You can now put the text into a json formatter :D", 60, 222, 22}
                end)
            end

            if a.message ~= nil then
                yu.rendering.coloredtext(table.unpck(a.message, 4))
            end

            do
                local x, y = ImGui.GetContentRegionAvail()
                local text, _ = ImGui.InputTextMultiline("##input", a.customthemetext, 2500000, x, y)
                SussySpt.pushDisableControls(ImGui.IsItemActive())
                if text ~= a.customthemetext then
                    a.customthemetext = text
                    a.message = nil
                end
            end
            ImGui.TreePop()
        end
    end

    tab.sub[2] = tab2
end

do -- ANCHOR Invisible
    local tab2 = SussySpt.rendering.newTab("Invisible")

    local a = {
        key = cfg.get("invisible_key", "L")
    }

    local makingVehicleInivs = false
    function SussySpt.ensureVis(state, id, veh)
        if state ~= true and state ~= false then
            return nil
        end
        if id ~= nil and yu.rendering.isCheckboxChecked("invisible_self") then
            ENTITY.SET_ENTITY_VISIBLE(id, state, false)
        end
        if not makingVehicleInivs and yu.rendering.isCheckboxChecked("invisible_vehicle") then
            tasks.addTask(function()
                makingVehicleInivs = true
                if veh ~= nil and entities.take_control_of(veh) then
                    ENTITY.SET_ENTITY_VISIBLE(veh, state, false)
                end
                makingVehicleInivs = false
            end)
        end
    end

    function SussySpt.enableVis()
        SussySpt.invisible = nil
        SussySpt.ensureVis(true, yu.ppid(), yu.veh())
    end

    local function bindHotkey(key)
        if key == nil then
            return
        end
        yu.key_listener.remove_callback(a.callback)
        a.callback = yu.key_listener.add_callback(key, function()
            if yu.rendering.isCheckboxChecked("invisible_hotkey") and not HUD.IS_PAUSE_MENU_ACTIVE() then
                if SussySpt.invisible == true then
                    SussySpt.enableVis()
                else
                    SussySpt.invisible = true
                end
                if yu.rendering.isCheckboxChecked("invisible_log") then
                    log.info("You are now "..yu.shc(SussySpt.invisible, "invisible", "visible").."!")
                end
            end
        end)
    end
    bindHotkey(yu.keys[a.key])

    yu.rendering.setCheckboxChecked("invisible_hotkey", cfg.get("invisible_hotkey", false))
    yu.rendering.setCheckboxChecked("invisible_log", cfg.get("invisible_log", false))
    yu.rendering.setCheckboxChecked("invisible_self", cfg.get("invisible_self", true))
    yu.rendering.setCheckboxChecked("invisible_vehicle", cfg.get("invisible_vehicle", true))

    function tab2.render()
        yu.rendering.renderCheckbox("Enabled", "invisible", function(state)
            if state then
                SussySpt.invisible = true
            else
                yu.rif(SussySpt.enableVis)
            end
        end)

        ImGui.Spacing()

        cfg.set("invisible_hotkey", yu.rendering.renderCheckbox("Hotkey enabled", "invisible_hotkey"))
        cfg.set("invisible_log", yu.rendering.renderCheckbox("Log", "invisible_log"))

        ImGui.Spacing()

        cfg.set("invisible_self", yu.rendering.renderCheckbox("Self", "invisible_self"))
        cfg.set("invisible_vehicle", yu.rendering.renderCheckbox("Vehicle", "invisible_vehicle"))

        ImGui.Spacing()

        ImGui.PushItemWidth(140)
        if ImGui.BeginCombo("Key", a.key) then
            for k, v in pairs(yu.keys) do
                if ImGui.Selectable(k, false) then
                    a.key = k
                    bindHotkey(yu.keys[k])
                    cfg.set("invisible_key", k)
                end
            end
            ImGui.EndCombo()
        end
        ImGui.PopItemWidth()
    end

    tab.sub[3] = tab2
end

require("./config/values").register(tab)

SussySpt.rendering.tabs[1] = tab
