local tasks = require("../tasks")

local tab = SussySpt.rendering.newTab("World")

do -- ANCHOR Object Spawner
    local tab2 = SussySpt.rendering.newTab("Object Spawner")

    local a = {
        model = "",
        awidth = 195
    }

    yu.rendering.setCheckboxChecked("world_objspawner_deleteprev")
    yu.rendering.setCheckboxChecked("world_objspawner_missionent")
    yu.rendering.setCheckboxChecked("world_objspawner_hashmodel")

    local function temp_text(infotext, duration)
        yu.rif(function(runscript)
            a.infotext = infotext
            local id = yu.gun()
            a.infotextid = id
            runscript:sleep(duration)
            if a.infotextid == id then
                a.infotext = nil
            end
        end)
    end

    tab2.render = function()
        ImGui.BeginGroup()

        ImGui.Text("Spawner")

        ImGui.PushItemWidth(a.awidth)

        local model_text, _ = ImGui.InputTextWithHint("Model", "ex. stt_prop_stunt_bowling_pin", a.model, 32)
        SussySpt.pushDisableControls(ImGui.IsItemActive())
        if a.model ~= model_text then
            a.model = model_text
            a.invalidmodel = nil
        end

        if a.invalidmodel then
            yu.rendering.coloredtext("Invalid model!", 255, 25, 25)
        elseif a.blocked then
            yu.rendering.coloredtext("Spawning...", 108, 149, 218)
        end

        if a.infotext ~= nil then
            yu.rendering.coloredtext(a.infotext[1], a.infotext[2], a.infotext[3], a.infotext[4])
        end

        ImGui.PopItemWidth()

        if not a.blocked and ImGui.Button("Spawn") then
            yu.rif(function(runscript)
                a.blocked = true

                local hash = yu.rendering.isCheckboxChecked("world_objspawner_hashmodel") and joaat(a.model) or tonumber(a.model)

                if hash == nil or not STREAMING.IS_MODEL_VALID(hash) or not STREAMING.IS_MODEL_A_VEHICLE(hash) then
                    a.invalidmodel = true
                else
                    STREAMING.REQUEST_MODEL(hash)
                    repeat runscript:yield() until STREAMING.HAS_MODEL_LOADED(hash)

                    if yu.rendering.isCheckboxChecked("world_objspawner_deleteprev") and yu.does_entity_exist(a.entity) then
                        ENTITY.DELETE_ENTITY(a.entity)
                    end

                    local c = yu.coords(yu.ppid())
                    a.entity = OBJECT.CREATE_OBJECT_NO_OFFSET(
                        hash,
                        c.x,
                        c.y,
                        c.z,
                        true,
                        yu.rendering.isCheckboxChecked("world_objspawner_missionent") ~= false,
                        true
                    )

                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

                    if a.entity then
                        ENTITY.SET_ENTITY_LOD_DIST(a.entity, 0xFFFF)
                        ENTITY.FREEZE_ENTITY_POSITION(a.entity, yu.rendering.isCheckboxChecked("world_objspawner_freeze"))
                        if yu.rendering.isCheckboxChecked("world_objspawner_groundplace") then
                            OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(a.entity)
                        end
                    else
                        temp_text({"Error while spawning entity", 255, 0, 0}, 2500)
                    end
                end

                a.blocked = nil
            end)
        end

        if a.entity ~= nil then
            ImGui.SameLine()

            if ImGui.Button("Delete##last_spawned") then
                yu.rif(function(runscript)
                    if yu.does_entity_exist(a.entity) then
                        ENTITY.DELETE_ENTITY(a.entity)
                    end
                end)
            end
        end

        ImGui.EndGroup()
        ImGui.SameLine()
        ImGui.BeginGroup()

        ImGui.Text("Options")

        if ImGui.TreeNodeEx("Spawn options") then
            yu.rendering.renderCheckbox("Frozen", "world_objspawner_freeze", function(state)
                tasks.addTask(function()
                    if a.entity ~= nil and yu.does_entity_exist(a.entity) then
                        ENTITY.FREEZE_ENTITY_POSITION(a.entity, state)
                    end
                end)
            end)

            yu.rendering.renderCheckbox("Delete previous", "world_objspawner_deleteprev")
            yu.rendering.renderCheckbox("Place on ground correctly", "world_objspawner_groundplace")
            yu.rendering.renderCheckbox("Mission entity", "world_objspawner_missionent")
            yu.rendering.renderCheckbox("Hash model", "world_objspawner_hashmodel")

            ImGui.TreePop()
        end

        ImGui.EndGroup()
    end

    tab.sub[1] = tab2
end

