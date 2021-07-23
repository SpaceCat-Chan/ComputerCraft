local cfa = require"cfa.cfa"

local a = cfa.var("hello,")
local b = cfa.var(" world!")

cfa.call_once_or_more(print, a..b)

local add = cfa.func(function()
    return cfa.arg() + cfa.arg()
end)

cfa.call_once_or_more(print, add(2, 2))

local number = cfa.var(0)
cfa.while_(number.lt + 10, function()
    cfa.call_once_or_more(print, number)
    number.a = number + 1
end)

local complex_function = cfa.func(function()
    cfa.if_(cfa.arg().gt + 10, function()
        return cfa.null
        -- cfa.null returns from the outer function
    end, function()
        return nil
        -- nil return is treated as the if statement not doing anything special
    end)
    cfa.call_once_or_more(print, cfa.arg())
end)

complex_function(11, "not printed")
complex_function(9, "printed")

cfa.run("basic_example", require"cfa.save_systems.mock")
