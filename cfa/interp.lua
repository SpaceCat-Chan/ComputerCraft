
local call_stack
local variable_values, variable_changed = {}, {}
local cfa_null
local expression_metatable
local saving_system
local run_name

local evals = {}
local function evaluate(expression)
    if expression == cfa_null then
        return nil
    end
    if type(expression) ~= "table"
    or getmetatable(expression) ~= expression_metatable then
        return expression
    end
    if rawget(expression, "id") then
        return variable_values[rawget(expression, "id")]
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
    variable_values[instruction.to.id] = evaluate(instruction.from)
    variable_changed[instruction.to.id] = true
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
    local func = variable_values[instruction.func.id]
    for arg_index, arg in ipairs(func.args) do
        variable_values[arg.id] = evaluate(instruction.args[arg_index])
        variable_changed[arg.id] = true
    end
    table.insert(call_stack, {
        instructions = func.instructions,
        result = instruction.result,
        IP = 1,
        id = func.id
    })
    return false
end

function ins.call_more(instruction, current_frame)
    local args = {}
    for _,v in ipairs(instruction.args) do
        table.insert(args, evaluate(v))
    end
    local result = instruction.func(table.unpack(args))
    variable_values[instruction.result.id] = result
    variable_changed[instruction.result.id] = true
    inc_ip(current_frame)
    saving_system.save(
        run_name,
        variable_values,
        variable_changed,
        call_stack
    )
    variable_changed = {}
    return false
end

function ins.call_less(instruction, current_frame)
    inc_ip(current_frame)
    saving_system.save(
        run_name,
        variable_values,
        variable_changed,
        call_stack
    )
    variable_changed = {}
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
        variable_values[current_frame.result.id] = return_value
        variable_changed[current_frame.result.id] = true
    end
    table.remove(call_stack, #call_stack)
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

local function init_new_interp_state(cfa, expression_metatable_, saving_system_, run_name_)
    call_stack = {{instructions = cfa.current_parse_stack[1].instructions, IP = 1, id = 1}}
    variable_values = {}
    variable_changed = {}
    cfa_null = cfa.null
    expression_metatable = expression_metatable_
    saving_system = saving_system_
    run_name = run_name_
end

local function restore_interp_state(last_save, cfa, expression_metatable_, saving_system_, run_name_)
    variable_values = last_save.variables
    variable_changed = {}
    cfa_null = cfa.null
    expression_metatable = expression_metatable_
    saving_system = saving_system_
    run_name = run_name_
    call_stack = {}
    for k,v in pairs(last_save.callstack) do
        call_stack[k] = {
            id = v.id,
            IP = v.IP,
            result = v.result,
            instructions = cfa.functions[v.id].instructions,
        }
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