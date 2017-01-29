local button = {};
local buttons = {};
local comp = require("computer");
local term = require("term");
local gpu = require("component").gpu;
local run = false;

local function checkForClick(x, y)
  for _, v in pairs(buttons) do
    if v.isEnabled then
		b = v.bounds;
		if x >= b.x and x < (b.x + b.w) then
		  if y >= b.y and y < (b.y + b.h) then
			comp.pushSignal("button_click", v.id);
		  end
		end
	end
  end
end

local function onClick(evt, id)
  
  if buttons[id] ~= nil then
    btn = buttons[id];

    if btn.isToggle then

      if btn.state then --If it is already active
        assert(btn.onUp, "Invalid button function, onUp")();
      else --It was not active
        assert(btn.onDown, "Invalid button function, onDown")();
      end
      btn.state = not btn.state; --Toggle state

    else
      assert(btn.onClick, "Invalid button function, onClick")();
    end
  end

  return true;
end

require("event").listen("button_click", onClick);

----------------------------------------------------------------------------------------

function button.makeButton()
  uuid = require("uuid").next();
  btn = {
    id = uuid,
    text = "New Button",
    isEnabled = false,
    isToggle = false,
    state = false,
    onClick = function() end,
    onDown = function() end,
    onUp = function() end,
    onHover = nil,
    bounds = {x=1, y=1, w=12, h=3},
    color = 0xFF0000,
	dcolor = 0x000000,
    click = function() comp.pushSignal("button_click", uuid); end,
  };

  return btn;
end

function button.add(btn)
  checkArg(1, btn, "table");
  buttons[btn.id] = btn;
  btn.isEnabled = true;
end

function button.remove(btn)
  checkArg(1, btn, "table");
  buttons[btn.id] = nil;
  btn.isEnabled = false;
end

function button.paint()
  background = gpu.getBackground();
  for _, btn in pairs(buttons) do
    if btn.isEnabled then
      b = btn.bounds;
      gpu.setBackground(btn.color);
      gpu.fill(b.x, b.y, b.w, b.h, " ");

      term.setCursor(b.x + ((b.w/2) - (#btn.text/2)), b.y + (b.h/2));
      term.write(btn.text);

    end
  end
  gpu.setBackground(background);
end

function button.dePaint()
	background = gpu.getBackground();
	
	for _, btn in pairs(buttons) do
		b = btn.bounds;
		gpu.setBackground(btn.dcolor);
		gpu.fill(b.x, b.y, b.w, b.h, " ");
	end
	
	gpu.setBackground(background);
end

function button.run()
  run = true;
  
  while run do 
	button.dePaint();
    button.paint();
    evt, _, x, y = require("event").pull(0.1, "touch");
    if evt then
       checkForClick(x, y);
    end
  end
  
  button.dePaint();
end

function button.stop()
  run = false;
end

function button.clear()
  
  for k,v in pairs(buttons) do
    v.isEnabled = false;
    buttons[k] = nil;
  end

end

--button.buttons = buttons;

-------------------------------------------------------------------------

return button;