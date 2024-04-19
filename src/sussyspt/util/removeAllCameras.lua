local models = {
    joaat("prop_cctv_cam_01a"), joaat("prop_cctv_cam_01b"),
    joaat("prop_cctv_cam_02a"), joaat("prop_cctv_cam_03a"),
    joaat("prop_cctv_cam_04a"), joaat("prop_cctv_cam_04c"),
    joaat("prop_cctv_cam_05a"), joaat("prop_cctv_cam_06a"),
    joaat("prop_cctv_cam_07a"), joaat("prop_cs_cctv"), joaat("p_cctv_s"),
    joaat("hei_prop_bank_cctv_01"), joaat("hei_prop_bank_cctv_02"),
    joaat("ch_prop_ch_cctv_cam_02a"), joaat("xm_prop_x17_server_farm_cctv_01")
}

return function()
    for k, entity in pairs(entities.get_all_objects_as_handles()) do
        local entityModel = ENTITY.GET_ENTITY_MODEL(entity)
        for k1, hash in pairs(models) do
            if entityModel == hash then
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entity, false, false)
                ENTITY.DELETE_ENTITY(entity)
                goto NEXT
            end
        end
        ::NEXT::
    end
end
