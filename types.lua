local types = {}
local readonly = require('lua-utils.misc').readonly

do
    local Null = setmetatable({}, {
        __tostring = function()
            return "null"
        end
    })
    types.null = Null
end


do
    ---an immutable Option 
    ---@class Option<T>
    ---@field private _tag "Some"|"None"
    ---@field private _value T
    local Option = {}
    Option.__index = Option
    Option.__newindex = function(_, _, _) error("Option is immutable", 2) end
    Option.__type = "Option"
    local opt_none = setmetatable({_tag = "None"}, Option)

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
    ---@param pred fun(v: T): boolean
    ---@return boolean
    function Option:is_some_and(pred)
        return self._tag == "Some" and pred(readonly(self._value)) == true
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

    ---return whatever _value is without checking if its Some, use this carefully
    ---@return T
    function Option:unwrap_unchecked()
        return self._value
    end

    ---run fn on the value if Some and return a new Option, return None otherwise
    ---@generic U
    ---@param fn fun(T): U
    ---@return Option<U>
    function Option:map(fn)
        if self._tag == "Some" then
            return Option.Some(fn(self._value))
        end
        return self     -- pointless to create a new None
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
    ---@param pred fun(T): boolean
    ---@return Option
    function Option:filter(pred)
        if self._tag == "Some" and pred(readonly(self._value)) then
            return self
        else
            return Option.None()
        end
    end


    ---flatten an Option<Option<T>> to an Option<T>
    ---@generic U
    ---@return Option<U>
    function Option:flatten()
        if self._tag == "None" then
            return self -- no need to create a new None reference
        end
        if type(self._value) ~= "table" then
            error("cannot flatten non Option value", 2)
        end
        if self._value.__type ~= "Option" then
            error("cannot flatten non Option value", 2)
        end
        return self._value -- and they said coding is hard
    end


    ---transpose an Option<Result<T, E>> to a Result<Option<T>, E>
    ---@generic E
    ---@return Result<Option<T>, E>
    function Option:transpose()
        if self._tag == "None" then
            return types.Result.Ok(self)
        else
            if type(self._value) ~= "table" then
                error("cannot transpose non Result value", 2)
            end
            if self._value.__type ~= "Result" then
                error("cannot transpose non Result value", 2)
            end
            if self._value:is_ok() then
                return types.Result.Ok(Option.Some(self._value:unwrap()))
            else
                return self._value -- return the Err directly, no reason to unwrap_err to make a new Err
            end
        end
    end

    ---run fn_some if Some, run fn_none if None
    ---@param fn_some fun(T): any
    ---@param fn_none fun(): any
    function Option:match(fn_some, fn_none)
        if self._tag == "Some" then
            return fn_some(self._value)
        else
            return fn_none()
        end
    end


    ---create a new Option with value val
    ---@generic T
    ---@param val T
    ---@return Option<T>
    function Option.Some(val)
        return setmetatable({ _tag="Some", _value=val }, Option)
    end

    ---create a new Option with None
    ---@generic T
    ---@return Option<T>
    function Option.None()
        return opt_none
    end


    types.Option = Option
end


