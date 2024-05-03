return function(tbl, index, callback)
    local value = tbl[index] or 85

    local text = index == 0 and "Non-host self cut" or "Player "..index.."'s cut"

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
