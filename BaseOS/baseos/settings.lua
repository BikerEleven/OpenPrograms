Settings = nil; --Stores all the settings that are use by the computer
local isLoaded = false; --Trying to get at settings before the file is loaded will block the accessing thread until its ready.
local Erc = {2123, os.getComputerID(), 5867, 7593, 15}; --Used for encryption.

function saveSettings() --Will dump the settings array to the settings.txt file

	file = io.open( BaseOS.getLocation().."baseos/data/settings.txt", "w" );
	--file:write(BaseOS.crypt(textutils.serialize(Settings), Erc));
    file:write(textutils.serialize(Settings));
	file:close();

end

local function firstTimeSetUp() --Used to setup a new install

	if fs.exists( BaseOS.getLocation().."baseos/data/settings.txt" ) and fs.exists( BaseOS.getLocation().."baseos/data/users.txt" ) then return end;
	--If the settings file exsist already then this should not have been called?
    
	BaseOS.clearScr()
	print( "This computer needs to be set up, Please contact your Administrator." );
	term.setCursorPos( 3, 6 );
	write( "Password: " );
	
	checkPass = read("*");
	
	if checkPass == "rootPasswordlol" then --temp system
		BaseOS.clearScr()
		term.setCursorPos( 1, 3 );
        
        Settings = {};
		
		write( "Allow Termination ( 0 | 1 ): " ); --Start asking questions to setup the basic computer
		i = read();
		
		Settings["allowterminate"] = {};
		
		if tonumber(i) ~= nil then	
			if tonumber(i) == 1 then	
				Settings[ "allowterminate" ]["value"] = "true"
			else
				Settings[ "allowterminate" ]["value"] = "false"
			end
		else
			Settings[ "allowterminate" ]["value"] = "true"
		end
		Settings[ "allowterminate" ]["owner"] = "core"
        
        write( "Persistent login ( 0 | 1 ): " );
		i = read();
		
		Settings[ "keeplogin" ] = {};
		if tonumber(i) ~= nil then	
			if tonumber(i) == 1 then	
				Settings[ "keeplogin" ]["value"] = "true"
			else
				Settings[ "keeplogin" ]["value"] = "false"
			end
		else
			Settings[ "keeplogin" ]["value"] = "false"
		end
		Settings[ "keeplogin" ]["owner"] = "core"
		
		print( "" );
		
        if not BaseOS.isMobile() then
        
            write( "Disk drive side: " );
            i = read();
            
            Settings[ "drivedir" ] = {};
            Settings[ "drivedir" ]["value"] = i;
            Settings[ "drivedir" ]["owner"] = "core";
            
            print( "" );
            
        end
		
		write( "User: " ); --This part setups the administrator account or "root" user
		user = read();
		
		write( "Password: " );
		pass = read("*");
				
		pass = utils.hash(pass);
        Users = {};
        Users[user] = {pass, "root"};
        
        file = io.open(BaseOS.getLocation().."baseos/data/users.txt", "w");
        file:write(textutils.serialize(Users));
        file:close();
		
        fs.makeDir(BaseOS.getLocation().."baseos/data");
        
		saveSettings()
        
		if not BaseOS.isMobile() then
            if not disk.isPresent(Settings[ "drivedir" ]["value"]) then --After seting up the user create an ID Disk for them
                print("Please insert a disk");
                while not disk.isPresent(Settings[ "drivedir" ]["value"]) do
                    pcall(sleep, 1)
                end
            end
        
            if fs.exists( disk.getMountPath(Settings[ "drivedir" ]["value"]).."/user.txt" ) then
                fs.delete( disk.getMountPath(Settings[ "drivedir" ]["value"]).."/user.txt" );
            end
            
            disk.setLabel(Settings[ "drivedir" ]["value"], user);
            
            file = io.open( disk.getMountPath(Settings[ "drivedir" ]["value"]).."/user.txt", "w" )
            
            if file ~= nil then
                file:write( user )
                file:write("\n")
                file:write( pass )
                file:write("\n")
                file:write( "root" )
                
                file:close();
            end
        end
		
		term.clear();
		term.setCursorPos( 1, 1 );
		print( "Finished." );
		
		pcall(sleep, 3)
		
	else --If they failed the password check
		firstTimeSetUp()
	end

end

local function setUp() --Will start loading 

	if not fs.exists( BaseOS.getLocation().."baseos/data/settings.txt" ) or not fs.exists( BaseOS.getLocation().."baseos/data/users.txt" ) then
		firstTimeSetUp(); --If this is a freash install or a critical file is missing
	end
	
	if Settings == nil then
        file = fs.open(BaseOS.getLocation().."baseos/data/settings.txt", "r");
        Settings = textutils.unserialize(file:readAll());
        file:close();
        
        file = fs.open(BaseOS.getLocation().."baseos/data/users.txt", "r");
        Users = textutils.unserialize(file:readAll());
        file:close();
        
        if Users == nil or Settings == nil then
            firstTimeSetUp();
        end
        
        Users = nil;
    end
	
	isLoaded = true;

end

function getSetting( setting ) --Gets the value of a setting

	if not isLoaded then --If its not loaded block until we have finished, should never happen as loading happens before the threadDispatch runs
		repeat
			sleep(1);
		until isLoaded;
	end

	for k,v in pairs( Settings ) do
		if k == setting:lower() then	
			return v["value"];
		end
	end
	return ""
end

function setSetting( setting, value ) --Sets the value of a setting

	if not isLoaded then --If its not loaded block until we have finished, should never happen as loading happens before the threadDispatch runs
		repeat
			sleep(1);
		until isLoaded;
	end
	
	for k,v in pairs( Settings ) do
		if k == setting:lower() then	
			v["value"] = value;
			break;
		end
	end
	
	saveSettings();

end

function hasSetting(setting) --Check to see if we have a setting
	
	if not isLoaded then
		repeat
			sleep(1);
		until isLoaded;
	end
    
    if Settings == nil then
        error("Settings is nil?");
    end

	if Settings[setting:lower()] ~= nil then
		return true
	else 
		return false
	end
end

function addSetting(owner, setting, value) --Will add a setting to the settings array 

	if not isLoaded then
		repeat
			sleep(1);
		until isLoaded;
	end
	
	if setting == nil then --Well this is required...
		return;
	end
	
	if Settings[setting:lower()] then
		error(owner.." tryed to define "..setting.." its already defined by "..Settings[setting:lower()]["owner"])
	else --If it was not already defined create it and set its value
		Settings[setting:lower()] = {};
		Settings[setting:lower()]["value"] = value
		Settings[setting:lower()]["owner"] = owner
	end
	
	saveSettings(); --Then save
	
end

setUp();
