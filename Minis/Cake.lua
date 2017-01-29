local sides = require("sides");
local component = require("component");
local robot = require("robot");
local term = require("term");

local item = component.inventory_controller;
local craft = component.crafting;

local chestSide = sides.top;

local cakeRecipe = {
    "minecraft:air", "minecraft:air", "minecraft:air", "minecraft:air",
    "minecraft:sugar", "minecraft:egg", "minecraft:sugar", "minecraft:air",
    "minecraft:wheat", "minecraft:wheat", "minecraft:wheat", "minecraft:air"
};

local function setStatus(status)
    
    term.setCursor(1, 1);
    term.clearLine();
    print(status);
    
end

local function transferItem(side, name, slot)

    tick = false;
    while not tick do
        for i = 1, item.getInventorySize(side) do
            iStack = item.getStackInSlot(side, i);
            if iStack ~= nil and iStack.name == name then
                robot.select(slot);
                tick = item.suckFromSlot(side, i, 1);
                break;
            end
        end
        if not tick then
            setStatus("Missing: "..name);
            os.sleep(5);
        end
    end
    setStatus("Baking");

end

local function craftItem(template)
    
    for i = 1, #template do
        if template[i] ~= "minecraft:air" then
            robot.select(i);
            robot.drop(chestSide);
            transferItem(chestSide, template[i], i)
        end
    end
    
    craft.craft();
    
end

term.clear();

while true do
    
    if not robot.detect() then
        
        setStatus("Baking");
        robot.turnLeft();
        robot.turnLeft();

        for i = 1, 3 do
            robot.select(i);
            item.equip();
            robot.use();
            item.equip();
        end
        
        robot.turnRight();
        robot.turnRight();
        
        craftItem(cakeRecipe);
        
        while not robot.place() do end
        
    end
    
    setStatus("waiting");
    os.sleep(1);
    
end
