local component = require("component");

if not component.isAvailable("robot") then return; end

local modem = require("modem");
local robot = require("robot");
local sides = require("sides");
local fs = require("filesystem");
local serialization = require("serialization");

local db = component.database;
local souls = {};
local port = 146;

local dataToSoul = {};
for i = 1, 4 do
    dataToSoul[db.get(i).label] = i;
end

if fs.exists("/souls.dat") then
    file = io.open("souls.dat", "r");
    souls = serialization.unserialize(file:read("*a"));
    file:close();
end

modem.open(port);

local function processesMessage(_, localaddr, remoteaddr, recport, _, proto, message, data)
    
    print(proto);
    
    if recport == port then
        
        if proto == "switchLayout" then
            if souls[message] == nil then
                modem.send(remoteaddr, port, "error", "Layout not found");
            else
                for i = 1, 4 do
                    robot.forward();
                    robot.digDown();
                end
                for i = 4, 1, -1 do
                    robot.select(dataToSoul[souls[message][i]]);
                    robot.placeDown();
                    robot.back();
                end
                modem.send(remoteaddr, port, "result", "Done.");
                print("Switched to "..message.." layout.");
            end
        elseif proto == "addLayout" then
            souls[message] = serialization.unserialize(data);
            file = io.open("/souls.dat", "w");
            file:write(serialization.serialize(souls));
            file:close();
            modem.send(remoteaddr, port, "result", "Layout added");
            print("Added "..message.." layout.");
        end
        
    end
    
end

require("term").clear();

while true do
    processesMessage(require("event").pull("modem_message"));
end
