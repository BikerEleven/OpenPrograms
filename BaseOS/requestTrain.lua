args = {...}
if not rednet.isOpen() then
  rednet.open("back");
end

rednet.broadcast(args[1], "requestTrain");
id, mess = rednet.receive("requestTrain");
print(mess);
