local tp = component.proxy(component.list("transposer")())

local block = 1296;
local ingot = 144;

local blockSide = 3;
local ingotSide = 2;
local smelterSide = 5;
local outputSide = 1;

local amntFluid = tp.getFluidInTank(smelterSide)[1].amount;
local dimBlocks = math.floor(amntFluid / block);
local dimIngots = math.floor((amntFluid % block) / ingot);

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

local function doProcesses()

	processing = function() 
        process(blockSide, block);
        process(ingotSide, ingot);
    end   

    if dimBlocks > 0 or dimIngots > 0 then
        processing();
    else
        computer.shutdown();
    end
	
end

while true do
    computer.pullSignal(1.5);
    doProcesses();
end