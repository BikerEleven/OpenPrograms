--This is a messy file and also a very OLD file, this file still contains code from the first version of BaseOS from 2012
--Only the new code has been commented

local Submenus = {{}}; --All submenus that exist
local inSubmenu = false; --If the user is currently in a submeny
local selctedMenu = {}; --The currently selected menu
local currentMenu = {{}}; --The currently opened menu?
local selectedMenuOption = 1; --The option thats selected

local notifications = {};
local noticeDisplay = false;
local noticeID = -1;

local MENU_UP_KEY = keys.w; --Key to go up, W 
local MENU_DOWN_KEY = keys.s; --Key to go down, S
local MENU_ENTER_KEY = keys.enter; --Key to enter, Enter

--This checks item to see if it is a table and contains the correct named index
local function isSubMenu( item )
	if type(item) == "table" then
        if item.actionNames ~= nil then
            return true;
        end
    end
	
    return false;
end

--Write a notification from the list
local function writeNotice()
    if noticeDisplay and #notifications > 0 then
        x, y = term.getSize();
        
        term.setCursorPos(1, y);
        term.clearLine();
        term.setCursorPos(1, y-1);
        term.clearLine();
        term.setCursorPos(1, y-2);
        term.clearLine();
        
        write(notifications[1]);
    end
end

--Every x number of seconds move to the next item in the notifcation list, or if we finished clear the screen and end
local function noticeTimer(evt, id)
    if id == noticeID then
        table.remove(notifications);
        
        if #notifications == 0 then
            noticeDisplay = false;
            x, y = term.getSize();
            
            term.setCursorPos(1, y-2);
            term.clearLine();
            term.setCursorPos(1, y-1);
            term.clearLine();
            term.setCursorPos(1, y-0);
            term.clearLine();
        else
            writeNotice();
            noticeID = os.startTimer(3);
        end
    end
end

--Start displaying notifications if we are not already
local function displayNotices()
    if #notifications > 0 and not noticeDisplay then
        noticeDisplay = true;
        writeNotice();
        noticeID = os.startTimer(3);
    end
end

local function syncUsers() --Quick little built in function that will sync the users file manualy
	BaseOS.clearScr();
	term.setCursorPos( 15,8 );
	print( "Sychronize users" );
	term.setCursorPos( 9,9 );
	print( "This will update the user list");
	term.setCursorPos( 9,10 );
	print("updated UserList" );
	term.setCursorPos( 9,11 );
	print( "type send or get to continue, or type exit" );
	
	txt = read();
	
	if txt:lower() == "send" then 
		sync.addFile("baseos/baseos/users/data.txt");
		createMenu();
		return;
	end
	
	if txt:lower() == "get" then --Get feature, don't remember if this is fully implimented yet...
		sync.getFile("baseos/baseos/users/data.txt");
		createMenu();
		return;
	end
	
	createMenu();
	return;
end

local function doLogOff()
    selctedMenu = nil;
    user.logoff();
end

local function edit() --Built in function that shutdown BaseOS and allows the user to access the computers default shell
	BaseOS.clearScr();
	term.setCursorBlink(true);
	utils.writeslowly("All threads suspending.");
	sleep(5);
	print("");
	
	utils.writeslowly("Goodbye Sir."); --Goodbye Karoline.
	sleep(2);
	
	BaseOS.clearScr();
	BaseOS.Exit();
end

--The default menus for the users
local menus = {
	root = { --Root user
		actionNames = { --Names to display
			"Sychronize users",
			"Edit",
			"Logoff"
		}, 
		actions = { --Functions to call
			syncUsers,
			edit,
			doLogOff
		},
		parent = nil, --Parent menu
		access = 1, --Access level
		name = "Root" --Access name
	},
	
	admin = {
		actionNames = { 
			"Sychronize users",
			"Logoff"
		 },
		 actions = {
			syncUsers,
			doLogOff
		},
		parent = nil,
		access = 2,
		name = "Admin"
	},
	
	client = {
		actionNames = { 
			"Logoff"
		 },
		 actions = {
			doLogOff
		},
		parent = nil,
		access = 3,
		name = "Client"
	}
};

--Gets the menu for the current access level
local function getAscessTable(Ascess)
    if Ascess == nil then
        cUser, Ascess = user.getLogin();
    end
    
	return menus[Ascess];
end

