local component = require("component");
local term = require("term");
local reactor = component.br_reactor;
local turbine = component.br_turbine;
local capacitor = component.tile_blockcapacitorbank_name;

local function clamp(min, max, value)
  if value > max then return max; end
  if value < min then return min; end
  return value;
end

local flipSwitch = false;

while true do
  local numRods = reactor.getNumberOfControlRods() * 100;
  local capacitorFill = capacitor.getEnergyStored() / capacitor.getMaxEnergyStored();
  
  if capacitorFill < 0.5 then
    turbine.setInductorEngaged(true);
  end

  if capacitorFill > 0.9 then
    turbine.setInductorEngaged(false);
  end

  if turbine.getRotorSpeed() < 1780 then
    turbine.setActive(true);
    reactor.setActive(true);
  end

  if turbine.getRotorSpeed() > 1775 then
    turbine.setActive(false);
    reactor.setActive(false);
  end

  if term.isAvailable() then
    term.clear()
    term.write("Power Storage "..(capacitorFill*100).."% ".."Reactor Status "..tostring(reactor.getActive()).." ".."Turbine Satus "..tostring(turbine.getActive()).." "..tostring(turbine.getInductorEngaged()), true)
  end

  os.sleep(1);
end