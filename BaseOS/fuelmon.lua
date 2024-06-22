if not rednet.isOpen() then
    rednet.open("back");
end

cid = rednet.lookup("fuelquery", "fuelmonitor");
rednet.send(cid, "", "fuelquery");
id, mess = rednet.receive("fuelquery", 5);
print("Fuel level is " .. mess:match("%d+").."%");
print("Oil level is"..mess:match(" %d+").."%");
