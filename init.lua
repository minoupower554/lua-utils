---@diagnostic disable: different-requires
local source = debug.getinfo(1).source
local dir = source:match("@(.*/)")

local function register_module(registry, name, mod)
    -- register the namespace
    registry[name] = mod

    -- register all functions directly
    for k, v in pairs(mod) do
        if type(v) ~= "table" then
            registry[k] = v
        end
    end
end

local old_path = package.path
package.path = table.concat({
    dir .. "?.lua",
    dir .. "?/init.lua",
    package.path
}, ";")
-- do as little as possible in the timeframe where it pokes package.path
local math = require('math')
local string = require('string')
local types = require('types')
local misc = require('misc')

package.path = old_path

local registry = {}
register_module(registry, "math", math)
register_module(registry, "string", string)
register_module(registry, "types", types)
register_module(registry, "misc", misc)


---collect any functions you might want dynamically, also allows you to collect namespaces
---@param ... string
return function(...)
    local vararg = {...}

    local acc = {}
    for k, v in pairs(vararg) do
        if registry[k] == nil then
            error("invalid import: "..k, 2)
        end
        table.insert(acc, registry[v])
    end

    return table.unpack(acc)
end
