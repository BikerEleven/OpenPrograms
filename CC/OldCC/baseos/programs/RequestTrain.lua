local stations = {};
local stationIDs = {};
local inMenu = false;

local function close()
    inMenu = false;
    menu.closeSubMenu();
end

local function refreash()
    
    if inMenu then
        menu.reOpenSubmenu();
    end
    
    stationIDs = {rednet.lookup("requestTrain")};
    for _,v in pairs(stationIDs) do
        rednet.send(v, "Hiya", "requestTrainName");
    end
    
end

local programMenu = {
    actionNames = {
        "Refreash",
        "Exit"
    },
    actions = {
        refreash,
        close
    },
    parent = nil,
    access = 3,
    name = "RequestaTrain",
    header = {
        "Request a train",
        "Catcha ride!"
    }
};

local function requestaTrain(name)
    rednet.broadcast(name, "requestTrain");
    close();
end

local function nameLookup(evt, id, message, proto)
    
    if proto == "requestTrainName" then
        table.insert(stations, message);
        if #stations == #stationIDs then
            
            programMenu.actions = {};
            for _, v in pairs(stations) do
                programMenu.actionNames = stations;
                table.insert(programMenu.actions, {requestaTrain, {v}});
            end
            
            table.insert(programMenu.actionNames, "Refreash");
            table.insert(programMenu.actions, refreash);
            table.insert(programMenu.actionNames, "Exit");
            table.insert(programMenu.actions, close);
            
            if inMenu then
                menu.updateProgramMenu(programMenu);
            end
            
        end
    elseif proto == "requestTrain" then
        menu.addNotification(message);
    end
    
end

function start()
    
    menu.setProgramMenu(programMenu);
    inMenu = true;
	
end

function ascess()
	return 3;
end

function description()
	return "Request a train";
end

hook.addHook("BaseOS.RequestTrain.nameLookup", "rednet_message", nameLookup);
refreash();
