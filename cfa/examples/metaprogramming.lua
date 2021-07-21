local cfa = require"cfa"

local function create_to_recursion_depth(depth, action)
    local layer = function(prev_layer, is_nil)
        if not is_nil then
            return cfa.func(function()
                return prev_layer(action(cfa.arg()))
            end)
        else
            return cfa.func(function()
                return action(cfa.arg())
            end)
        end
    end
    local current_layer
    for x = 1,depth do
        current_layer = layer(current_layer, x == 1)
    end
end

local add_one = cfa.func(function()
    return cfa.arg() + 1
end)

local add_ten = create_to_recursion_depth(10, add_one)

cfa.call_once_or_more(print, add_ten(2)) -- 12

local add_thirty = create_to_recursion_depth(3, add_ten)

cfa.call_once_or_more(print, add_thirty(2)) -- 32


cfa.run("metaprogramming_example")