debuging = false;

local Running = false; --If the main loop is running
local loaded = false; --Used to see if BaseOS is finished loading the core moduals
local components = {} --This holds pheripheral data
local location = "";

local version = 0; --BaseOS interal version, mostly for shows

local function getComponents() --Used at startup to quickly catalog all attached peripherals
    
    for address, componentType in component.list() do
        if components[componentType] == nil then
            components[componentType] = component.proxy(address);
        end
    end

end

local function attachComponent(address, compType) --Updates the peripheral list

    if components[compType] == nil then
        components[compType] = component.proxy(address);
        computer.pushSignal("component_available", compType);
    end

end

local function detachComponent(address, compType) --Updates the peripheral list
    
    if components[compType] ~= nil then
        if component.list(compType, true)() ~= nil then
            components[compType] = component.proxy(component.list(compType, true)());
        else
            computer.pushSignal("component_unavailable", compType);
        end
    end

end

local function onHttpRequest(event, page, handel)

    v = page:gsub("https://dl.dropboxusercontent.com/u/16655497/BaseOS/", "");

    if handel == nil then
        print( "Error downloading file "..v );
        return false;
    end

    lfile = io.open( v, "w" );

    while true do
        line = handel:readLine();
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
    
    for k,v in pairs( files ) do
        if v == nil or v == "" then return false end
        if string.find( v, "/", string.len(v) - 1, string.len(v) ) ~= nil then
            dirToMake = string.sub( v, 0, string.len(v) - 1)
            fs.makeDir( dirToMake );
        else
            response = http.get("https://dl.dropboxusercontent.com/u/16655497/BaseOS/"..v);
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
    work, p1 = loadAPI( location.."baseos/utils.lua" ); if not work then error(p1); end
    print("loading hook");
    work, p1 = loadAPI( location.."baseos/hook.lua" ); if not work then error(p1); end
    print("loading network");
    work, p1 = loadAPI( location.."baseos/network.lua" ); if not work then error(p1); end
    print("loading sync");
    work, p1 = loadAPI( location.."baseos/sync.lua" ); if not work then error(p1); end
    print("loading settings");
    work, p1 = loadAPI( location.."baseos/settings.lua" ); if not work then error(p1); end
    print("loading user");
    work, p1 = loadAPI( location.."baseos/user.lua" ); if not work then error(p1); end
    print("loading menu");
    work, p1 = loadAPI( location.."baseos/menu.lua" ); if not work then error(p1); end
    
    hook.addHook("BaseOS.component_attach", "component_added", attachComponent); --Used to update components array
    hook.addHook("BaseOS.component_detach", "component_removed", detachComponent); --Used to update components array

    log("##########BaseOS Setup finished##########\n\n");

    getComponents(); --Used to create the components array

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

    if not debuging then 
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

function getComponent(componentType) --Returns the component using our components array

    return components[componentType];

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

    checkVersion(); --See if we are up to date

    print("Starting Event Dispatch");
    
    os.queueEvent("BaseOSLoaded");
    
    hook.setAllowTerminate(settings.getSetting("allowterminate"));
    --hook.setEventBlacklist({"rednet_message"});
    
    hook.start(); --And then kick off the eventdispatch and thread dispatch, as they say the rest is history

end
