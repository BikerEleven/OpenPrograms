local sides = require("sides");
local component = require("component");
local event = require("event");
local tp = component.transposer;

local chest = sides.down;
local me_int = sides.up;
if _G.biker11 == nil then _G.biker11 = {}; end
_G.biker11.itemTimer = -1;

local args, ops = require("shell").parse(...);
if args[1] ~= nil then tp = component.proxy(args[1]); end

local function itemDrop()
  for i = 1, tp.getInventorySize(me_int) do
    template = tp.getStackInSlot(me_int, i);
    if template ~= nil then
      for k = 1, tp.getInventorySize(chest) do
        iStack = tp.getStackInSlot(chest, k);
        if iStack ~= nil then
          if iStack.label == template.label then
            tp.transferItem(me_int, chest, template.size - iStack.size, i, k);
            i = i + 1;
          end
        end
      end 
    end
  end
end

_G.biker11.itemTimer = event.timer(60, itemDrop, math.huge);