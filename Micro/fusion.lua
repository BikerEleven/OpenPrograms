local r = component.proxy(component.list("nc_fusion_reactor")());

local opt = 4430;
local mode = false;

r.deactivate();

while true do
	temp = r.getTemperature() / 1000000;
	if not mode and temp <= opt then
		r.activate();
		mode = true;
	elseif mode and temp >= (opt * 1.02) then
		r.deactivate()
		mode = false;
	end
	
	computer.pullSignal(1);
end