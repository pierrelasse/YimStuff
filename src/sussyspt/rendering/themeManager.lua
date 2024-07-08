local themes = require("./defaultThemes")

local exports = {}

exports.themes = themes

local pops = {}

local function pushTheme(theme)
    if type(theme) ~= "table" then return end

    if theme.parent ~= nil then
        pushTheme(SussySpt.rendering.themes[theme.parent])
    end

    for k, v in pairs(theme) do
        if type(k) == "string" and type(v) == "table" then
            for k1, v1 in pairs(v) do
                if k == "ImGuiCol" then
                    if ImGuiCol[k1] ~= nil then
                        ImGui.PushStyleColor(ImGuiCol[k1], v1[1], v1[2], v1[3], v1[4])
                        pops.PopStyleColor = (pops.PopStyleColor or 0) + 1
                    end
                elseif k == "ImGuiStyleVar" then
                    if ImGuiStyleVar[k1] ~= nil then
                        if v1[2] == nil then
                            ImGui.PushStyleVar(ImGuiStyleVar[k1], v1[1])
                        else
                            ImGui.PushStyleVar(ImGuiStyleVar[k1], v1[1], v1[2])
                        end
                        pops.PopStyleVar = (pops.PopStyleVar or 0) + 1
                    end
                end
            end
        end
    end
end
exports.pushTheme = pushTheme

local function popTheme()
    for k, v in pairs(pops) do
        ImGui[k](v)
        pops[k] = nil
    end
end
exports.popTheme = popTheme

return exports
