local Hooks = {};  --Events that are qued
local PullHooks = {}; --Holds threads that listen to all events, ex overriden os.pullEvents
local Threads = {}; --Threads that are running
local AllowTerminate = true;

local oldFuncts = {};
local running = false;

--This will process the event we received
local function processEvent(data)
    if data[1] == nil then return end--Make sure the event is valid
    
    for k,v in ipairs(PullHooks) do
        if v[1] ~= nil and v[1] == data[1] then
            table.insert(Threads, {v[2], data});
            PullHooks[k] = nil;
        elseif v[1] == nil then
            table.insert(Threads, {v[2], data});
            PullHooks[k] = nil;
        end
    end
    
    if Hooks["*"] ~= nil then --If we have any hooks that trigger on anything
        for _,v in pairs(Hooks["*"]) do
            if type(v) == "thread" then
                table.insert(Threads, {v, data}) --If they are then add them as a thread to run next cycle
            else
                table.insert(Threads, {coroutine.create(v), data}) --If they are then add them as a thread to run next cycle
            end
        end
    end
    
    if Hooks[data[1]] ~= nil then --If we have any hooks for this event
        for _,v in pairs(Hooks[data[1]]) do
            if type(v) == "thread" then
                table.insert(Threads, {v, data}) --If they are then add them as a thread to run next cycle
            else
                table.insert(Threads, {coroutine.create(v), data}) --If they are then add them as a thread to run next cycle
            end
        end
    end
    
    os.queueEvent("wake");
    
end

local function threadDispatch() --Thread Dispatch loop - CORE, will manage all currently runing and sleeping threads. Will also handle errors that bubble up
    while running do

        for i = 1, #Threads do
            threadData = Threads[i] -- [1 = coroutine, 2 = params]
            if threadData ~= nil and threadData[1] ~= nil then    --Check to make sure the coroutine exists

                if coroutine.status(threadData[1]) == "suspended" then --Check to make sure its not dead
                    ok, event = coroutine.resume(threadData[1], unpack(threadData[2]));
                end

                if ok then
                    if coroutine.status(threadData[1]) == "suspended" and event ~= nil then --If its still not dead and returned an id
                        table.insert(PullHooks, {event, threadData[1]});
                    end
                else --If there was an error during execution then show an error dump
                    print(event);
                end

                table.remove(Threads, i);  --After its done runing remove it
            end
        end

        coroutine.yield(); --Need to yield
    end
end

local function eventDispatch() --Event Dispatch loop - CORE, will pull all events that get thrown then send them off to where they need to go
    while running do

        data = {os.pullEventRaw()}; --Pull an event

        if data[1] == "terminate" then  --If its the terminate event
            if AllowTerminate then --Check if its allowed
                stop() --If yes terminate
                break
            end
        elseif data[1] ~= "wake" then --Wake is a fake event used to trick the eventDispach into not blocking
            processEvent( data ) --Otherwise if its not wake or terminate send the event to be processed
        end

    end
end

function addHook(id, event, callback) --Add an function that will be called on an event or "*" for all events
    
    if Hooks[event] == nil then
        Hooks[event] = {};
    end
    
    if Hooks[event][id] ~= nil then
        error("Tried to add an hook that already exists "..event.." "..id);
    else
        Hooks[event][id] = callback;
    end

end

function removeHook(id, event) --Remove the function from the event queue
    if id == nil or id == "" then
        error("Hook id must not be nil");
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

function pullEvent(filter) --Replacement for os.pullEvent
    table.insert(PullHooks, {filter, coroutine.running()});
    return coroutine.yield();
end

function addCoroutine(funct, ...)   --Shortcut function to add a coroutine to the thread list
    local params = {};
    params[1] = coroutine.create(funct);
    params[2] = {...};

    table.insert(Threads, params);
end

function start() --Will become the new toplevel process and kick off eventdispatch and thread dispatch
    running = true;
    oldFuncts.pullEvent = os.pullEvent; --We will overload os.pullEvent so save the original function
    os.pullEvent = pullEvent; --Overload os.pullEvent to use our pullEvent function
    parallel.waitForAll(eventDispatch, threadDispatch);
    os.pullEvent = oldFuncts.pullEvent;
end

function stop() --Kills hook and resets any functions we overloaded
    running = false;
end