--This helps translate the access string into a number
local function getAccessNumber(Ascess)
    if Ascess == nil then
        cUser, Ascess = user.getLogin();
    end

    return menus[Ascess].access;
end

--Will redraw a submenu using the provided menu, or selectedMenu
local function redrawSubmenu(menuToDraw)
	cUser, Ascess = user.getLogin();
	if cUser == nil or Ascess == nil then 
		return;
	end

	p = 2;
	
	if menuToDraw == nil then --If menuToDraw is nill then just use the currently selected menu, used by programs to return to the user menu
		menuToDraw = selctedMenu;
	end

	BaseOS.clearScr();
    
    offset = 15;
    --If we are on a mobile computer then lower the y offset
    if BaseOS.isMobile() then
        offset = 1;
    end
    
    if menuToDraw.header == nil then --If the current menu has no header
    
        term.setCursorPos(offset, p);
        print("Welcome "..cUser);
        p = p + 1;
        term.setCursorPos(offset, p);
        print(menuToDraw.name.." menu"); --Access level name .." menu"
        
    else
        
        local size = 0; --This will draw the header
        if #menuToDraw.header > 6 then --We cap the header to 6 items
            size = 6;
        else
            size = #menuToDraw.header;
        end
        
        for i = 1, size do 
            term.setCursorPos( offset, p + (i - 1) );
            print(menuToDraw.header[i]);
        end
        p = p + (size - 1); --Need to update the x offset
        
    end
	
	for k = 1, 10 do --Only display 10 items
		i = k + math.max((selectedMenuOption - 9), 0); --Get 9 items
		term.setCursorPos(offset+2, p+k);
		
		if selectedMenuOption < 10 then
			if k == math.max(selectedMenuOption % 11, 1) then --This will figure out if our current index is selected
				write("-> "); --For whatever index is selected put a -> by its name to show its selected
			end
		else
			if k == 9 then --small work around
				write("-> ");
			end
		end
		
		if isSubMenu(menuToDraw.actions[i]) then --This shows that an option is a submenu
            if menuToDraw.actions[i].access < getAccessNumber() then
                print( "--RESTRICTED--" );
            else
                term.write( "--"..menuToDraw.actionNames[i].."--" );
            end --This writes the menu name surrounted by -- -- to denote a submenu
		else
			if menuToDraw.actionNames[i] ~= nil then
                term.write(menuToDraw.actionNames[i]);
            end --Write the programs name
		end
	end
	
	if #menuToDraw.actionNames > 10 and selectedMenuOption + 1 < #menuToDraw.actionNames then --If there are more than 9 items make the 10th a more display
		term.setCursorPos(offset+2, p+11);
		print("vv-More-vv");
	end
end

local function addSubMenu(child, parent, dir) --This will load the programs in a submenu, is recursive
	--make a sub menu
	subPlugins = fs.list( BaseOS.getLocation().."baseos/programs/"..dir );
	
	Submenus[child] = {}; --Create the menu entry
	Submenus[child].name = child;
	Submenus[child].access = 3;
	Submenus[child].parent = parent;
	Submenus[child].actions = {};
	Submenus[child].actionNames = {};
	
	for x,z in pairs( subPlugins ) do --Add the subprograms to the submenu
		if not fs.isDir( BaseOS.getLocation().."baseos/programs/"..dir.."/"..z) then
			status, err = os.loadAPI(BaseOS.getLocation().."baseos/programs/"..dir.."/"..z); --Load the program as an API
			if status then
				plugin = _G[string.gsub(z, ".lua", "")]; --Get the program from the global table
				if plugin == nil or plugin.ascess == nil or plugin.description == nil or plugin.start == nil then
					--malformed plugin or unknown program skiping
				else
					table.insert( Submenus[child].actionNames, plugin.description() );
					table.insert( Submenus[child].actions, plugin.start );
					if plugin.ascess() < Submenus[child].access then --Go with the lowest access level
						Submenus[child].access = plugin.ascess();
					end
				end
				
			else
				BaseOS.errorDump("Error loading plugin "..dir..":"..z.."\n"..err);
			end
		else
        
			addSubMenu(z, child, dir.."/"..z); --RECURSE!
			
		end
		
	end
	
	table.insert( Submenus[child].actionNames, "Exit menu"); --Add the close menu option to each submenu
	table.insert( Submenus[child].actions, closeSubMenu );
	
	if parent == nil then --If their parent is the access table
		if Submenus[child] ~= nil and Submenus[child].access ~= nil then --Set permissions
			if Submenus[child].access == 3 then --If access level three clients can use it
				table.insert( menus.client.actionNames, child );
                table.insert( menus.client.actions, Submenus[child]);
				
				table.insert( menus.admin.actionNames, child );
                table.insert( menus.admin.actions, Submenus[child]);
				
				table.insert( menus.root.actionNames, child );
                table.insert( menus.root.actions, Submenus[child]);
			elseif Submenus[child].access == 2 then --If 2 then only admin and root
				table.insert( menus.admin.actionNames, child );
                table.insert( menus.admin.actions, Submenus[child]);
				
				table.insert( menus.root.actionNames, child );
                table.insert( menus.root.actions, Submenus[child]);
			else --If one then only root can access
				table.insert( menus.root.actionNames, child );
                table.insert( menus.root.actions, Submenus[child]);
			end
		end
	else
	
		table.insert( Submenus[parent].actionNames, child);
		table.insert( Submenus[parent].actions, Submenus[child]); --passing a table designates this as a submenu
	
	end