do -- ANCHOR Entities
    local tab2 = SussySpt.rendering.newTab("Entities")

    tab2.should_display = SussySpt.getDev

    tab2.render = function()
        ImGui.Text("This is not finished!")

        ImGui.Spacing()

        if ImGui.TreeNodeEx("Door controller") then

            for i = 0, 10 do
                ImGui.Text(i..":")
                ImGui.SameLine()
                if ImGui.SmallButton("Open##"..i) then
                    tasks.addTask(function()
                        local veh = yu.veh(yu.ppid())
                        if veh ~= nil then
                            VEHICLE.SET_VEHICLE_DOOR_OPEN(veh, i, false, true)
                        end
                    end)
                end
                ImGui.SameLine()
                if ImGui.SmallButton("Closed##"..i) then
                    tasks.addTask(function()
                        local veh = yu.veh(yu.ppid())
                        if veh ~= nil then
                            VEHICLE.SET_VEHICLE_DOOR_SHUT(veh, i, true)
                        end
                    end)
                end
            end

            ImGui.TreePop()
        end
    end

    tab.sub[2] = tab2
end

do -- ANCHOR Particle Spawner
    local tab2 = SussySpt.rendering.newTab("Particle Spawner")

    local a = {
        awidth = 280,
        dict = "core",
        effect = "ent_sht_petrol_fire"
    }

    tab2.render = function()
        ImGui.PushItemWidth(a.awidth)

        local dict, _ = ImGui.InputTextWithHint("Dict", "ex. core", a.dict, 32)
        SussySpt.pushDisableControls(ImGui.IsItemActive())
        if a.dict ~= dict then
            a.dict = dict
        end

        local effect, _ = ImGui.InputTextWithHint("Effect", "ex. ent_sht_petrol_fire", a.effect, 32)
        SussySpt.pushDisableControls(ImGui.IsItemActive())
        if a.effect ~= effect then
            a.effect = effect
        end

        ImGui.PopItemWidth()

        if a.blocked ~= true and ImGui.Button("Spawn") then
            yu.rif(function(rs)
                a.blocked = true

                STREAMING.REQUEST_NAMED_PTFX_ASSET(a.dict)
                repeat rs:yield() until STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(a.dict)
                GRAPHICS.USE_PARTICLE_FX_ASSET(a.dict)

                local c = yu.coords(yu.ppid())
                local x, y, z = c.x, c.y, c.z
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(a.effect, x, y, z, 90, -100, 90, 1, true, true, true, false)

                STREAMING.REMOVE_PTFX_ASSET()

                a.blocked = nil
            end)
        end
    end

    tab.sub[3] = tab2
end

do -- ANCHOR Peds
    local tab2 = SussySpt.rendering.newTab("Peds")

    tab2.should_display = SussySpt.getDev

    yu.rif(function(rs)
        while true do
            if yu.rendering.isCheckboxChecked("world_peds_pedsblind") then
                for k, v in pairs(entities.get_all_peds_as_handles()) do
                    PED.SET_PED_SEEING_RANGE(v, 0)
                end
            end
            rs:yield()
        end
    end)

    tab2.render = function()
        yu.rendering.renderCheckbox("Make enemies blind", "world_peds_pedsblind")
    end

    tab.sub[4] = tab2
end

do -- ANCHOR Other
    local tab2 = SussySpt.rendering.newTab("Other")

    local a = {
        blockexplosionshake = {
            pattern = "4C 8B 0D ? ? ? ? 44 ? ? 05 ? ? ? ? 48 8D 15",
            m_name = 0x0,
            m_cam_shake_name = 0x7c,
            struct_size = 0x88,
            patch_registry = {}
        }
    }

    yu.rendering.setCheckboxChecked("world_other_blockexplosionshake", SussySpt.cfg.get("world_blockexplosionshake", false))

    yu.rif(function()
        CExplosionInfoManager = memory.scan_pattern(a.blockexplosionshake.pattern):add(3):rip()
        exp_list_base = CExplosionInfoManager:deref()
        exp_count = CExplosionInfoManager:add(0x8):get_word()

        local enabled = yu.rendering.isCheckboxChecked("world_other_blockexplosionshake")

        for i = 0, exp_count - 1 do
            local exp_base = exp_list_base:add(a.blockexplosionshake.struct_size * i)
            local p = exp_base:add(a.blockexplosionshake.m_cam_shake_name):patch_dword(0)
            if enabled then
                p:apply()
            end
            table.insert(a.blockexplosionshake.patch_registry, p)
        end
        SussySpt.debug((enabled and "Blocked " or "Found ")..tostring(exp_count).." explosion shakes")
    end)

    tab2.render = function()
        yu.rendering.renderCheckbox("Block explosion shake", "world_other_blockexplosionshake", function(state)
            enabled = SussySpt.cfg.set("world_blockexplosionshake", state)

            local i = 0
            for k, v in ipairs(a.blockexplosionshake.patch_registry) do
                if state then
                    v:apply()
                else
                    v:restore()
                end
                i = i + 1
            end
            SussySpt.debug((state and "Block" or "Restor").."ed "..i.." explosion shakes")
        end)
        yu.rendering.tooltip("This prevents the camera from shaking by explosions")
    end

    tab.sub[5] = tab2
end

SussySpt.rendering.tabs[2] = tab
