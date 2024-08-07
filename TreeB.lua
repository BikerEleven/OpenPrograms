local sapling = 1;
local log = 2;
local fuel = 3;
local fertalizer = 4;

local robot = require("robot");
local term = require("term");
local computer = require("computer");
local sides = require("sides");
local component = require("component");
local gen = component.generator;
local inv = component.inventory_controller;

local function checkFuel()
    if ((computer.energy() / computer.maxEnergy()) < .3) then
        local slot = robot.select();
        robot.select(fuel);

        if robot.count() <= 1 then
            print("Waiting for more fuel");
            repeat
                os.sleep(1);
            until robot.count() > 1;
        end

        gen.insert(robot.count() - gen.count() - 1);
        print("Refueling .. "..((computer.energy() / computer.maxEnergy())*100).."%");
        robot.select(slot);
    end
end

local function tryMove( direction )
    checkFuel();
    if direction == "down" then
        if robot.detectDown() then
            robot.swingDown();
        end
        while not robot.down() do
            robot.swingDown();
            os.sleep(1);
        end
    end

    if direction == "forward" then
        if robot.detect() then
            robot.swing();
        end
        while not robot.forward() do
            robot.swing();
            os.sleep(1);
        end
    end

    if direction == "up" then
        if robot.detectUp() then
            robot.swingUp();
        end
        while not robot.up() do
            robot.swingUp();
            os.sleep(1);
        end
    end
end

local function plantTree()
    robot.select(sapling);

    if robot.count(sapling)  <= 1 then
        print("Waiting for more saplings");
        repeat
            os.sleep(1);
        until robot.count(sapling) > 1;
    end

    robot.place();
end

local function outputDrops()
    local slot = robot.select();

    for i=1, 16 do
        if robot.count(i) > 0 then
            robot.select(i);

            if i ~= sapling and robot.compareTo(sapling) then
                robot.transferTo(sapling, 64 - robot.count(sapling));
            end

            if i == log then
                robot.drop(robot.count(i) - 1);
            elseif i > 4 then
                robot.drop();
            end
        end
    end

    local size = inv.getInventorySize(sides.front);
    local sapItem = inv.getStackInInternalSlot(sapling);
    local fuelItem = inv.getStackInInternalSlot(fuel);
    local fertItem = inv.getStackInInternalSlot(fertalizer);

    for i=1, size do
       local item = inv.getStackInSlot(sides.front, i);
        if item ~= nil and item.label == sapItem.label then
            robot.select(sapling);
            inv.suckFromSlot(sides.front, i, 64 - robot.count(sapling));
        end

        if item ~= nil and item.label == fuelItem.label then
            robot.select(fuel);
            inv.suckFromSlot(sides.front, i, 64 - robot.count(fuel));
        end

        if item ~= nil and fertItem ~= nil and item.label == fertItem.label then
            robot.select(fertalizer);
            inv.suckFromSlot(sides.front, i, 64 - robot.count(fertalizer));
        end
    end

    robot.select(slot);
end

local function harvestTree()
    steps = 0;
    tryMove("forward");
    robot.select(log);

    while robot.compareUp() do
        tryMove( "up" );
        steps = steps + 1;
    end

    while steps >= 1 do
        tryMove( "down" );
        steps = steps - 1;
    end

    robot.suckDown();
    robot.turnAround();
    tryMove("forward");
    outputDrops();
    robot.turnAround();
    plantTree();

    robot.select(log);
end

local function fertilizeTree()
    if robot.count(fertalizer) > 1 then
        local slot = robot.select();
        robot.select(fertalizer);
        inv.equip();
        robot.use();
        inv.equip();
        robot.select(slot);
    end
end

robot.select(log);
local run = true;

while run do
    if robot.compare() then
        harvestTree();
    else
        fertilizeTree();
    end

    if event.pull(5, "interrupted") ~= nil then
        run = false;
    end
end