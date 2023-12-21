# RepeatingDecimalNotations.jl

A Julia package to handle repeating decimal numbers.

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://hyrodium.github.io/RepeatingDecimalNotations.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://hyrodium.github.io/RepeatingDecimalNotations.jl/dev)
[![Build Status](https://github.com/hyrodium/RepeatingDecimalNotations.jl/workflows/CI/badge.svg)](https://github.com/hyrodium/RepeatingDecimalNotations.jl/actions)
[![Coverage](https://codecov.io/gh/hyrodium/RepeatingDecimalNotations.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/hyrodium/RepeatingDecimalNotations.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![RepeatingDecimalNotations Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/RepeatingDecimalNotations)](https://pkgs.genieframework.com?packages=RepeatingDecimalNotations)

## Quick start

```@repl
using RepeatingDecimalNotations
using RepeatingDecimalNotations: stringify, rationalify
r = rd"123.4(56)"  # 123.4565656...
rd"1.234r56e2"  # Other notations
rd"123.45656..."  # are also supported.
float(r)  # Check floating point number approximation.
rd"0.(9)"  # 0.999... is equal to 1.
rd"0.99(9)", rd"1", rd"1.000_000"  # The notation of repeating decimals is not unique.
stringify(1//7)  # Generate `String` from `Rational`.
rationalify("0.1(6)")  # vice versa.
```
