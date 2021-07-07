local modems = {peripheral.find("modem")}
local modem = modems[1]
if modem then
    print("found modem")
    modem.transmit(6780, 6781, "0x40 0x41 0x42")
else
    print("did not find modem")
end
