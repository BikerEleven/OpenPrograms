local r, md = component.proxy(component.list("redstone")()), component.proxy(component.list("modem")())
md.open(163);
while true do
    result = table.pack(computer.pullSignal(10))
    if result[1] == nil then
        if r.getOutput(4) <= 14 then
            md.broadcast(163, "r_drop");
        end
    end
end