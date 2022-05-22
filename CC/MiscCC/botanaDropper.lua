--[[
Botania controller
Expects that a mana detector is causing a redstone pulse anywhere
]]--

local TIMEOUT = 5 * 60; --5 Minutes
local POLL = 15; --Seconds
local POOL_SIDE = "back";
local EMIT_SIDE = "right";
local PULSES = 9;

---@type hook
local hook = require("hook");
local timer = -1;
local pool = peripheral.wrap(POOL_SIDE);
if not pool then return; end

local function onRedstone()
    if timer ~= -1 then
        os.cancelTimer(timer);
        timer = os.startTimer(POLL);
    end

    per = pool.getMana() / 1000000;
    term.clear();
    term.setCursorPos(1, 1);
    print("Current mana", (per * 100 .. "%"));
end

local function onTimer(_, timerId)
    if timerId == timer then
        timer = -1;

        per = pool.getMana() / 1000000;
        term.clear();
        term.setCursorPos(1, 1);
        print("Current mana", (per * 100 .. "%"));

        if per < .85 then
            for _ = 1, PULSES do
                redstone.setOutput(EMIT_SIDE, true);
                sleep(0.25);
                redstone.setOutput(EMIT_SIDE, false);
                sleep(0.25);
            end

            timer = os.startTimer(POLL);
        else
            timer = os.startTimer(TIMEOUT);
        end
    end
end

term.clear();
term.setCursorPos(1, 1);
print("Current mana", (pool.getMana() / 1000000 * 100 .. "%"));

hook.addHook("onRedstone", "redstone", onRedstone);
hook.addHook("onTimer", "timer", onTimer);
timer = os.startTimer(POLL);
hook.start();