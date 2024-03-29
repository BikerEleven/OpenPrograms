debugging = false;

local Running = false; --If the main loop is running
local loaded = false; --Used to see if BaseOS is finished loading the core moduals
local sides = {} --This holds pheripheral data
local runningRednet = false; --If rednet is currently runing or not, should be in networking but the peripheral stuff is over here
local rednetSide = ""; --The side or name of the modem we are using for rednet
local location = "";

local version = 0; --BaseOS interal version, mostly for shows

local function getPeripherals() --Used at startup to quickly catalog all attached peripherals

    local stuff = peripheral.getNames();

    for _, v in pairs(stuff) do
        sides[v] = peripheral.getType(v); --Add it into the sides array
        if sides[v] == "modem" and peripheral.wrap(v).isWireless() then --If its a wireless modem
            if runningRednet == false then --If we currently don't have a rednet modem open
                rednet.open(v);
                runningRednet = true;
                rednetSide = v; --Open it and set the modem that we are using
            end
            sides[v] = "wirelessmodem" --Rename the modem to wireless modem to make it easier to find
        end
    end

end

local function attachPeripheral(_, name) --Updates the peripheral list

    sides[name] = peripheral.getType(name);
    if sides[name] == "modem" and peripheral.wrap(name).isWireless() then
        if runningRednet == false then --If we currently don't have a rednet modem open
            rednet.open(name);
            runningRednet = true; --Open it and set this modem as being used
            rednetSide = name;
        end
        sides[name] = "wirelessmodem" --And rename it to make it easy to find
    end

end

local function detachPeripheral(_, name) --Updates the peripheral list

    sides[name] = nil; --Just remove it
    if name == rednetSide then --If we where using that modem
        runningRednet = false; --We have to set rednet runing to false
        rednetSide = "";
        for k, v in pairs(sides) do
            if v == "wirelessmodem" and peripheral.wrap(k).isWireless() then --Search for a new modem to use
                rednet.open(k); --If we find a new one open it and set it to our currently used modem
                runningRednet = true;
                rednetSide = k;
            end
        end
    end

end

local function onHttpRequest(_, page, handel)
    local v = page:gsub("https://dl.dropboxusercontent.com/u/16655497/BaseOS/", "");

    if handel == nil then
        print( "Error downloading file "..v );
        return false;
    end

    local lfile = io.open( v, "w" );

    while true do
        local line = handel:readLine();
        if line ~= nil then
            lfile:write(line.."\n");
        else
            break;
        end
    end
    lfile:close();
    handel:close();
    
    return true;
end

local function download( files ) --Function used for updating, handles all the files
    local result = true;
    
    for _, v in pairs( files ) do
        if v == nil or v == "" then return false end
        if string.find( v, "/", string.len(v) - 1, string.len(v) ) ~= nil then
            fs.makeDir( string.sub( v, 0, string.len(v) - 1) );
        else
            local response = http.get("https://dl.dropboxusercontent.com/u/16655497/BaseOS/"..v);
            result = result and onHttpRequest(nil, "https://dl.dropboxusercontent.com/u/16655497/BaseOS/"..v, response);
        end
    end
    
    return result;
end

local function init() --This will load all of the APIs that BaseOS uses and attach all the events that are used in various places
    clearScr();
    
    --print("loading debug");
    --debug = dofile( location.."baseos/debug" );
    print("loading utils");
    work, p1 = os.loadAPI( location.."baseos/utils.lua" ); if not work then error(p1); end
    print("loading hook");
    work, p1 = os.loadAPI( location.."baseos/hook.lua" ); if not work then error(p1); end
    print("loading network");
    work, p1 = os.loadAPI( location.."baseos/network.lua" ); if not work then error(p1); end
    print("loading sync");
    work, p1 = os.loadAPI( location.."baseos/sync.lua" ); if not work then error(p1); end
    print("loading settings");
    work, p1 = os.loadAPI( location.."baseos/settings.lua" ); if not work then error(p1); end
    print("loading user");
    work, p1 = os.loadAPI( location.."baseos/user.lua" ); if not work then error(p1); end
    print("loading menu");
    work, p1 = os.loadAPI( location.."baseos/menu.lua" ); if not work then error(p1); end
    
    hook.addHook("BaseOS.peripheral_attach", "peripheral", attachPeripheral); --Used to update sides array
    hook.addHook("BaseOS.peripheral_detach", "peripheral_detach", detachPeripheral); --Used to update sides array

    log("##########BaseOS Setup finished##########\n\n");

    getPeripherals(); --Used to create the sides array
