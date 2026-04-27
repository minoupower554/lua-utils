---@generic T
---@generic S
---@param cases table<T, S>
---@param value T
---@param default S?
---@return S
return function(value, cases, default)
    local val = cases[value]
    if val == nil then
        return default
    else
        return val
    end
end
