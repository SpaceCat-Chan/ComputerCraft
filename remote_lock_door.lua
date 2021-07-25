---@diagnostic disable: lowercase-global, undefined-field
local arg = {...}
if #arg < 1 then
    print("usage: open_time_seconds")
    return
end

local time = tonumber(arg[1])
if time == nil then
    print("usage: open_time_seconds")
    return
end

local modem = peripheral.wrap("right")
modem.open(6780)

local verify_token = "0x40 0x41 0x42"

function open_door()
    redstone.setOutput("back", true)
    sleep(time)
    redstone.setOutput("back", false)
end

while true do
    local _, _, _, sender, mesg, _ = os.pullEvent("modem_message")
    print("received message: ", mesg)
    if mesg == verify_token then
    print("opening door")
        open_door()
    end
end