# RepeatingDecimalNotations.jl

A Julia package to handle repeating decimal numbers.

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://hyrodium.github.io/RepeatingDecimalNotations.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://hyrodium.github.io/RepeatingDecimalNotations.jl/dev)
[![Build Status](https://github.com/hyrodium/RepeatingDecimalNotations.jl/workflows/CI/badge.svg)](https://github.com/hyrodium/RepeatingDecimalNotations.jl/actions)
[![Coverage](https://codecov.io/gh/hyrodium/RepeatingDecimalNotations.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/hyrodium/RepeatingDecimalNotations.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![RepeatingDecimalNotations Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/RepeatingDecimalNotations)](https://pkgs.genieframework.com?packages=RepeatingDecimalNotations).

```julia
julia> using RepeatingDecimalNotations

julia> using RepeatingDecimalNotations: stringify, rationalify

julia> r = rd"123.4(56)"  # 123.4565656...
61111//495

julia> typeof(r), float(r)  # Check floating point number approximation.
(Rational{Int64}, 123.45656565656566)

julia> stringify(r)  # Generate string from `Rational`.
"123.4(56)"

julia> rd"0.(9)"  # 0.999... is equal to 1.
1//1

julia> rd"0.99(9)", rd"1", rd"1.000_000"  # The notation of repeating decimals is not unique.
(1//1, 1//1, 1//1)

julia> rationalify("0.24(666)")
37//150
```

# TODO
- Add support for other notations such as `123.45 67...` (See [Repeating decimal (Wikipedia)](https://en.wikipedia.org/wiki/Repeating_decimal))
- Register this package
