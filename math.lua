---@class m A collection of math tools to supplement the built-in math module
local m = {}

--- round a number to the specified step
--- throws if step is 0
---@param v number the number to round
---@param step number the step to round to
---@return number result the result of the rounding
function m.round(v, step)
    if step==0 then
        error("the step cannot be zero", 2)
    end
    return math.floor(v/math.abs(step)+0.5)*math.abs(step)
end


--- clamp a number between min and max
--- throws if the minimum is larger than the maximum
---@param v number the number to clamp
---@param min number? the minimum the value is allowed to be, defaults to 0
---@param max number? the maximum the value is allowed to be, defaults to 1
---@return number result
function m.clamp(v, min, max)
    if type(v) ~= "number" then
        error("the value has to be a number", 2)
    end
    if type(min) ~= "number" then
        error("the min value has to be a number", 2)
    end
    if type(max) ~= "number" then
        error("the max value has to be a number", 2)
    end
    min = min or 0
    max = max or 1
    if min>max then
        error("the minimum cannot be larger than the maximum", 2)
    end
    if v < min then
        return min
    elseif v > max then
        return max
    else
        return v
    end
end


--- linearly interpolates from start to stop with an unclamped factor (allowing for extrapolation)
---@param start number the start to interpolate from
---@param stop number the end to interpolate to
---@param factor number the interpolation factor, can be any valid number
---@return number result the result of the interpolation
function m.lerp(start, stop, factor)
    if type(start) ~= "number" then
        error("the start value has to be a number", 2)
    end
    if type(stop) ~= "number" then
        error("the stop value has to be a number", 2)
    end
    if type(factor) ~= "number" then
        error("the factor has to be a number", 2)
    end
    return start+(stop-start)*factor
end

--- linearly interpolates from start to stop with a clamped factor
---@param start number the start to interpolate from
---@param stop number the end to interpolate to
---@param factor number the interpolation factor between 0 and 1
---@return number result the result of the interpolation
function m.lerp_clamp(start, stop, factor)
    if type(start) ~= "number" then
        error("the start value has to be a number", 2)
    end
    if type(stop) ~= "number" then
        error("the stop value has to be a number", 2)
    end
    if type(factor) ~= "number" then
        error("the factor has to be a number", 2)
    end
    return start+(stop-start)*m.clamp(factor)
end

return m
