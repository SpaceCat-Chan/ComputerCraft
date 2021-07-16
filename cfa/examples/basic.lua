local cfa = require"cfa"

local a = cfa.var("hello,")
local b = cfa.var(" world!")

cfa.call(print, a..b)

local add = cfa.func("add_numbers")
local first = add.arg()
local second = add.arg()
local result = first + second
add.result(result)

cfa.call(print, add(2, 2))

local number = cfa.var(0)
local while_not_10 = cfa.while_(number < cfa.var(10))
while_not_10.call(print, number)
while_not_10.assign(number, number + 1)

cfa.run("basic_example")

