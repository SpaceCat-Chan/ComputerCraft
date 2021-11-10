local walp = require("walp.main")
local bindings = require("walp.common_bindings.lua_impl")

local digger = walp.parse("dig_area.wasm")

digger.IMPORTS = {
    env = {
        forward = function()
            print("forward")
            local res = turtle.forward()
            if res then return 1 else return 0 end
        end,
        backward = function()
            print("backward")
            local res = turtle.back()
            if res then return 1 else return 0 end
        end,
        upwards = function()
            print("upwards")
            local res = turtle.up()
            if res then return 1 else return 0 end
        end,
        downwards = function()
            print("downwards")
            local res = turtle.down()
            if res then return 1 else return 0 end
        end,
        rotate_right = function()
            print("rotate_right")
            turtle.turnRight()
        end,
        rotate_left = function()
            print("rotate_left")
            turtle.turnLeft()
        end,
        get_fuel_level = function()
            return turtle.getFuelLevel()
        end,
        refuel = function()
            for x=1,16 do
                turtle.select(x)
                turtle.refuel()
            end
        end,
        dig_forwards = function()
            print("dig_forwards")
            turtle.dig()
        end,
        dig_up = function()
            print("dig_up")
            turtle.digUp()
        end,
        dig_down = function()
            print("dig_down")
            turtle.digDown()
        end,
    }
}

bindings(digger)

walp.instantiate(digger)

local args = {...}


digger.EXPORTS.main.call(tonumber(args[1]), tonumber(args[2]), tonumber(args[3]))