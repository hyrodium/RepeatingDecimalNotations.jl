function _remove_underscore(str::AbstractString)
    str = replace(str, r"(\d)_(\d)" => s"\1\2")
    str = replace(str, r"(\d)_(\d)" => s"\1\2")
    return str
end

function _try_unpromote_type(r::Rational{BigInt})
    for T in (Int128, Int64, Int)
        if typemin(T) ≤ r.num ≤ typemax(T) && typemin(T) ≤ r.den ≤ typemax(T)
            r = Rational{T}(r)
        end
    end
    return r
end
