# Design

```@setup design
using RepeatingDecimalNotations
using RepeatingDecimalNotations: stringify, rationalify
using InteractiveUtils
```

## Types that represents repeating decimals
There are three types that represents a repeating decimal number; `String`, `Rational`, and [`RepeatingDecimal`](@ref).

* `Rational`
    * The representation is unique.
    * e.g. `4111111//33300`
* `String`
    * The representation is not unique.
    * e.g. `"123.45(678)"`, `"123.456(786)"`, `"123.456_786_786(786_786)"`
* [`RepeatingDecimal`](@ref)
    * The representation is not unique.
    * e.g. `RepeatingDecimal(123,45,678,2,3)`, `RepeatingDecimal(123,456,786,3,3)`, `RepeatingDecimal(123,456_786_786,786_786,9,6)`

## Converting functions: `stringify`, `rationalify`

```mermaid
graph LR
    A -- "RepeatingDecimal" --> C
    A[String] -- "rationalify" --> B[Rational]
    B -- "RepeatingDecimal" --> C[RepeatingDecimal]
    C -- "rationalify" --> B
    B -- "stringify" --> A
    C -- "stringify" --> A
```

* Avoid adding methods to `Base.string` and `Base.rationalize` not to induce type-piracy (Type III).
* These functions are not exported because the names of these functions does not imply relation to repeating decimals Please use them like the following in your code.
    * `RepeatingDecimalNotations.stringify(...)`
    * `import RepeatingDecimalNotations: stringify`

## Subtypes of `RepeatingDecimalNotation`
There are several supported notations for repeating decimals.

```@repl design
subtypes(RepeatingDecimalNotation)
```

### `ParenthesesNotation` (Default)
`"123.45(678)"`

### `DotsNotation`
`"123.45(6̇78̇)"`

TODO

### `ScientificNotation`
`"123.45r678"`

TODO

### `EllipsisNotation`
`"123.45 678..."`

TODO

## About the logo

![](assets/logo.svg)

``0.\dot{6}\dot{6} = 12/18`` was the day of [the first commit of the repository](https://github.com/hyrodium/RepeatingDecimalNotations.jl/commit/218d639cd0e0ea07449a1ea7e571622cfd2e54fe).