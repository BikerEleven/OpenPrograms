Buttons = {};
Windows = {};

if not hook then
    error("The hook API is required for button to function");
end

--[[
    button = {
        color=1(orange),
        pos={x1, y1, x2, y2},
        action=[funct],
        text="clickme"
    }
]]--

local function processClicks(event, button, xpos, ypos)
    for _,v in pairs(Buttons) do
        if xpos >= v.pos[1] and ypos >= v.pos[2] and xpos <= v.pos[3] and ypos <= v.pos[4] then
            hook.addCoroutine(v.action, v);
        end
    end
end

function redrawButtons()

    term.clear();
    
    w, h = term.getSize();

    padding = 2;
    width = w/2 - padding;
    height = 3;
    
    k = 0;
    
    for _, button in pairs(Buttons) do
    
        y = 2 + ( (1 + height) * math.floor(k/2));
        
        if (k+1)%2 == 0 then
            x = padding + ((padding + width));
        else
            x = padding;
        end
        
        term.setBackgroundColor(button.color);
        
        term.setCursorPos(x, y);
        for i=1, width do write(" "); end
        term.setCursorPos(x, y+1 );
        
        strpad = math.ceil(width - button.text:len());
        write(string.rep(" ", math.ceil(strpad/2)));
        write(button.text);
        write(string.rep(" ", width - (math.ceil(strpad/2) + button.text:len())));
        
        term.setCursorPos(x, y+2 );
        for i=1, width do write(" "); end
    
        button.pos = {x, y, x+width, y+height};
        term.setBackgroundColor(colors.black);
        
        k = k + 1;
        
    end
    
end

function addButton(uid, button)
    Buttons[uid] = button;
    redrawButtons();
end

function removeButton(uid)
    Buttons[uid] = nil;
    redrawButtons();
end

function addWindow()
    table.insert(Windows, Buttons);
    Buttons = {};
end

function popWindow()
    if #Windows > 0 then
        Buttons = table.remove(Windows);
    end
end

hook.addHook("buttonAPI.clickHandel", "mouse_click", processClicks);
