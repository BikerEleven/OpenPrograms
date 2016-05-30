local Channels = {}; --Used to keep track of all open channels and their callback functions
local Waiting = {}; --Channels that are waiting for a input signal

function onSignalGet(_, id, message) --Event callback function hooked to rednet_message

    packet = nil;
    if type(message) == "string" then
        packet = textutils.unserialize(message);
    elseif type(message) == "table" then
        packet = message;
    end

    if packet == nil or type(packet) ~= "table" then return; end --If its not a table ignore it
    
    if Channels[packet[1]] ~= nil then --If we have a chanel listening for this
        hook.addCoroutine(Channels[packet[1]], id, packet[2]); --Run its callback and pass it the message
        os.queueEvent("network.waiting", packet[1]);
    else --Otherwise just ignore it
        BaseOS.log("Unchanneled message "..tostring(message));
    end

end

function requestChannel(channel, callback) --Try to reserve a channel to listen on, takes the channel and a callback function

    if callback == nil then return false; end; --Need a callback

    if Channels[channel] ~= nil then --If the channel is already taken return false
        return false;
    else
        Channels[channel] = callback; --Otherwise reserve it
    end
    
    return true; --Report a success

end

function releaseChannel(channel, callback) --This will release a reserved channel, requires the channel that was reserved and the callback used to make it

    if Channels[channel] ~= nil then
        if Channels[channel] == callback then --I require the callback to check that the this is actualy being remove by who added or, or at least whoever has access to the callback
            Channels[channel] = nil; --Release it
        end
    end
    
end

function broadcast(channel, packet) --Just do a rednet broadcast over whatever channel was supplyed

    if channel == nil or packet == nil then return false; end --Need a channel or packet to send

    Sent = false;
    if BaseOS.isRednetOpen() then --If we have rednet capabilitys 
        Sent = rednet.broadcast({channel, packet}); --Send it
    else
        return false;
    end
    
    return Sent; --Report success
end

function send(channel, id, packet) --Sends a packet to a specific computer using the channel
    
    if channel == nil or id == nil or packet == nil then return false; end
    --Channel, id, and packet can't be nil 
    Sent = false;
    if BaseOS.isRednetOpen() then --If we can send rednet messages
        Sent = rednet.send(id, {channel, packet});
    else
        return false;
    end

    return Sent; --Report Success
    
end

function waitForSignal(channel) --Used to suspend a thread and cause it to wait for a response from an external(or internal) source

    p2, p1 = coroutine.yield("network.waiting");
    
    while p1 ~= channel do
        p1 = coroutine.yield("network.waiting");
    end

end

hook.addHook("BaseOS.network.rednet_message", "rednet_message", onSignalGet); --Hook into the rednet_message event
