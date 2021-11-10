
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

function basic_lua.save(run_name, callstack)
    local instruction_backup = {}
    for k,v in pairs(callstack) do
        instruction_backup[k] = v.instructions
        v.instructions = nil
    end
    local serialized = serpent.dump{callstack = callstack}
    for k,v in pairs(callstack) do
        v.instructions = instruction_backup[k]
    end
    local filename = "./"..run_name..".lua"
    local file, err = io.open(filename, "wb")
    file:write(serialized)
    file:close()
end

return basic_lua