local hook = {};

local Hooks = {};  --Events that are queued {"event"={"uid"=function}}
local PullHooks = {}; --Holds threads that listen to all events, ex overriden os.pullEvents {1={filter, coroutine}}
local Threads = {}; --Threads that are running or will be ran, FIFO {1={function, {data}}}
local AllowTerminate = true;
local BlackList = {}; --Restricted events
local running = false;

--This will process the event we received
local function processEvent(data)
    if data[1] == nil then return end--Make sure the event is valid
    
    for k,v in ipairs(PullHooks) do
        if v[1] ~= nil and v[1] == data[1] then --If the pull hook only runs against specific events
            if BaseOS then
                BaseOS.log("Handeling hook "..tostring(v[2]));
            end
            table.insert(Threads, {v[2], data});
            PullHooks[k] = nil;
        elseif v[1] == nil then --If it runs against any event
            if BaseOS then
                BaseOS.log("Handeling hook "..tostring(v[2]));
            end
            table.insert(Threads, {v[2], data});
            PullHooks[k] = nil;
        end
    end
    
    if Hooks["*"] ~= nil then --If we have any hooks that trigger on anything
        for k,v in pairs(Hooks["*"]) do
            if BaseOS then
                BaseOS.log("Handeling hook "..k);
            end
            if type(v) == "thread" then
                table.insert(Threads, {v, data}); --If they are then add them as a thread to run next cycle
            else
                table.insert(Threads, {coroutine.create(v), data}); --If they are then add them as a thread to run next cycle
            end
        end
    end
    
    if Hooks[data[1]] ~= nil then --If we have any hooks for this event
        for k,v in pairs(Hooks[data[1]]) do
            if BaseOS then
                BaseOS.log("Handeling hook "..k);
            end
            if type(v) == "thread" then
                table.insert(Threads, {v, data}); --If they are then add them as a thread to run next cycle
            else
                table.insert(Threads, {coroutine.create(v), data}); --If they are then add them as a thread to run next cycle
            end
        end
    end
        
end

local function threadDispatch() --Thread Dispatch loop - CORE, will manage all currently runing and sleeping threads. Will also manage(mostly) errors that bubble up
    
    while #Threads > 0 do
        threadData = table.remove(Threads, 1); -- [1 = coroutine, 2 = params]
        
        if threadData ~= nil and threadData[1] ~= nil then    --Check to make sure the coroutine exists

            if BaseOS then
                BaseOS.log("Executing coroutine "..tostring(threadData[1]));
            end
            
            local ok, event = false, nil;
            
            if coroutine.status(threadData[1]) == "suspended" then --Check to make sure it's not dead
                if table.unpack then
                    ok, event = coroutine.resume(threadData[1], table.unpack(threadData[2]));
                else
                    ok, event = coroutine.resume(threadData[1], unpack(threadData[2]));
                end
            end

            if ok then
                if coroutine.status(threadData[1]) == "suspended" then --If its still not dead
                    if event ~= nil then
                        table.insert(PullHooks, {event, threadData[1]}); --If it returned an event
                    end
                end
            else --If there was an error during execution then show an error dump
                if BaseOS then
                    BaseOS.errorDump(event);
                else
                    print(event);
                end
            end

        end
    end
    
end

local function eventDispatch() --Event Dispatch loop - CORE, will pull all events that get thrown then send them off to where they need to go
    data = {computer.pullSignal()}; --Pull an event

    if data[1] == "terminate" then  --If its the terminate event
        if AllowTerminate then --Check if its allowed
            hook.stop(); --If yes stop running
        end
    else
        processEvent( data ); --Otherwise if its not wake or terminate send the event to be processed
    end
    
end

----------------------------------------------------------------------------------------

function hook.addHook(id, event, callback) --Add an function that will be called on an event or "*" for all events
    
    for _,v in ipairs(BlackList) do
        if v == event then
            error(id .. " attempted to hook blacklisted event "..event);
        end
    end
    
    if Hooks[event] == nil then
        Hooks[event] = {};
    end
    
    if BaseOS then
        BaseOS.log("Adding hook "..id);
    end
    
    if Hooks[event][id] ~= nil then
        error("Tried to add an hook that already exists "..event.." "..id);
    else
        Hooks[event][id] = callback;
    end

end

function hook.removeHook(id, event) --Remove the function from the event queue
    if id == nil or id == "" then
        error("Hook id must not be nil");
    end
    
    if BaseOS then
        BaseOS.log("Removing hook "..id);
    end
    
    if event ~= nil then --If they supply the event then we don't have to look for it
        Hooks[event][id] = nil;
    else
        for _,v in pairs(Hooks) do --Otherwise search all the events for the unique id
            if v[id] ~= nil then
                v[id] = nil;
            end
        end
    end
end

function hook.pullEvent(filter) --Replacement for os.pullEvent
    if BaseOS then
        BaseOS.log("PullEvent "..tostring(filter).." "..tostring(coroutine.running()));
    end
    table.insert(PullHooks, {filter, coroutine.running()});
    return coroutine.yield();
end

function hook.addCoroutine(funct, ...)   --Shortcut function to add a coroutine to the thread list
    local params = {};
    params[1] = coroutine.create(funct);
    params[2] = {...};
    
    if BaseOS then
        BaseOS.log("Adding coroutine "..tostring(funct).." : "..tostring(params[1]));
    end

    table.insert(Threads, params);
end

function hook.setAllowTerminate(setting)
    if not running then --Only allow this setting to be changed while hook is not running
        AllowTerminate = setting;
    end
end

function hook.setEventBlacklist(list)
    if not running then --Only allow this setting to be changed while hook is not running
        BlackList = list;
    end
end

function hook.start() --Will become the new toplevel process and kick off eventdispatch and thread dispatch
    
    running = true;
    
    while running do
        
        eventDispatch();
        threadDispatch();
        
    end
    
end

function hook.stop() --Stops hook from running
    running = false;
end

----------------------------------------------------------------------------------------

return hook;