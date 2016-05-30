--This syncs files and other things between computers using an ecrypted public/private key like system
--It's a mess I might clean this up and comment it later....
Sync = {};
syncOrder = {};
local SyncCount = 0;

local LocalKey = {math.random(9999), math.random(9999), math.random(9999), math.random(9999), math.random(10,20)}
local keyPacket = "";
local usedKeys = {}

local willRun = false;

local gotKey = false;
local keyID = -1;
local recKey = {};
local encPacket = "";

local getFiles = {};

local function contains(array, strMatch)
    
    return utils.find(array, strMatch) > 0;
    
end

local function makeNewKey()

	LocalKey[math.max(math.random(4), 1)] = math.random(9999);
	keyPacket = textutils.serialize(LocalKey);

	while contains(usedKeys, keyPacket) do
		LocalKey[math.max(math.random(4), 1)] = math.random(9999);
		keyPacket = textutils.serialize(LocalKey);
	end
	
end

local function output()
    
	while #Sync > 0 do
	
		makeNewKey();
		
        utils.sortedInsert(usedKeys, keyPacket);
		
		syncOrder = table.remove(Sync);
		
	
		if syncOrder ~= nil and syncOrder[1] ~= nil and syncOrder[2] ~= nil then
			
			packet = {};
			packet["operation"] = syncOrder[2];
			
			if syncOrder[2] == "add" or syncOrder[2] == "remove" or syncOrder[2] == "get" then
				packet["path"] = syncOrder[1];
			end
			
			if syncOrder[2] == "add" then
			
				str = "";
				packet["content"] = "";
				file = io.open( packet["path"], "r" );
				if file ~= nil then
					str = file:read();
					while str ~= nil do
						packet["content"] = packet["content"]..str.."<neline>";
						str = file:read();
					end	
					file:close();
				end
				
			elseif syncOrder[2] == "send" then
				
				packet["receverID"] = syncOrder[1];
				packet["content"] = syncOrder[2];
				packet["senderID"] = os.getComputerID();
				
			elseif syncOrder[2] == "get" then
				packet["senderID"] = os.getComputerID();
				table.insert(getFiles, packet["path"]);
			end
			
			network.broadcast( "sync", keyPacket );
			network.broadcast( "sync", utils.crypt( textutils.serialize(packet), LocalKey ) );
			
		end
		
	end
	
	willRun = false;
	
end

local function readPacket(id, message)
	
	if id == keyID then
		
		message = utils.crypt(message, recKey, true);
	
		packet = textutils.unserialize(message);
		
		if packet ~= nil then
		
			if packet["operation"] == "add" then --We need to add or update a file to match others
				packet["content"] = packet["content"]:gsub( "<neline>", "\n" )
				file = io.open( packet["path"], "w" );
				file:write( packet["content"] );
				file:close();
                os.queueEvent("BaseOS.sync.add", packet["path"]);
			end
			
			if packet["operation"] == "remove" then --We need to remove a file to match the others 
				if fs.exists(packet["path"]) then
					fs.delete(packet["path"]);
                    os.queueEvent("BaseOS.sync.remove", packet["path"]);
				end
			end
			
			if packet["operation"] == "get" then --A computer is asking us for a file
				
				newPacket = {};
				
				newPacket["path"] = packet["path"];
				newPacket["senderID"] = packet["senderID"];
				newPacket["operation"] = "receveSentFile";
				
				str = "";
				packet["content"] = "";
				file = io.open( packet["path"], "r" );
				if file ~= nil then
					str = file:read();
					while str ~= nil do
						newPacket["content"] = newPacket["content"]..str.."<neline>";
						str = file:read();
					end	
					file:close();
				end
				
				network.broadcast( "sync", keyPacket );
				network.broadcast( "sync", utils.crypt( textutils.serialize(newPacket), LocalKey ) );
				
				utils.sortedInsert(usedKeys, keyPacket);
				makeNewKey();
				
			end
			
			if packet["operation"] == "send" then --A computer sent us a message? NYI
				
			end
			
			if packet["operation"] == "receveSentFile" then --We got a file back from the other computers
				
				if contains(getFiles, packet["path"]) then --We asked for this file
					if tonumber(packet["senderID"]) == os.getComputerID() then --This file belongs to us
					
						packet["content"] = packet["content"]:gsub( "<neline>", "\n" )
						file = io.open( packet["path"], "w" );
						file:write( packet["content"] );
						file:close();
						
					end
					
					table.remove(getFiles, packet["path"]);
				end
				
			end
			
			network.broadcast( "sync", textutils.serialize(recKey) );
			network.broadcast( "sync", utils.crypt( textutils.serialize(packet), recKey ) );
			
			recKey = {};
			gotKey = false;
			keyID = -1;
			
		end
	
	end
	
end

local function input( id, message )
		
	if not gotKey then
		recKey = textutils.unserialize(message);
		if recKey ~= nil and recKey[1] ~= nil then
			if contains(usedKeys, message) then
				return;
			end
		
			gotKey = true;
			keyID = id;
			
            utils.sortedInsert(usedKeys, message);
			if localKey == recKey then
				makeNewKey();
			end
			
			if encPacket ~= "" then
				readPacket(id, encPacket);
				encPacket = "";
			end
			
		end
	else
		readPacket(id, message);
	end
	
end

function addFile(path)
	table.insert(Sync, {path, "add"});
	
	if not willRun then
		hook.addCoroutine( output );
		willRun = true;
	end
end

function getFile(path)
	table.insert(Sync, {path, "get"});
	
	if not willRun then
		hook.addCoroutine( output );
		willRun = true;
	end
end

function send(id, message)
	table.insert(Sync, {id, "send", message});
	
	if not willRun then
		hook.addCoroutine( output );
		willRun = true;
	end
	
end

function removeFile(path)
	table.insert(Sync, {path, "remove"});
	
	if not willRun then
		hook.addCoroutine( output );
		willRun = true;
	end
end

network.requestChannel( "sync", input );
