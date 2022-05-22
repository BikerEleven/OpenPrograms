local tp = component.proxy(component.list("transposer")());
local charger = 1;
local chest = 0;

while true do
    if tp.getStackInSlot(charger, 1) == nil then
        tp.transferItem(chest, charger, 1);
    elseif tp.getStackInSlot(charger, 1).damage == 1 then
        for i = tp.getInventorySize(chest), tp.getInventorySize(chest), -1 do
            if t.getStackInSlot(chest, i) == nil then
                tp.transferItem(charger, chest, 1, 1, i);
            end
        end
    end
    computer.pullSignal(1);
end