end

function getVersion()
    return version;
end

function getLocation()
    return location;
end

function Exit() --Will stop BaseOS and cause the program to exit cleanly
    os.queueEvent("BaseOS.Shutdown"); --Tell anything thats still runing to clean up
    sleep(0.1); --Give things time to clean up
    Running = false;
    hook.stop();
end

function log(...)
    if not debugging then
        return nil;
    end

    logFile = io.open(location.."baseos/logs/log.txt", "a");
    logFile:write(os.day().." ");

    for _,v in ipairs({...}) do
        logFile:write(tostring(v).." ");
    end

    logFile:write("\n");

    logFile:close();
end

function clearScr() --Will clear the screen and add the BaseOS label
    term.clear()
    term.setCursorPos(1,1)
    print("BaseOS v"..version)
    os.queueEvent("BaseOS.clearScreen");
end

function isRednetOpen() --Just a little accessor
    return runningRednet;
end

function getSide(object) --Returns the side (or name) a pheripheral is on using our sides array
    for k,v in pairs(sides) do
        if v == object then
            return k;
        end
    end

    return nil;
end

function isMobile()
    x = term.getSize();
    return x <= 26;
end

function errorDump(message, level) --Function used to format errors as they appear and suspend all computer activity, broken
    print("----RUNTIME ERROR----")
    print("DUMP: "..message)
    --print("TRACE: "..debug.traceback())
    print("Hit P to resume");

    log(message, debug.traceback());

    tripError = true;

    repeat
        evt, p1 = os.pullEvent("char");
    until p1 == "p"
    os.queueEvent("errorResolved", "1");
end

function getVersionFile(inet) --Event callback used for updating
    rVersion = inet:readLine()
    if tonumber(rVersion) == nil then
        rVersion = -1;
    else
        rVersion = tonumber(rVersion);
    end

    print("Remote version is "..rVersion);
    lVersion = "0";

    if fs.exists("version.txt") then
        lnet = io.open( "version.txt", "r" );
        if lnet ~= nil then
            lVersion = lnet:read();
            lnet:close();
        end
    end

    lVersion = tonumber( lVersion )

    version = lVersion;

    if rVersion ~= nil and lVersion ~= nil then
        if lVersion < rVersion then

            print("Preforming system update.");
            sleep(5);

            files = {}

            line = inet:readLine()

            while line ~= nil do
                table.insert( files, line );
                line = inet:readLine()
            end

            if not download( files ) then
                print( "Error downloading the latest version. Please contact the Administrator." );
                sleep(15);
            else
                vir = io.open("version.txt", "w");
                vir:write(rVersion);
                vir:close();
                print("Update finished system rebooting");
                sleep(5)

                Exit();
                os.reboot();
            end
        else
            loaded = true;
            os.queueEvent("BaseOSLoaded");
            print("Loading finished");
            sleep(2);
        end
    end

    inet:close()
end

function checkVersion() --Checks my main server to see if theres an updated version of BaseOS
    print("Checking Version");
    response = http.get("https://dl.dropboxusercontent.com/u/16655497/BaseOS/versions.txt");
    if response ~= nil then
        getVersionFile(response);
    else
        print("Error checking the latest version. Please contact the Administrator.")
    end
end

function start(loc) --Entry point of the API
    location = loc;
    
    log("\n##########BaseOS Setup started##########\n");
    
    if Running then return; end

    Running = true;

    print("BaseOS is loading...");

    init(); --Load the other APIs

    --checkVersion(); --See if we are up to date

    print("Starting Event Dispatch");
    
    os.queueEvent("BaseOSLoaded");
    
    hook.setAllowTerminate(settings.getSetting("allowterminate"));
    --hook.setEventBlacklist({"rednet_message"});
    
    hook.start(); --And then kick off the eventdispatch and thread dispatch, as they say the rest is history
end
