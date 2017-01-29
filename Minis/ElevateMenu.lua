local button = require("button");
local term = require("term");
local modem = require("component").modem;

button.clear();
term.clear();

local floor1 = button.makeButton();
floor1.text = "Garden Level";
floor1.onClick = function() 
  modem.broadcast(123, "elevate");
end
floor1.bounds.y = 1;
floor1.bounds.x = 1;
floor1.bounds.w = #floor1.text + 2;

button.add(floor1);

local floor2 = button.makeButton();
floor2.text = "Power and Mid mining";
floor2.onClick = function() 
  modem.broadcast(122, "elevate");
end
floor2.bounds.y = 5;
floor2.bounds.x = 1;
floor2.bounds.w = #floor2.text + 2;

button.add(floor2);

local floor3 = button.makeButton();
floor3.text = "The Depths";
floor3.onClick = function() 
  modem.broadcast(121, "elevate");
end
floor3.bounds.y = 9;
floor3.bounds.x = 1;

button.add(floor3);

local back = button.makeButton();
back.text = "Back";
back.onClick = function()
  button.stop();
  require("shell").execute("MainMenu");
end
back.bounds.y = 13;
back.bounds.x = 1;
back.bounds.w = #back.text + 2;

button.add(back);

button.run();