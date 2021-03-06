local component = require("component");
local term = require("term");
local sides = require("sides");

local tp = component.transposer;
local timerId = -1;

--Options are -[p passive mode] [block amount, ingot amount]
local args, ops = require("shell").parse(...);

if args[1] then tp = component.proxy(args[1]); end
local block = args[2] or 1296;
local ingot = args[3] or 144;
local passive = ops.p or false;

local blockSide = sides.north;
local ingotSide = sides.south;
local smelterSide = sides.east;
local outputSide = sides.up;

local amntFluid = tp.getFluidInTank(smelterSide)[1].amount;
local dimBlocks = math.floor(amntFluid / block);
local dimIngots = math.floor((amntFluid % block) / ingot);

if not passive then
    term.clear();
    print("To Processes: "..dimBlocks.." blocks "..dimIngots.." ingots.");
end

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
        
        if not passive then
            term.setCursor(1, 2);
            term.clearLine();
            print("Processing: "..dimBlocks.." blocks, "..dimIngots.." ingots.");
            os.sleep(1);
        end
	end

	if passive then
	
		if dimBlocks > 0 or dimIngots > 0 then
			processing();
		else
			require("event").cancel(timerId);
		end
		
	else
		while dimBlocks > 0 or dimIngots > 0 do
			processing();
		end
	end
	
end

if passive then
    timerId = require("event").timer(1.5, doProcesses, math.huge);
else
    doProcesses();
end

