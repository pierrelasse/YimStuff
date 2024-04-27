local cfg = require("sussyspt/config")

local exports = {}

function exports.register(tab)
    local tab2 = SussySpt.rendering.newTab("Chatlog")

    yu.rendering.setCheckboxChecked("online_chatlog_enabled", cfg.get("chatlog_enabled", true))
    yu.rendering.setCheckboxChecked("online_chatlog_console", cfg.get("chatlog_console", true))
    yu.rendering.setCheckboxChecked("online_chatlog_log_timestamp", cfg.get("chatlog_timestamp", true))

    function tab2.render()
        if cfg.set("chatlog_enabled", yu.rendering.renderCheckbox("Enabled", "online_chatlog_enabled")) then
            ImGui.Spacing()
            cfg.set("chatlog_console", yu.rendering.renderCheckbox("Log to console", "online_chatlog_console"))
        end

        if SussySpt.chatlog.text ~= nil then
            if ImGui.TreeNodeEx("Logs") then
                cfg.set("chatlog_timestamp", yu.rendering.renderCheckbox("Timestamp", "online_chatlog_log_timestamp", SussySpt.chatlog.rebuildLog))

                do
                    local x, y = ImGui.GetContentRegionAvail()
                    ImGui.InputTextMultiline("##chat_log", SussySpt.chatlog.text, SussySpt.chatlog.text:length(), x, math.min(140, y), ImGuiInputTextFlags.ReadOnly)
                end
                SussySpt.pushDisableControls(ImGui.IsItemActive())

                ImGui.TreePop()
            end
        else
            ImGui.Spacing()
            ImGui.Text("Nothing to show yet")
        end
    end

    tab.sub[4] = tab2
end

return exports
