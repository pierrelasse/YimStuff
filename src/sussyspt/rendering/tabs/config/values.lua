local cfg = require("sussyspt/config")

local tableFlags =
    ImGuiTableFlags.Borders
    | ImGuiTableFlags.RowBg
    | ImGuiTableFlags.NoClip

local function renderValues()
    -- local allowEdit = yu.rendering.renderCheckbox("Allow edit", "config/values/allowEdit")
    -- if ImGui.IsItemHovered() then
    --     ImGui.BeginTooltip()
    --     yu.rendering.coloredtext("Editing values can break things", 255, 101, 101)
    --     ImGui.EndTooltip()
    -- end

    if not ImGui.BeginTable("##storage_table", 3, tableFlags) then
        ImGui.EndTable()
        return
    end

    ImGui.TableSetupColumn("Key")
    ImGui.TableSetupColumn("Value")
    ImGui.TableSetupColumn("Actions")
    ImGui.TableHeadersRow()

    local row = 0
    for key, value in pairs(cfg.data) do
        ImGui.TableNextRow()
        ImGui.PushID(row)

        do
            ImGui.TableSetColumnIndex(0)
            ImGui.TextWrapped(key)
        end

        do
            ImGui.TableSetColumnIndex(1)
            local valueText
            local valueType = type(value)
            if valueType == "nil" then
                valueText = "null"
            elseif valueType == "string" then
                valueText = "\""..value.."\""
            elseif valueType == "number" then
                valueText = tostring(valueType)
            elseif valueType == "boolean" then
                valueText = value and "true" or "false"
            else
                valueText = "???"
            end

            -- if allowEdit then
            --     ImGui.InputText("", valueText, inputValueFlagsBase)
            -- else
            ImGui.Text(valueText)
            -- end
        end

        do
            ImGui.TableSetColumnIndex(2)
            ImGui.Button("Delete")
        end

        ImGui.PopID()
        row = row + 1
    end

    ImGui.EndTable()
end

local function render()
    if type(cfg.data) == "table" then
        renderValues()
    else
        ImGui.Text("No values found")
    end
end

local exports = {}

function exports.register(parentTab)
    local tab = SussySpt.rendering.newTab("Values")
    tab.should_display = SussySpt.getDev
    tab.render = render
    parentTab.sub[#parentTab.sub + 1] = tab
end

return exports