end

local function loadPrograms() --Will load all plugins / programs
	files = fs.list(BaseOS.getLocation().."baseos/programs/");

	for k,v in pairs( files ) do
		if not fs.isDir( BaseOS.getLocation().."baseos/programs/"..v) then --If its not a directory
			--Load plugin as an api
			status, p1 = pcall(os.loadAPI, BaseOS.getLocation().."baseos/programs/"..v);
            
			if status and p1 then

				plugin = _G[string.gsub(v, ".lua", "")]; --Then grab it from the globals table
			
				if plugin ~= nil then
				
					if plugin.start == nil or plugin.ascess() == nil or plugin.description() == nil then
						--malformed plugin or unknow program skip it
					else
						if plugin.ascess() == 3 then --Clients can access
							table.insert( menus.client.actionNames, plugin.description() );
							table.insert( menus.client.actions, plugin.start );
							
							table.insert( menus.admin.actionNames, plugin.description() );
							table.insert( menus.admin.actions, plugin.start );
							
							table.insert( menus.root.actionNames, plugin.description() );
							table.insert( menus.root.actions, plugin.start );
						elseif plugin.ascess() == 2 then --Only admins and root
							table.insert( menus.admin.actionNames, plugin.description() );
							table.insert( menus.admin.actions, plugin.start );
							
							table.insert( menus.root.actionNames, plugin.description() );
							table.insert( menus.root.actions, plugin.start );
						else --Only root
							table.insert( menus.root.actionNames, plugin.description() );
							table.insert( menus.root.actions, plugin.start );
						end
					end
				end
			else
				BaseOS.log("Error loading plugin "..tostring(v).."\n"..tostring(status)..tostring(p1));
			end
			
		else --Otherwise delve into the folder
			
			addSubMenu(v, nil, v); --Start a recursive function.
			
		end
	end

end

function reOpenSubmenu() --Used by programs to return to the user menu

	redrawSubmenu();
    os.queueEvent("BaseOS.Menu.Redraw", selctedMenu.name);
	hook.addHook("BaseOS.menu.EvalInput", "key", evalInput );

end

function closeSubMenu() --Closes a submenu and returns to parent menu or the access tables if there is no parent

	if selctedMenu.parent == nil then
		selctedMenu = getAscessTable();
	else
		selctedMenu = selctedMenu.parent;
	end
	selectedMenuOption = 1;
	redrawSubmenu();
	os.queueEvent("BaseOS.Menu.Redraw", selctedMenu.name);
	hook.addHook("BaseOS.menu.EvalInput", "key", evalInput );
	
end

function getCurrentMenu()

    return selctedMenu.name;

end

function createAccessMenu() --Creates a top level menu, aka access tables

	cUser, Ascess = user.getLogin();
	selctedMenu = getAscessTable(Ascess);
    selectedMenuOption = 1;
    redrawSubmenu();
	
	hook.addHook("BaseOS.menu.EvalInput", "key", evalInput );
	
end

