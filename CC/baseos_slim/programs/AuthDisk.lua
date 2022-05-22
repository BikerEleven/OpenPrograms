local function deAuth()
    if fs.exists("user.txt") then
        fs.delete("user.txt");
    end
end

function start()
    
    uName, access, pass = user.getLogin();
    
    file = io.open( "user.txt", "w" );
	file:write(uName);
	file:write("\n");
	file:write(pass);
	file:write("\n");
	file:write(access);
	file:close();
    
    menu.addNotification("ID created, will be removed on restart or logoff.");
    menu.reOpenSubmenu();
	
end

function ascess()
	if BaseOS.isMobile() then
        return 3;
    else
        return nil;
    end
end

function description()
	return "Portable ID";
end

if BaseOS.isMobile() then
    hook.addHook("BaseOS.AuthDisk.logoff", "logoff", deAuth);
    deAuth();
end
