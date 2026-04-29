local misc = {}

---@generic T
---@generic S
---@param cases table<T, S>
---@param value T
---@param default S?
---@return S
function misc.switch(value, cases, default)
    local val = cases[value]
    if val == nil then
        return default
    else
        return val
    end
end


---make an immutable copy of any value
---@generic T
---@param v T
---@return T
function misc.readonly(v)
    if type(v) ~= "table" then
        return v -- primitives already copy
    end
    local function readonly(tbl, seen)
        seen = seen or {}

        if seen[tbl] then
            return seen[tbl]
        end

        local proxy = {}

        seen[tbl] = proxy

        setmetatable(proxy, {
            __index = function(_, key)
                local value = tbl[key]

                if type(value) == "table" then
                    return readonly(value, seen)
                end

                return value
            end,

            __newindex = function()
                error("read-only table", 2)
            end,

            __metatable = false
        })

        return proxy
    end

    return readonly(v)
end

return misc
