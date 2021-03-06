--local JSON = require("JSON")
local JSON = {}

local x, y, z, o, dim, server

local instance = {}

function instance.override(new_x, new_y, new_z, new_o, new_dim, new_server)
	x = new_x
	y = new_y
	z = new_z
	o = new_o
	dim = new_dim
	server = new_server
end

function instance.turnLeft()
	o = o - 1
	if o < 0 then o = o + 4 end
	local result = turtle.turnLeft()
	return result
end

function instance.turnRight()
	o = o + 1
	if o > 3 then o = o - 4 end
	local result = turtle.turnRight()
	return result
end

function instance.turn_to(target_o)
    if target_o - o == 0 then
        return
    end
    if target_o - o == 1 then
        instance.turnRight()
        return
    end
    if target_o - o == 2 then
        instance.turnRight()
        instance.turnRight()
        return
    end
    if target_o - o == 3 then
        instance.turnLeft()
        return
    end
    if target_o - o == -1 then
        instance.turnLeft()
        return
    end
    if target_o - o == -2 then
        instance.turnLeft()
        instance.turnLeft()
        return
    end
    if target_o - o == -3 then
        instance.turnRight()
        return
    end
end

function instance.orientation_to_offset(_o)
	local offset_x, offset_z
	if _o == 0 then
		offset_x = 0
		offset_z = -1
	elseif _o == 1 then
		offset_x = 1
		offset_z = 0
	elseif _o == 2 then
		offset_x = 0
		offset_z = 1
	elseif _o == 3 then
		offset_x = -1
		offset_z = 0
	end
	return offset_x, offset_z
end

function instance.forward()
	local success = turtle.forward()
	if success then
		local offset_x, offset_z = instance.orientation_to_offset(o)
		x, z = x + offset_x, z + offset_z
	end
	return success
end

function instance.back()
	local success = turtle.back()
	if success then
		local offset_x, offset_z = instance.orientation_to_offset(o)
		x, z = x + -offset_x, z + -offset_z
	end
	return success
end

function instance.up()
	local success = turtle.up()
	if success then
		y = y + 1
	end
	return success
end

function instance.down()
	local success = turtle.down()
	if success then
		y = y - 1
	end
	return success
end

function instance.get()
	return x,y,z,o,dim,server
end

function instance.get_table()
	return {instance.get()}
end

return instance