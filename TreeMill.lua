local settings = {};
settings.shouldOutput = false
settings.alarmMode = false
settings.width = 0
settings.length = 0
settings.parent = -1
settings.fuel = 0
settings.saplings = 0
settings.dirt = 0
settings.template = 0

local alarmid = 0;
local harvesting = false;

local function explode(d,p)
	local t, ll
	t={}
	ll=0
	if(#p == 1) then return {p} end
	while true do
		l=string.find(p,d,ll,true) -- find the next d in the string
		if l~=nil then -- if "not not" found then..
			table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
			ll=l+1 -- save just after where we found it for searching next time.
		else
			table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
			break -- Break at end, as it should be, according to the lua manual.
		end
	end
	return t
end

local function loadSettings()

	file = io.open( "settings.txt", "r" )
	
    line = file:read("*a");
    temp = settings;
    settings = textutils.unserialize(line);
	
	file:close()
	
    if settings == nil then
        settings = temp;
        return false;
    end
    
	return true;

end

local function saveSettings()
    
    file = io.open("settings.txt", "w");
    file:write(textutils.serialize(settings));
    file:close();
    
end

local function getSettingsFromParent(id, message)
    if id == settings.parent then
        rednet.send(id, "ok")
    else
        rednet.send(id, "denied")
        return;
    end
    
    file = io.open("settings.txt", "w")
	if file == nil then
		--error? could be locked
		return
	end
    
    message = message:gsub( "<neline>", "\n" )
    file:write( message );
	file:close();
    
    loadSettings()
    
end

local function createSettings() 

	term.clear()
	term.setCursorPos( 1,1 )
	print( "Set the settings." )

	write( "Output drops: " )
	local str = string.lower( read() )
	if str == "1" or str == "yes" or str == "true" then
		settings.shouldOutput = true
	else
		settings.shouldOutput = false
	end

	write( "Rows: " )
	settings.width = tonumber(read())

	write( "Trees: " )
	settings.length = tonumber(read())
	
	write( "Fuel slot(1 - 16): " )
	settings.fuel = tonumber(read())
	
	write( "Sapling slot(1 - 16): " )
	settings.saplings = tonumber(read())
	
	write( "Dirt slot(1 - 16): " )
	settings.dirt = tonumber(read())
    
    write( "Template log slot(1 - 16): " )
	settings.template = tonumber(read())
	
	write( "ID of settings.parent computer -1 for off: " )
	settings.parent = tonumber(read())
    
    settings.alarmMode = settings.parent == -1;
	
	saveSettings();
	
	term.clear()
	term.setCursorPos( 1,1 )
	print( "Ready to cycle" )

end

local function checkFuel()
	if (turtle.getFuelLevel() < 200) then
		turtle.select(settings.fuel)
		if not turtle.refuel(3) then
			print("Waiting for settings.fuel...")
			while not turtle.refuel(3) do
				sleep(1)
			end
		end
		print("Refueling .. "..turtle.getFuelLevel())
	end
end

local function usefulInspect(direction, itemslot)
    if direction == "down" then
        x, y = turtle.inspectDown();
        if x then
            return y;
        else
            return {name="minecraft:air"};
        end
    end
    
    if direction == "front" then
        x, y = turtle.inspect();
        if x then
            return y;
        else
            return {name="minecraft:air"};
        end
    end
    
    if direction == "up" then
        x, y = turtle.inspectUp();
        if x then
            return y;
        else
            return {name="minecraft:air"};
        end
    end
    
    if direction == "back" then
        x = turtle.getItemDetail(itemslot);
        if x then
            return x;
        else
            return {name="minecraft:air"};
        end
    end
end

local function tryMove( direction )
	checkFuel()
	if direction == "down" then
		if turtle.detectDown() then
			turtle.digDown()
		end
		while not turtle.down() do
			turtle.digDown()
			sleep(1)
		end
	end
	
	if direction == "forward" then
		if turtle.detect() then
			turtle.dig()
		end
		while not turtle.forward() do
			turtle.dig()
			sleep(1)
		end
	end
	
	if direction == "up" then
		if turtle.detectUp() then
			turtle.digUp()
		end
		while not turtle.up() do
			turtle.digUp()
			sleep(1)
		end
	end
end

local function plantTree()
	turtle.select(settings.saplings)
    if turtle.detectDown() then turtle.digDown() end
    
    if turtle.getItemCount(settings.saplings)  <= 1 then return end
	
	l = turtle.getItemCount(settings.saplings)
	turtle.placeDown()
	t = turtle.getItemCount(settings.saplings)
	
	if t == l then --must have not been able to place a sapling
		turtle.select(settings.dirt)
		tryMove("down")
		if turtle.detectDown() then turtle.digDown() end
		turtle.placeDown()
		turtle.select(settings.saplings)
		tryMove("up")
		turtle.placeDown()
	end

	turtle.select(settings.saplings)
end

local function harvestTree() 
	steps = 0
	tryMove("forward")
	while usefulInspect("up")["name"] == usefulInspect("back", settings.template)["name"] do
		tryMove( "up" )
		steps = steps + 1
	end
	
	while steps > 1 do
		tryMove( "down" )
		steps = steps - 1
	end
	
	turtle.suckDown()
	plantTree()
end

local function checkTree()
    sleep(0.1);
    turtle.select(settings.template)
	if usefulInspect("front")["name"] == usefulInspect("back", settings.template)["name"] then
		tryMove( "down" )
		harvestTree()
	else
		tryMove( "forward" )
		turtle.select(settings.saplings)
        sapInv = usefulInspect("back", settings.saplings);
        sapWld = usefulInspect("down");
		if sapWld["name"] ~= sapInv["name"] or sapWld["metadata"] ~= sapInv["damage"] then
			plantTree()
		end
		turtle.suckDown()
	end
end

local function outputDrops()
    turtle.turnLeft();
    turtle.turnLeft();

    
    for i=1, 16 do
        if turtle.getItemCount( i ) > 0 then
            turtle.select(i)
            
            if turtle.compareTo(settings.saplings) and i ~= settings.saplings then
                turtle.transferTo(settings.saplings, 64 - turtle.getItemCount(settings.saplings))
            end
            
            if turtle.compareTo(settings.dirt) and i ~= settings.dirt then
                turtle.transferTo(settings.dirt, 64 - turtle.getItemCount(settings.dirt))
            end
            
            if i == settings.template then 
               turtle.drop(turtle.getItemCount(i) - 1) 
            elseif i ~= settings.saplings and i ~= settings.fuel and i ~= settings.dirt then
               turtle.drop(turtle.getItemCount( i ))  
            end
        end
    end
    
    turtle.select(settings.saplings);
    
    if turtle.getItemCount( settings.saplings ) < (settings.width * settings.length) + 1 then
        turtle.suck(((settings.width * settings.length) + 1) - turtle.getItemCount( settings.saplings ));
    end
        
    turtle.turnLeft()
    turtle.turnLeft()
    
end

local function harvest()
    if harvesting then return; end
    harvesting = true;
    
	turtle.select(settings.saplings)
	tryMove( "forward" )
	tryMove( "up" )
	checkTree()
	
	bump = false
	
	for w=1, settings.width do
	
		for l=1, settings.length do
		
			if l~=settings.length then
				tryMove( "forward" )
				tryMove( "forward" )
				checkTree()
			end
		
		end
	
		if w~=settings.width then
			if not bump then
				turtle.turnLeft()
				tryMove( "forward" )
				tryMove( "forward" )
			else
				turtle.turnRight()
				tryMove( "forward" )
				tryMove( "forward" )
			end
			checkTree()
			
			if bump then
				turtle.turnRight()
			else
				turtle.turnLeft()
			end
			
			bump = not bump
		end
		
	end
	
	
	--Return
	if not bump then
		turtle.turnLeft()
		tryMove( "forward" )
		turtle.turnLeft()
		for i = 1, settings.length do
			tryMove( "forward" )
			tryMove( "forward" )
			if i~=settings.length then
				tryMove( "forward" )
			end
		end
	else
		tryMove( "forward" )
		tryMove( "forward" )
	end
	turtle.turnLeft()
	
	if settings.width == 1 then
		tryMove( "forward" )
	else
		for i=1, settings.width - 1 do
			tryMove( "forward" )
			tryMove( "forward" )
			tryMove( "forward" )
		end
		if not bump then
			tryMove( "forward" )
		end
	end
	
	turtle.turnLeft()
	tryMove( "down" )
	turtle.select(settings.saplings)
	
	
	--Drop off and resupply
	if settings.shouldOutput then
		outputDrops()
	end
    
    harvesting = false;
end

local function handleRednet(event, cid, message, protocol)
        
    if message == "startLoging" and (protocol == nil or protocol == "") then
        if cid == settings.parent then
            rednet.send(cid, "ok")
            hook.addCoroutine(harvest);
        else
            rednet.send(cid, "denied")
        end
    end
    
    if (protocol == nil or protocol == "") and explode(message, ";")[1] == "newSettings" then
        getSettingsFromParent(cid, explode(message, ";")[2])
    end
    
    if protocol == "treeloggercontrol" then
        if message == "harvest" then
        
            rednet.send(cid, true, "treeloggercontrol");
            hook.addCoroutine(harvest);
            
        elseif message == "restart" then
            rednet.send(cid, true, "treeloggercontrol");
            os.reboot();
        elseif message == "start" then
        
            settings.alarmMode = true;
            term.setCursorPos(1, 1);
            term.clearLine();
            print("Automatic mode: on");
            saveSettings();
            alarmid = os.setAlarm(10);
            rednet.send(cid, true, "treeloggerquery");
            
        elseif message == "stop" then
        
            settings.alarmMode = false;
            saveSettings();
            term.setCursorPos(1, 1);
            term.clearLine();
            print("Automatic mode: off");
            os.cancelAlarm(alarmid);
            rednet.send(cid, false, "treeloggerquery");
            
        else
            rednet.send(cid, false, "treeloggercontrol");
        end
    end
    
    if protocol == "treeloggerquery" then
        if settings.alarmMode then
            rednet.send(cid, "1", "treeloggerquery");
        else
            rednet.send(cid, "0", "treeloggerquery");
        end
    end
    
end

local function handleAlarm(event, aid)
    if aid == alarmid then
        hook.addCoroutine(harvest);
        if settings.alarmMode then alarmid = os.setAlarm(10); end
    end
end

local function handleKeys(event, key)
    if key == "s" then
        hook.addCoroutine(createSettings);
    end
    
    if key == "r" then
        hook.addCoroutine(harvest);
    end
end

if (_G["turtle"] ~= nil) then
	term.clear()
	term.setCursorPos( 1,1 )
	print( "Logger program starting..." )
    
    work, p1 = os.loadAPI("hook.lua"); if not work then error(p1); end

	if fs.exists( "settings.txt" ) then
		if not loadSettings() then
			createSettings()
		end
		
		term.clear()
		term.setCursorPos( 1,1 )

	else
		createSettings()
	end
    
    if settings.alarmMode then
        alarmid = os.setAlarm(10);
        print("Automatic mode: on");
    else
        print("Automatic mode: off");
    end
    
    pcall(rednet.open, "left");
    if rednet.isOpen() then
        rednet.host("treeloggercontrol", "treelogger");
        rednet.host("treeloggerquery", "treelogger");
        
        hook.addHook("treemill.rednet", "rednet_message", handleRednet);
    end
    
    hook.addHook("treemill.alarms", "alarm", handleAlarm);
    hook.addHook("treemill.keychars", "char", handleKeys);
    
    print("System ready");
    hook.start();
	
else
	term.clear()
	term.setCursorPos( 1,1 )
	print( "This is a turtle program." )
end
