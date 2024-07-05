local robot = require("robot");
local term = require("term");
local computer = require("computer");
local event = require("event");
local sides = require("sides");
local component = require("component");
local inv = component.inventory_controller;
local delay_default = 30

local recipes = {
    Ender_Pearl = {
        Layers = {
            "Obsidian", "Obsidian", "Obsidian",
            "Obsidian", "Obsidian", "Obsidian",
            "Obsidian", "Obsidian", "Obsidian",
            --
            "Obsidian", "Obsidian", "Obsidian",
            "Obsidian", "Block of Redstone", "Obsidian",
            "Obsidian", "Obsidian", "Obsidian",
            --
            "Obsidian", "Obsidian", "Obsidian",
            "Obsidian", "Obsidian", "Obsidian",
            "Obsidian", "Obsidian", "Obsidian"
        },
        Catalyst = "Redstone",
        Delay = 15
    },

    Normal_Machine = {
        Layers = {
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Block of Gold", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
        },
        Catalyst = "Ender Pearl"
    },

    Machine_Casing = {
        Layers = {
            "Air", "Air", "Air",
            "Air", "Block of Iron", "Air",
            "Air", "Air", "Air",
            --
            "Air", "Air", "Air",
            "Air", "Redstone", "Air",
            "Air", "Air", "Air",
            --
            "Air", "Air", "Air",
            "Air", "Air", "Air",
            "Air", "Air", "Air",
        },
        Catalyst = "Redstone",
        Delay = 5
    },

    Maximum_Machine = {
        Layers = {
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Glitched Giant Machine", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Glitched Giant Machine", "Compact Machine Wall",
            "Glitched Giant Machine", "Machine Casing", "Glitched Giant Machine",
            "Compact Machine Wall", "Glitched Giant Machine", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Glitched Giant Machine", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
        },
        Catalyst = "Ender Pearl"
    },

    Giant_Machine = {
        Layers = {
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Glitched Large Machine", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Glitched Large Machine", "Compact Machine Wall",
            "Glitched Large Machine", "Machine Casing", "Glitched Large Machine",
            "Compact Machine Wall", "Glitched Large Machine", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Glitched Large Machine", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
        },
        Catalyst = "Ender Pearl"
    },

    Zombie_Egg = {
        Layers = {
            "Netherrack", "Netherrack", "Netherrack",
            "Netherrack", "Netherrack", "Netherrack",
            "Netherrack", "Netherrack", "Netherrack",
            --
            "Fire", "Fire", "Fire",
            "Fire", "Soul Sand", "Fire",
            "Fire", "Fire", "Fire",
            --
            "Air", "Air", "Air",
            "Air", "Soul Sand", "Air",
            "Air", "Air", "Air",
        },
        Catalyst = "Redstone"
    },

    Emerald_Block = {
        Layers = {
            "Slime Block", "Slime Block", "Slime Block",
            "Slime Block", "Slime Block", "Slime Block",
            "Slime Block", "Slime Block", "Slime Block",
            --
            "Slime Block", "Slime Block", "Slime Block",
            "Slime Block", "Graphite Block", "Slime Block",
            "Slime Block", "Slime Block", "Slime Block",
            --
            "Slime Block", "Slime Block", "Slime Block",
            "Slime Block", "Slime Block", "Slime Block",
            "Slime Block", "Slime Block", "Slime Block",
        },
        Catalyst = "Diamond Nugget"
    },

    Red_Mushroom = {
        Layers = {
            "Air", "Air", "Air",
            "Air", "Oak Wood", "Air",
            "Air", "Air", "Air",
            --
            "Air", "Air", "Air",
            "Air", "Oak Wood", "Air",
            "Air", "Air", "Air",
            --
            "Air", "Red Wool", "Air",
            "Red Wool", "Red Wool", "Red Wool",
            "Air", "Red Wool", "Air",
        },
        Catalyst = "Seeds"
    },

    Brown_Mushroom = {
        Layers = {
            "Air", "Air", "Air",
            "Air", "Oak Wood", "Air",
            "Air", "Air", "Air",
            --
            "Air", "Air", "Air",
            "Air", "Oak Wood", "Air",
            "Air", "Air", "Air",
            --
            "Air", "Brown Wool", "Air",
            "Brown Wool", "Brown Wool", "Brown Wool",
            "Air", "Brown Wool", "Air",
        },
        Catalyst = "Seeds"
    }
};

