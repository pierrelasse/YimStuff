local cfg = require("sussyspt/config")

local tab = SussySpt.rendering.newTab("QOL")

local pattern = "4C 8B 0D ? ? ? ? 44 ? ? 05 ? ? ? ? 48 8D 15"
local m_cam_shake_name = 0x7c
local struct_size = 0x88
local patch_registry = {}

yu.rendering.setCheckboxChecked("world_other_blockexplosionshake", cfg.get("world_blockexplosionshake", false))

yu.rif(function()
    local CExplosionInfoManager = memory.scan_pattern(pattern):add(3):rip()
    local exp_list_base = CExplosionInfoManager:deref()
    local exp_count = CExplosionInfoManager:add(0x8):get_word()

    local enabled = yu.rendering.isCheckboxChecked("world_other_blockexplosionshake")

    for i = 0, exp_count - 1 do
        local exp_base = exp_list_base:add(struct_size * i)
        local p = exp_base:add(m_cam_shake_name):patch_dword(0)
        if enabled then p:apply() end
        table.insert(patch_registry, p)
    end
    SussySpt.debug((enabled and "Blocked " or "Found ")..tostring(exp_count).." explosion shakes")
end)

function tab.render()
    yu.rendering.renderCheckbox("Block explosion shake", "world_other_blockexplosionshake", function(state)
        cfg.set("world_blockexplosionshake", state)
        local i = 0
        for _, patch in ipairs(patch_registry) do
            if state then
                patch:apply()
            else
                patch:restore()
            end
            i = i + 1
        end
        SussySpt.debug((state and "Block" or "Restor").."ed "..i.." explosion shakes")
    end)
    yu.rendering.tooltip("Prevents camera shaking from explosions")
end

SussySpt.rendering.tabs[3] = tab
