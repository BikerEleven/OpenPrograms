args = {...};
local loc;

if args and #args > 0 then
    loc = args[1];
else
    loc = "";
end

shell.setDir(loc.."baseos" );
os.loadAPI(loc.."baseos/BaseOS.lua" );
BaseOS.start(loc);
