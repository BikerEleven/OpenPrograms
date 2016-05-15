local Erc = {2123,9,5867,7593,0}
local stop = false

local function readDisk()

	if fs.exists( disk.getMountPath(settings.getSetting( "drivedir" )).."/user.txt" ) then
		fs.delete( disk.getMountPath(settings.getSetting( "drivedir" )).."/user.txt" )
	end
	
	while tUser == nil do
		BaseOS.clearScr()
		
		Users = user.getUsers()
		
		if Users == nil then return end
		
		for k,v in pairs( Users ) do
			if v[2] ~= nil then
				print( "Users: "..k )
			end
		end
		
		print( "" )
		
		write( "User: " )
		tUser = read()
		
		if tUser:lower() == "exit" then
			menu.reOpenSubmenu()
			return;
		end
		
		if not user.hasUser( tUser ) then
			print("User '"..tUser.."' not found!")
			sleep(5);
			tUser = nil
		end
	end
	
	if (user.getAscessLevel( user.getLogin() ) ~= 1) and (user.getAscessLevel( user.getLogin() ) <= user.getAscessLevel( tUser )) then
		print("You lack the ascess to create a card for this account "..user.getAscessLevel( user.getLogin() ))
		sleep(2);
		menu.reOpenSubmenu()
	end
	
	disk.setLabel(settings.getSetting( "drivedir" ), tUser);
	
	file = io.open( disk.getMountPath(settings.getSetting( "drivedir" )).."/user.txt", "w" )
	
	file:write( tUser )
	file:write("\n")
	file:write( Users[ tUser ][1] )
	file:write("\n")
	file:write( Users[ tUser ][2] )
	
	file:close();
	
	print( "Done." )
	if disk.isPresent(settings.getSetting( "drivedir" )) then disk.eject(settings.getSetting( "drivedir" )) end
	
	sleep(3);
	menu.reOpenSubmenu()

end

function getDisk( _, p1 )

	if stop then
		hook.removeHook( "BaseOS.createCard.disk", "disk" )
		stop = false
		hook.removeHook( "BaseOS.createCard.Char", "char" )
		return;
	end
	
	if p1 == settings.getSetting( "drivedir" ) then
		hook.removeHook( "BaseOS.createCard.disk", "disk" )
		hook.removeHook( "BaseOS.createCard.Char", "char" )
		readDisk()
	end
end

function cancel( _, p1 )

	if p1 == "e" then
		stop = true
		hook.removeHook( "BaseOS.createCard.Char", "char" )
		hook.removeHook( "BaseOS.createCard.disk", "disk" )
		menu.reOpenSubmenu()
	end

end

function start()

	BaseOS.clearScr()
	print( "Please insert the IDCard to be writen to" )
	print( "Press e to exit" )
	
	hook.addHook("BaseOS.createCard.Char", "char", cancel )
	hook.addHook("BaseOS.createCard.disk", "disk", getDisk )
	
	stop = false;
	
	return true
	
end

function ascess()

	return 1

end

function description()

	return "Create a card"

end
