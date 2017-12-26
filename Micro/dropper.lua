local r, t = component.proxy(component.list("redstone")()), component.proxy(component.list("transposer")())
local s = false;
while true do
    e, _, _, _, _, _, m = computer.pullSignal(10)
    if e == nil and s then
        t.transferItem(1, 0, 9)
    elseif e == "modem_message" then
        if m == "r_on" then
            s = true;
        elseif m == "r_off" then
            s = false;
        end
    end
end