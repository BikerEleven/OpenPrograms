local function checkForNotes() --Checks to see if the current user has any outstanding notes to view

	cUser, ascess = user.getLogin();
	
	if cUser == nil or ascess == nil then return false end
	
	if fs.exists(BaseOS.getLocation().."baseos/notes/"..cUser..".txt" ) then --If a notes file exists for them
		return true
	else
		return false
	end
	
end

local function syncNotesCheck(evt, editedPath)
    
    cUser, ascess = user.getLogin();
    if cUser ~= nil then
        if BaseOS.getLocation().."baseos/notes/"..cUser..".txt" == editedPath then
            menu.addNotification("You have an unread message!");
        end
    end
end

local function onLogin()
    if checkForNotes() then
        menu.addNotification("You have an unread message!");
    end
end

local function readNotes() --Start displaying the notes for them

	cUser, ascess = user.getLogin()

	notes = io.open( BaseOS.getLocation().."baseos/notes/"..cUser..".txt", "r" )
	term.clear()
	term.setCursorPos( 1,1 )
	
	while true do
		txt = notes:read()
		if txt == nil then break end
		if txt == "<|>" then --I used <|> to seperate notes, was required because newlines are allowed in notes
			print("")
			print( "type \"next\" for the next note, else type \"end\" to continue loging in." )
			txt = read();
		
			BaseOS.clearScr()
			
			if txt:lower() == "end" then break end
		else
			print( txt )
		end
	end
	
	notes:close()
	
	fs.delete( BaseOS.getLocation().."baseos/notes/"..cUser..".txt" ) --After the user has read them all delete the file
	
	print("")
	print( "End of notes. Press enter to continue." )
	
	sync.removeFile( BaseOS.getLocation().."baseos/notes/"..cUser..".txt" ) --Alert sync to update over the network
	
	read();
    menu.reOpenSubmenu();
    
    menu.changeProgramMenuInfo({
        "Notes Menu", 
        "Unread Messages: "..tostring(checkForNotes()),
    });

end

local function writeNote() --Allows users to write notes to other users

	cUser, ascess = user.getLogin()

	repeat
        BaseOS.clearScr()
	
        print( "Type exit to return to menu" )
        write( "Note is for user: " )
        tUser = read();
        
        if tUser == "exit" then
            menu.reOpenSubmenu();
            break;
        end
        
        have, ascess = user.hasUser( tUser )
        
        if not have then
            print( "Invalid user!" )
            sleep(3);
        end
        
    until have
	
	print( "Use <end> to end the note." )
    note = "";
    add = false;
    if fs.exists( BaseOS.getLocation().."baseos/notes/"..tUser..".txt" ) then
        add = true;
    end
    
    fs.makeDir(BaseOS.getLocation().."baseos/notes");
    notes = io.open( BaseOS.getLocation().."baseos/notes/"..tUser..".txt", "a" );
    
    if add then --If we are adding on to an existing notes file
        note = "<|>";
        notes:write( note );
        notes:write( "\n" ); --Add a <|> to show that this is a new note
    end
    
    while note ~= "<end>" do --While we don't hit a <end> keep writing stuffs
        
        txt = read();
        if txt == "<end>" then --Don't actualy write the <end> to the file
            break;
        end
        note = cUser..": " .. txt; --Add the users name to the note to show who its from
        
        notes:write( note );
        notes:write( "\n" );
        
    end
    
    notes:close();
    sync.addFile( BaseOS.getLocation().."baseos/notes/"..tUser..".txt" );
    
    menu.reOpenSubmenu();
    menu.changeProgramMenuInfo({
        "Notes Menu", 
        "Have message: "..tostring(checkForNotes()),
    });
    menu.addNotification("Message sent!");

end

local programMenu = {
    actionNames = {
        "Create message", 
        "Read messages", 
        "Exit"
    },
    action = {
        writeNote, 
        readNotes,
        menu.closeSubMenu
    },
    parent = nil,
    access = 3,
    name = "Notes",
    header = {
        "Notes Menu", 
        "Have Message: "..tostring(checkForNotes()),
    }
};

function start()
    programMenu[6] = {
        "Notes Menu", 
        "Have message: "..tostring(checkForNotes()),
    };
	menu.setProgramMenu(programMenu);
end

function ascess()
	return 3;
end

function description()
	return "Notes";
end

hook.addHook("BaseOS.notes.Logon", "logon", onLogin);
hook.addHook("BaseOS.notes.syncCheck", "BaseOS.sync.add", syncNotesCheck);
