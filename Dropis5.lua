local robot = require("robot");
local term = require("term");
local computer = require("computer");
local event = require("event");
local sides = require("sides");
local component = require("component");
local inv = component.inventory_controller;
local delay_default = 30

local recipes = {
    Normal_Machine = {
        Layers = {
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Air",
            "Air", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Air", 
            "Air", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Air",
            "Air", "Air", "Air", "Air", "Air",
            --
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Air",
            "Air", "Compact Machine Wall", "Block of Gold",        "Compact Machine Wall", "Air",
            "Air", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Air",
            "Air", "Air", "Air", "Air", "Air",
            --
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Air",
            "Air", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Air",
            "Air", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Air",
            "Air", "Air", "Air", "Air", "Air",
            --
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Air", "Air", "Air", "Air",
            --
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Air", "Air", "Air", "Air",
            "Air", "Air", "Air", "Air", "Air"
        },
        Catalyst = "Ender Pearl"
    },

    Large_Machine = {
        Layers = {
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", 
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", 
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall"
        },
        Catalyst = "Ender Pearl",
        Delay = 60
    },

    Maximum_Machine = {
        Layers = {
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", 
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "tile.contenttweaker.glitched4.name",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Air",                  "Air",                  "Air",                  "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            --
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", 
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall",
            "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall", "Compact Machine Wall"
        },
        Catalyst = "Ender Pearl",
        Delay = 60
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

local function get(label, index)
    for k, v in pairs(index[label]) do
        local item = inv.getStackInInternalSlot(k);
        if item ~= nil and item.label == label then
            return k;
        end
    end
end

local function craft(recipe)
    local index = {};
    robot.select(1);

    local have = {};
    for i = 1, inv.getInventorySize(sides.front) do
        local item = inv.getStackInSlot(sides.front, i);

        if item ~= nil and costs[recipe][item.label] ~= nil and (have[item.label] or 0) < costs[recipe][item.label] then
            local count = inv.suckFromSlot(sides.front, i, costs[recipe][item.label] - (have[item.label] or 0));
            have[item.label] = (have[item.label] or 0) + count;
        end
    end

    for i = 1, 16 do
        local item = inv.getStackInInternalSlot(i);
        if item ~= nil and item.label ~= "Air" then
            if index[item.label] == nil then
                index[item.label] = {};
                index[item.label][i] = true;
            else
                index[item.label][i] = true;
            end
        end
    end

    robot.down();
    robot.forward();
    robot.forward();
    robot.turnLeft();
    robot.forward();
    robot.forward();
    robot.turnLeft();
    robot.down();
    robot.down();
    robot.down();
    robot.down();

    local flip = false;
    for i = 1, 125 do
        local item = recipes[recipe].Layers[i];

        if item ~= "Air" then
            robot.select(get(item, index));
            robot.placeDown();
        end

        if i % 25 == 0 then
            robot.up();
            robot.turnAround();
            flip = false;
        elseif i % 5 == 0 and not flip then
            robot.turnLeft();
            robot.forward();
            robot.turnLeft();
            flip = true;
        elseif i % 5 == 0 and flip then
            robot.turnRight();
            robot.forward();
            robot.turnRight();
            flip = false;
        else
            robot.forward();
        end
    end

    robot.select(get(recipes[recipe].Catalyst, index));

    robot.forward();
    robot.forward();
    robot.turnLeft();
    robot.forward();
    robot.forward();
    robot.turnRight();
    robot.up();
    robot.dropDown();
    ---@diagnostic disable-next-line: undefined-field
    os.sleep(recipes[recipe].Delay or delay_default);
    robot.down();
    robot.down();
    robot.down();
    robot.down();
    robot.down();
    robot.suckDown();
    robot.up();
    robot.up();
    robot.up();
    robot.up();
    robot.up();
    robot.turnLeft();
    robot.drop();
    robot.turnRight();

    ---@diagnostic disable-next-line: undefined-field
    os.sleep(1);
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

return { recipies = recipes, costs = costs, checkRecipe = checkRecipe, craft = craft, checkInv = checkInv, get = get };
