# RepeatingDecimalNotations.jl

A Julia package to handle repeating decimal numbers.

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

julia> rd"0.99(9)"  # The notation of repeating decimals is not unique.
1//1
```

# TODO
- Add support for negative numbers
- Add support for `Int128` and `BigInt`
- Add support for other notations such as `123.45 67...` (See [Repeating decimal (Wikipedia)](https://en.wikipedia.org/wiki/Repeating_decimal))
- Add more docs
- Add more tests
- Register this package
