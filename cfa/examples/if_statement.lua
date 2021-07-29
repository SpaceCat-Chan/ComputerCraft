package.path = "../../?.lua"..package.path

local cfa = require"cfa.cfa"

local ten = cfa.var(10)
cfa.if_(ten.gt + 5, function() 
    cfa.call_once_or_more(print, "ten is big")
end, function()
    cfa.call_once_or_more(print, "ten is small")
end)

cfa.run("if_statement_example", require"cfa.save_systems.mock")

