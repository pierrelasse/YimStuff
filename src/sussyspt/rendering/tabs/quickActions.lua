local tab = SussySpt.rendering.newTab("Quick Actions")

function tab.render()
    if ImGui.Button("Save") then
        SussySpt.qa.config.save()
    end

    ImGui.SameLine()

    if ImGui.Button("Reset") then
        SussySpt.qa.config.sort = yu.copy_table(SussySpt.qa.config.default)
    end

    if ImGui.BeginTable("##actions", 2) then
        -- ImGui.TableSetupColumn("##1")
        -- ImGui.TableSetupColumn("##2")
        ImGui.TableHeadersRow()

        local row = 0
        for k, v in pairs(SussySpt.qa.config.sort) do
            ImGui.TableNextRow()
            ImGui.PushID(row)
            ImGui.TableSetColumnIndex(0)

            local ok = false
            if type(v) == "number" then
                if v == 0 then
                    yu.rendering.coloredtext("[Newline]", 106, 106, 106, 255)
                    ok = true
                end

            elseif type(v) == "string" then
                local b = SussySpt.qa.actions[v]
                if b ~= nil then
                    ImGui.Text(b[2])
                    ok = true
                end
            end

            if not ok then
                yu.rendering.coloredtext("[Invalid]", 255, 50, 50, 255)
            end

            ImGui.TableSetColumnIndex(1)

            if ImGui.Button("<##"..k) then
                local newIndex = k - 1
                if newIndex <= 0 then
                    newIndex = #SussySpt.qa.config.sort
                end
                table.swap(SussySpt.qa.config.sort, k, newIndex)
            end
            ImGui.SameLine()
            if ImGui.Button(">##"..k) then
                local newIndex = k + 1
                if newIndex > #SussySpt.qa.config.sort then
                    newIndex = 1
                end
                table.swap(SussySpt.qa.config.sort, k, newIndex)
            end
            ImGui.SameLine()
            if ImGui.Button("X##"..k) then
                local tbl = {}
                local i = 1
                for k2, v2 in pairs(SussySpt.qa.config.sort) do
                    if k2 ~= k then
                        tbl[i] = v2
                        i = i + 1
                    end
                end
                SussySpt.qa.config.sort = tbl
            end

            ImGui.PopID()
            row = row + 1
        end

        ImGui.EndTable()
    end
end

SussySpt.rendering.tabs[4] = tab
