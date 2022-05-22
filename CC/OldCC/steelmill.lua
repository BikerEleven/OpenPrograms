if not rednet.isOpen() then
    rednet.open("back");
end

local args = {...};

local cid = rednet.lookup("steelcontrol", "steelmill");
if cid == nil then
    print("Failed to find computer");
    return;
end

if #args > 0 then
    if args[1]:lower() == "query" then
        rednet.send(cid, "0", "steelquery");
        id, mess = rednet.receive("steelquery", 5);
        if mess == "1" then print("Steel mill is online"); else print("Steel mill is offline"); end
    elseif #args == 2 and args[1]:lower() == "control" then
        if args[2]:lower() == "on" then
            rednet.send(cid, "1", "steelcontrol");
        elseif args[2]:lower() == "off" then
            rednet.send(cid, "0", "steelcontrol");
        end
        id, mess = rednet.receive("steelcontrol", 5);
        if mess == "1" then print("Steel mill was turned on"); else print("Steel mill was turned off"); end
    end
else
    print("usage steelmill <action:query, control> [control:on, off]");
end