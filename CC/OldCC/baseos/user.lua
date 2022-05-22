local trys = 3; --How many times a user can try to login
local Users = {{}}; --Holds all users, {userName={pass, access}}
local Ascess = { "root", "admin", "client" }; --Access table
local Erc = {2123, os.getComputerID(), 5867, 7593, 15}; --Used in encryption
local cUser = "Unknown"; --Current user
local uAscess = "Unknown"; --Current user access
local usrFile = BaseOS.getLocation().."baseos/data/users.txt";

if not settings.hasSetting("logedinuser") then --Check to see if a custom setting is registered
	settings.addSetting("core", "logedinuser", ""); --If not register it
end

function getUsers() --Will update the users array from the file and return all users, for external reference mostly

	if not fs.exists(usrFile) then --This loads after settings so it "should" never happen
		print( "Computer is not set up Please contact your Administrator exiting..." );
		return false;
	else
		file = io.open(usrFile, "r" );
		Users = textutils.unserialize(file:read("*a"));
		file:close();
		return Users;
	end

end

--This will check to see if a user exists and will return true and their access if they do
function hasUser(Name)

    if Users[Name] ~= nil then
        return true, Users[Name][2];
    else
        return false;
    end

end

function getAscessLevel(userName) --Gets the access level of a user
	
	accessLevel = 4;
	
	if hasUser(userName) then
		accessLevel = Users[userName][2];
	end
	
	return accessLevel;
end

function addUser(user, pass, access) --Will add a user to the system, must be root or admin to add a user

	pass = utils.hash(pass);
	
	if getAscessLevel(cUser) ~= 1 then --Admins can't add other Admins or Root accounts
		if access == "root" or access == "admin" then
			return;
		end
	elseif getAscessLevel(cUser) == 3 then --Clients can never add other users
        return;
    end

    getUsers(); --This ensures I have the latest user table.
    
	if not hasUser(user) then --I check to see that they don't exist already
    
		Users[user] = {pass, access};
		
		file = io.open(usrFile, "w");
		file:write(textutils.serialize(Users));
		file:close();
		
		sync.addFile(usrFile); --Sync the users folder to other computers
		
	end

end

function removeUser(userN) --Removes a user from the system

	if getAscessLevel(cUser) ~= 1 then --If your not root
		if getAscessLevel(userN) == 1 or getAscessLevel(userN) == 2 then --If the account is a root account or admin account you can't do it
			return false, "Bad Privlage";
		end
	end
	
	Users[userN] = nil; --Drop them
	
	file = io.open(usrFile, "w");
	file:write(textutils.serialize(Users));
	file:close();
	
	sync.addFile(usrFile); --Write and sync
	
	return true;

end

function validateUser(usern, pass) --Used to validate a user 
	
	local isValid = false;
	
	if hasUser(usern) then
		if pass == Users[usern][1] then
			isValid = true;
		end
	end
	
	return isValid;

end

local function logUserIn( usern ) --Starts the login process as a short cut, if keeplogin is true

    if usern ~= nil then 
		BaseOS.clearScr();
        print("Logging you in "..usern);
        sleep(3);
        
        BaseOS.clearScr();
        
        cUser = usern;
        uAscess = Users[usern][2];
        
        if settings.getSetting( "keeplogin" ) == "true" then
            settings.setSetting( "logedinuser", usern);
        end
        
        if BaseOS.debuging then 
            term.clear();
        end
        
        os.queueEvent("logon", cUser, uAscess); --And announce that a user loged in
    end

end

function readIdDisk(driveSide) --Will read an ID disk and return the info from it
	    
	if not disk.isPresent(driveSide) then
		return nil;
	end
	
	if fs.exists( disk.getMountPath(driveSide).."/user.txt" ) then
	
		file = fs.open( disk.getMountPath(driveSide).."/user.txt", "r" );
        isValid = true;
		
		if file == nil then return nil; end
		
		usercheck = file:readLine()
		if (usercheck == nil) and isValid then 
			isValid = false;
		end
		
		passcheck = file:readLine()
		if (passcheck == nil) and isValid  then 
			isValid = false;
		end
		
		ascesscheck = file:readLine()
		if (ascesscheck == nil) and isValid  then 
			isValid = false;
		end
		file:close()
		
        if isValid then
            return {usercheck, passcheck, ascesscheck};
        else
            return nil;
        end
		
	end
	
end

local function createBlank() --Creates a blank login screen

	BaseOS.clearScr();
	print( "Press r to log in." );
	hook.addHook("BaseOS.user.LoginChar", "char", createLogin );

end

