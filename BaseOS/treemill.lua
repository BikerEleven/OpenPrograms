if not rednet.isOpen() then
    rednet.open("back");
end

local args = {...};

local cid = rednet.lookup("treeloggercontrol", "treelogger");
if cid == nil then
    print("Failed to find computer");
    return;
end

if #args > 0 then
    if args[1]:lower() == "query" then
        rednet.send(cid, "0", "treeloggerquery");
        id, mess = rednet.receive("treeloggerquery", 10);
        if mess == nil then
            print("No response");
        elseif mess == "1" then 
            print("Tree mill is online");
        else 
            print("Tree mill is offline"); 
        end
        
    elseif #args == 2 and args[1]:lower() == "control" then
        rednet.send(cid, args[2]:lower(), "treeloggercontrol");
        id, mess = rednet.receive("treeloggercontrol", 10);
        print("Response: "..tostring(mess));
    end
else
    print("usage treemill <action:query, control> [control:on, off]");
end
