local function download( files )

	if #files == 0 then return false end
	print( "Let the download commence" )
	
	for k,v in pairs( files ) do
		if v == nil or v == "" then return false end
		if string.find( v, "/", string.len(v) - 1, string.len(v) ) ~= nil then
			print("makeing dir "..v)
			dirToMake = string.sub( v, 0, string.len(v) - 1)
			fs.makeDir( dirToMake );
		else
			rfile = http.get("http://www.aoeghq.com/external/BaseOS/"..v);
			lfile = io.open( v, "w" );
            
			print("making file "..v)
			while true do
				line = rfile:readLine();
				if line ~= nil then
					lfile:write(line.."\n");
				else
					break
				end
			end
            
			lfile:close();
			rfile:close();
		end
	end
	
	return true;

end

function checkVersion()

	http.request("http://www.aoeghq.com/external/versions.txt")
	while true do
		evt, p1, p2, p3 = os.pullEvent()
		if evt == "http_success" then
		
			inet = p2
			
			rVersion = inet:readLine()
			print("Remote version is "..rVersion);
			lVersion = "0";
			
			if fs.exists("version.txt") then
				lnet = io.open( "version.txt", "r" );
				if lnet ~= nil then
					lVersion = lnet:read();
					lnet:close();
				end
			end
			
			rVersion = tonumber( rVersion )
			lVersion = tonumber( lVersion )
			
			if rVersion ~= nil and lVersion ~= nil then
				if lVersion < rVersion then
					
					files = {}
					
					while true do
						line = inet:readLine()
						if line == nil then break end
						print("Adding "..line)
						table.insert( files, line );
					end
					
					if not download( files ) then 
						print( "Error downloading the latest version. Please contact the Administrator." ) 
					else
						vir = io.open("version.txt", "w");
						vir:write(rVersion);
						vir:close();
						print( "Update finished" )
						sleep(5)
						os.reboot()
					end
				end
			end
			
			inet:close()
			
			break
		end
		if evt == "http_failure" then
			print( "Error checking the latest version. Please contact the Administrator." )
			break
		end
	end

end

term.clear()
term.setCursorPos(1,1)
checkVersion()