function evalInput(evt, key) --Event callback function, hooks char event used to capture menu input

    if selctedMenu == nil then 
        BaseOS.log("invalid menu");
        hook.removeHook("BaseOS.menu.EvalInput", "key"); 
        return; 
    end
    
    BaseOS.log("[Menu] Asked to do an eval", selctedMenu.name, key);
        
	if key == MENU_UP_KEY or key == MENU_DOWN_KEY or key == MENU_ENTER_KEY then --If they hit one of our command keys
		
        if key ~= MENU_ENTER_KEY then --If its not enter
            
            if key == MENU_DOWN_KEY and selectedMenuOption < #selctedMenu.actionNames then
                selectedMenuOption = selectedMenuOption + 1; --If down_key then go down the menu
                redrawSubmenu();
            end
                
            if key == MENU_UP_KEY and selectedMenuOption > 1 then --Otherwise go up the menu
                selectedMenuOption = selectedMenuOption - 1;
                redrawSubmenu();
            end
            
        else --Enter
            
			if isSubMenu(selctedMenu.actions[selectedMenuOption]) then --Enter a submenu
                if selctedMenu.actions[selectedMenuOption].access < getAccessNumber() then
                    --Restricted
                else
                    selctedMenu = selctedMenu.actions[selectedMenuOption];
                    selectedMenuOption = 1;
                    redrawSubmenu();
                    os.queueEvent("BaseOS.Menu.Redraw", selctedMenu.name);
                end
			else --Execute a function
                hook.removeHook("BaseOS.menu.EvalInput", "key");  --Need to dehook the event
            
				if selctedMenu ~= nil and selctedMenu.actions ~= nil and selctedMenu.actions[selectedMenuOption] ~= nil then
                    if type(selctedMenu.actions[selectedMenuOption]) == "table" then --If it's a table there a function and params
                        plist = selctedMenu.actions[selectedMenuOption]; --{function, {params}}
                        hook.addCoroutine(plist[1], unpack(plist[2]));
                    else
                        hook.addCoroutine(selctedMenu.actions[selectedMenuOption]);
                    end
				else
					error("Failed to add?!? corutine "..selectedMenuOption.." "..tostring(selctedMenu.actions[selectedMenuOption]));
				end
			end
            
        end
        
	end
        
end

--This is for programs to create their own menus
function setProgramMenu(newMenu)

    newMenu.parent = selctedMenu; --Add whatever menu we where just on as the programs parent
    selctedMenu = newMenu; --Then switch to this as the current menu
    selectedMenuOption = 1;
    BaseOS.log("Making a program menu", newMenu.name);
    hook.addHook("BaseOS.menu.EvalInput", "key", evalInput )
    redrawSubmenu(); --Draw the new menu

end

--This does the same as above, however it correctly handles seting the parent
function updateProgramMenu(newMenu)
    newMenu.parent = selctedMenu.parent;
    selctedMenu = newMenu;
    selectedMenuOption = 1;
    BaseOS.log("Updating a program menu", newMenu.name);
    redrawSubmenu();
end

--This only updates the header portion of the menu
function changeProgramMenuInfo(newInfo)
	selctedMenu.header = newInfo;
    redrawSubmenu();
end

--This will add a notification to be displayed to the user eventually.
function addNotification(notice)
    table.insert(notifications, notice);
    os.queueEvent("BaseOS.menu.haveNotice");
end

hook.addCoroutine(loadPrograms); --Tell hook to load the programs whenever we have the processing time
hook.addHook("BaseOS.menu.Logon", "logon", createAccessMenu);
hook.addHook("BaseOS.menu.NoticeDisplay", "BaseOS.menu.haveNotice", displayNotices);
hook.addHook("BaseOS.menu.NoticeTimer", "timer", noticeTimer);
hook.addHook("BaseOS.menu.NoticeClear", "BaseOS.clearScreen", writeNotice);

function generateMenu()
    
    local MENU = {
        
        name = "NoName",
        header = {},
        actions = {},
        actionNames = {},
        parent = nil,
        isOrdered = true,
        
        addItem = function(actionName, action)
            if isOrdered then
                pos, nex = utils.find(actionNames, actionName);
                table.insert(actionNames, nex, actionName);
                table.insert(actions, nex, action);
            else
                table.insert(actionNames, actionName);
                table.insert(actions, action);
            end
        end,
        removeItem = function(item)
            if isOrdered then
                pos = utils.find(actionNames, item);
                table.remove(actionNames, pos);
                table.remove(actions, pos);
            else
                for k,v in ipairs(actionNames) do
                    if v == item then
                        table.remove(actionNames, k);
                        table.remove(actions, k);
                    end
                end
            end
        end,
        
    };
    
end
