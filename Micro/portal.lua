local r, t = component.proxy(component.list("modem")()), component.proxy(component.list("transposer")())
r.open(2);

while true do
  e, _, a, p, _, m, l = computer.pullSignal("modem_message")
  
  if m == "dial" then
    for i = 1, t.getInventorySize(3) do
      s = t.getStackInSlot(3, i)
      if s ~= nil and s.label == l then
        t.transferItem(4, 3);
        t.transferItem(3, 4, 1, i);
        r.send(a, p, "Dialing");
      end
    end
  end
  
  if m == "close" then
    t.transferItem(4, 3);
    r.send(a, p, "Closing");
  end
  
  if m == "request" then
    d = "{"
    for i = 1, t.getInventorySize(3) do
      s = t.getStackInSlot(3, i)
      if s ~= nil then
        d = d.."['".. s.label .."']={trig=false,btn=0},"
      end
    end
    d = d:sub(1, -2);
    s = t.getStackInSlot(4, 1)
    if s ~= nil then
      d = d..",['".. s.label.."']={trig=true,btn=0}";
    end
    d = d.."}";

    r.send(a, p, d);
  end
end