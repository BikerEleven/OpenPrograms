local comp = require("component");
local ed = comp.energy_device;
local reactor = comp.br_reactor;

if _G["BIKER"] == nil then
    _G["BIKER"] = {};
end

if _G["BIKER"]["reactor"] == nil then
    _G["BIKER"]["reactor"] = {};
    _G["BIKER"]["reactor"]["timer"] = nil;
end

if _G["BIKER"]["reactor"]["timer"] ~= nil then
    require("event").cancel(_G["BIKER"]["reactor"]["timer"]);
    _G["BIKER"]["reactor"]["timer"] = nil;
end

local function calcThrottle()
    
    per = ed.getEnergyStored() / ed.getMaxEnergyStored();
    for i = 0, 12, 1 do
        reactor.setControlRodLevel(i, per*100);
    end

end

_G["BIKER"]["reactor"]["timer"] = require("event").timer(10, calcThrottle, math.huge);