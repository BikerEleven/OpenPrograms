local programMenu = {
    actionNames = {
        "Exit"
    },
    actions = {
        menu.closeSubMenu
    },
    parent = nil,
    access = 2,
    name = "Outfitter",
    header = {
        "Outfitter",
        "Loading outfits..."
    }
}

local function outfit(id)
    rednet.send(comp, id, "outfit");
    
    menu.closeSubMenu();
end

local function getOutfits(evt, id, mess, proto)
    
    if proto == "outfitQuery" then
                
        programMenu.actionNames = mess;
        programMenu.actions = {};
        
        for _,v in ipairs(mess) do
            table.insert(programMenu.actions, {outfit, {v}});
        end
        
        table.insert(programMenu.actionNames, "Exit");
        table.insert(programMenu.actions, menu.closeSubMenu);
        
        programMenu.header = {
            "Outfitter",
            "Select an outfit"
        };
        
        menu.updateProgramMenu(programMenu);
    elseif proto == "outfit" then
        menu.addNotification(mess);
    end

end

function start()
    menu.setProgramMenu(programMenu);
    comp = rednet.lookup("outfit", "outfiter");
    rednet.send(comp, "", "outfitQuery");
end

function ascess()
	return 2;
end

function description()
	return "Outfitter";
end

hook.addHook("Outfitter.rednet.getOutfits", "rednet_message", getOutfits);
