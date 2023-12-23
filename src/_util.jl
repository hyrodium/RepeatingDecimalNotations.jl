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

function _repeating_decimal_from_strings(sign_str::AbstractString, integer_str::AbstractString, decimal_str::AbstractString, repeat_str::AbstractString)
    period = length(repeat_str)
    point_position = length(decimal_str)
    r_finite = parse(BigInt, '0'*integer_str*decimal_str)
    r_repeat = parse(BigInt, repeat_str)
    sign = sign_str in ("", "+")
    return RepeatingDecimal(sign, r_finite, r_repeat, point_position, period)
end

function _repeating_decimal_from_strings(sign_str::AbstractString, integer_str::AbstractString, decimal_str::AbstractString, repeat_str::AbstractString, exponet_str::AbstractString)
    rd = _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, repeat_str)
    if exponet_str[1] == '−'
        exponet_str = exponet_str[nextind(exponet_str, 1):end]
        return shift_decimal_point(rd, -parse(Int, exponet_str))
    else
        return shift_decimal_point(rd, parse(Int, exponet_str))
    end
end