local costs = {}; -- {enderpearl = {obsidian = 1, redstone = 1, gold = 1}, ...}
for k, v in pairs(recipes) do
    v.Weight = 0
    costs[k] = {};

    for i = 1, #v.Layers do
        local item = v.Layers[i]
        if item ~= "Air" then
            costs[k][item] = (costs[k][item] or 0) + 1;
            v.Weight = v.Weight + 1
        end
    end

    costs[k][v.Catalyst] = (costs[k][v.Catalyst] or 0) + 1;
end

local function craft(recipe)
    local index = {};
    local slot = 1;

    local have = {};
    for i = 1, inv.getInventorySize(sides.front) do
        local item = inv.getStackInSlot(sides.front, i);

        if item ~= nil and costs[recipe][item.label] ~= nil and (have[item.label] or 0) < costs[recipe][item.label] then
            robot.select(slot);
            index[item.label] = slot;

            local count = inv.suckFromSlot(sides.front, i, costs[recipe][item.label] - (have[item.label] or 0));
            have[item.label] = (have[item.label] or 0) + count;

            if have[item.label] == costs[recipe][item.label] then slot = slot + 1; end
        end
    end

    robot.down();
    robot.forward();
    robot.turnLeft();
    robot.forward();
    robot.turnLeft();
    robot.down();
    robot.down();

    local flip = false;
    for i = 1, 27 do
        local item = recipes[recipe].Layers[i];

        if item ~= "Air" then
            robot.select(index[item]);
            robot.placeDown();
        end

        if i % 9 == 0 then
            robot.up();
            robot.turnAround();
            flip = false;
        elseif i % 3 == 0 and not flip then
            robot.turnLeft();
            robot.forward();
            robot.turnLeft();
            flip = true;
        elseif i % 3 == 0 and flip then
            robot.turnRight();
            robot.forward();
            robot.turnRight();
            flip = false;
        else
            robot.forward();
        end
    end

    robot.select(index[recipes[recipe].Catalyst]);

    robot.forward();
    robot.turnLeft();
    robot.forward();
    robot.turnRight();
    robot.up();
    robot.dropDown();
    ---@diagnostic disable-next-line: undefined-field
    os.sleep(recipes[recipe].Delay or delay_default);
    robot.down();
    robot.down();
    robot.down();
    robot.suckDown();
    robot.up();
    robot.up();
    robot.up();
    robot.drop();

    ---@diagnostic disable-next-line: undefined-field
    os.sleep(5);
end

local function checkInv()
    local have = {};
    for i = 1, inv.getInventorySize(sides.front) do
        local item = inv.getStackInSlot(sides.front, i);

        if item ~= nil then
            have[item.label] = (have[item.label] or 0) + item.size;
        end
    end

    return have;
end

local function checkRecipe()
    local have = checkInv();
    local weight = 0;
    local best = nil;

    for tag, recipe in pairs(costs) do
        local fail = false;

        if recipes[tag].Weight >= weight then
            for name, amount in pairs(recipe) do
                if have[name] == nil or have[name] < amount then
                    fail = true;
                    break;
                end
            end

            if not fail then
                weight = recipes[tag].Weight;
                best = tag;
            end
        end
    end

    return best;
end

local run = true;

while run do
    local recipe = checkRecipe();
    if recipe ~= nil then
        craft(recipe);
    end

    if event.pull(1, "interrupted") ~= nil then
        run = false;
    end
end

return { recipies = recipes, costs = costs, checkRecipe = checkRecipe, craft = craft, checkInv = checkInv };
