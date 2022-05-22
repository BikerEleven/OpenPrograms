if not settings.hasSetting("kd.wireSide") then

	settings.addSetting("Keydoor", "kd.wireSide", "back")
	settings.addSetting("Keydoor", "kd.driveSide", "")
	settings.addSetting("Keydoor", "kd.wireColor", "1")
	settings.addSetting("Keydoor", "kd.isLocked", "false")

end

local wireSide = settings.getSetting("kd.wireSide");
local driveSide = settings.getSetting("kd.driveSide");
local wireColor = tonumber(settings.getSetting("kd.wireColor"));
local isLocked = false;
local delay = false;

if settings.getSetting("kd.isLocked") == "true" then
	isLocked = true;
end

function doorCall(_, side)

	if side == driveSide and not delay then
		local userDisk = user.readIdDisk(driveSide);
        
        if userDisk ~= nil then
            if user.validateUser(userDisk[1], userDisk[2]) and not isLocked then
                delay = true;
                disk.eject(driveSide);
                redstone.setBundledOutput(wireSide, colors.combine(redstone.getBundledOutput(wireSide), wireColor));
                sleep(5);
                redstone.setBundledOutput(wireSide, colors.subtract(redstone.getBundledOutput(wireSide), wireColor));
                delay = false;
            end
        end
		
	end

end

local function updateInfo(evt, menuName)
    
    if menuName:find("KeyDoor") ~= nil then
    
        menu.changeProgramMenuInfo({
            "Door settings", 
            "Wire Direction "..tostring(wireSide), 
            "Drive side "..tostring(driveSide), 
            "Wire color "..tostring(wireColor), 
            "Is locked "..tostring(isLocked)
        });
        
    end
	
end

function lock()

	isLocked = not isLocked;
	settings.setSetting("kd.isLocked", tostring(isLocked));
	menu.reOpenSubmenu();
	
end

function wiredir()

	tempWireSide = wireSide;
	wireSide = read();
	
	ok, obj = pcall(redstone.testBundledInput, wireSide, wireColor);
	if ok and obj ~= nil then
		settings.setSetting("kd.wireSide", wireSide);
	else
		print("Bad Direction");
		wireSide = tempWireSide;
		sleep(2);
	end
	
	menu.reOpenSubmenu();

end

function drivesid()

	tempdriveSide = driveSide;
	driveSide = read();
	ok, obj = pcall(peripheral.wrap, driveSide);
	
	if ok and obj ~= nil then
		redstone.setBundledOutput(wireSide, colors.combine(redstone.getBundledOutput(wireSide), wireColor));
		settings.setSetting("kd.driveSide", driveSide);
	else
		print("Bad Direction");
		driveSide = tempdriveSide;
		sleep(2);
	end
	
	menu.reOpenSubmenu();

end

function wirecol()

	wireColor = tonumber(read());
	settings.setSetting("kd.wireColor", wireColor);
	
	menu.reOpenSubmenu();

end

local function closeMenu()
    
    hook.removeHook("BaseOS.keydoor.MenuRedraw", "BaseOS.Menu.Redraw");
    menu.closeSubMenu();
    
end

local programMenu = {
    actionNames = {
        "Switch lock", 
        "Settings", 
        "Exit"
     },
     actions = {
        lock, 
        nil, 
        closeMenu
    },
    parent = nil,
    access = 1,
    name = "KeyDoor",
    header = {
        "Door settings", 
        "Wire Direction "..tostring(wireSide), 
        "Drive side "..tostring(driveSide), 
        "Wire color "..tostring(wireColor), 
        "Is locked "..tostring(isLocked)
    }
};

local settingsMenu = {
    actionNames = {
        "Wire Direction", 
        "Wire Color", 
        "Drive Side", 
        "Back"
    },
    actions = {
        wiredir, 
        wirecol, 
        drivesid,
        menu.closeSubMenu
    },
    parent = programMenu,
    access = 1,
    name = "KeyDoor Settings",
    header = {
        "Door settings", 
        "Wire Direction "..tostring(wireSide), 
        "Drive side "..tostring(driveSide), 
        "Wire color "..tostring(wireColor), 
        "Is locked "..tostring(isLocked)
    }
};

programMenu.actions[2] = settingsMenu;

function start()

    hook.addHook("BaseOS.keydoor.MenuRedraw", "BaseOS.Menu.Redraw", updateInfo);
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
	return "Keycard door accesss";
end

hook.addHook("BaseOS.keydoor.Keycard", "disk", doorCall);
