local cfa = require"cfa"

local ten = cfa.var(10)
local big = cfa.if_(ten > 5)
big.if_.call(print, "ten is big")
big.else_.call(print, "ten is small")

--maybe this instead?
cfa.if_(ten > 5, function(cfa) 
    cfa.call(print, "ten is big")
end, function(cfa)
    cfa.call(print, "ten is small")
end)

--[[
    i kinda like the function example, it avoids needing to name the if statement,
    and it provides better visual distinction between the if case and the else case.
    this idea could also be applied to the other control flow constructs
]]


cfa.run("if_statement_example")