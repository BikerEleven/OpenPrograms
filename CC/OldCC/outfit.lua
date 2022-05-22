args = {...};

if not rednet.isOpen() then
  rednet.open("back");
end

comp = rednet.lookup("outfit", "outfiter");

rednet.send(comp, "true", "outfitQuery");
id, list = rednet.receive("outfitQuery", 5);
if list ~= nil then
  
end

rednet.send(comp, args[2], args[1]);

id, mess = rednet.receive(args[1]);
print(mess);
 
