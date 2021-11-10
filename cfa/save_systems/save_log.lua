local require_path = (...):match("(.-)[^%.]+$")
local serpent = require(require_path.."serpent")
---@type save_system
local save_log = {enabled = true}

local actual_system

function save_log.disable()
    save_log.enabled = false
end
function save_log.enable()
    save_log.enabled = true
end

function save_log.register_system(system)
    actual_system = system
end

function save_log.load_state(run_name)
    if save_log.enabled then
        print("Asked to load: "..run_name)
    end
    return actual_system.load_state(run_name)
end

function save_log.save(run_name, callstack)
    if save_log.enabled then
        print("Asked to save: "..run_name)
        print("with callstack:")
        for x=#callstack,1,-1 do
            print("#"..tostring(x).." function_id: "..tostring(callstack[x].id).." IP: "..tostring(callstack[x].IP))
            print("Variables:")
            for k,v in pairs(callstack.variables) do
                if type(v) == "table" and rawget(v, "args") and rawget(v, "instructions") and rawget(v, "id") then
                    print("#"..tostring(k).." function "..tostring(rawget(v, "id")))
                else
                    print("#"..tostring(k).." value: "..serpent.line(v))
                end
            end
            print("")
        end
    end
    return actual_system.save(run_name, callstack)
end

return save_log