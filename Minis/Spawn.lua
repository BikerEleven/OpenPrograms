local robot = require("robot");
local component = require("component");
local sides = require("sides");
local item = component.inventory_controller;
local modem = component.modem;
local db = component.database

local function move(direction, times)
	
	times = times or 1;
	
	status = false;
	for i = 1, times do
		repeat
			if direction == "forward" then
				status = robot.forward();
			end
			if direction == "up" then
				status = robot.up();
			end
			if direction == "down" then
				status = robot.down();
			end
		until status;
	end
	
end

while true do
	
	run = true;
	
	stack = item.getStackInSlot(sides.down, 1);
	if stack == nil or stack.lable ~= db.get(1).lable or stack.size < 4 then
		run = false;
	end
	
	stack = item.getStackInSlot(sides.down, 2);
	if stack == nil or stack.lable ~= db.get(2).lable or stack.size < 3  then
		run = false;
	end
	
	if run then
	
		robot.select(1);
		item.suckFromSlot(sides.down, 1, 4);
		robot.select(2);
		item.suckFromSlot(sides.down, 2, 3);

		move("forward");
		robot.turnLeft();
		move("forward", 3);
		robot.turnLeft();
		modem.broadcast(10, "shield", 15);
		os.sleep(0.5);
		move("forward", 3);
		move("up");
		
		robot.select(1);
		robot.placeDown();
		robot.place();
		robot.turnLeft();
		robot.turnLeft();
		robot.place();
		robot.turnLeft();
		robot.turnLeft();
		
		move("up");
		
		robot.select(1);
		robot.placeDown();
		robot.select(2);
		robot.place();
		robot.turnLeft();
		robot.turnLeft();
		robot.place();
		robot.turnLeft();
		robot.turnLeft();
		
		move("up");
		robot.placeDown();
		
		move("up", 2);
		modem.broadcast(10, "shield", 0);
		robot.turnLeft();
		move("forward", 3);
		robot.turnLeft();
		move("forward", 2);
		move("down", 5);
	
	end
	
	os.sleep(20);
	
end

--[[

	1f tl 3f 1l soff 3f 1u place(1d 1f 1b) 1u place(1f 1b 1d) 1u place(1d) 2u son tl 3f tl 2f 5d
	1b = (tl tl pf tl tl)

]]--