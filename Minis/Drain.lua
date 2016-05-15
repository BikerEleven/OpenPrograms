local component = require("component");
local term = require("term");
local sides = require("sides");

local tp = component.transposer();

local args = {...};

local block = args[1] or 1296;
local ingot = args[2] or 144;

local blockSide = sides.east;
local ingotSide = sides.west;
local smelterSide = sides.south;
local outputSide = sides.up;

local amntFluid = tp.getFluidInTank(smelterSide)[1].amount;
local dimBlocks = math.floor(amntFluid / block);
local dimIngots = math.floor(amntFluid % block);

term.clear();
print("To Processes: "..dimBlocks.." blocks "..dimIngots.." ingots.");

local function process(side, object)
    
    if tp.getStackInSlot(side, 2) ~= nil then
        tp.transferItem(side, outputSide, 1, 2);
        if object == block then
            dimBlocks = dimBlocks - 1;
        else
            dimIngots = dimIngots - 1;
        end
    else
        if tp.getFluidInTank(side)[1].amount <= 0 and dimBlocks > 0 then
            tp.transferFluid(smelterSide, blockSide, block);
        end
        if tp.getFluidInTank(side)[1].amount <= 0 and dimIngots > 0 then
            tp.transferFluid(smelterSide, ingotSide, ingot);
        end
    end
    
end

while dimBlocks > 0 or dimIngots > 0 then
    
    process(blockSide, block);
    process(ingotSide, ingot);
    
    term.setCursor(1, 2);
    term.clearLine();
    print("Processing: "..dimBlocks.." blocks, "..dimIngots.." ingots.");
    os.sleep(1);
    
end

print("Finished.");