---@class cfa_env
local cfa = {}
cfa.next_var_id = 0
cfa.current_parse_stack = {{
    instructions = {},
    args = {},
    id = 1,
    name = "main"
}}
cfa.functions = {cfa.current_parse_stack[1]}

---@class cfa_expression
local ignore
---@class cfa_variable : cfa_expression
local ignore

local require_path = (...):match("(.-)[^%.]+$")

local expression_metatable = require(require_path.."expression_metatable")(cfa)

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

function cfa.named_var(name, init)
    local var = cfa.var_no_init(name)
    local current_frame = cfa.current_parse_stack[1]
    table.insert(current_frame.instructions, {
        type = "assign",
        to = var,
        from = init,
    })
    return var
end

---@return cfa_variable
function cfa.var_no_init(name)
    local id = cfa.next_var_id
    cfa.next_var_id = id + 1
    local var = {
        id = id,
        name = name -- only used by disassembler
    }
    setmetatable(var, expression_metatable)
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

---@param func fun():any|string
---@param func2 nil|fun():any
---@return cfa_variable
function cfa.func(func, func2)
    local func_name = (type(func) == "string") and func or nil
    local func = func2 or func
    local new_stack_frame
    new_stack_frame = {
        instructions = {},
        args = {},
        name = func_name
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
    table.insert(cfa.functions, instructions)
    instructions.id = #cfa.functions
    local func_result = cfa.named_var(func_name, instructions)
    return func_result
end

---@return cfa_variable
function cfa.arg()
    local name = #cfa.current_parse_stack[1].args + 1
    local argument = cfa.var_no_init("arg "..tostring(name))
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
local interp = require(require_path.."interp")

---@param name string
---@param save_system save_system
function cfa.run(name, save_system)
    cfa.exit(0)
    local last_save = save_system.load_state(name)
    if last_save then
        interp.restore(last_save, cfa, expression_metatable, save_system, name)
    else
        interp.init(cfa, expression_metatable, save_system, name)
    end
    interp.run()
end

cfa.disassembler = require(require_path.."disassembler")
cfa.disassembler.init(cfa.null, expression_metatable)

return cfa