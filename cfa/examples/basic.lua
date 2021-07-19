local cfa = require"cfa"

local a = cfa.var("hello,")
local b = cfa.var(" world!")

cfa.call(print, a..b)

local add = cfa.func(function(cfa)
    return cfa.arg() + cfa.arg()
end)

cfa.call(print, add(2, 2))

local number = cfa.var(0)
cfa.while_(number < 10, function(cfa)
    cfa.call(print, number)
    number.a = number + 1
end)

local complex_function = cfa.func(function(cfa)
    cfa.if_(cfa.arg() > 10, function(cfa)
        return cfa.null
        -- cfa.null returns from the outer function
    end, function(cfa)
        -- nil return is treated as the if statement not doing anything special
        return nil
    end)
    cfa.call(print, cfa.arg())
end)

complex_function(11, "not printed")
complex_function(9, "printed")

cfa.run("basic_example")
