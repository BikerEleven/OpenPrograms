local turtleID = nil;
local inMenu = false;
local switchMenu = false;
local status = "Offline";

local function close()
    inMenu = false;
    menu.closeSubMenu();
end

local function on()
    rednet.send(turtleID, "start", "treeloggercontrol");
    menu.reOpenSubmenu();
end

local function off()
    rednet.send(turtleID, "stop", "treeloggercontrol");
    menu.reOpenSubmenu();
end

local function harvest()
    rednet.send(turtleID, "harvest", "treeloggercontrol");
    menu.reOpenSubmenu();
end

local function restart()
    rednet.send(turtleID, "restart", "treeloggercontrol");
    menu.reOpenSubmenu();
end

local function refresh()

    menu.reOpenSubmenu();
    turtleID = rednet.lookup("treeloggercontrol");

    if turtleID ~= nil then
        switchMenu = true;
        rednet.send(turtleID, "", "treeloggerquery");
    end
end

local activeProgramMenu = {
    actionNames = {
        "Turn On",
        "Turn Off",
        "Harvest",
        "Restart",
        "Exit"
    },
    actions = {
        on,
        off,
        harvest,
        restart,
        close
    },
    access = 3,
    parent = nil,
    name = "TreeTurtleControl",
    header = {
        "Tree Mill Controller",
        "Turtle Status: "..status
    }
}

local inactiveProgramMenu = {
    actionNames = {
        "Refresh",
        "Exit"
    },
    actions = {
        refresh,
        close
    },
    access = 3,
    parent = nil,
    name = "TreeTurtleControl",
    header = {
        "Tree Mill Controller",
        "Turtle Status: No turtle"
    }
}

local function updateHeader()
    
    menu.changeProgramMenuInfo({
        "Tree Mill Controller",
        "Turtle Status: "..status
    });

end

local function turtleMessage(evt, id, mess, proto)
    if proto == "treeloggerquery" then
        if mess then
            status = "Online";
        else
            status = "Offline";
        end
        
        if switchMenu then
            activeProgramMenu.header = {
                "Tree Mill Controller",
                "Turtle Status: "..status
            };
            
            switchMenu = false;
            menu.updateProgramMenu(activeProgramMenu);
        elseif inMenu then
            updateHeader();
        end
    elseif proto == "treeloggercontrol" then
        if not mess then
            menu.addNotification("There was an issue with the harvesters last command.");
        end
    end
end

function start()
    inMenu = true;
    if turtleID == nil then
        menu.setProgramMenu(inactiveProgramMenu);
    else
        menu.setProgramMenu(activeProgramMenu);
    end
end

function ascess()
	return 3;
end

function description()
	return "Tree Harvest control";
end

hook.addHook("BaseOS.Harvester.rednetMessage", "rednet_message", turtleMessage);
turtleID = rednet.lookup("treeloggercontrol");

if turtleID ~= nil then
    rednet.send(turtleID, "", "treeloggerquery");
end
