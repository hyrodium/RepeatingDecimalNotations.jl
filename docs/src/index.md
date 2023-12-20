# RepeatingDecimalNotations.jl

## Quick start

```@repl
using RepeatingDecimalNotations
using RepeatingDecimalNotations: stringify, rationalify
r = rd"123.4(56)"  # 123.4565656...
typeof(r), float(r)  # Check floating point number approximation.
stringify(r)  # Generate string from `Rational`.
rd"0.(9)"  # 0.999... is equal to 1.
rd"0.99(9)", rd"1", rd"1.000_000"  # The notation of repeating decimals is not unique.
rationalify("0.24(666)")
```
