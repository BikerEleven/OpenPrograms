if not rednet.isOpen() then
    rednet.open("back");
end

local args = {...};

if #args ~= 2 and #args ~= 3 then
    print("usage lasercontrol <action:query, control> <color:white,.etc> [control:on, off]");
end

local cid = rednet.lookup("lasercontrol", "lasercontrol"..args[1]:lower());
if cid == nil then
    print("Failed to find computer", "lasercontrol"..args[1]:lower());
    return;
end

if args[2]:lower() == "query" then
    rednet.send(cid, "0", "laserquery");
    id, mess = rednet.receive("laserquery", 5);
    if mess == "1" then print("Laser is online"); else print("Laser is offline"); end
elseif args[2]:lower() == "control" then
    if args[3]:lower() == "on" then
        rednet.send(cid, "1", "lasercontrol");
    elseif args[3]:lower() == "off" then
        rednet.send(cid, "0", "lasercontrol");
    end
    id, mess = rednet.receive("lasercontrol", 5);
    if mess == "1" then print("Laser was turned on"); else print("Laser was turned off"); end
end