local function validate(uDisk)
    
    write("User: ");
	usern = read();
    
	write("Password: ");
	pass = read("*");
	pass = utils.hash(pass);
    
    if not hasUser(usern) then
        return false;
    end
    
    if pass ~= Users[usern][1] then
        return false;
    end
    
    if uDisk then
        if usern ~= uDisk[1] then
            BaseOS.clearScr();
			print("Incorrect IDDisk"); --Just pop it out and go back to blank
            disk.eject(settings.getSetting( "drivedir" ));
			sleep(3);
			
			createBlank();
            return nil;
        end
        
        if pass ~= uDisk[2] then
            BaseOS.clearScr();
				
            print("Bad Disk."); --Well this looks like a bad attempt
            fs.delete(disk.getMountPath(settings.getSetting( "drivedir" )).."/user.txt");
            disk.eject(settings.getSetting( "drivedir" ));
            sleep(3); --Annoy them and delete the disk file
            
            createBlank(); --And just walk off
            return nil;
        end
        
        if uDisk[3] ~= Users[usern][2] then --If their access fails to match
            BaseOS.clearScr();
				
            print("Bad Disk."); --Well this looks like a bad attempt
            fs.delete(disk.getMountPath(settings.getSetting( "drivedir" )).."/user.txt");
            disk.eject(settings.getSetting( "drivedir" ));
            sleep(3); --Annoy them and delete the disk file
            
            createBlank(); --And just walk off
            return nil;
        end
    end
    
    return true;
    
end

local function tryLogin(disk)
    
    valid = false;
    
    repeat 
        valid = validate(disk);
    
        if valid == nil then
            break;
        elseif valid == false then
            print( "Incorrect username or password "..trys.." tries left" )
            trys = trys - 1 --Same as above, 3 tries to get it right before lockout
            if trys < 0 then
                BaseOS.clearScr();
                print("----LOCKOUT----");
                sleep(60);
                trys = 3
                
                createBlank();
                break;
            end
        end
        
    until valid
    
    if valid then
        hook.addCoroutine(logUserIn, usern); --And log them in
    end
    
    trys = 3;
end

function createLogin(_, key) --If a used wants to login to the computer

	if (key == "r") then
        
        if BaseOS.isMobile() then
            hook.removeHook("BaseOS.user.LoginChar", "char");
            tryLogin();
        else
            if disk.isPresent(settings.getSetting( "drivedir" )) then --If we have a disk in the ID disk drive,
                disk.eject(settings.getSetting( "drivedir" )); --Eject it 
            end
            
            hook.removeHook("BaseOS.user.LoginChar", "char");
            print( "Please now insert your Issued IDDisk" ); --Then we ask the user for an ID disk
            hook.addHook("BaseOS.user.diskLogin", "disk", login );
        end
	end
		
end

function login( _, side ) --Event callback function, called when a user enters a disk during the login process

	if side == nil or side ~= settings.getSetting( "drivedir" ) then 
		return;
	end

	userDisk = readIdDisk(settings.getSetting( "drivedir" )); --usercheck, passcheck, ascesscheck
	
    if userDisk then
    
        tryLogin(userDisk);
		
		hook.removeHook("BaseOS.user.diskLogin", "disk" ) --Remove the disk event
		if disk.isPresent( settings.getSetting( "drivedir" ) ) then
			disk.eject( settings.getSetting( "drivedir" ) )
		end --Then eject the ID disk if its still in there
		
    end
end

function logoff() --Logs off the current user

	os.queueEvent("logoff", cUser, uAscess) --Announce to any runing programs that the current user just loged off

	cUser = "Unknown"
	uAscess = "Unknown"
	
	createBlank(); --Go back to a blank slate
    
    if settings.getSetting( "keeplogin" ) == "true" then --If we should keep logins then remove the current user
        settings.setSetting( "logedinuser", "" )
    end

end

function getLogin() --Get the current loged in user
	
	if cUser ~= nil and cUser ~= "Unknown" and cUser ~= "" then
		return cUser, Users[cUser][2], Users[cUser][1];
	else
		return nil, nil, nil;
	end

end

local function onComputerLoad() --Event Callback function, called once BaseOS is fully loaded
    if settings.getSetting( "keeplogin" ) == "true" then
        if settings.getSetting( "logedinuser" ) ~= "" and hasUser(settings.getSetting( "logedinuser" )) then
            hook.addCoroutine(logUserIn, settings.getSetting( "logedinuser" ));
        else
            createBlank();
        end
    else
        createBlank();
    end
    
    hook.removeHook("BaseOS.user.BaseOSLoaded", "BaseOSLoaded");
end

getUsers()

hook.addHook("BaseOS.user.BaseOSLoaded", "BaseOSLoaded", onComputerLoad);
