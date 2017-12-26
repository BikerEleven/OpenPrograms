local r, m = component.proxy(component.list("redstone")()), component.proxy(component.list("modem")())
m.open(10)
while true do
e, _, _, _, _, m, a = computer.pullSignal()
if e == "modem_message" and m == "shield" then
r.setOutput(0, a)
end
end