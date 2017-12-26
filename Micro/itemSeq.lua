local t = component.proxy(component.list("transposer")())
sink = 2;
prov = 3;

si = 1;
while true do
  for pi=1, t.getInventorySize(prov) do
    s = t.getStackInSlot(prov, pi);
    if s ~= nil then
      titem = 0;
      while titem < s.size do
        while not t.transferItem(prov, sink, 1, pi, si) do end
        titem = titem + 1;
        si = si + 1;
        if si > t.getInventorySize(sink) then si = 1; end
      end
    end
  end
end