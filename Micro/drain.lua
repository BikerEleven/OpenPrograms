local tp = component.proxy(component.list("transposer")())

local mblock = 1296;
local block;
local mingot = 144;
local ingot;

local blockSide = 2;
local blockSide2 = 0;
local ingotSide = 3;
local smelterSide = 5;
local outputSide = 1;

local b1 = false;
local b2 = false;
local i1 = false;
local isProcessing = false;

local fluidLookup = {{}}
fluidLookup["glass"] = {1000, 0};
fluidLookup["obsidian"] = {1000, 0};
local dimBlocks;
local dimIngots;

local function calcProcessing()
    if fluidLookup[tp.getFluidInTank(smelterSide)[1].name] ~= nil then
        block = fluidLookup[tp.getFluidInTank(smelterSide)[1].name][1];
        ingot = fluidLookup[tp.getFluidInTank(smelterSide)[1].name][2];
    else
        block = mblock;
        ingot = mingot;
    end

    local amntFluid = tp.getFluidInTank(smelterSide)[1].amount;
    dimBlocks = math.floor(amntFluid / block);
    dimIngots = math.floor((amntFluid % block) / ingot);
end

local function process(side, object)
    
    if tp.getStackInSlot(side, 2) ~= nil then
        tp.transferItem(side, outputSide, 1, 2);
        if object == block then
            dimBlocks = dimBlocks - 1;
            if side == blockSide then
                b1 = false;
            else
                b2 = false;
            end
        else
            i1 = false;
        end
    else
        if object == ingot then
            if tp.getFluidInTank(side)[1].amount <= 0 and dimIngots > 0 then
                tp.transferFluid(smelterSide, side, ingot);
                dimIngots = dimIngots - 1;
                i1 = true;
            end
        else
            if tp.getFluidInTank(side)[1].amount <= 0 and dimBlocks > 0 then
                tp.transferFluid(smelterSide, side, block);
                dimBlocks = dimBlocks - 1;
                if side == blockSide then
                    b1 = true;
                else
                    b2 = true;
                end
            end
        end
    end
    
end

local function processing() 
    process(blockSide, block);
    process(blockSide2, block);
    process(ingotSide, ingot);
end  

local function doProcesses()

    if dimBlocks > 0 or dimIngots > 0 or b1 or b2 or i1 then
        processing();
    else
        isProcessing = false;
    end
	
end

while true do
    if isProcessing then
        doProcesses();
        computer.pullSignal(1);
    else
        computer.pullSignal(5);
        calcProcessing();
        doProcesses();
        isProcessing = true;
    end
end

