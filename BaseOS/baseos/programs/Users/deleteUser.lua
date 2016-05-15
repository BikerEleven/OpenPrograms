local stop = false

function start()

	tUser = nil;

	while tUser == nil do
		BaseOS.clearScr()
		
		Users = user.getUsers()
		
		if Users == nil then return end
		
		for k,v in pairs( Users ) do
			if v[2] ~= nil then
				print( "Users: "..k )
			end
		end
		
		print( "Type exit to exit" )
		
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
		print("You lack the ascess to remove this account "..user.getAscessLevel( user.getLogin() ))
		sleep(2);
		menu.reOpenSubmenu()
	end

	worked, err = user.removeUser(tUser);
	
	if worked then
		print( "Done." )
	else
		print( "Could not remove user. "..err )
	end
	
	sleep(3);
	menu.reOpenSubmenu()
	
end

function ascess()

	return 2

end

function description()

	return "Remove a user"

end
