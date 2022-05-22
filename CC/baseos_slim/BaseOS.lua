debugging = false;

local baseos = {};

local Running = false; --If the main loop is running
local sides = {} --This holds peripheral data
local runningRednet = false; --If rednet is currently running or not, should be in networking but the peripheral stuff is over here
local rednetSide = ""; --The side or name of the modem we are using for rednet
local location = "";
local hook;
local settings;

local version = 0; --BaseOS internal version, mostly for shows

local function attachPeripheral(_, name) --Updates the peripheral list
    sides[name] = peripheral.getType(name);
    if sides[name] == "modem" and peripheral.wrap(name).isWireless() then
        if runningRednet == false then --If we currently don't have a rednet modem open
            rednet.open(name);
            runningRednet = true; --Open it and set this modem as being used
            rednetSide = name;
        end
        sides[name] = "wireless_modem" --And rename it to make it easy to find
    end
end

local function detachPeripheral(_, name) --Updates the peripheral list
    sides[name] = nil; --Just remove it

    if name == rednetSide then --If we where using that modem
        runningRednet = false; --We have to set rednet running to false
        rednetSide = "";
        for k, v in pairs(sides) do
            if v == "wireless_modem" then --Search for a new modem to use
                rednet.open(k); --If we find a new one open it and set it to our currently used modem
                runningRednet = true;
                rednetSide = k;
                return;
            end
        end
    end
end

local function getPeripherals() --Used at startup to quickly catalog all attached peripherals
    local stuff = peripheral.getNames();

    for _, v in pairs(stuff) do
        attachPeripheral(nil, v);
    end
end

local function init() --This will load all of the APIs that BaseOS uses and attach all the events that are used in various places
    baseos.clearScr();

    print("loading utils");
    local work, p1 = require( "utils" ); if not work then error(p1); end
    print("loading hook");
    hook, p1 = require( "hook" ); if not hook then error(p1); end
    print("loading network");
    work, p1 = require( "network" ); if not work then error(p1); end
    print("loading settings");
    settings, p1 = require( "settings" ); if not settings then error(p1); end
    print("loading user");
    work, p1 = require( "user" ); if not work then error(p1); end
    print("loading menu");
    work, p1 = require( "menu" ); if not work then error(p1); end
    
    hook.addHook("BaseOS.peripheral_attach", "peripheral", attachPeripheral); --Used to update sides array
    hook.addHook("BaseOS.peripheral_detach", "peripheral_detach", detachPeripheral); --Used to update sides array

    baseos.log("##########BaseOS Setup finished##########\n\n");

    getPeripherals(); --Used to create the sides array
end

function baseos.getVersion()
    return version;
end

function baseos.getLocation()
    return location;
end

function baseos.exit() --Will stop BaseOS and cause the program to exit cleanly
    os.queueEvent("BaseOS.Shutdown"); --Tell anything thats still runing to clean up
    sleep(0.1); --Give things time to clean up
    Running = false;
    hook.stop();
end

function baseos.log(...)
    if not debugging then return; end
    logFile = io.open(location.."baseos/logs/log.txt", "a");
    logFile:write(os.day().." ");

    for _,v in ipairs({...}) do
        logFile:write(tostring(v).." ");
    end

    logFile:write("\n");
    logFile:close();
end

function baseos.clearScr() --Will clear the screen and add the BaseOS label
    term.clear()
    term.setCursorPos(1,1)
    print("BaseOS v"..version)
    os.queueEvent("BaseOS.clearScreen");
end

function baseos.isRednetOpen() --Just a little accessor
    return runningRednet;
end

function baseos.getSide(object) --Returns the side (or name) a peripheral is on using our sides array
    for k,v in pairs(sides) do
        if v == object then
            return k;
        end
    end

    return nil;
end

function baseos.isMobile()
    return term.getSize() <= 26;
end

function baseos.errorDump(message, level) --Function used to format errors as they appear and suspend all computer activity, broken
    print("----RUNTIME ERROR----")
    print("DUMP: "..message)
    --print("TRACE: "..debug.traceback())
    print("Hit P to resume");

    baseos.log(message, debug.traceback());

    repeat
        local _, p1 = os.pullEvent("char");
    until p1 == "p"
    os.queueEvent("errorResolved", "1");
end

function baseos.start(loc) --Entry point of the API
    location = loc;
    baseos.log("\n##########BaseOS Setup started##########\n");
    if Running then return; end

    Running = true;
    print("BaseOS is loading...");
    init(); --Load the other APIs

    print("Starting Event Dispatch");
    os.queueEvent("BaseOSLoaded");
    
    hook.setAllowTerminate(settings.getSetting("allowterminate"));
    --hook.setEventBlacklist({"rednet_message"});
    hook.start(); --And then kick off the eventdispatch and thread dispatch, as they say the rest is history
end

return baseos;