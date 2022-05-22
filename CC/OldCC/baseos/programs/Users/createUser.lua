function start()

	BaseOS.clearScr()
	write( "User: " )
	userN = read();
	print("")
	
	if userN == "exit" then
		menu.createSubmenu()
		return
	end
	
	write( "Password: " )
	pass = read("*");
	print("")
	
	write( "Ascess: " )
	asc = read();
	
	name,_ = user.getLogin();
	
	if asc ~= "root" and asc ~= "admin" and asc ~= "client" then
		print( "Invalid access: root, admin, client." );
		sleep(3);
		start();
		return;
	end
	
	if user.getAscessLevel(name) ~= 1 then
		if asc == "root" then
			print( "You don't have permission to use root." );
			sleep(3);
			start();
			return;
		elseif asc == "admin" then
			print( "You don't have permission to use admin." );
			sleep(3);
			start();
			return;
		end
		return;
	end
	
	user.addUser(userN, pass, asc);
	
	print( "Done." )
	sleep(5);
	
	menu.reOpenSubmenu();

end

function ascess()

	return 2

end

function description()

	return "Create a user"

end
