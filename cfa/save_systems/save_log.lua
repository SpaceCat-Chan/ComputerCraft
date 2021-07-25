local require_path = (...):match("(.-)[^%.]+$")
local serpent = require(require_path.."serpent")
---@class save_system
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

function save_log.save(run_name, variables, changed_variables, callstack)
    if save_log.enabled then
        print("Asked to save: "..run_name)
        print("with callstack:")
        for x=#callstack,1,-1 do
            print("#"..tostring(x).." function_id: "..tostring(callstack[x].id).." IP: "..tostring(callstack[x].IP))
        end
        print("variables: ")
        local largest_index = 0
        for k,_ in pairs(variables) do
            largest_index = math.max(k, largest_index)
        end
        for x=0,largest_index do
            local v = variables[x]
            if type(v) == "table" and rawget(v, "args") and rawget(v, "instructions") and rawget(v, "id") then
                print("#"..tostring(x).." function "..tostring(rawget(v, "id")))
            else
                print("#"..tostring(x).." value: "..serpent.line(v))
            end
        end
    end
    return actual_system.save(run_name, variables, changed_variables, callstack)
end

return save_log