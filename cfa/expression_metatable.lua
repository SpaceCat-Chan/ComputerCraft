return function(cfa)
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
    return expression_metatable    
end