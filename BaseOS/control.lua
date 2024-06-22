
os.loadAPI("hook");
os.loadAPI("button");

local function getInput()
    
    _, h = term.getSize();
    term.setCursorPos(1, h);
    term.clearLine();
    write("<<");
    return read();
    
end

local function printResponse(text)
    _, h = term.getSize();
    term.setCursorPos(1, h-1);
    term.clearLine();
    write(">>"..text);
end

local function sendRednet(host, protocol, )

    

end

local fuelButton = {
    color=colors.blue,
    action=function()
            
        end,
    text="Fuel"
};

local treesButton = {
    color=colors.blue,
    action=testFunct,
    text="Trees"
};

local steelButton = {
    color=colors.blue,
    action=testFunct,
    text="Steel"
};

local laserButton = {
    color=colors.blue,
    action=testFunct,
    text="Laser"
};

button.addButton("testingButton", testButton);
button.addButton("testingButton2", testButton2);

button.addButton("testingButton3", testButton3);
button.addButton("testingButton4", testButton4);

hook.start();
