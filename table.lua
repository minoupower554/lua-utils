local _table = {}

do
    local printer = {}

    local keyword = {}
    for _, k in ipairs({
        'and', 'break', 'do', 'else', 'elseif', 'end', 'false',
        'for', 'function', 'goto', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat',
        'return', 'then', 'true', 'until', 'while'
    }) do keyword[k] = true end

    local function safestr(s)
        if type(s) == "number" then
            if s ~= s then
                return "0/0"
            elseif s == math.huge then
                return "math.huge"
            elseif s == -math.huge then
                return "-math.huge"
            else
                return ("%.6g"):format(s)
            end
        elseif type(s) == "string" then
            return ("%q"):format(s):gsub("\010", "n"):gsub("\026", "\\026"):gsub("\\%d+", function(esc)
                local byte = tonumber(esc:sub(2))
                local readable = { [9] = "\\t", [13] = "\\r", [8] = "\\b", [12] = "\\f" }
                return readable[byte] or esc
            end)
        else
            return tostring(s)
        end
    end

    local function safename(path, name)
        local n = name == nil and '' or name
        local plain = type(n) == "string" and n:match("^[%l%u_][%w_]*$") and not keyword[n]
        local safe = plain and n or '[' .. safestr(n) .. ']'
        return (path or '') .. (plain and path and '.' or '') .. safe, safe
    end

    local function serialize(t, opts)
        opts = opts or {}
        if opts.usestr == nil then opts.usestr = true end
        local indent   = opts.indent or '  '
        local maxlevel = opts.maxlevel or 64
        local usemt    = opts.usestr or opts.usemt or false -- opts.usemt is for backwards compat
        local seen     = {}
        local function val2str(val, name, level, path, plainindex)
            level = level or 0
            local ttype = type(val)
            local spath, sname = safename(path, name)
            local tag
            if plainindex then
                tag = (type(name) == "number") and '' or (name .. ' = ')
            else
                tag = (name ~= nil) and (sname .. ' = ') or ''
            end
            if ttype == "table" then
                if usemt then
                    local mt = getmetatable(val)
                    if mt and mt.__tostring then
                        return tag .. safestr(tostring(val))
                    end
                end
                if seen[val] then
                    return tag .. "--[[circular ref: " .. (seen[val] or "?") .. "]]"
                end
                if level >= maxlevel then
                    return tag .. "{--[[max depth]]}"
                end
                seen[val] = spath or "root"
                if next(val) == nil then
                    return tag .. "{}"
                end
                local keys = {}
                for k in pairs(val) do keys[#keys + 1] = k end
                table.sort(keys, function(a, b)
                    local ta, tb = type(a), type(b)
                    if ta == "number" and tb == "number" then return a < b end
                    if ta == "number" then return true end
                    if tb == "number" then return false end
                    return tostring(a) < tostring(b)
                end)
                local prefix = string.rep(indent, level)
                local inner  = string.rep(indent, level + 1)
                local out    = {}
                for _, k in ipairs(keys) do
                    local v = val[k]
                    local isplain = type(k) == "number"
                        and k >= 1 and k == math.floor(k)
                        and k <= #val
                    out[#out + 1] = inner .. val2str(v, k, level + 1, spath, isplain)
                end
                return tag .. "{\n" .. table.concat(out, ",\n") .. "\n" .. prefix .. "}"
            elseif ttype == "function" then
                return tag .. "function(...) --[[skipped]] end"
            elseif ttype == "thread" then
                return tag .. "\"[thread]\""
            elseif ttype == "userdata" then
                return tag .. '"' .. tostring(val) .. '"'
            else
                return tag .. safestr(val)
            end
        end
        return val2str(t, opts.name, 0, opts.name)
    end

    ---@alias options {indent: string, maxlevel: integer, usestr: boolean}


    ---pretty print a table with indentation on multiple lines
    ---@param val table
    ---@param opts options indent: edit what string is used for indentation (4 spaces default); maxlevel: change how many levels it recurses before cutting off (default 64); usestr: use tostring if any table has __tostring (default true); name: set a root label for the table to get in the output, nil resulting in an anonymous table output (default nil)
    ---@return string
    function printer.block(val, opts)
        return serialize(val, opts)
    end

    ---dump a table to a single line string, useful for debugging output
    ---@param val table
    ---@param opts options maxlevel: change how many levels it recurses before cutting off (default 64); usestr: use tostring if any table has __tostring (default true); name: set a root label for the table to get in the output, nil resulting in an anonymous table output (default nil)
    ---@return string
    function printer.line(val, opts)
        local s = serialize(val, opts)
        return (s:gsub("%s+", " "):gsub("{ ", "{"):gsub(" }", "}"))
    end

    _table.pprint = printer
end


return _table
