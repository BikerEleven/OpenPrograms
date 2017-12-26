local button = require("button");
local term = require("term");
local modem = require("component").modem;
local event = require("event");
local utils = require("utils");
local serialize = require("serialization");

local green = 0x00FF00;
local red = 0xFF0000;

button.clear();
term.clear();

modem.open(3);
modem.broadcast(2, "request");
local view = {term.getViewport()};

_, _, sendAddr, port, _, message = event.pull("modem_message");

local dests = serialize.unserialize(message);

local step = 1;
local slide = 1;
local visible = true;

local function recieveMessage(_, _, sendAddr, port, _, message)
	
	if message ~= nil then
		for k,v in pairs(dests) do
			if v.trig and k ~= message then
				v.btn.color = red;
				v.trig = false;
			elseif not v.trig and k == message then
				v.btn.color = green;
				v.trig = true;
			end
		end
	else
		for k,v in pairs(dests) do
			if v.trig then
				v.btn.color = red;
				v.trig = false;
			end
		end
	end
	
	return visible;
end

event.listen("modem_message", recieveMessage);

for k,v in pairs(dests) do
  btn = button.makeButton();
  v.btn = btn;
  btn.text = k;
  btn.bounds.x = slide;
  btn.bounds.y = step;
  btn.bounds.w = 16;
  if v.trig then btn.color = green; end
  btn.onClick = function()
    modem.send(sendAddr, port, "dial", k);
    for i,j in pairs(dests) do
      if j.trig then j.btn.color = red; j.trig = false; end
    end

    v.trig = true;
    v.btn.color = green;
  end  

  button.add(btn);
  step = step + 4;
  if step > view[2] then
    step = 1;
    slide = slide + 17;
  end
end

local stop = button.makeButton();
stop.text = "Close Portal";
stop.onClick = function() 
  modem.send(sendAddr, port, "close");
  for k,v in pairs(dests) do
    if v.trig then
      v.btn.color = red;
      v.trig = false;
    end
  end
end
stop.bounds.y = step;
stop.bounds.x = slide;

button.add(stop);

step = step + 4;
if step > view[2] then
step = 1;
slide = slide + 17;
end

local back = button.makeButton();
back.text = "Back";
back.onClick = function()
  visible = false;
  button.stop();
  require("shell").execute("MainMenu");
end
back.bounds.y = step;
back.bounds.x = slide;

button.add(back);

button.run();