module RepeatingDecimalNotations

export @rd_str
export RepeatingDecimal
export RepeatingDecimalNotation
export ParenthesesNotation
export ScientificNotation

abstract type RepeatingDecimalNotation end

include("_util.jl")
include("_RepeatingDecimal.jl")
include("_ParenthesesNotation.jl")
include("_ScientificNotation.jl")

macro rd_str(str)
    rd = RepeatingDecimal(ParenthesesNotation(), str)
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
