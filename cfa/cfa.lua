---@class cfa_env
local cfa = {}
cfa.next_var_id = 0
cfa.instructions = {}
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
        type = "init_variable",
        var = var,
        init = init,
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

cfa.null = {}

function cfa.run(name)
end

return cfa