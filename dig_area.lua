local position = require("position")

local arg = {...}
if #arg < 3 then
    print("Usage: x y z 1")
    return
end
local x, y, z = tonumber(arg[1]), tonumber(arg[2]) tonumber(arg[3])
if x == nil or y == nil or z == nil then
    print(arg[0], arg[1], arg[2], arg[3], arg[4])
    print("Usage: x y z 2")
    return
end

if x == 0 or y == 0 or z == 0 then
    return
end
x, y, z = x - 1, y - 1, z - 1

local invert_x, invert_y, invert_z = x < 1, y < 1, z < 1

local plus_x, minus_x, plus_y, minus_y, plus_z, minus_z = 1, 3, position.up, position.down, 2, 0
if invert_x then
    plus_x, minus_x = minus_x, plus_x
end
if invert_y then
    plus_y, minus_y = minus_y, plus_y
end
if invert_z then
    plus_z, minus_z = minus_z, plus_z
end

position.override(0, 1, 1, 1, "", "")


function dig_x_line()
    position.turn_to(plus_x)
    while position.get_table()[1] ~= x do
        turtle.dig()
        position.forward()
    end
    position.turn_to(minus_x)
    while position.get_table()[1] ~= 1 do
        turtle.dig()
        position.forward()
    end
end

function dig_z_area()
    local next_z
    if not invert_z then
        next_z = 2
    else
        next_z = 0
    end
    while position.get_table()[3] ~= z do
        dig_x_line()
        position.turn_to(plus_z)
        while position.get_table()[3] ~= next_z do
            turtle.dig()
            position.forward()
        end
        if not invert_z then
            next_z = next_z + 1
        else
            next_z = next_z - 1
        end
    end
    position.turn_to(minus_z)
    while position.get_table()[3] ~= 1 do
        turtle.dig()
        turtle.forward()
    end
end

function dig_y_volume()
    local next_y
    if y < 1 then
        next_y = 2
    else
        next_y = 0
    end
    while position.get_table()[2] ~= y do
        dig_z_area()
        while position.get_table()[2] ~= next_y do
            if y < 1 then
                turtle.digDown()
            else
                turtle.digUp()
            end
            plus_y()
        end
        if y < 1 then
            next_y = next_y + 1
        else
            next_y = next_y - 1
        end
    end
    while position.get_table()[2] ~= 1 do
        if y < 1 then
            turtle.digUp()
        else
            turtle.digDown()
        end
        minus_y()
    end
end

while position.get_table()[1] ~= 1 do
    turtle.dig()
    position.forward()
end
dig_y_volume()
position.turn_to(plus_x)
position.back()
