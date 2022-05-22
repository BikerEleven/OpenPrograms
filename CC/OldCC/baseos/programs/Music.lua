local song = "";
local cDisk = "None";
local playing = "None";

local function updateInfo()
    
    if disk.isPresent( settings.getSetting( "drivedir" ) ) and disk.hasAudio( settings.getSetting( "drivedir" ) ) then
        cDisk = disk.getAudioTitle( settings.getSetting( "drivedir" ) );
    else
        playing = "None";
        cDisk = "None";
    end
    
    menu.changeProgramMenuInfo({
        "Music player", 
        "Current disk: "..cDisk, 
        "Currently playing: "..playing 
    });

end

local function play()

	if disk.isPresent( settings.getSetting( "drivedir" ) ) and disk.hasAudio( settings.getSetting( "drivedir" ) ) then
		song = disk.getAudioTitle( settings.getSetting( "drivedir" ) )
		disk.playAudio( settings.getSetting( "drivedir" ) )
        playing = song;
		updateInfo()
	elseif disk.isPresent( settings.getSetting( "drivedir" ) ) and not disk.hasAudio( settings.getSetting( "drivedir" ) ) then
		print("")
		print("--Needs to be a music disk--")
		sleep(2);
	else
		print("")
		print("--No disk in slot--")
		sleep(2);
	end
    
	menu.reOpenSubmenu();
end

local function stopMusic()

	playing = "None";
    song = "None";
    
    if disk.isPresent(settings.getSetting( "drivedir" )) and disk.hasAudio( settings.getSetting( "drivedir" ) ) then 
		disk.eject(settings.getSetting( "drivedir" ));
        disk.stopAudio();
    end
    
end

local function stop()

	if song == "None" then
		print("")
		print("--No song is playing--")
		sleep(2);
	else
		if disk.isPresent( settings.getSetting( "drivedir" ) ) and disk.hasAudio( settings.getSetting( "drivedir" ) ) then
			song = "None"
            playing = "None";
			disk.stopAudio()
			updateInfo()
		elseif disk.isPresent( settings.getSetting( "drivedir" ) ) and not disk.hasAudio( settings.getSetting( "drivedir" ) ) then
			print("")
			print("--Needs to be a music disk--")
			sleep(2);
		else
			print("")
			print("--No disk in slot--")
			sleep(2);
		end
	end
    
	menu.reOpenSubmenu();
end

local function eject()

	if disk.isPresent(settings.getSetting( "drivedir" )) then 
		disk.eject(settings.getSetting( "drivedir" ))
        song = "None";
        playing = "None";
	else
		print("")
		print("--No disk in slot--")
		sleep(2);
	end
    
	menu.reOpenSubmenu();
end

local function exit()
    
    hook.removeHook("BaseOS.music.UpdateDisk", "disk");
	hook.removeHook("BaseOS.music.UpdateDiskEject", "disk_eject");
    menu.closeSubMenu();
    
end

local programMenu = {
    actionNames = {
        "Play", 
        "Stop", 
        "Eject", 
        "Exit"
    },
    actions = {
        play, 
        stop, 
        eject, 
        exit
    },
    parent = nil,
    access = 3,
    name = "Music",
    header = {
        "Music player", 
        "Current disk: "..cDisk, 
        "Currently playing: "..playing 
    }
};

function start()
	hook.addHook("BaseOS.music.UpdateDisk", "disk", updateInfo)
	hook.addHook("BaseOS.music.UpdateDiskEject", "disk_eject", updateInfo)
    
	if disk.isPresent( settings.getSetting( "drivedir" ) ) and disk.hasAudio( settings.getSetting( "drivedir" ) ) then 
        cDisk = disk.getAudioTitle( settings.getSetting( "drivedir" ) ) 
    else 
        cDisk = "None" 
    end
    
	if song ~= "" then playing = song else playing = "None" end
    
    programMenu.header = {
        "Music player", 
        "Current disk: "..cDisk, 
        "Currently playing: "..playing 
    };
	
	menu.setProgramMenu(programMenu);
end

function ascess()
    if BaseOS.isMobile() then
        return nil;
    else
        return 3;
    end
end

function description()

	return "Play a disk";

end

hook.addHook("BaseOS.music.OnLogoff", "logoff", stopMusic);
