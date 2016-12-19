local component = require("component");
local term = require("term");
local sides = require("sides");

local tp = component.transposer;

--Options are -[p passive mode] [block amount, ingot amount]
local args, ops = require("shell").parse(...);

if args[1] then tp = component.proxy(args[1]); end
local block = args[2] or 1296;
local ingot = args[3] or 144;
local passive = ops.p or false;

local blockSide = sides.east;
local ingotSide = sides.west;
local smelterSide = sides.south;
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
	while dimBlocks > 0 or dimIngots > 0 do
    
		process(blockSide, block);
		process(ingotSide, ingot);
		
		if not passive then
			term.setCursor(1, 2);
			term.clearLine();
			print("Processing: "..dimBlocks.." blocks, "..dimIngots.." ingots.");
			os.sleep(1);
		end
		
	end
end

if passive then
	require("event").timer(0.05, doProcesses);
end

