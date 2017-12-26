local comp = require("component");
local ed = comp.energy_device;
local reactor = comp.br_reactor;

local function calcThrottle()
    
    per = ed.getEnergyStored() / ed.getMaxEnergyStored();
    for (i = 0, 12, 1) do
        reactor.setControlRodLevel(i, per);
    end

end

require("event").timer(10, calcThrottle, math.huge);