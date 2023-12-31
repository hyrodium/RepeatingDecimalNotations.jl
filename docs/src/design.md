# Design

```@setup design
using RepeatingDecimalNotations
using RepeatingDecimalNotations: stringify, rationalify
using InteractiveUtils
```

## Types that represents repeating decimals
There are three types that represents a repeating decimal number; `String`, `Rational`, and [`RepeatingDecimal`](@ref).

* `Rational{T}`
    * Stores a numerator and a denominator as `T<:Real`.
    * The representation is unique.
    * e.g. `4111111//33300`
* `String`
    * Stores characters that can represent repeating decimals directly.
    * The representation is not unique.
    * e.g. `"123.45(678)"`, `"123.456(786)"`, `"123.456_786_786(786_786)"`
* [`RepeatingDecimal`](@ref)
    * Stores `sign::Bool`, `finite_part::BigInt`, `repeat_part::BigInt`, `point_position::Int`, and `period::Int` to represent a repeating decimal.
    * The representation is not unique.
    * e.g. `RepeatingDecimal(true, 12345, 678, 2, 3)`, `RepeatingDecimal(true, 123456, 786, 3, 3)`, `RepeatingDecimal(true, 123456_786_786, 786_786, 9, 6)`

```@repl design
RepeatingDecimal(true, 12345, 678, 2, 3)
RepeatingDecimal(true, 123456, 786, 3, 3)
RepeatingDecimal(true, 123456_786_786, 786_786, 9, 6)
```

## Converting functions: [`stringify`](@ref RepeatingDecimalNotations.stringify), [`rationalify`](@ref RepeatingDecimalNotations.rationalify)

```mermaid
graph LR
    A -- "RepeatingDecimal" --> C
    A[String] -- "rationalify" --> B[Rational]
    B -- "RepeatingDecimal" --> C[RepeatingDecimal]
    C -- "rationalify" --> B
    B -- "stringify" --> A
    C -- "stringify" --> A
```

* We avoided adding methods to `Base.string` and `Base.rationalize` not to induce type piracy.
* These functions are not exported because the names of these functions does not imply relation to repeating decimals. Please use them like the following in your code.
    * `RepeatingDecimalNotations.stringify(...)`
    * `import RepeatingDecimalNotations: stringify`
    * `using RepeatingDecimalNotations: stringify`

```@repl
using RepeatingDecimalNotations
using RepeatingDecimalNotations: stringify, rationalify
str = "123.45(678)"
rd = RepeatingDecimal(true,12345,678,2,3)
r = 4111111//33300
str == stringify(rd) == stringify(r)
rd == RepeatingDecimal(str) == RepeatingDecimal(r)
r == rationalify(str) == rationalify(rd)
```

## Subtypes of `RepeatingDecimalNotation`
There are several supported notations[^Notations] for repeating decimals.

```@repl design
subtypes(RepeatingDecimalNotation)
```

[^Notations]: Please check [Notaion section](https://en.wikipedia.org/wiki/Repeating_decimal#Notation) in the wikipedia article

### [`ParenthesesNotation`](@ref) (Default)

* 😊 Common notations in some regions.
* 😆 Easy to input.
* 😇 May conflict with Julia syntax[^Conflict].

```math
123.45(678)
```

```@repl design
rd"123.45(678)"
no = ParenthesesNotation()
stringify(no, 1//11)
rationalify(no, "123.45(678)")
```

[^Conflict]: Try `123.45(678) == 83699.1` on Julia REPL.

### `DotsNotation`

* 😊 Common notations in some regions.
* 😁 Does not break digit positions.
* 😂 Requires more typings `\dot[TAB]` and correct font environment.

```math
123.45\dot{6}7\dot{8}
```

```@repl design
rd"123.456̇78̇"
no = DotsNotation()
stringify(no, 1//11)
rationalify(no, "123.456̇78̇")
```

Note that the above code block may not show `\dot (\u0307)` correctly.
If you are using [JuliaMono v0.053](https://github.com/cormullion/juliamono/releases/tag/v0.053) or later, the characters will be rendered correctly like this[^JuliaMono196]:

![](img/DotsNotationREPL.png)

[^JuliaMono196]: See [JuliaMono issue#196](https://github.com/cormullion/juliamono/issues/196) for more information.

### [`ScientificNotation`](@ref)

* 😉 Easy to combine with exponential notation.
* 🥲 Not much common notation[^r_notation].

[^r_notation]: See [hsjoihs's tweet](https://twitter.com/hsjoihs/status/1740719888828944773) and [the best way to count (YouTube)](https://www.youtube.com/watch?v=rDDaEVcwIJM&t=2610s) for example usages.

```math
1.2345\text{r}678\text{e}2
```

```@repl design
rd"123.45r678"
no = ScientificNotation()
stringify(no, 1//11)
rationalify(no, "123.45r678")
rd"1.2345r678e2"  # Exponent term is supported.
```

### [`EllipsisNotation`](@ref)

* 🤩 You don't have to specify the repeating decimal part.
* 😝 Sometimes repeating part will be long and hard to read.

```math
123.45678678...
```

```@repl design
rd"123.45678678..."
no = EllipsisNotation()
stringify(no, 1//11)
rationalify(no, "123.45678678...")
rd"0.4545..."      # Same as 0.(45), repeating [45] two times
rd"0.333..."       # Same as 0.(3), repeating one digit [3] three times
rd"0.13331333..."  # Same as 0.(1333), repeating [1333] has priority over repeating [3]
rd"0.133313333..." # Same as 0.13331(3), adding additional [3] resolves the ambiguity.
```

### Non-supported notation
Vinculum notation ``123.45\overline{678}`` is not supported because it is hard to input with Unicode.

## About the logo

![](assets/logo.svg)

``0.\dot{6}\dot{6} = 12/18`` is [the birthday of the package](https://github.com/hyrodium/RepeatingDecimalNotations.jl/commit/218d639cd0e0ea07449a1ea7e571622cfd2e54fe).
