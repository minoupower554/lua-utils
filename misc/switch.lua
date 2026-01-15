---@generic T
---@generic S
---@param cases table<T, S>
---@param value T
---@param default S?
---@return S
return function(cases, value, default)
    return cases[value] or default
end
