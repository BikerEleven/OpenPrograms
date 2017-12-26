local r, md = component.proxy(component.list("redstone")()), component.proxy(component.list("modem")())
md.open(105);
while true do
    result = table.pack(computer.pullSignal()) --5
    if result[1] == "modem_message" and result[6] == "spawn_it" then
        r.setOutput(5, 15);
        time = computer.uptime() + 1;
        repeat 
        until computer.uptime() > time
        r.setOutput(5, 0);
    end
end