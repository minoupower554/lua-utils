# Lua Utilities

### These are just some simple utilities to supplement the standard library

## Modules
### math
The math module returns a table that contains these methods:
<br/>
- `round(v: number, step: number) -> number` rounds v to the specified step
- `clamp(v: number, min: number?, max: number?) -> number` clamps v between min and max, min defaults to 0 and max defaults to 1
- `lerp(start, stop, factor) -> number` linearly interpolates between start and stop, returning the interpolated value at factor. the factor is unclamped allowing for extrapolation
- `lerp_clamp(start, stop, factor) -> number` the same as lerp() but is clamped meaning it does not allow extrapolation

### misc
The misc module is not a classic module but instead a directory, therefore you have to import every function you want explicitely. It contains a number of miscellaneous functions that arent related to eachother, the current methods are:
<br/>
- `switch(cases: table<T, S>, value: T, default: S?) -> S|nil` emulates the behaviour of a switch from other programming languages, returning the case of the passed value or an optional default if provided, returns nil otherwise
- `dump` a lua table pretty printer

## Third Party
This project includes a heavily rewritten version of [serpent](https://github.com/pkulchenko/serpent) made by Paul Kulchenko and licensed under the MIT license, see the file header for the license contents.
