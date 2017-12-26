local r, m = component.proxy(component.list("redstone")()), component.proxy(component.list("modem")());
m.open(120+1);

while true do
    e, _, _, _, _, m = computer.pullSignal();
    if e == "modem_message" and m == "elevate" then
        r.setOutput(1, 15);
        time = computer.uptime() + 1;
        repeat 
        until computer.uptime() > time
        r.setOutput(1, 0);
    end
end