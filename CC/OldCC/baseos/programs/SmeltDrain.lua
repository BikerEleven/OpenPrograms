if not settings.hasSetting("sd.ingotColor") then

	settings.addSetting("SmelteryDrain", "sd.ingotColor", "1");
	settings.addSetting("SmelteryDrain", "sd.castColor", "3");
	settings.addSetting("SmelteryDrain", "sd.peripheralControler", "back");
    settings.addSetting("SmelteryDrain", "sd.wireDir", "bottom");

end

local peripheralControler = settings.getSetting("sd.peripheralControler");
local wireSide = settings.getSetting("sd.wireDir");
local castColor = tonumber(settings.getSetting("sd.castColor"));
local ingotColor = tonumber(settings.getSetting("sd.ingotColor"));
local working = false;
local inMenu = false;

local function updateSettingsMenu()

    info = {"Drain Settings", "Wire Direction "..wireSide, "Smeltery Direction "..peripheralControler, "Ingot Color "..ingotColor, "Block Color "..castColor};
	menu.changeMenuInfoAndUpdate(info);

end

function wiredir()
	
	tempWireSide = wireSide;
	wireSide = read();

	ok, obj = pcall(redstone.testBundledInput, wireSide, ingotColor);
	print(tostring(ok).." "..tostring(obj));
	if ok and obj ~= nil then
		settings.setSetting("sd.wireDir", wireSide);
	else
		print("Bad Direction");
		wireSide = tempWireSide;
		sleep(2);
	end
	
	updateSettingsMenu();
	return 2;

end

function controlerDir()
	
	tempdriveSide = peripheralControler;
	peripheralControler = read();
	ok, obj = pcall(peripheral.wrap, peripheralControler);
	
	if ok and obj ~= nil then
		settings.setSetting("sd.peripheralControler", peripheralControler);
	else
		print("Bad Direction");
		peripheralControler = tempdriveSide;
		sleep(2);
	end
	
	updateSettingsMenu();
	return 2;

end

function icol()

    redstone.setBundledOutput(wireSide, colors.subtract(redstone.getBundledOutput(wireSide), ingotColor));
	ingotColor = tonumber(read());
	settings.setSetting("sd.ingotColor", ingotColor);
	if doorState then
		redstone.setBundledOutput(wireSide, colors.combine(redstone.getBundledOutput(wireSide), ingotColor));
	end
	
	updateSettingsMenu();
	return 2;

end

function bcol()

    redstone.setBundledOutput(wireSide, colors.subtract(redstone.getBundledOutput(wireSide), castColor));
	castColor = tonumber(read());
	settings.setSetting("sd.castColor", castColor);
	if doorState then
		redstone.setBundledOutput(wireSide, colors.combine(redstone.getBundledOutput(wireSide), castColor));
	end
    
    updateSettingsMenu();
	
	return 2;

end

function changeSettings()

	info = {"Drain Settings", "Wire Direction "..wireSide, "Smeltery Direction "..peripheralControler, "Ingot Color "..ingotColor, "Block Color "..castColor};
	options = {"Wire Direction", "Controler Direction", "Ingot Color", "Block Color", "Back"};
	events = {wiredir, controlerDir, icol, bcol, start};
	
	menu.createOptionMenu(info, options, events);
    
    inMenu = false;
	
	return 1;

end

function getResults()
    
    local tank = peripheral.wrap(peripheralControler);
    if tank == nil then
        print("System is not setup.");
        sleep(3);
        return 2;
    end
    local mb = tank.getInfo()["amount"];
    
    if mb == nil then
        print("Smeltery is empty.");
        sleep(3);
        return 2;
    end
    
    local blocks = math.floor(mb / 1296);
    local ingots = math.floor((mb % 1296) / 144);
    local leftover = mb % 144;
    
    print(blocks.." Blocks and "..ingots.." Ingots with "..leftover.." mb left over");
    sleep(5);
    
    return 2;
    
end

local function processLiquids(tank)

    local mb = tank.getInfo()["amount"];
    local blocks = math.floor(mb / 1296);
    local ingots = math.floor((mb % 1296) / 144);
    
    for i = 1, blocks, 1 do
        redstone.setBundledOutput(wireSide, castColor);
        sleep(20);
        redstone.setBundledOutput(wireSide, 0);
        sleep(0.15);
    end
    
    for i = 1, ingots, 1 do
        redstone.setBundledOutput(wireSide, ingotColor);
        sleep(0.15);
        redstone.setBundledOutput(wireSide, 0);
        sleep(6);
    end
    
    working = false;
    
    if inMenu then
    
        info = {"Smeltery Drainer", "Working "..tostring(working)};
        menu.changeMenuInfoAndUpdate(info);
        
    end

end

function drain()

    if working then 
        print("System is already runing.");
        sleep(3);
        return 2; 
    end
    
    local tank = peripheral.wrap(peripheralControler);
    if tank == nil then
        print("System is not setup.");
        sleep(3);
        return 2;
    end
    
    if tank.getInfo()["amount"] == nil then
        print("Smeltery is empty.");
        sleep(3);
        return 2;
    end
    
    working = true;
    info = {"Smeltery Drainer", "Working "..tostring(working)};
    menu.changeMenuInfoAndUpdate(info);
    
    hook.addCoroutine(processLiquids, tank);

   return 2; 

end

function reexit()

    inMenu = false;
	return 0;

end

function start()

	info = {"Smeltery Drainer", "Working "..tostring(working)};
	options = {"Run", "Estimate Results", "Settings", "Exit"};
	events = {drain, getResults, changeSettings, reexit};
	
	menu.createOptionMenu(info, options, events);
    
    inMenu = true;
	
	return 1;

end

function ascess()
	if BaseOS.isMobile() then
        return nil;
    else
        return 2;
    end
end

function description()
	return "Smeltery Autodrain";
end

redstone.setBundledOutput(wireSide, 0);
