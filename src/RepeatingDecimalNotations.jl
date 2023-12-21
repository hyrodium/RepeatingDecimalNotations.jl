module RepeatingDecimalNotations

export @rd_str
export RepeatingDecimal
export RepeatingDecimalNotation
export ParenthesesNotation
export ScientificNotation

abstract type RepeatingDecimalNotation end

"""
    RepeatingDecimal

Intermediate struct to represent a repeating decimal number.
"""
struct RepeatingDecimal
    sign::Bool  # true/false corresponds to +/-
    finite_part::BigInt     # Finite decimal part
    repeat_part::BigInt  # Repeating decimal part, easily overflows in Int64. (e.g. 1//97)
    point_position::Int  # digits of decimal part
    period::Int  # digits of repeating part
end

function RepeatingDecimal(sign::Bool, finite_part::Integer, repeating_part::Integer, m::Integer, n::Integer)
    RepeatingDecimal(sign, BigInt(finite_part), BigInt(repeating_part), Int(m), Int(n))
end

function Base.:(==)(rd1::RepeatingDecimal, rd2::RepeatingDecimal)
    return (rd1.sign == rd2.sign)&(rd1.finite_part == rd2.finite_part)&(rd1.repeat_part == rd2.repeat_part)&(rd1.point_position == rd2.point_position)&(rd1.period == rd2.period)
end

function RepeatingDecimal(r::Rational)
    if r < 0
        sign = false
        r = -r
    else
        sign = true
    end
    int = big(floor(Int, r))
    frac = r - int
    pow = 0
    num = big(frac.num)
    den = big(frac.den)
    while true
        if rem(den,10) == 0
            den = den ÷ 10
            pow += 1
        end
        rem(den,10) ≠ 0 && break
    end
    while true
        if rem(den,5) == 0
            num *= 2
            den ÷= 5
            pow += 1
        end
        if rem(den,2) == 0
            num *= 5
            den ÷= 2
            pow += 1
        end
        rem(den,2) ≠ 0 && rem(den,5) ≠ 0 && break
    end
    n = 1
    while true
        rem(big(10)^n-1, den)==0 && break
        n = n+1
    end
    num *= div(big(10)^n-1, den)
    den *= div(big(10)^n-1, den)
    dec, rep = divrem(num,den)
    if rep == 0
        n = 0
    end
    finite = int*10^pow + dec
    return RepeatingDecimal(sign, finite, rep, pow, n)
end

# Defaults to `ParenthesesNotation`
RepeatingDecimal(r::Union{Integer, Rational}) = RepeatingDecimal(ParenthesesNotation(), r)
RepeatingDecimal(str::AbstractString) = RepeatingDecimal(ParenthesesNotation(), str)
stringify(rd::RepeatingDecimal) = stringify(ParenthesesNotation(), rd)
stringify(r::Union{Integer, Rational}) = stringify(RepeatingDecimal(r))
stringify(rdn::RepeatingDecimalNotation, rd::RepeatingDecimal) = stringify(rdn, rd)
stringify(rdn::RepeatingDecimalNotation, r::Union{Integer, Rational}) = stringify(rdn, RepeatingDecimal(r))

function _remove_underscore(str::AbstractString)
    str = replace(str, r"(\d)_(\d)" => s"\1\2")
    str = replace(str, r"(\d)_(\d)" => s"\1\2")
    return str
end

include("_ParenthesesNotation.jl")
include("_ScientificNotation.jl")

macro rd_str(str)
    rd = RepeatingDecimal(ParenthesesNotation(), str)
    r = rationalify(BigInt, rd)
    return _try_unpromote_type(r)
end

function _try_unpromote_type(r::Rational{BigInt})
    for T in (Int128, Int64, Int)
        if typemin(T) ≤ r.num ≤ typemax(T) && typemin(T) ≤ r.den ≤ typemax(T)
            r = Rational{T}(r)
        end
    end
    return r
end

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
