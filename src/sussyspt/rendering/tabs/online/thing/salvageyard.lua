local tasks = require("../../../../tasks")
local values = require("../../../../values")

local exports = {}

function exports.register(tab2)
    local tab3 = SussySpt.rendering.newTab("Salvage Yard")

    local a = {
        loaded = false,

        cooldown = {
            value = 0,

            getStatHashForCharStat = function()--Position - 0xD247
                return STATS.GET_STAT_HASH_FOR_CHARACTER_STAT_(0, 12230, yu.playerindex(2))
            end,
            get = function(self)
                local success, result = STATS.STAT_GET_INT(self.getStatHashForCharStat(), 0, -1)
                if not success then
                    return nil
                end
                return result - NETWORK.GET_CLOUD_TIME_AS_INT()
            end,
            set = function(self, secs)
                STATS.STAT_SET_INT(self.getStatHashForCharStat(), NETWORK.GET_CLOUD_TIME_AS_INT() + secs, false)
            end
        },

        vehicleSearch = "",
        vehicles = {"lm87","cinquemila","autarch","tigon","champion","tenf","sm722","omnisegt","growler","deity","italirsx","coquette4",
            "jubilee","astron","comet7","torero","cheetah2","turismo2","infernus2","stafford","gt500","viseris","mamba","coquette3",
            "stingergt","ztype","broadway","vigero2","buffalo4","ruston","gauntlet4","dominator8","btype3","swinger","feltzer3","omnis",
            "tropos","jugular","patriot3","toros","caracara2","sentinel3","weevil","kanjo","eudora","kamacho","hellion","ellie","hermes",
            "hustler","turismo3","buffalo5","stingertt","virtue","ignus","zentorno","neon","furia","zorrusso","thrax","vagner","panthere",
            "italigto","s80","tyrant","entity3","torero2","neo","corsita","paragon","btype2","comet4","fr36","everon2","komoda","tailgater2",
            "jester3","jester4","euros","zr350","cypher","dominator7","baller8","casco","yosemite2","everon","penumbra2","vstr","dominator9",
            "schlagen","cavalcade3","clique","boor","sugoi","greenwood","brigham","issi8","seminole2","kanjosj","previon"},
        translatedVehicles = {},

        slot = 1,
        robberies = {
            "The Cargo Ship",
            "The Gangbanger",
            "The Duggan",
            "The Podium",
            "The McTony"
        }
    }

    for k, v in pairs(a.vehicles) do
        a.translatedVehicles[k] = vehicles.get_vehicle_display_name(joaat(v))
    end

    do -- SECTION Robbery
        local tab4 = SussySpt.rendering.newTab("Robbery")

        local function tick() -- ANCHOR tick
            local mpx = yu.mpx()

            a.savlv23 = stats.get_int(mpx.."SALV23_GEN_BS")
            a.canSkipPreps = (a.savlv23 & (1 << 0)) ~= 0
            a.robbery = tunables.get_int("SALV23_VEHICLE_ROBBERY_"..a.slot)
            a.vehicle = tunables.get_int("SALV23_VEHICLE_ROBBERY_ID_"..a.slot) - 1
            a.canKeep = tunables.get_bool("SALV23_VEHICLE_ROBBERY_CAN_KEEP_"..a.slot)

            a.loaded = nil
        end

        function tab4.render() -- ANCHOR render
            tasks.tasks.thing_salvageyard_robbery_tick = tick

            if a.loaded == false then
                return
            end

            do
                ImGui.PushItemWidth(342)
                local value, changed = ImGui.SliderInt("Slot", a.slot, 1, 3)
                if changed then
                    a.slot = value
                end
                ImGui.PopItemWidth()
            end

            ImGui.BeginGroup()
            ImGui.Text("Robbery ["..tostring(a.robbery).."]")
            if ImGui.BeginListBox("##robbery_list", 150, 262) then
                for k, v in pairs(a.robberies) do
                    local selected = a.robbery == k
                    if ImGui.Selectable(v, selected) and not selected then
                        tasks.addTask(function()
                            tunables.set_int("SALV23_VEHICLE_ROBBERY_"..a.slot, k)
                        end)
                    end
                    yu.rendering.tooltip(k)
                end

                ImGui.EndListBox()
            end
            ImGui.EndGroup()

            ImGui.SameLine()

            ImGui.BeginGroup()
            ImGui.Text("Vehicle ["..tostring(a.vehicle).."]")

            ImGui.PushItemWidth(180)
            do
                local resp = yu.rendering.input("text", {
                    label = "##vehicle_search",
                    hint = "Search...",
                    text = a.vehicleSearch
                })
                SussySpt.pushDisableControls(ImGui.IsItemActive())
                if resp ~= nil and resp.changed then
                    a.vehicleSearch = resp.text:lowercase()
                end
            end
            ImGui.PopItemWidth()

            if ImGui.BeginListBox("##vehicle_list", 180, 224) then
                for k, v in pairs(a.translatedVehicles) do
                    if a.vehicles[k]:contains(a.vehicleSearch) or v:lowercase():contains(a.vehicleSearch) then
                        local selected = a.vehicle == k
                        if ImGui.Selectable(v, selected) and not selected then
                            tasks.addTask(function()
                                tunables.set_int("SALV23_VEHICLE_ROBBERY_ID_"..a.slot, k + 1)
                            end)
                        end
                        if ImGui.IsItemHovered() then
                            ImGui.SetTooltip(a.vehicles[k])
                        end
                    end
                end

                ImGui.EndListBox()
            end
            ImGui.EndGroup()

            ImGui.SameLine()

            ImGui.BeginGroup()

            ImGui.Text("Options")

            do
                local state, toggled = ImGui.Checkbox("Can keep", a.canKeep)
                yu.rendering.tooltip("Allows you to buy the vehicle")
                if toggled then
                    tunables.set_bool("SALV23_VEHICLE_ROBBERY_CAN_KEEP_"..a.slot, state)
                end
            end

            ImGui.EndGroup()

            ImGui.Spacing()

            ImGui.BeginDisabled(not a.canSkipPreps)
            if ImGui.Button("Skip preps") then
                tasks.addTask(function()
                    stats.set_int(yu.mpx("SALV23_FM_PROG"), -1)
                end)
            end
            ImGui.EndDisabled()

            ImGui.Separator()

            ImGui.Text("Weekly cooldown")

            ImGui.SameLine()

            if ImGui.Button("Remove") then
                tasks.addTask(function()
                    tunables.set_int(values.t.salvageyard_week, stats.get_int("MPX_SALV23_WEEK_SYNC") + 1)
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Restore") then
                tasks.addTask(function()
                    tunables.set_int(values.t.salvageyard_week, stats.get_int("MPX_SALV23_WEEK_SYNC"))
                end)
            end

            ImGui.Spacing()

            ImGui.Text("Robbery delay")
            ImGui.SameLine()
            do
                ImGui.PushItemWidth(148)
                local resp = yu.rendering.input("int", {
                    label = "##cooldown_input",
                    value = a.cooldown.value
                })
                if resp ~= nil and resp.changed then
                    a.cooldown.value = resp.value
                end
                ImGui.PopItemWidth()
                yu.rendering.tooltip("Sets the cooldown below in seconds.\n'An error has occurred. There is a short delay before you can start another robbery.'")
            end

            ImGui.SameLine()

            if ImGui.Button("Set##cooldown") then
                tasks.addTask(function()
                    a.cooldown:set(a.cooldown.value)
                end)
            end

            ImGui.SameLine()

            if ImGui.Button("Get##cooldown") then
                tasks.addTask(function()
                    a.cooldown.value = a.cooldown:get()
                end)
            end
        end

        tab3.sub[1] = tab4
    end -- !SECTION

    tab2.sub[5] = tab3
end

return exports
