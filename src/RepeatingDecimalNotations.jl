module RepeatingDecimalNotations

export @rd_str
export RepeatingDecimal
export RepeatingDecimalNotation
export ParenthesesNotation
export ScientificNotation
export EllipsisNotation

"""
Abstract supertype for repeating decimals notations.
"""
abstract type RepeatingDecimalNotation end

include("_util.jl")
include("_RepeatingDecimal.jl")
include("_ParenthesesNotation.jl")
include("_ScientificNotation.jl")
include("_EllipsisNotation.jl")

"""
    @rd_str

A string macro to create a rational number.

# Examples
```jldoctest
julia> r = rd"123.4(56)"  # 123.4565656...
61111//495

julia> rd"1.234r56e2"  # Other notations
61111//495

julia> rd"123.45656..."  # are also supported.
61111//495

julia> float(r)  # Check floating point number approximation.
123.45656565656566

julia> rd"0.(9)"  # 0.999... is equal to 1.
1//1

julia> rd"0.99(9)", rd"1", rd"1.000_000"  # The notation of repeating decimals is not unique.
(1//1, 1//1, 1//1)
```
"""
macro rd_str(str)
    rd = RepeatingDecimal(str)
    r = rationalify(BigInt, rd)
    return _try_unpromote_type(r)
end

"""
    stringify(::RepeatingDecimalNotation, ::RepeatingDecimal)
    stringify(::RepeatingDecimalNotation, ::Rational)
    stringify(::RepeatingDecimal)
    stringify(::Rational)

Generate `String` from `Rational` or `RepeatingDecimal` instance.

# Examples
```jldoctest
julia> using RepeatingDecimalNotations: stringify  # `stringify` is not exported.

julia> stringify(ScientificNotation(), RepeatingDecimal(true, 123, 45, 2, 3))
"1.23r045"

julia> stringify(EllipsisNotation(), 1//11)
"0.0909..."

julia> stringify(RepeatingDecimal(true, 123, 45, 2, 3))  # Defaults to `ParenthesesNotation()`.
"1.23(045)"

julia> stringify(1//11)
"0.(09)"
```
"""
stringify

# Defaults to `ParenthesesNotation`
stringify(rd::RepeatingDecimal) = stringify(ParenthesesNotation(), rd)
stringify(r::Union{Integer, Rational}) = stringify(RepeatingDecimal(r))
stringify(rdn::RepeatingDecimalNotation, rd::RepeatingDecimal) = stringify(rdn, rd)
stringify(rdn::RepeatingDecimalNotation, r::Union{Integer, Rational}) = stringify(rdn, RepeatingDecimal(r))

"""
    rationalify(::Type{<:Integer}, ::RepeatingDecimalNotation, ::AbstractString)
    rationalify(::Type{<:Integer}, ::RepeatingDecimal)
    rationalify(::Type{<:Integer}, ::AbstractString)
    rationalify(::RepeatingDecimalNotation, ::AbstractString)
    rationalify(::RepeatingDecimal)
    rationalify(::AbstractString)

Generate `String` from `Rational` or `RepeatingDecimal` instance.

# Examples
```jldoctest
julia> using RepeatingDecimalNotations: rationalify  # `rationalify` is not exported.

julia> rationalify(RepeatingDecimal(true, 123, 45, 2, 3))  # `RepeatingDecimal` to `Rational{Int}`
6829//5550

julia> rationalify("1.23r045")  # `String` to `Rational{Int}`
6829//5550

julia> rationalify(EllipsisNotation(), "1.23r045")  # If notation style is specified, the input string should follow the style.
ERROR: invalid input!
Stacktrace:
[...]

julia> rationalify(Int128, "1.23r045")  # `String` to `Rational{Int128}`
6829//5550

julia> typeof(ans)
Rational{Int128}
```
"""
rationalify

# Defaults to `Int`
rationalify(str::AbstractString) = rationalify(Int, RepeatingDecimal(str))
rationalify(rdn::RepeatingDecimalNotation, str::AbstractString) = rationalify(Int, rdn, str)
rationalify(rd::RepeatingDecimal) = rationalify(Int, rd)
function rationalify(T::Type{<:Integer}, str::AbstractString)
    rd = RepeatingDecimal(str)
    return rationalify(T, rd)
end
function rationalify(T::Type{<:Integer}, rdn::RepeatingDecimalNotation, str::AbstractString)
    rd = RepeatingDecimal(rdn, str)
    return rationalify(T, rd)
end
function rationalify(T::Type{<:Integer}, rd::RepeatingDecimal)
    r = rd.finite_part // (T(10)^rd.point_position)
    r += rd.repeat_part // (T(10)^rd.period-1) / (T(10)^rd.point_position)
    if rd.sign
        return Rational{T}(r)
    else
        return -Rational{T}(r)
    end
end

end # module RepeatingDecimalNotations
