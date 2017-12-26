local r, m = component.proxy(component.list("redstone")()), component.proxy(component.list("modem")());
m.open(121);
m.open(122);
m.open(123);
local rl = true;

while true do
    e, _, _, p, d, m = computer.pullSignal();
    if e == "modem_message" and m == "elevate" then
        if p == 123 and rl then
            r.setOutput(1, 0);
            rl = false;
        elseif p ~= 123 and not rl then
            r.setOutput(1, 15);
            rl = true;
        end
    end
end