local cfa = require"cfa.cfa"

cfa.call_once_or_more(io.write, "hi there, please enter some text: ")
local result = cfa.call_once_or_more(io.read)
cfa.call_once_or_more(io.write, "ignore this one: ")
cfa.call_once_or_more(io.read)
cfa.call_once_or_more(print, "you wrote: "..result)

local logger = require("cfa.save_systems.save_log")

logger.register_system(require"cfa.save_systems.basic_lua")
logger.disable()

cfa.run("basic_example", logger)