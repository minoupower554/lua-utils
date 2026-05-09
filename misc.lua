local misc = {}

---@generic K
---@generic V
---@param cases table<K, V>
---@param value K
---@param default V?
---@return V
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
---@param val T
---@return T
function misc.readonly(val)
    if type(val) ~= "table" then
        return val -- primitives already copy
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

    return readonly(val)
end


---shallow merge two tables without mutating the originals, key conflicts will always be won by t2
---@generic K, V
---@param t1 table<K, V>
---@param t2 table<K, V>
---@return table<K, V>
function misc.merge(t1, t2)
    local result = {}

    for k, v in pairs(t1) do
        result[k] = v
    end

    for k, v in pairs(t2) do
        result[k] = v
    end

    return result
end


return misc
