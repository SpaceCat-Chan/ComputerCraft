local cfa = require"cfa"

local ten = cfa.var(10)
cfa.if_(ten > 5, function(cfa) 
    cfa.call(print, "ten is big")
end, function(cfa)
    cfa.call(print, "ten is small")
end)

cfa.run("if_statement_example")