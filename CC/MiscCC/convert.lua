local hook = require("hook");

local chest = "left";
local charger = "right";

local pchest = peripheral.wrap(chest);
local pcharger = peripheral.wrap(charger);

local function run()
    while true do
        for slot, item in pairs(pchest.list()) do
            if item.name == "appliedenergistics2:certus_quartz_crystal" then
                while item.count > 0 do
                    pcharger.pullItems(chest, slot, 1);

                    while pcharger.getItemDetail(1).name ~= "appliedenergistics2:charged_certus_quartz_crystal" do
                        os.sleep(1);
                    end

                    pcharger.pushItems(chest, 1, 1);
                    item.count = item.count - 1;
                end
            end
        end

        os.sleep(5);
    end
end

hook.addCoroutine(run);
hook.start();
