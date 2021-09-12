package.path = "../../?.lua;"..package.path

local cfa = require"cfa.cfa"

local make_func = cfa.func("closure maker", function()
    local value = cfa.named_var("counter", 0)
    return cfa.func("inc_and_print", function() 
        value.a = value + 1
        cfa.call_once_or_more(print, value)
    end)
end)

local inner_func = make_func()
inner_func()
inner_func()
inner_func()

cfa.run("if_statement_example", require"cfa.save_systems.mock")

