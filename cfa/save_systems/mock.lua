---@class save_system
local mock = {}

function mock.load_state(run_name)
    return nil
end

function mock.save(run_name, variables, changed_variables, callstack)
end

return mock