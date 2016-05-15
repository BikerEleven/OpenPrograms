local Channel = "None";
local Last = "";

local function updateInfo()

	menu.changeProgramMenuInfo({
        "Rednet Control", 
        "Channel: "..Channel, 
        "Last Recieved: "..Last
    });

end

function cSet()

    print("Enter Channel: ");
	newChannel = read();
    
    if network.requestChannel(newChannel, display) then
        if Channel ~= "None" then
            network.releaseChannel(Channel, display);
        end
        
        Channel = newChannel
        updateInfo();
    else
        print("Could not request channel");
        sleep(2);
    end
	
	menu.reOpenSubmenu();
end

function send()

    if Channel == "None" then
        write("You need to join a channel first");
        sleep(2);
        return 2;
    end

    write("Enter computer id or -1 to broadcast: ");
	id = read();
    print();
    write("Enter message: ");
	message = read();
    
    if tonumber(id) == -1 then
        network.broadcast(Channel, message);
    else
        network.send(Channel, tonumber(id), message);
    end
	
	menu.reOpenSubmenu();
end

function display(id, message)

    Last = message;
    updateInfo();

end

local programMenu = {
    actionNames = {
        "Set Channel", 
        "Send", 
        "Exit"
    },
    actions = {
        cSet, 
        send,
        menu.closeSubMenu
    },
    parent = nil,
    access = 2,
    name = "Rednet",
    header = {
        "Rednet Control", 
        "Channel: "..Channel, 
        "Last Recieved: "..Last
    }
};

function start()

	menu.setProgramMenu(programMenu);
		
end

function ascess()

	return 2;

end

function description()

	return "Send Rednet"

end
