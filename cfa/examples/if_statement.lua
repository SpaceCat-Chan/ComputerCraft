local cfa = require"cfa"

local ten = cfa.var(10)
cfa.if_(ten > 5, function() 
    cfa.call_once_or_more(print, "ten is big")
end, function()
    cfa.call_once_or_more(print, "ten is small")
end)

cfa.run("if_statement_example")