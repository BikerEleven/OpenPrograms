local comp = -1;

local function addOutfit()
    if comp ~= -1 then
        rednet.send(comp, {playerID=user.getLogin()}, "OutfitNewLookup");
    end
    
    menu.reOpenSubmenu();
end

local function deEquip()
    if comp ~= -1 then
        rednet.send(comp, {playerID=user.getLogin()}, "OutfitDeEquip");
    end
    
    menu.reOpenSubmenu();
end

local function outfit(id)
    rednet.send(comp, {playerID=user.getLogin(), arg=id}, "OutfitMe");
    
    menu.reOpenSubmenu();
end

local programMenu = {
    actionNames = {
        "Add Outfit",
        "DeEquip",
        "Exit"
    },
    actions = {
        addOutfit,
        deEquip,
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

local function getOutfits(evt, id, mess, proto)
    
    if proto == "OutfitResponseList" then
                
        programMenu.actionNames = mess;
        programMenu.actions = {};
        
        for _,v in ipairs(mess) do
            table.insert(programMenu.actions, {outfit, {v}});
        end
        
        table.insert(programMenu.actionNames, "Add Outfit");
        table.insert(programMenu.actions, addOutfit);
        
        table.insert(programMenu.actionNames, "DeEquip");
        table.insert(programMenu.actions, deEquip);
        
        table.insert(programMenu.actionNames, "Exit");
        table.insert(programMenu.actions, menu.closeSubMenu);
        
        programMenu.header = {
            "Outfitter",
            "Select an outfit"
        };
        
        menu.updateProgramMenu(programMenu);
    elseif proto == "OutfitResponse" then
        menu.addNotification(mess);
    end

end

function start()
    menu.setProgramMenu(programMenu);
    comp = rednet.lookup("OutfitList", "Outfitter");
    
    if comp == nil then
        comp = -1;
        menu.addNotification("Unable to find outfiter");
    else
        rednet.send(comp, {playerID=user.getLogin()}, "OutfitList");
    end
    
end

function ascess()
	return 2;
end

function description()
	return "Outfitter - IDC";
end

hook.addHook("Outfitter2.rednet.getOutfits", "rednet_message", getOutfits);
