local button = require("button");
local term = require("term");
local shell = require("shell");

button.clear();
term.clear();

local floor1 = button.makeButton();
floor1.text = "Elevator Menu";
floor1.onClick = function() 
  button.stop();
  shell.execute("ElevateMenu");
end
floor1.bounds.y = 1;
floor1.bounds.x = 1;
floor1.bounds.w = #floor1.text + 2;

button.add(floor1);

local floor2 = button.makeButton();
floor2.text = "Portal Menu";
floor2.onClick = function() 
  button.stop();
  shell.execute("PortalMenu");
end
floor2.bounds.y = 5;
floor2.bounds.x = 1;
floor2.bounds.w = #floor2.text + 2;

button.add(floor2);

button.run();