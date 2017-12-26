local t = component.proxy(component.list("transposer")())
sink = 0;
prov = 4;

while true do
  for i=1, t.getInventorySize(prov) do
    s = t.getStackInSlot(prov, i);
    if s ~= nil then
      si = 0;
      while si < s.size do
        for ti = 1, t.getInventorySize(sink) do
          while not t.transferItem(prov, sink, 1, i, ti) and si < s.size do end
          si = si + 1;
        end
      end
    end
  end
end

local t = component.proxy(component.list("transposer")())

while true do
	for i=1, t.getInventorySize(4) do
		s = t.getStackInSlot(4, i);
		if s ~= nil then
			for si=1, s.size do
				while t.transferItem(4, 0, i, math.random(t.getInventorySize(0))) < 1 do
				end
			end
		end
	end
end