local exports = {}

-- local global_computerType = 1962105

local function startScript(rs, scriptHash, stackSize, customComputerType)
    -- if yu.is_script_running_hash(scriptHash) then return end
    -- if customComputerType ~= nil then
    --     globals.set_int(global_computerType, customComputerType)
    -- end
    log.info("uhh"..scriptHash)
    SCRIPT.REQUEST_SCRIPT(scriptHash)
    repeat rs:yield() until SCRIPT.HAS_SCRIPT_LOADED(scriptHash)
    SYSTEM.START_NEW_SCRIPT(scriptHash, 5000)
    SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(scriptHash)
    log.info("wtf")
end

-- function exports.bunker(rs)
--     startScript(rs, joaat("appBunkerBusiness"), 1424)
-- end

-- function exports.nighclub(rs)
--     startScript(rs, joaat("appBusinessHub"), 1424)
-- end

-- function exports.terrorbyte(rs)
--     startScript(rs, joaat("appHackerTruck"), 4592)
-- end

-- function exports.hangar(rs)
--     startScript(rs, joaat("appSmuggler"), 4592)
-- end

-- function exports.arcade(rs)
--     startScript(rs, joaat("appArcadeBusiness"), 4592)
-- end

-- function exports.biker_cocaine(rs)
--     startScript(rs, joaat("appBikerBusiness"), 4592, 8)
-- end

-- function exports.biker_meth(rs)
--     startScript(rs, joaat("appBikerBusiness"), 4592, 6)
-- end

-- function exports.biker_weed(rs)
--     startScript(rs, joaat("appBikerBusiness"), 4592, 7)
-- end

-- function exports.biker_cash(rs)
--     startScript(rs, joaat("appBikerBusiness"), 4592, 9)
-- end

-- function exports.biker_documents(rs)
--     startScript(rs, joaat("appBikerBusiness"), 4592, 10)
-- end

-- function exports.avenger(rs)
--     startScript(rs, joaat("appAvengerOperations"), 4592)
-- end

-- function exports.biker(rs)
--     startScript(rs, joaat("appBikerBusiness"), 4592)
-- end

-- function exports.agency(rs)
--     startScript(rs, joaat("appFixerSecurity"), 4592)
-- end

function exports.master(rs)
    startScript(rs, joaat("apparcadebusinesshub"), 1424)
end

return exports
