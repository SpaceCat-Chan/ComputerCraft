---@class cfa_env
local cfa = {}
cfa.top_level = cfa
cfa.next_var_id = 0
cfa.instructions = {}

---@class cfa_variable
local ignore
---@class cfa_expression
local ignore

local function create_var_function(cfa)
    local expression_metatable
    expression_metatable = {
        __newindex = function(this, exp)
            cfa.assign(this, exp)
        end,

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

        __unm = function(this)
            local result = {
                type = "unm",
                this = this
                --TODO: eval function
            }
            setmetatable(result, expression_metatable)
            return result
        end,

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

        __eq = function(this, other)
            local result = {
                type = "eq",
                left = this,
                right = other
                --TODO: eval function
            }
            setmetatable(result, expression_metatable)
            return result
        end,

        __lt = function(this, other)
            local result = {
                type = "lt",
                left = this,
                right = other
                --TODO: eval function
            }
            setmetatable(result, expression_metatable)
            return result
        end,

        __le = function(this, other)
            local result = {
                type = "le",
                left = this,
                right = other
                --TODO: eval function
            }
            setmetatable(result, expression_metatable)
            return result
        end,
    }

    return function(init)
        local id = cfa.top_level.next_var_id
        cfa.top_level.next_var_id = id + 1
        local var = {
            id = id,
            initial = init
        }
        setmetatable(var, expression_metatable)
        return var
    end
end

local actual_var = create_var_function(cfa)

---@param init any|nil @ initial value for variable
---@return cfa_variable
function cfa.var(init)
    return actual_var(init)
end

---@param exp cfa_expression
---@param if_branch fun(cfa:cfa_env):any
---@param else_branch fun(cfa:cfa_env):any
---@return nil
function cfa.if_(exp, if_branch, else_branch)
end

---@param exp cfa_expression
---@param loop fun(cfa:cfa_env):any
---@return nil
function cfa.while_(exp, loop)
end

---@param func fun(cfa:cfa_env):any
---@return cfa_variable
function cfa.func(func)
end

---@return cfa_variable
function cfa.arg()
end

---@param func fun(...):any
---@return cfa_variable
function cfa.call_once_or_less(func, ...)
end

---@param func fun(...):any
---@return cfa_variable
function cfa.call_once_or_more(func, ...)
end

---@param var cfa_variable
---@param exp cfa_expression
function cfa.assign(var, exp)
end

cfa.null = {}

function cfa.run(name)
end

return cfa