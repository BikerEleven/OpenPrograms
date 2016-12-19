local event = require("event");
local sides = require("sides");
local tp = require("component").transposer

local timerId = -1;

local args = {...};
local fluidAmount = args[2] or 8000;
local tankProvider = args[3] or sides.south;
local tankSink = args[4] or sides.up;

if args[1] then
	local tp = require("component").proxy(args[1]);
end

local function checkFluid()
  stack = tp.getFluidInTank(tankSink)[1];
  worked = true;

  if stack ~= nil and stack.amount < fluidAmmount then
    worked = tp.transferFluid(tankProvider, tankSink, fluidAmount - stack.amount);
  elseif stack == nil then
    worked = tp.transferFluid(tankProvider, tankSink, fluidAmount);
  end

  if not worked then
    event.cancel(timerId);
  end
end

timerId = event.timer(1, checkFluid, math.huge);