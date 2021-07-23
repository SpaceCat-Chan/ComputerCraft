---@class cfa_env
local cfa = {}
cfa.next_var_id = 0
cfa.current_parse_stack = {{
    instructions = {},
    args = {}
}}
cfa.variables = {}

---@class cfa_expression
local ignore
---@class cfa_variable : cfa_expression
local ignore

local eq_helper_metatable
local lt_helper_metatable
local le_helper_metatable
local gt_helper_metatable
local ge_helper_metatable

local expression_metatable
expression_metatable = {
    ---@param this cfa_variable
    ---@param exp cfa_expression
    __newindex = function(this, _, exp)
        cfa.assign(this, exp)
    end,

    __index = function(this, what)
        if what == "eq" then
            return setmetatable({this = this}, eq_helper_metatable)
        elseif what == "lt" then
            return setmetatable({this = this}, lt_helper_metatable)
        elseif what == "le" then
            return setmetatable({this = this}, le_helper_metatable)
        elseif what == "gt" then
            return setmetatable({this = this}, gt_helper_metatable)
        elseif what == "ge" then
            return setmetatable({this = this}, ge_helper_metatable)
        else
            error("unsupported index: "..tostring(what).."\ndid you mean to use .table to access the variables table? (not supported)")
        end
    end,

    ---@param this cfa_expression
    ---@param other cfa_expression
    ---@return cfa_expression
    __add = function(this, other)
        local result = {
            type = "add",
            left = this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,

    ---@param this cfa_expression
    ---@param other cfa_expression
    ---@return cfa_expression
    __sub = function(this, other)
        local result = {
            type = "sub",
            left = this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,

    ---@param this cfa_expression
    ---@param other cfa_expression
    ---@return cfa_expression
    __mul = function(this, other)
        local result = {
            type = "mul",
            left = this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,

    ---@param this cfa_expression
    ---@param other cfa_expression
    ---@return cfa_expression
    __div = function(this, other)
        local result = {
            type = "div",
            left = this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,

    ---@param this cfa_expression
    ---@return cfa_expression
    __unm = function(this)
        local result = {
            type = "unm",
            this = this
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,

    ---@param this cfa_expression
    ---@param other cfa_expression
    ---@return cfa_expression
    __mod = function(this, other)
        local result = {
            type = "mod",
            left = this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,

    ---@param this cfa_expression
    ---@param other cfa_expression
    ---@return cfa_expression
    __pow = function(this, other)
        local result = {
            type = "pow",
            left = this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,

    ---@param this cfa_expression
    ---@param other cfa_expression
    ---@return cfa_expression
    __concat = function(this, other)
        local result = {
            type = "concat",
            left = this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,

    ---@param this cfa_variable
    ---@return cfa_variable
    __call = function(this, ...)
        local result = cfa.var_no_init()
        local call = {
            type = "call",
            func = this,
            args = {...},
            result = result
        }
        table.insert(cfa.current_parse_stack[1].instructions, call)
        return result
    end,
}

lt_helper_metatable = {
    __add = function(helper, other)
        local result = {
            type = "lt",
            left = helper.this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,
}

le_helper_metatable = {
    __add = function(helper, other)
        local result = {
            type = "le",
            left = helper.this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,
}

gt_helper_metatable = {
    __add = function(helper, other)
        local result = {
            type = "gt",
            left = helper.this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,
}

ge_helper_metatable = {
    __add = function(helper, other)
        local result = {
            type = "ge",
            left = helper.this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,
}

eq_helper_metatable = {
    __add = function(helper, other)
        local result = {
            type = "eq",
            left = helper.this,
            right = other
            --TODO: eval function
        }
        setmetatable(result, expression_metatable)
        return result
    end,
}

---@param init any|nil @ initial value for variable
---@return cfa_variable
function cfa.var(init)
    local var = cfa.var_no_init()
    local current_frame = cfa.current_parse_stack[1]
    table.insert(current_frame.instructions, {
        type = "assign",
        to = var,
        from = init,
    })
    return var
end

---@return cfa_variable
function cfa.var_no_init()
    local id = cfa.next_var_id
    cfa.next_var_id = id + 1
    local var = {
        id = id
    }
    setmetatable(var, expression_metatable)
    cfa.variables[id] = var
    return var
end

---@param exp cfa_expression
---@param if_branch fun():any
---@param else_branch fun():any
---@return nil
function cfa.if_(exp, if_branch, else_branch)
    local current_frame = cfa.current_parse_stack[1]
    local instruction_count_before_if = #current_frame.instructions
    local else_start = {
        type = "jump_if_not",
        exp = exp,
        offset = 0
    }
    table.insert(current_frame.instructions, else_start)
    local result = if_branch()
    local jump_over_else = {
        type = "jump",
        offset = 0
    }
    local instruction_count_before_else = #current_frame.instructions
    if else_branch and result == nil then
        table.insert(current_frame.instructions, jump_over_else)
    elseif result ~= nil then
        table.insert(current_frame.instructions, {
            type = "function_return",
            exp = result
        })
    end
    else_start.offset = (#current_frame.instructions - instruction_count_before_if)
    if else_branch then
        local else_result = else_branch()
        if else_result ~= nil then
            table.insert(current_frame.instructions, {
                type = "function_return",
                exp = else_result
            })
        end
        if result == nil then
            jump_over_else.offset = (#current_frame.instructions - instruction_count_before_else)
        end
    end
end

---@param exp cfa_expression
---@param loop fun(cfa:cfa_env):any
---@return nil
function cfa.while_(exp, loop)
    local current_frame = cfa.current_parse_stack[1]
    local instruction_count_before_while = #current_frame.instructions
    local loop_start = {
        type = "jump_if_not",
        exp = exp,
        offset = 0
    }
    table.insert(current_frame.instructions, loop_start)
    local result = loop()
    local loop_end = {
        type = "jump",
        offset = 0,
    }
    table.insert(current_frame.instructions, loop_end)
    local amount_of_instruction = #current_frame.instructions - instruction_count_before_while
    loop_start.offset = amount_of_instruction
    loop_end.offset = -(amount_of_instruction - 1)

    if result ~= nil then
        table.insert(current_frame.instructions, {
            type = "function_return",
            exp = result
        })
    end
end

---@param func fun():any
---@return cfa_variable
function cfa.func(func)
    local new_stack_frame
    new_stack_frame = {
        instructions = {},
        args = {}
    }
    table.insert(cfa.current_parse_stack, 1, new_stack_frame)
    local result = func()
    local instructions = cfa.current_parse_stack[1]
    if result ~= nil then
        table.insert(instructions.instructions, {
            type = "function_return",
            exp = result
        })
    else
        table.insert(instructions.instructions, {
            type = "function_return",
            exp = cfa.null
        })
    end
    table.remove(cfa.current_parse_stack, 1)
    local func_result = cfa.var(instructions)
    return func_result
end

---@return cfa_variable
function cfa.arg()
    local argument = cfa.var_no_init()
    table.insert(cfa.current_parse_stack[1].args, argument)
    return argument
end

---@param func fun(...):any
function cfa.call_once_or_less(func, ...)
    table.insert(cfa.current_parse_stack[1].instructions, {
        type = "call_less",
        func = func,
        args = {...},
    })
end

---@param func fun(...):any
---@return cfa_variable
function cfa.call_once_or_more(func, ...)
    local result_variable = cfa.var_no_init()
    table.insert(cfa.current_parse_stack[1].instructions, {
        type = "call_more",
        func = func,
        args = {...},
        result = result_variable,
    })
    return result_variable
end

---@param var cfa_variable
---@param exp cfa_expression
function cfa.assign(var, exp)
    table.insert(cfa.current_parse_stack[1].instructions, {
        type = "assign",
        to = var,
        from = exp,
    })
end

function cfa.exit(exit_code)
    table.insert(cfa.current_parse_stack[1].instructions, {
        type = "exit",
        exit_code = exit_code
    })
end

cfa.null = {}

local function init_new_interp_state()
    cfa.call_stack = {{instructions = cfa.current_parse_stack[1].instructions, IP = 1}}
    cfa.variable_values = {}
    cfa.variable_changed = {}
end

local evals = {}
local function evaluate(expression)
    if expression == cfa.null then
        return nil
    end
    if type(expression) ~= "table"
    or getmetatable(expression) ~= expression_metatable then
        return expression
    end
    if rawget(expression, "id") then
        return cfa.variable_values[rawget(expression, "id")]
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
    cfa.variable_values[instruction.to.id] = evaluate(instruction.from)
    cfa.variable_changed[instruction.to.id] = true
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
    local func = cfa.variable_values[instruction.func.id]
    for arg_index, arg in ipairs(func.args) do
        cfa.variable_values[arg.id] = evaluate(instruction.args[arg_index])
        cfa.variable_changed[arg.id] = true
    end
    table.insert(cfa.call_stack, {
        instructions = func.instructions,
        result = instruction.result,
        IP = 1
    })
    return false
end

function ins.call_more(instruction, current_frame)
    local args = {}
    for k,v in ipairs(instruction.args) do
        table.insert(args, evaluate(v))
    end
    local result = instruction.func(table.unpack(args))
    cfa.variable_values[instruction.result.id] = result
    cfa.variable_changed[instruction.result.id] = true
    inc_ip(current_frame)
    cfa.saving_system.save(
        cfa.run_name,
        cfa.variable_values,
        cfa.variable_changed,
        cfa.call_stack
    )
    cfa.variable_changed = {}
    return false
end

function ins.call_less(instruction, current_frame)
    inc_ip(current_frame)
    cfa.saving_system.save(
        cfa.run_name,
        cfa.variable_values,
        cfa.variable_changed,
        cfa.call_stack
    )
    cfa.variable_changed = {}
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
        cfa.variable_values[current_frame.result.id] = return_value
        cfa.variable_changed[current_frame.result.id] = true
    end
    table.remove(cfa.call_stack, #cfa.call_stack)
    cfa.call_stack[#cfa.call_stack].IP = cfa.call_stack[#cfa.call_stack].IP + 1
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


local function run_interp()
    while true do
        local current_frame = cfa.call_stack[#cfa.call_stack]
        local current_instruction = current_frame.instructions[current_frame.IP]
        local done, exit_code = ins[current_instruction.type](current_instruction, current_frame)
        if done then
            print("Finished with code: ", exit_code)
            break
        end
    end
end

---@param name string
---@param save_system save_system
function cfa.run(name, save_system)
    cfa.exit(0)
    local last_save = save_system.load_state(name)
    if last_save then
        restore_interp_state(last_save)
    else
        init_new_interp_state()
    end
    cfa.saving_system = save_system
    cfa.run_name = name
    run_interp()
end

return cfa