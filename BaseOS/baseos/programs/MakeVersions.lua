local Blacklisted = {
    "httpSync", 
    "settings.txt", 
    "test",
    "logs",
    "version.txt",
    "versions.txt",
    "data",
    "notes",
    "MakeVersions.lua",
    "rom",
    "openp"
};

local function contains(key)

    for k, v in pairs(Blacklisted) do
        if v == key then
            return true;
        end
    end
    
    return false;

end

local function exploreDir(dir, lnet)
    
    local children = fs.list(dir);
    
    for k,v in pairs(children) do
        
        if not contains(fs.getName(dir..v)) then
        
            if fs.isDir(dir..v) then
                print("Dive! ", v);
                lnet:write(dir..v.."/\n");
                exploreDir(dir..v.."/", lnet);
            else
                lnet:write(dir..v.."\n");
            end
            
        end
        
    end
    
end

function makeFile()

    local nv = BaseOS.getVersion() + 0.1;
    
    lnet = io.open( "versions.txt", "w" );
    lnet:write(nv.."\n");
    
    exploreDir("", lnet);
    
    lnet:close();
    
    menu.addNotification("Finished!");

end

function reexit()

	return 0;
    
end

function start()
	makeFile();
    menu.reOpenSubmenu();
end

function ascess()
	return 1;
end

function description()
	return "Make the versions file";
end
