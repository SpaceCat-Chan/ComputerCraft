
local require_path = (...):match("(.-)[^%.]+$")
local serpent = require (require_path.."serpent")
---@type save_system
local basic_lua = {}

function basic_lua.load_state(run_name)
    local filename = "./"..run_name..".lua"
    local file = io.open(filename, "rb")
    if file == nil then
        return nil
    end
    local serialized = file:read("*a")
    local _, deserialized = serpent.load(serialized)
    file:close()
    return deserialized
end

function basic_lua.save(run_name, variables, changed_variables, callstack)
    local id_based_callstack = {}
    for k,v in pairs(callstack) do
        id_based_callstack[k] = {
            result = v.result,
            id = v.id,
            IP = v.IP,
        }
    end
    local serialized = serpent.dump{variables = variables, callstack = id_based_callstack}
    local filename = "./"..run_name..".lua"
    local file, err = io.open(filename, "wb")
    file:write(serialized)
    file:close()
end

return basic_lua