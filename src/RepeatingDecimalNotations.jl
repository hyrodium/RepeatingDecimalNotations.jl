module RepeatingDecimalNotations

export @rd_str
export ParenthesesNotation
export RepeatingDecimal

abstract type RepeatingDecimalNotation end

"""
    RepeatingDecimal

Intermediate struct to represent a repeating decimal number.
"""
struct RepeatingDecimal
    sign::Bool  # true/false corresponds to +/-
    integer_part::BigInt    # Integer part
    finite_part::BigInt     # Finite decimal part
    repeating_part::BigInt  # Repeating decimal part, easily overflows in Int64. (e.g. 1//97)
    m::Int  # digits of decimal part
    n::Int  # digits of repeating part
end

function RepeatingDecimal(r::Rational)
    int = big(floor(Int, r))
    frac = r - int
    cof = 1//1
    num = big(frac.num)
    den = big(frac.den)
    while true
        if rem(den,10) == 0
            den = den ÷ 10
            cof //= 10
        end
        rem(den,10) ≠ 0 && break
    end
    while true
        if rem(den,5) == 0
            num *= 2
            den ÷= 5
            cof //= 10
        end
        if rem(den,2) == 0
            num *= 5
            den ÷= 2
            cof //= 10
        end
        rem(den,2) ≠ 0 && rem(den,5) ≠ 0 && break
    end
    m = Int(log10(inv(cof)))
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
    return RepeatingDecimal(true, int, dec, rep, m, n)
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
    r = rd.integer_part
    r += rd.finite_part // (10^rd.m)
    r += rd.repeating_part // (10^rd.n-1) / (10^rd.m)
    if rd.sign
        return Rational{T}(r)
    else
        return -Rational{T}(r)
    end
end

end # module RepeatingDecimalNotations
