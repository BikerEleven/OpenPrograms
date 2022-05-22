function start()
    
    timeOfDay = textutils.formatTime(os.time());
    day = os.day();
    menu.addNotification("It is currently "..timeOfDay.." on the "..day.."th day.");
    menu.reOpenSubmenu();
	
end

function ascess()
	return 3;
end

function description()
	return "Display time";
end
