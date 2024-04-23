local tasks = require("../../tasks")

local tab = SussySpt.rendering.newTab("Dev")
tab.should_display = SussySpt.getDev

-- ANCHOR Object Spawner

local objSpawner = { model = "", awidth = 195 }

local function temp_text(infotext, duration)
    yu.rif(function(runscript)
        objSpawner.infotext = infotext
        local id = yu.gun()
        objSpawner.infotextid = id
        runscript:sleep(duration)
        if objSpawner.infotextid == id then objSpawner.infotext = nil end
    end)
end

yu.rendering.setCheckboxChecked("world_objspawner_deleteprev")
yu.rendering.setCheckboxChecked("world_objspawner_missionent")
yu.rendering.setCheckboxChecked("world_objspawner_hashmodel")

local function renderObjectSpawner()
    ImGui.BeginGroup()

    ImGui.Text("Spawner")

    ImGui.PushItemWidth(objSpawner.awidth)

    local model_text = ImGui.InputTextWithHint("Model", "ex. stt_prop_stunt_bowling_pin", objSpawner.model, 32)
    SussySpt.pushDisableControls(ImGui.IsItemActive())
    if objSpawner.model ~= model_text then
        objSpawner.model = model_text
        objSpawner.invalidmodel = nil
    end

    if objSpawner.invalidmodel then
        yu.rendering.coloredtext("Invalid model!", 255, 25, 25)
    elseif objSpawner.blocked then
        yu.rendering.coloredtext("Spawning...", 108, 149, 218)
    end

    if objSpawner.infotext ~= nil then
        yu.rendering.coloredtext(
            objSpawner.infotext[1],
            objSpawner.infotext[2],
            objSpawner.infotext[3],
            objSpawner.infotext[4]
        )
    end

    ImGui.PopItemWidth()

    if not objSpawner.blocked and ImGui.Button("Spawn") then
        yu.rif(function(runscript)
            objSpawner.blocked = true

            local hash = yu.rendering.isCheckboxChecked("world_objspawner_hashmodel") and joaat(objSpawner.model)
                or tonumber(objSpawner.model)

            if hash == nil or not STREAMING.IS_MODEL_VALID(hash) or not STREAMING.IS_MODEL_A_VEHICLE(hash) then
                objSpawner.invalidmodel = true
            else
                STREAMING.REQUEST_MODEL(hash)
                repeat
                    runscript:yield()
                until STREAMING.HAS_MODEL_LOADED(hash)

                if
                    yu.rendering.isCheckboxChecked("world_objspawner_deleteprev")
                and yu.does_entity_exist(objSpawner.entity)
                then
                    ENTITY.DELETE_ENTITY(objSpawner.entity)
                end

                local c = yu.coords(yu.ppid())
                objSpawner.entity = OBJECT.CREATE_OBJECT_NO_OFFSET(
                    hash,
                    c.x,
                    c.y,
                    c.z,
                    true,
                    yu.rendering.isCheckboxChecked("world_objspawner_missionent") ~= false,
                    true
                )

                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

                if objSpawner.entity then
                    ENTITY.SET_ENTITY_LOD_DIST(objSpawner.entity, 0xFFFF)
                    ENTITY.FREEZE_ENTITY_POSITION(
                        objSpawner.entity,
                        yu.rendering.isCheckboxChecked("world_objspawner_freeze")
                    )
                    if yu.rendering.isCheckboxChecked("world_objspawner_groundplace") then
                        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(objSpawner.entity)
                    end
                else
                    temp_text({ "Error while spawning entity", 255, 0, 0 }, 2500)
                end
            end

            objSpawner.blocked = nil
        end)
    end

    if objSpawner.entity ~= nil then
        ImGui.SameLine()

        if ImGui.Button("Delete##last_spawned") then
            yu.rif(function()
                if yu.does_entity_exist(objSpawner.entity) then ENTITY.DELETE_ENTITY(objSpawner.entity) end
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
                if objSpawner.entity ~= nil and yu.does_entity_exist(objSpawner.entity) then
                    ENTITY.FREEZE_ENTITY_POSITION(objSpawner.entity, state)
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

-- ANCHOR Door Controller
function renderDoorController()
    for i = 0, 10 do
        ImGui.Text(i..":")
        ImGui.SameLine()
        if ImGui.SmallButton("Open##"..i) then
            tasks.addTask(function()
                local veh = yu.veh(yu.ppid())
                if veh ~= nil then VEHICLE.SET_VEHICLE_DOOR_OPEN(veh, i, false, true) end
            end)
        end
        ImGui.SameLine()
        if ImGui.SmallButton("Closed##"..i) then
            tasks.addTask(function()
                local veh = yu.veh(yu.ppid())
                if veh ~= nil then VEHICLE.SET_VEHICLE_DOOR_SHUT(veh, i, true) end
            end)
        end
    end
end

-- ANCHOR Particle Spawner
local parSpawner = {
    awidth = 280,
    dict = "core",
    effect = "ent_sht_petrol_fire",
}
local function renderParticleSpawner()
    ImGui.PushItemWidth(parSpawner.awidth)

    local dict, _ = ImGui.InputTextWithHint("Dict", "ex. core", parSpawner.dict, 32)
    SussySpt.pushDisableControls(ImGui.IsItemActive())
    if parSpawner.dict ~= dict then parSpawner.dict = dict end

    local effect, _ = ImGui.InputTextWithHint("Effect", "ex. ent_sht_petrol_fire", parSpawner.effect, 32)
    SussySpt.pushDisableControls(ImGui.IsItemActive())
    if parSpawner.effect ~= effect then parSpawner.effect = effect end

    ImGui.PopItemWidth()

    if parSpawner.blocked ~= true and ImGui.Button("Spawn") then
        yu.rif(function(rs)
            parSpawner.blocked = true

            STREAMING.REQUEST_NAMED_PTFX_ASSET(parSpawner.dict)
            repeat
                rs:yield()
            until STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(parSpawner.dict)
            GRAPHICS.USE_PARTICLE_FX_ASSET(parSpawner.dict)

            local c = yu.coords(yu.ppid())
            local x, y, z = c.x, c.y, c.z
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                parSpawner.effect,
                x,
                y,
                z,
                90,
                -100,
                90,
                1,
                true,
                true,
                true,
                false
            )

            STREAMING.REMOVE_PTFX_ASSET()

            parSpawner.blocked = nil
        end)
    end
end

function tab.render()
    yu.rendering.bigText("Object spawner")
    renderObjectSpawner()
    ImGui.Separator()
    yu.rendering.bigText("Particle spawner")
    renderParticleSpawner()
    ImGui.Separator()
    yu.rendering.bigText("Door controller")
    renderDoorController()
end

SussySpt.rendering.tabs[6] = tab
