local exports = {}

local global_computerType = 1962105

local function startScript(rs, script, stackSize, customComputerType)
    if yu.is_script_running(script) then return end
    if customComputerType ~= nil then
        globals.set_int(global_computerType, customComputerType)
    end
    SCRIPT.REQUEST_SCRIPT(script)
    repeat rs:yield() until SCRIPT.HAS_SCRIPT_LOADED(script)
    SYSTEM.START_NEW_SCRIPT(script, stackSize)
    SCRIPT.SET_SCRIPT_AS_NO_LONGER_NEEDED(script)
end

function exports.master(rs) startScript(rs, "apparcadebusinesshub", 1424) end

function exports.bunker(rs) startScript(rs, "appBunkerBusiness", 1424) end

function exports.biker(rs) startScript(rs, "appBikerBusiness", 4592) end

function exports.biker_cocaine(rs) startScript(rs, "appBikerBusiness", 4592, 8) end

function exports.biker_meth(rs) startScript(rs, "appBikerBusiness", 4592, 6) end

function exports.biker_weed(rs) startScript(rs, "appBikerBusiness", 4592, 7) end

function exports.biker_cash(rs) startScript(rs, "appBikerBusiness", 4592, 9) end

function exports.biker_documents(rs) startScript(rs, "appBikerBusiness", 4592, 10) end

-- function exports.nighclub(rs)
--     startScript(rs, "appBusinessHub", 1424)
-- end

-- function exports.terrorbyte(rs)
--     startScript(rs, "appHackerTruck", 4592)
-- end

-- function exports.hangar(rs)
--     startScript(rs, "appSmuggler", 4592)
-- end

-- function exports.arcade(rs)
--     startScript(rs, "appArcadeBusiness", 4592)
-- end

-- function exports.avenger(rs)
--     startScript(rs, "appAvengerOperations", 4592)
-- end

-- function exports.agency(rs)
--     startScript(rs, "appFixerSecurity", 4592)
-- end

return exports
