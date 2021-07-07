local modem = peripheral.wrap("right")
modem.open(6780)

local verify_token = "0x40 0x41 0x42"

function open_door()
    redstone.setOutput("front", true)
    sleep(10)
    redstone.setOutput("front", false)
end

while true do
    local _, _, _, sender, mesg, _ = os.pullEvent("modem_message")
    print("received message: ", mesg)
    if mesg == verify_token then
    print("opening door")
        open_door()
    end
end