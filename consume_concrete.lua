function find_powder()
    for x=1,16 do
        if turtle.getItemDetail(x).name == "minecraft:concrete_powder" then
            return x
        end
    end
    return 0
end

function consume_powder_stack(slot)
    turtle.select(slot)
    while find_powder() == slot do
        turtle.place()
        turtle.dig()
    end
end

local curr_slot = find_powder()
while curr_slot ~= 0 do
    consume_powder_stack(slot)
    curr_slot = find_powder()
end
