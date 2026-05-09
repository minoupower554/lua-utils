local _string = {}
local merge = require('lua-utils.misc').merge


---@param str string
---@param stripEdgeNewlines boolean|nil -- removes first/last newline if present (default: true)
---@return string
function _string.dedent(str, stripEdgeNewlines)
    stripEdgeNewlines = (stripEdgeNewlines == nil) and true or stripEdgeNewlines

    -- strip only ONE leading newline
    if stripEdgeNewlines and str:sub(1, 1) == "\n" then
        str = str:sub(2)
    end

    -- strip only ONE trailing newline
    if stripEdgeNewlines and str:sub(-1) == "\n" then
        str = str:sub(1, -2)
    end

    -- split into lines
    local lines = {}
    for line in (str .. "\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
    end

    -- find minimum indentation (tabs + spaces)
    local minIndent = nil

    for _, line in ipairs(lines) do
        if line:match("%S") then
            local indent = line:match("^(%s*)")
            local len = 0

            for c in indent:gmatch(".") do
                if c == "\t" then
                    len = len + 4
                else
                    len = len + 1
                end
            end

            if not minIndent or len < minIndent then
                minIndent = len
            end
        end
    end

    if not minIndent or minIndent == 0 then
        return str
    end

    local function strip_indent(line)
        local count = minIndent
        local i = 1

        while count > 0 and i <= #line do
            local c = line:sub(i, i)

            if c == " " then
                count = count - 1
            elseif c == "\t" then
                count = count - 4
            else
                break
            end

            i = i + 1
        end

        return line:sub(i)
    end

    for i, line in ipairs(lines) do
        lines[i] = strip_indent(line)
    end

    return table.concat(lines, "\n")
end


return _string
