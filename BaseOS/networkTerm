local usedKeys = {}
local receavedKey = {};
local Path = ""
local skip = false
local skipMessage = false
local booster = {};

local function explode(d,p)
	local t, ll;
	t={};
	ll=0;
	if(#p == 1) then return {p} end
	while true do
		l=string.find(p,d,ll,true); -- find the next d in the string
		if l~=nil then -- if "not not" found then..
			if string.sub(p,ll,l-1) ~= nil then
				table.insert(t, string.sub(p,ll,l-1)); -- Save it in our array.
				ll=l+1; -- save just after where we found it for searching next time.
			end
		else
			table.insert(t, string.sub(p,ll)); -- Save what's left in our array.
			break; -- Break at end, as it should be, according to the lua manual.
		end
	end
	return t;
end

local function contains(array, strMatch)
    
    for k,v in pairs(array) do
        if (v == strMatch) then
            return true;
        end
    end
    
    return false;
end

local function checkStuffs(p1, p2, p3)
    local key = explode( "|", p3 )
    skip = false
    
    if key ~= nil and #key == 5 then
        for k,v in pairs( key ) do
            receavedKey[k] = tonumber( v );
        end
        if contains(usedKeys, p3) then skipMessage = true return end
        table.insert(usedKeys, p3)
        booster = {}
        table.insert(booster, p3)
        skip = true
        skipMessage = false
    end
    
    if receavedKey[1] ~= nil and not skip and Path == "" and not skipMessage then 
        Path = "Garbage"
        table.insert(booster, p3)
        skip = true
    end
    
    if receavedKey[1] ~= nil and BaseOS.crypt( p3, receavedKey, true ) == "RESET" and not skip and not skipMessage then
        receavedKey = {};
        Path = "";
        skip = true
        table.insert(booster, p3)
        for k,v in pairs(booster) do
            rednet.broadcast(v)
        end
    end
    
    if receavedKey[1] ~= nil and BaseOS.crypt( p3, receavedKey, true ) == "remove" and not skip and not skipMessage then
        skip = true
        table.insert(booster, p3)
    elseif receavedKey[1] ~= nil and not skip and not skipMessage then
        table.insert(booster, p3)
        skip = true
    end
end

rednet.open("top")

while true do
    evt, p1, p2, p3 = os.pullEventRaw();
    
    if evt == "terminate" then
        --nope.avi
    elseif evt == "rednet_message" then
        checkStuffs(evt, p1, p2, p3)
    end
end
