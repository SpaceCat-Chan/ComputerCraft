
local call_stack
local cfa_null
local expression_metatable
local saving_system
local run_name
local func_private

local function find_variable(var)
    local current_frame = call_stack[#call_stack]
    local variables = current_frame.variables
    local difference = current_frame.func_depth - rawget(var, "func_depth")
    while difference > 0 do
        variables = variables.parent
        difference = difference - 1
    end
    return variables[rawget(var, "id")]
end

local function assign_to_variable(var, value)
    local current_frame = call_stack[#call_stack]
    local variables = current_frame.variables
    local difference = current_frame.func_depth - rawget(var, "func_depth")
    while difference > 0 do
        variables = variables.parent
        difference = difference - 1
    end
    variables[rawget(var, "id")] = value
end

local evals = {}
local function evaluate(expression)
    if expression == cfa_null then
        return nil
    end
    if type(expression) ~= "table"
    or getmetatable(expression) ~= expression_metatable then
        if type(expression) == "table" and expression.is_function == func_private then
            local new_func = {
                instructions = expression.instructions,
                args = expression.args,
                name = expression.name,
                func_depth = expression.func_depth,
                id = expression.id,
                parent = call_stack[#call_stack].variables,
                is_function = func_private,
            }
            return new_func
        end
        return expression
    end
    if rawget(expression, "id") then
        return find_variable(expression)
    end
    return evals[rawget(expression, "type")](expression)
end
local eval_id = function(eval)
    local serpent = require"cfa.save_systems.serpent" -- not stable path
    print(serpent.block(eval))
    return nil
end
setmetatable(evals, {
    __index = function(_, type)
        print("unknown eval type: "..type)
        return eval_id
    end
})

function evals.gt(eval)
    return evaluate(rawget(eval, "left")) > evaluate(rawget(eval, "right"))
end
function evals.lt(eval)
    return evaluate(rawget(eval, "left")) < evaluate(rawget(eval, "right"))
end
function evals.ge(eval)
    return evaluate(rawget(eval, "left")) >= evaluate(rawget(eval, "right"))
end
function evals.le(eval)
    return evaluate(rawget(eval, "left")) <= evaluate(rawget(eval, "right"))
end
function evals.eq(eval)
    return evaluate(rawget(eval, "left")) == evaluate(rawget(eval, "right"))
end
function evals.add(eval)
    return evaluate(rawget(eval, "left")) + evaluate(rawget(eval, "right"))
end
function evals.sub(eval)
    return evaluate(rawget(eval, "left")) - evaluate(rawget(eval, "right"))
end
function evals.mul(eval)
    return evaluate(rawget(eval, "left")) * evaluate(rawget(eval, "right"))
end
function evals.div(eval)
    return evaluate(rawget(eval, "left")) / evaluate(rawget(eval, "right"))
end
function evals.mod(eval)
    return evaluate(rawget(eval, "left")) % evaluate(rawget(eval, "right"))
end
function evals.concat(eval)
    return evaluate(rawget(eval, "left"))..evaluate(rawget(eval, "right"))
end
function evals.unm(eval)
    return -evaluate(rawget(eval, "this"))
end


local function inc_ip(a)
    a.IP = a.IP + 1
end

local ins = {}
function ins.assign(instruction, current_frame)
    assign_to_variable(instruction.to, evaluate(instruction.from))
    inc_ip(current_frame)
    return false
end

function ins.jump(instruction, current_frame)
    current_frame.IP = current_frame.IP + instruction.offset
    return false
end

function ins.jump_if(instruction, current_frame)
    if evaluate(ins.exp) then
        current_frame.IP = current_frame.IP + instruction.offset
    else
        inc_ip(current_frame)
    end
    return false
end

function ins.jump_if_not(instruction, current_frame)
    if not evaluate(instruction.exp) then
        current_frame.IP = current_frame.IP + instruction.offset
    else
        inc_ip(current_frame)
    end
    return false
end

function ins.exit(instruction, current_frame)
    return true, evaluate(instruction.exit_code)
end

function ins.call(instruction, current_frame)
    local func = find_variable(instruction.func)
    local frame = {
        instructions = func.instructions,
        result = instruction.result,
        IP = 1,
        id = func.id,
        func_depth = func.func_depth,
        variables = {parent = func.parent},
    }
    local args = {}
    for arg_index, _ in ipairs(func.args) do
        args[arg_index] = evaluate(instruction.args[arg_index])
    end
    table.insert(call_stack, frame)
    for arg_index, arg in ipairs(func.args) do
        assign_to_variable(arg, args[arg_index])
    end
    return false
end

function ins.call_more(instruction, current_frame)
    local args = {}
    for _,v in ipairs(instruction.args) do
        table.insert(args, evaluate(v))
    end
    local result = instruction.func(table.unpack(args))
    assign_to_variable(instruction.result, result)
    inc_ip(current_frame)
    saving_system.save(
        run_name,
        call_stack
    )
    return false
end

function ins.call_less(instruction, current_frame)
    inc_ip(current_frame)
    saving_system.save(
        run_name,
        call_stack
    )
    local args = {}
    for k,v in ipairs(instruction.args) do
        table.insert(args, evaluate(v))
    end
    ins.func(table.unpack(args))
    return false
end

function ins.function_return(instruction, current_frame)
    if current_frame.result then
        local return_value = evaluate(instruction.exp)
        table.remove(call_stack, #call_stack)
        assign_to_variable(current_frame.result, return_value)
    else
        table.remove(call_stack, #call_stack)
    end
    call_stack[#call_stack].IP = call_stack[#call_stack].IP + 1
    return false
end

local id = function(i, current_frame)
    local serpent = require"cfa.save_systems.serpent" -- not stable path
    print(serpent.block(i))
    current_frame.IP = current_frame.IP + 1
end
setmetatable(ins, {
    __index = function(_, type)
        print("unknown instruction type: "..type)
        return id
    end
})

local function init_new_interp_state(cfa, expression_metatable_, saving_system_, run_name_, func_private_)
    call_stack = {
        {
            instructions = cfa.current_parse_stack[1].instructions,
            IP = 1,
            id = 1,
            variables = {},
            func_depth = 1
        }
    }
    cfa_null = cfa.null
    expression_metatable = expression_metatable_
    saving_system = saving_system_
    run_name = run_name_
    func_private = func_private_
end

local function restore_interp_state(last_save, cfa, expression_metatable_, saving_system_, run_name_, func_private_)
    cfa_null = cfa.null
    expression_metatable = expression_metatable_
    saving_system = saving_system_
    run_name = run_name_
    call_stack = last_save.callstack
    func_private = func_private_
    for _,v in pairs(call_stack) do
        v.instructions = cfa.current_parse_stack[v.id].instructions
    end
end

local function run_interp()
    while true do
        local current_frame = call_stack[#call_stack]
        local current_instruction = current_frame.instructions[current_frame.IP]
        local done, exit_code = ins[current_instruction.type](current_instruction, current_frame)
        if done then
            print("Finished with code: ", exit_code)
            break
        end
    end
end

return {run = run_interp, init=init_new_interp_state, restore=restore_interp_state}