# RepeatingDecimalNotations.jl

A Julia package to handle repeating decimal numbers.

```julia
julia> using RepeatingDecimalNotations

julia> r = rd"123.4(56)"  # Notation to represent 123.4565656...
61111//495

julia> float(r)  # Check floating point number approximation
123.45656565656566

julia> repeating_decimal_notation(r)  # Generate string from `Rational`.
"123.4(56)"

julia> rd"0.(9)"  # Notation to represent 0.999...
1//1

julia> rd"1.0"
1//1

julia> rd"0.9(999)"
1//1
```

# TODO
- Add support for negative numbers
- Add support for `Int128` and `BigInt`
- Add support for other notations such as `123.45 67...` (See [Repeating decimal (Wikipedia)](https://en.wikipedia.org/wiki/Repeating_decimal))
- Add more docs
- Add more tests
- Register this package
