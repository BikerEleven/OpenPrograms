local args = {...};
local depth = tonumber(args[1] or 1);

local function tryMove(direction)
	if direction == "down" then
		if turtle.detectDown() then
			turtle.digDown();
		end
		while not turtle.down() do
			turtle.digDown();
			sleep(1);
		end
	end
	
	if direction == "forward" then
		if turtle.detect() then
			turtle.dig();
		end
		while not turtle.forward() do
			turtle.dig();
			sleep(1);
		end
	end
	
	if direction == "up" then
		if turtle.detectUp() then
			turtle.digUp();
		end
		while not turtle.up() do
			turtle.digUp();
			sleep(1);
		end
	end
end

turtle.select(1);
local placeTorches = turtle.getItemCount(1) ~= 0;
local fuel = turtle.getFuelLevel();
while fuel < 90 * depth do
  if not turtle.refuel(1) then
    print("Not enough fuel");
	fuel = turtle.getFuelLevel();
	print("Need", (90 * depth) - fuel, "more units");
    return;
  end
end

--Move from center start to bottom left edge
turtle.dig();
tryMove("forward");
turtle.digUp();
turtle.digDown();
turtle.turnLeft();

for i = 1, 4 do
	turtle.dig();
	tryMove("forward");
	turtle.digUp();
	turtle.digDown();
end
turtle.turnRight();

--Start room movement
for d = 1, depth do
	local flip = true;
	for i = 1, 8 do
		for j = 1, 8 do
			if placeTorches and d == depth then -- Lighting, only on bottom floor
				if i == 2 or i == 8 then
					if j == 2 or j == 8 then
						turtle.placeDown();
					end
				end
				
				if i == 5 and j == 5 then
					turtle.placeDown();
				end
			end
		
			turtle.dig();
			tryMove("forward");
			turtle.digUp();
			turtle.digDown();
		end
		
		if flip then
			turtle.turnRight();
		else
			turtle.turnLeft();
		end
		
		turtle.dig();
		tryMove("forward");
		turtle.digUp();
		turtle.digDown();
		
		if flip then
			turtle.turnRight();
		else
			turtle.turnLeft();
		end

		flip = not flip;
		idx = 1;
	end

	for j = 1, 8 do -- Last row
		turtle.dig();
		tryMove("forward");
		turtle.digUp();
		turtle.digDown();
	end
	
	if d ~= depth then -- If we have more floors, move down
		turtle.turnRight();
		turtle.turnRight();
		tryMove("down");
		tryMove("down");
		tryMove("down");
		turtle.digDown();
	end	
end