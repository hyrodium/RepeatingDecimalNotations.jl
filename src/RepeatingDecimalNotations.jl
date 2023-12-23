module RepeatingDecimalNotations

export @rd_str
export RepeatingDecimal
export RepeatingDecimalNotation
export ParenthesesNotation
export ScientificNotation
export EllipsisNotation
export shift_decimal_point

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

# Defaults to `ParenthesesNotation`
stringify(rd::RepeatingDecimal) = stringify(ParenthesesNotation(), rd)
stringify(r::Union{Integer, Rational}) = stringify(RepeatingDecimal(r))
stringify(rdn::RepeatingDecimalNotation, rd::RepeatingDecimal) = stringify(rdn, rd)
stringify(rdn::RepeatingDecimalNotation, r::Union{Integer, Rational}) = stringify(rdn, RepeatingDecimal(r))

# Defaults to `Int`
rationalify(str::AbstractString) = rationalify(Int, ParenthesesNotation(), str)
rationalify(rdn::RepeatingDecimalNotation, str::AbstractString) = rationalify(Int, rdn, str)
rationalify(rd::RepeatingDecimal) = rationalify(Int, rd)
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
