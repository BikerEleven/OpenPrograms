local md, t = component.proxy(component.list("modem")()), component.proxy(component.list("transposer")())
md.open(163);
while true do
    result = table.pack(computer.pullSignal())
    if result[1] == "modem_message" then
        if result[6] == "r_drop" then
            t.transferItem(1, 0, 9)
        end
    end
end