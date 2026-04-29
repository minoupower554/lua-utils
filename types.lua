local types = {}
local readonly = require('misc').readonly

do
    local Null = setmetatable({}, {
        __tostring = function()
            return "null"
        end
    })
    types.null = Null
end


do
    ---@class Option<T>
    ---@field private _value T?
    ---@field private _tag "Some"|"None"
    local Option = {}
    Option.__index = Option

    Option.__tostring = function(self)
        if self._tag == "Some" then
            return "Some("..tostring(self._value)..")"
        else
            return "None"
        end
    end


    ---create a new Option with value val
    ---@param val T
    ---@return Option<T>
    function Option.some(val)
        return setmetatable({_tag = "Some", _value = val}, Option)
    end

    ---create a new Option with None
    ---@return Option<unknown>
    function Option.none()
        return setmetatable({_tag = "None"}, Option)
    end


    ---returns whether the Option is None
    ---@return boolean
    function Option:is_none()
        return self._tag == "None"
    end


    ---returns whether the Option is Some
    ---@return boolean
    function Option:is_some()
        return self._tag == "Some"
    end


    ---return true if the Option is Some and the predicate function returns true. throws if you attempt to edit value in predicate
    ---@param fn fun(v: T): boolean
    ---@return boolean
    function Option:is_some_and(fn)
        ---@diagnostic disable-next-line: param-type-mismatch -- short circuits if its nil unless the user manually poked _tag/_value which is on them
        return self._tag == "Some" and fn(readonly(self._value)) == true
    end


    ---return the inner value if its Some, error with msg otherwise
    ---@param msg any
    ---@return T
    function Option:expect(msg)
        if self._tag == "Some" then
            return self._value
        end
        error(msg, 2)
    end


    ---return the inner value if its Some, error otherwise
    ---@return T
    function Option:unwrap()
        if self._tag == "Some" then
            return self._value
        end
        error("unwrapped None Option", 2)
    end


    ---return the inner value if its Some, default otherwise
    ---@param default any
    ---@return T
    function Option:unwrap_or(default)
        if self._tag == "Some" then
            return self._value
        else
            return default
        end
    end


    ---returns the inner value if its Some, calls fn and returns its result otherwise
    ---@param fn fun(): T
    ---@return T
    function Option:unwrap_or_else(fn)
        if self._tag == "Some" then
            return self._value
        else
            return fn()
        end
    end


    ---run fn on the value if Some and return a new Option, return None otherwise
    ---@generic U
    ---@param fn fun(T): U
    ---@return Option<U>
    function Option:map(fn)
        if self._tag == "Some" then
            return Option.some(fn(self._value))
        end
        return self -- pointless to create a new None
    end


    ---run fn on the value if Some and return the output, return default otherwise
    ---@generic U
    ---@param fn fun(T): U
    ---@param default U
    ---@return U
    function Option:map_or(fn, default)
        if self._tag == "Some" then
            return fn(self._value)
        else
            return default
        end
    end


    ---run fn on the inner value if Some and return the output, otherwise run default_fn and return its output
    ---@generic U
    ---@param fn fun(T): U
    ---@param default_fn fun(): U
    ---@return U
    function Option:map_or_else(fn, default_fn)
        if self._tag == "Some" then
            return fn(self._value)
        else
            return default_fn()
        end
    end


    ---run a side effect function on the value if Some, do nothing otherwise. will throw if you attempt to edit value in function
    ---@param fn fun(T): nil
    ---@return Option<T>
    function Option:inspect(fn)
        if self._tag == "Some" then
            fn(readonly(self._value))
        end
        return self
    end


    ---return the Option only if its Some and passes the predicate function, returns none otherwise. throws if you attempt to edit value in predicate
    ---@param fn fun(T): boolean
    ---@return Option
    function Option:filter(fn)
        if self._tag == "Some" and fn(readonly(self._value)) then
            return self
        else
            return Option.none()
        end
    end
end


return types
