if not rednet.isOpen() then
    rednet.open("back");
end

args = {...};

if #args == 3 then
  rednet.send(tonumber(args[1]), args[2], args[3]);
else
  rednet.broadcast(args[1], args[2]);
end