do
    local Some = function(v) return types.Option.Some(v) end
    local None = function() return types.Option.None() end
    ---an immutable Result type
    ---@class Result<T, E>
    ---@field private _tag "Ok"|"Err"
    ---@field private _value T?
    ---@field private _error E?
    local Result = {}
    Result.__index = Result
    Result.__newindex = function(_, _, _) error("Result is immutable", 2) end
    Result.__type = "Result"


    ---return true if its Ok, false otherwise
    ---@return boolean
    function Result:is_ok()
        return self._tag == "Ok"
    end


    ---return true if its Err, false otherwise
    ---@return boolean
    function Result:is_err()
        return self._tag == "Err"
    end


    ---return true if its Ok and predicate passes, false otherwise
    ---@param pred fun(T): boolean
    ---@return boolean
    function Result:is_ok_and(pred)
        return self._tag == "Ok" and pred(readonly(self._value))
    end


    ---return true if its Err and predicate passes, false otherwise
    ---@param pred fun(T): boolean
    ---@return boolean
    function Result:is_err_and(pred)
        return self._tag == "Err" and pred(readonly(self._error))
    end


    ---return the inner value if Ok, error otherwise
    ---@return T
    function Result:unwrap()
        if self._tag == "Ok" then
            return self._value
        end
        error("unwrapped Err value", 2)
    end


    ---return the inner value if Ok, error with msg otherwise
    ---@param msg string
    ---@return T
    function Result:expect(msg)
        if self._tag == "Ok" then
            return self._value
        end
        error(msg, 2)
    end


    ---return the inner error if Err, error otherwise
    ---@return E
    function Result:unwrap_err()
        if self._tag == "Err" then
            return self._error
        end
        error("unwrapped Ok value", 2)
    end


    ---return the inner error if Err, error with msg otherwise
    ---@param msg string
    ---@return E
    function Result:expect_err(msg)
        if self._tag == "Err" then
            return self._error
        end
        error(msg, 2)
    end


    ---return the inner value of Ok, default otherwise
    ---@param default T
    ---@return T
    function Result:unwrap_or(default)
        if self._tag == "Ok" then
            return self._value
        else
            return default
        end
    end


    ---return the inner value if Ok, run fn and return its result otherwise
    ---@param fn fun(): T
    ---@return T
    function Result:unwrap_or_else(fn)
        if self._tag == "Ok" then
            return self._value
        else
            return fn()
        end
    end


    ---return whatever _value is without checking if its Ok, use this carefully
    ---@return T
    function Result:unwrap_unchecked()
        return self._value
    end


    ---run fn on the inner value and return a new Result with the output if Ok, return self otherwise
    ---@generic U
    ---@param fn fun(T): U
    ---@return Result<U, E>
    function Result:map(fn)
        if self._tag == "Ok" then
            return Result.Ok(fn(self._value))
        else
            return self
        end
    end


    ---run side effect function on inner value if Ok and return self, return self otherwise
    ---@param fn fun(T): nil
    ---@return Result<T, E>
    function Result:inspect(fn)
        if self._tag == "Ok" then
            fn(readonly(self._value))
        end
        return self
    end


    ---run fn on inner error and return a new result with the output if Err, return self otherwise
    ---@generic U
    ---@param fn fun(E): U
    ---@return Result<T, U>
    function Result:map_err(fn)
        if self._tag == "Err" then
            return Result.Err(fn(self._error))
        else
            return self
        end
    end


    ---run side effect function on inner error if Err and return self, return self otherwise
    ---@param fn fun(E): nil
    ---@return Result<T, E>
    function Result:inspect_err(fn)
        if self._tag == "Err" then
            fn(readonly(self._error))
        end
        return self
    end


    ---run fn on inner value of Ok and return result, return default otherwise
    ---@generic U
    ---@param fn fun(T): U
    ---@param default U
    ---@return U
    function Result:map_or(fn, default)
        if self._tag == "Ok" then
            return fn(self._value)
        else
            return default
        end
    end


    ---run fn on inner value if Ok and return result, run default_fn and return its result otherwise
    ---@generic U
    ---@param fn fun(T): U
    ---@param default_fn fun(): U
    ---@return U
    function Result:map_or_else(fn, default_fn)
        if self._tag == "Ok" then
            return fn(self._value)
        else
            return default_fn()
        end
    end


    ---discard inner value and return res if Ok, return self otherwise
    ---@generic U, I
    ---@param res Result<U, I>
    ---@return Result<T, E>|Result<U, I>
    function Result:chain(res)
        if self._tag == "Ok" then
            return res
        else
            return self
        end
    end


    ---run fn with inner value and return Result from fn, return self otherwise
    ---@generic U, I
    ---@param fn fun(T): Result<U, I>
    ---@return Result<T, E>|Result<U, I>
    function Result:and_then(fn)
        if self._tag == "Ok" then
            return fn(self._value)
        else
            return self
        end
    end


    ---discard inner error and return res if Err, return self otherwise
    ---@generic U, I
    ---@param res Result<U, I>
    ---@return Result<T, E>|Result<U,I>
    function Result:chain_err(res)
        if self._tag == "Err" then
            return res
        else
            return self
        end
    end


    ---run fn with inner error and return Result from fn, return self otherwise
    ---@generic U, I
    ---@param fn fun(E): Result<U, I>
    ---@return Result<T, E>|Result<U, I>
    function Result:or_else(fn)
        if self._tag == "Err" then
            return fn(self._error)
        else
            return self
        end
    end


    ---return Some with inner value if Ok, return None otherwise
    ---@return Option<T>
    function Result:ok()
        if self._tag == "Ok" then
            return Some(self._value)
        else
            return None()
        end
    end


    ---return Some with inner error if Err, return None otherwise
    ---@return Option<E>
    function Result:err()
        if self._tag == "Err" then
            return Some(self._error)
        else
            return None()
        end
    end


    ---flatten a Result<Result<T, E>, E> to a Result<T, E>
    ---@generic U
    ---@return Result<U>
    function Result:flatten()
        if self._tag == "Err" then
            return self
        end
        if type(self._value) ~= "table" then
            error("cannot flatten non Result value", 2)
        end
        if self._value.__type ~= "Result" then
            error("cannot flatten non Result value", 2)
        end
        return self._value
    end


    ---transpose a Result<Option<T>, E> to an Option<Result<T, E>>
    ---@generic E
    ---@return Option<Result<T, E>>
    function Result:transpose()
        if self._tag == "Err" then
            return Some(self)
        else
            if type(self._value) ~= "table" then
                error("cannot transpose non Option value", 2)
            end
            if self._value.__type ~= "Option" then
                error("cannot transpose non Option value", 2)
            end
            if self._value:is_some() then
                return Some(Result.Ok(self._value:unwrap()))
            else
                return self._value -- return None 
            end
        end
    end


    ---run fn_ok with inner value if Ok, run fn_err with inner error otherwise
    ---@param fn_ok fun(T): any
    ---@param fn_err fun(E): any
    ---@return any
    function Result:match(fn_ok, fn_err)
        if self._tag == "Ok" then
            return fn_ok(self._value)
        else
            return fn_err(self._error)
        end
    end



    ---return an Ok result with inner value val
    ---@generic T, E
    ---@param val T
    ---@return Result<T, E>
    function Result.Ok(val)
        return setmetatable({_tag="Ok", _value=val}, Result)
    end


    ---return an Err result with inner error err
    ---@generic T, E
    ---@param err E
    ---@return Result<T, E>
    function Result.Err(err)
        return setmetatable({_tag="Err", _error=err}, Result)
    end


    types.Result = Result
end


return types
