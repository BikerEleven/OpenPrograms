if not settings.hasSetting("dc.doorState") then

	settings.addSetting("DoorControl", "dc.doorState", "false")
	settings.addSetting("DoorControl", "dc.wireColor", "1")
	settings.addSetting("DoorControl", "dc.wireSide", "back")

end

local doorState = false;
local wireSide = settings.getSetting("dc.wireSide");
local wireColor = tonumber(settings.getSetting("dc.wireColor"));

if settings.getSetting("dc.doorState") == "true" then

	doorState = true;

end

local function updateMenuInfo()

    menu.changeProgramMenuInfo({
        "Door settings", 
        "Wire Direction "..wireSide, 
        "Wire color "..wireColor
    });

end

local function updateMenuState()

    menu.changeProgramMenuInfo({
        "Door Control", 
        "Door open "..tostring(doorState)
    });

end

function openDoor()

	doorState = true;
	settings.setSetting("dc.doorState", tostring(doorState));
	redstone.setBundledOutput(wireSide, colors.combine(redstone.getBundledOutput(wireSide), wireColor));
	
	updateMenuState();
	menu.reOpenSubmenu();

end

function closeDoor()

	doorState = false;
	settings.setSetting("dc.doorState", tostring(doorState));
	redstone.setBundledOutput(wireSide, colors.subtract(redstone.getBundledOutput(wireSide), wireColor));
	
	updateMenuState();
	menu.reOpenSubmenu();

end

function wiredir()

	redstone.setBundledOutput(wireSide, colors.subtract(redstone.getBundledOutput(wireSide), wireColor));
	
	tempWireSide = wireSide;
	wireSide = read();

	ok, obj = pcall(redstone.testBundledInput, wireSide, wireColor);
	print(tostring(ok).." "..tostring(obj));
	if ok and obj ~= nil then
		settings.setSetting("dc.wireSide", wireSide);
		if doorState then
			redstone.setBundledOutput(wireSide, colors.combine(redstone.getBundledOutput(wireSide), wireColor));
		end
	else
		print("Bad Direction");
		wireSide = tempWireSide;
		sleep(2);
	end
	
	updateMenuInfo();
	menu.reOpenSubmenu();

end

function wirecol()

	redstone.setBundledOutput(wireSide, colors.subtract(redstone.getBundledOutput(wireSide), wireColor));
	wireColor = tonumber(read());
	settings.setSetting("dc.wireColor", wireColor);
	if doorState then
		redstone.setBundledOutput(wireSide, colors.combine(redstone.getBundledOutput(wireSide), wireColor));
	end
	
	updateMenuInfo();
	menu.reOpenSubmenu();

end

local programMenu = {
    actionNames = {
        "Open", 
        "Close", 
        "Settings", 
        "Exit"
     },
     actions = {
        openDoor, 
        closeDoor, 
        nil, 
        menu.closeSubMenu
     },
    parent = nil,
    access = 1,
    name = "DoorControl",
    header = {
        "Door Control", 
        "Door open "..tostring(doorState)
    }
};

local settingsMenu = {
    actionNames = {
        "Wire Direction", 
        "Wire Color", 
        "Back", 
    },
    actions = {
        wiredir, 
        wirecol, 
        menu.closeSubMenu, 
    },
    parent = programMenu,
    access = 1,
    name = "DoorControlSettings",
    header = {
        "Door settings", 
        "Wire Direction "..wireSide, 
        "Wire color "..wireColor
    }
};

programMenu.actions[3] = settingsMenu;

function start()
    
    menu.setProgramMenu(programMenu);
	
end

function ascess()
    if BaseOS.isMobile() then
        return nil;
    else
        return 2;
    end
end

function description()
	return "Door Control";
end

if doorState then
	redstone.setBundledOutput(wireSide, colors.combine(redstone.getBundledOutput(wireSide), wireColor));
end
