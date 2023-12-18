# RepeatingDecimalNotations.jl

This package exports one string macro `@rd_str` that converts repeating decimal numbers to rational numbers.

```julia
julia> using RepeatingDecimalNotations

julia> rd"123"
123

julia> rd"123.45"
2469//20

julia> rd"123.45(6)"
37037//300

julia> rd"123.45(67)"
611111//4950

julia> float(rd"123")
123.0

julia> float(rd"123.45")
123.45

julia> float(rd"123.45(6)")
123.45666666666666

julia> float(rd"123.45(67)")
123.45676767676768
```

# TODO
- Add support for negative numbers
- Add support for `Int128` and `BigInt`
- Add support for other notations such as `123.45 67...` (See [Repeating decimal](https://en.wikipedia.org/wiki/Repeating_decimal))
- Add more docs
- Add tests
- Register this package
