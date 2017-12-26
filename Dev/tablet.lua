local button = require("button");
local colors = require("colors");

local function toEle()
  ele.isEnabled = false;

  floor1 = button.makeButton();
  floor1.text = "Lower Mines";
  floor1.bounds = {1, 9, 10, 3};
  floor1.color = colors.green;

  floor2 = button.makeButton();
  floor2.text = "Upper Mines";
  floor2.bounds = {1, 5, 10, 3};
  floor2.color = colors.green;

  floor3 = button.makeButton();
  floor3.text = "Gardens";
  floor3.bounds = {1, 1, 10, 3};
  floor3.color = colors.green;

  button.add(floor1);
  button.add(floor2);
  button.add(floor3);
end

local ele = button.makeButton();
ele.text = "Elevators";
ele.color = colors.red;
ele.bounds = {x=1, y=1, w=10, h=5};
ele.onClick = toEle;

button.add(ele);
button.run();