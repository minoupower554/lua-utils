---@param str string
---@return string
return function(str)
    -- split into lines
    local lines = {}
    for line in (str .. "\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
    end

    -- find minimum indentation (tabs + spaces)
    local minIndent = nil

    for _, line in ipairs(lines) do
        if line:match("%S") then -- ignore empty/whitespace-only lines
            local indent = line:match("^(%s*)")
            local len = 0

            -- count indentation width (treat tab as 1 unit; adjust if you want 4 spaces per tab)
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

    -- remove indentation
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
