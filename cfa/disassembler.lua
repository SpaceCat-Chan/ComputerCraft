local disassembler = {}

local cfa_null
local expression_metatable

local require_path = (...):match("(.-)[^%.]+$")
local serpent = require(require_path.."save_systems.serpent")

local exp_formats = {}
setmetatable(exp_formats, {
    __index = function(_, name)
        return function()
            return "(unrecognized expression type "..tostring(name)..")"
        end
    end
})

function two_arg_exp_maker(op)
    return function(exp)
        return disassembler.format_expression(rawget(exp, "left"))
             ..op
             ..disassembler.format_expression(rawget(exp, "right"))
    end
end

exp_formats.add = two_arg_exp_maker" + "
exp_formats.sub = two_arg_exp_maker" - "
exp_formats.mul = two_arg_exp_maker" * "
exp_formats.div = two_arg_exp_maker" / "
exp_formats.mod = two_arg_exp_maker" % "
exp_formats.eq = two_arg_exp_maker" == "
exp_formats.gt = two_arg_exp_maker" > "
exp_formats.lt = two_arg_exp_maker" < "
exp_formats.ge = two_arg_exp_maker" >= "
exp_formats.le = two_arg_exp_maker" <= "
exp_formats.concat = two_arg_exp_maker".."

function exp_formats.unm(exp)
    return "-"..disassembler.format_expression(rawget(exp, "this"))
end

function disassembler.format_expression(exp)
    if exp == cfa_null then
        return "nil"
    end
    if type(exp) ~= "table" then
        if type(exp) == "string" then
            return "\""..exp.."\""
        else
            return tostring(exp)
        end
    end
    if getmetatable(exp) ~= expression_metatable then
        if rawget(exp, "instructions") and rawget(exp, "args") and rawget(exp, "id") then
            local name
            if rawget(exp, "name") then
                name = tostring(rawget(exp, "name"))
            else
                name = tostring(rawget(exp, "id"))
            end
            return "{function "..name.."}"
        else
            return tostring(exp)
        end
    end
    if rawget(exp, "id") then
        local name
        if rawget(exp, "name") then
            name = tostring(rawget(exp, "name"))
        else
            name = tostring(rawget(exp, "id"))
        end
        return "{"..name.."}"
    else
        return "("..exp_formats[rawget(exp, "type")](exp)..")"
    end
end

local instruction_formats = {}
setmetatable(instruction_formats, {
    __index = function(_, name)
        return function()
            return "(unrecognized instruction "..tostring(name)..")"
        end
    end
})

function instruction_formats.call(ins)
    local fmt = "call "
    fmt = fmt..disassembler.format_expression(ins.result)
    fmt = fmt.." "..disassembler.format_expression(ins.func)
    for _,arg in ipairs(ins.args) do
        fmt = fmt.." "..disassembler.format_expression(arg)
    end
    return fmt
end

function instruction_formats.call_more(ins)
    local fmt = "call_more "
    fmt = fmt..disassembler.format_expression(ins.result)
    fmt = fmt.." {"..serpent.line(ins.func).."}"
    for _,arg in ipairs(ins.args) do
        fmt = fmt.." "..disassembler.format_expression(arg)
    end
    return fmt
end

function instruction_formats.call_less(ins)
    local fmt = "call_less "
    fmt = fmt.."{"..serpent.line(ins.func).."}"
    for _,arg in ipairs(ins.args) do
        fmt = fmt.." "..disassembler.format_expression(arg)
    end
    return fmt
end

function instruction_formats.function_return(ins)
    return "function_return "..disassembler.format_expression(ins.exp)
end

function instruction_formats.assign(ins)
    return "assign "..disassembler.format_expression(ins.to).." "..disassembler.format_expression(ins.from)
end

function instruction_formats.jump(ins)
    return "jump "..disassembler.format_expression(ins.offset)
end

function instruction_formats.jump_if(ins)
    return "jump_if "..disassembler.format_expression(ins.offset).." "..disassembler.format_expression(ins.exp)
end

function instruction_formats.jump_if_not(ins)
    return "jump_if_not "..disassembler.format_expression(ins.offset).." "..disassembler.format_expression(ins.exp)
end

function instruction_formats.exit(ins)
    return "exit "..disassembler.format_expression(ins.exit_code)
end

function disassembler.instruction_format(ins)
    return instruction_formats[ins.type](ins)
end

function disassembler.disassemble_function(func)
    local fmt = ""
    for k,v in ipairs(func.instructions) do
        local k_string = tostring(k)
        local padded_k = string.rep(' ', 6 - #k_string) .. k_string
        fmt = fmt..padded_k..": "..disassembler.instruction_format(v).."\n"
    end
    return fmt
end

function disassembler.disassemble_all(functions)
    local fmt = ""
    for k,v in ipairs(functions) do
        if v.name then
            fmt = fmt.."============ function "..k.." ("..tostring(v.name)..") ============\n"
        else
            fmt = fmt.."============ function "..k.." ============\n"
        end
 
        fmt = fmt..disassembler.disassemble_function(v)
        fmt = fmt.."\n\n"
    end
    return fmt
end

function disassembler.init(cfa_null_, expression_metatable_)
    cfa_null = cfa_null_
    expression_metatable = expression_metatable_
end

return disassembler