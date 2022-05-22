---@class hook
local hook = {};

---Events that are queued {"event"={"uid"=function}}
local Hooks = {};
---Holds threads that listen to all events, ex overriden os.pullEvents {1={filter, coroutine}}
local PullHooks = {};
---Threads that are running or will be ran, FIFO {1={function, {parameters}}}
local Threads = {};
local AllowTerminate = true;
local BlockList = {}; --Restricted events
local Overrides = {};
local running = false;

--This will process the event we received
local function processEvent(data)
    if data[1] == nil then return end--Make sure the event is valid

    for k,v in ipairs(PullHooks) do
        if v[1] ~= nil and v[1] == data[1] then --If the pull hook only runs against specific events
            table.insert(Threads, {v[2], data});
            PullHooks[k] = nil;
        elseif v[1] == nil then --If it runs against any event
            table.insert(Threads, {v[2], data});
            PullHooks[k] = nil;
        end
    end

    if Hooks["*"] ~= nil then --If we have any hooks that trigger on anything
        for _, v in pairs(Hooks["*"]) do
            if type(v) == "thread" then
                table.insert(Threads, {v, data}); --If they are then add them as a thread to run next cycle
            else
                table.insert(Threads, {coroutine.create(v), data}); --If they are then add them as a thread to run next cycle
            end
        end
    end

    if Hooks[data[1]] ~= nil then --If we have any hooks for this event
        for _, v in pairs(Hooks[data[1]]) do
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
        local threadData = table.remove(Threads, 1);

        if threadData ~= nil and threadData[1] ~= nil then    --Check to make sure the coroutine exists
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
                error(event);
            end
        end
    end
end

local function eventDispatch() --Event Dispatch loop - CORE, will pull all events that get thrown then send them off to where they need to go
    local data = {os.pullEventRaw()}; --Pull an event

    if data[1] == "terminate" then  --If its the terminate event
        if AllowTerminate then --Check if its allowed
            hook.stop(); --If yes stop running
        end
    else
        processEvent( data ); --Otherwise if its not wake or terminate send the event to be processed
    end
end

----------------------------------------------------------------------------------------

---Add an function that will be called on an event or "*" for all events
---@param id string Unique event ID
---@param event string The event to act on, or * for all events
---@param callback function The callback function
function hook.addHook(id, event, callback)
    for _,v in ipairs(BlockList) do
        if v == event then
            error(id .. " attempted to hook blacklisted event "..event);
        end
    end

    if Hooks[event] == nil then
        Hooks[event] = {};
    end

    if Hooks[event][id] ~= nil then
        error("Tried to add an hook that already exists "..event.." "..id);
    else
        Hooks[event][id] = callback;
    end
end

---Remove the function from the event queue
---@param id string Unique event ID
---@param event string The event to act on
function hook.removeHook(id, event)
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

---Replacement for os.pullEvent, integrates with hooks
---@param filter string A specific event to wait for
---@return any Data returned from the event
function hook.pullEvent(filter) --Replacement for os.pullEvent
    table.insert(PullHooks, {filter, coroutine.running()});
    return coroutine.yield();
end

---Add a coroutine to the thread list
---@param func function Function to execute
---@vararg any Parameters for func
function hook.addCoroutine(func, ...)
    local params = {};
    params[1] = coroutine.create(func);
    params[2] = {...};

    table.insert(Threads, params);
end

---Set if hook allows the terminate command. Can only be set before hook.start is called.
---@param setting boolean True for allow termination. Defaults to true
function hook.setAllowTerminate(setting)
    if not running then --Only allow this setting to be changed while hook is not running
        AllowTerminate = setting;
    end
end

---Set a list of events that can't be used for hooks once started. Can only be set before hook.start is called.
---@param list string[] List of blocked events
function hook.setEventBlocklist(list)
    if not running then --Only allow this setting to be changed while hook is not running
        BlockList = list;
    end
end

---Start the event dispatch queue. Will start the top level program loop
function hook.start()
    running = true;
    Overrides.pullEvent = os.pullEvent; --We will overload os.pullEvent so save the original function
    os.pullEvent = hook.pullEvent; --Overload os.pullEvent to use our pullEvent function

    while running do
        threadDispatch();
        eventDispatch();
    end

    os.pullEvent = Overrides.pullEvent;
end

---Stop the event dispatch queue. Will eventually return control of the program
function hook.stop() --Stops hook from running
    running = false;
end

----------------------------------------------------------------------------------------

return hook;