local tp = require("component").proxy("f5f1a717-a19a-4c6d-85b8-71c6d92c5444");
local comp = require("component").computer;
local sides = require("sides");
local charger = sides.south;
local chest = sides.east;

while tp.getStackInSlot(chest, 1) ~= nil or tp.getStackInSlot(charger, 1) ~= nil do
  if tp.getStackInSlot(charger, 1) == nil then
    tp.transferItem(chest, charger, 1);
  elseif tp.getStackInSlot(charger, 1).damage == 1 then
    tp.transferItem(charger, chest, 1, 1, 2);
  end

  os.sleep(0.1);
end

while tp.getStackInSlot(chest, 2) ~= nil do
  comp.beep();
  os.sleep(1);
end