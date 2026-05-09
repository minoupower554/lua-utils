# Lua Utilities

### These are just some simple utilities to supplement the standard library

## Modules
### math
The math module contains these methods:
- `round(v: number, step: number): number` rounds v to the specified step.
- `clamp(v: number, min: number?, max: number?): number` clamps v between min and max, min defaults to 0 and max defaults to 1.
- `lerp(start, stop, factor): number` linearly interpolates between start and stop, returning the interpolated value at factor. the factor is unclamped allowing for extrapolation.
- `lerp_clamp(start, stop, factor): number` the same as lerp() but is clamped meaning it does not allow extrapolation.

### string
The string module contains these methods:
- `dedent(str: string, stripOuterNewline: boolean?): string` dedent a function with the (by default enabled) option to also strip the first and last newline if it exists for easy multiline string usage.

### types
The types module contains these types:
- `null` an identity only object that just serves as a differentiation between nil and explicit absence of data.
- `Option<T>` a lua implementation of a rust-like Option type.
  - `.some(val: T): Option<T>` create a new Option object with value val.
  - `.none(): Option<unknown>` create a new Option object with no value.
  - `:is_some(): boolean` returns true if Some.
  - `:is_none(): boolean` returns true if None.
  - `:is_some_and(pred: (&T) -> boolean): boolean` returns true if Some and the predicate function passes.
  - `:expect(msg: string): T` return the inner value if Some, error with msg otherwise.
  - `:unwrap(): T` return the inner value if Some, error otherwise.
  - `:unwrap_or(default: T): T` return the inner value if Some, return default otherwise.
  - `:unwrap_or_else(fn: () -> T): T` return the inner value if Some, run fn and return its result otherwise.
  - `:map(fn: (T) -> U): Option<U>` run fn on the inner value and return a new option with the result if Some, return None otherwise.
  - `:map_or(fn: (T) -> U, default: U): U` run fn on the inner value and return the result if Some, return default otherwise.
  - `:map_or_else(fn: (T) -> U, default_fn: () -> U): U` run fn on the inner value and return the result if Some, run default_fn and return it's result otherwise
  - `:inspect(fn: (&T) -> nil): Option<T>` run a side effect function on the inner value if Some and return self, do nothing otherwise.
  - `:flatten<where T: Option<U>>(): Option<U>` flatten an `Option<Option<U>>` into `Option<U>`.
  - `:transpose<where T: Result<U, E>>(): Result<Option<U>, E>` turn an `Option<Result<U, E>>` into a `Result<Option<U>, E>`.
  - `:filter(pred: (&T) -> boolean): Option<T>` run the predicate function on the value and return self if Some and predicate returns true. return None otherwise.
- `Result<T, E>` a lua implementation of a rust-like Option type
  - TODO: ADD RESULT DOCS AND FINISH OPTION DOCS

### table
the table module currently contains this method:
- `pprint` returns a table of 2 functions that allow you to easily print tables.
  - `opts: table` the options table used by both methods provided.
    - `indent: string` define what is used as the indentation (repeated once, so "  " is 2 spaces, not 8). default: 4 spaces.
    - `maxlevel: integer` set how deep the printer recurses before cutting off output. default: 64 levels deep.
    - `usestr: boolean` whether to use the __tostring method instead of printing table contents when available. default: true.
    - `name: string` what name to prefix the table with (eg `myname={foo="bar"}`), nil results in an anonymous table. default: nil.
  - `block(val: table, opts: table)` pretty print a table across multiple lines with indentation. see opts for options info.
  - `line(val: table, opts: table)` pretty print a table on a single line. see opts for options info.

### misc
The misc module contains misc methods that are not particularly related:
- `switch(value: K, cases: table<K, V>, default: V?): V` take a value val and check it against the cases, if no match is found either return nil or default.
- `readonly(val: T): U` take a value and return an immutable copy of it (using deep proxying on tables).
