"""
    ScientificNotation <: RepeatingDecimalNotation

A type to represent a repeating decial with scientific notation like "0.1r6".
```jldoctest
julia> rd"123.45r678"
4111111//33300

julia> no = ScientificNotation()
ScientificNotation()

julia> stringify(no, 1//11)
"0.r09"

julia> rationalify(no, "123.45r678")
4111111//33300

julia> rd"1.2345r678e2"  # Exponent term is supported.
4111111//33300
```
"""
struct ScientificNotation <: RepeatingDecimalNotation end

function isvalidnotaiton(::ScientificNotation, str::AbstractString)
    str = _remove_underscore(str)
    isnothing(match(r"^(\-|−|\+?)([0-9]+)\.?$", str))                                    || return true
    isnothing(match(r"^(\-|−|\+?)([0-9]*)\.([0-9]+)$", str))                             || return true
    isnothing(match(r"^(\-|−|\+?)([0-9]+)\.([0-9]*)r([0-9]+)$", str))                    || return true
    isnothing(match(r"^(\-|−|\+?)\.([0-9]*)r([0-9]+)$", str))                            || return true
    isnothing(match(r"^(\-|−|\+?)([0-9]+)\.([0-9]*)e((\-|−|\+)?[0-9]+)$", str))          || return true
    isnothing(match(r"^(\-|−|\+?)\.([0-9]+)e((\-|−|\+)?[0-9]+)$", str))                  || return true
    isnothing(match(r"^(\-|−|\+?)([0-9]*)\.([0-9]*)r([0-9]+)e((\-|−|\+)?[0-9]+)$", str)) || return true
    return false
end

function stringify(::ScientificNotation, rd::RepeatingDecimal)
    integer_str = string(rd.finite_part)[begin:end-rd.point_position]
    finite_decimal_str = string(rd.finite_part)[end-rd.point_position+1:end]
    if integer_str == ""
        integer_str = "0"
    end
    if rd.period == 0
        rep_str = ""
    else
        rep_str = "r$(lpad(string(rd.repeat_part), rd.period, '0'))"
    end
    decimal_part = "$finite_decimal_str$rep_str"
    sign_str = rd.sign ? "" : "-"
    if decimal_part == ""
        return "$sign_str$integer_str"
    else
        return "$sign_str$integer_str.$decimal_part"
    end
end

function RepeatingDecimal(::ScientificNotation, str::AbstractString)
    str = _remove_underscore(str)
    m = match(r"^(\-|−|\+?)([0-9]+)\.?$", str)
    if !isnothing(m)
        # 123
        # 123.
        # +123
        # +123.
        # -123
        # -123.
        # −123
        # −123.
        sign_str, integer_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, "", "0")
    end
    m = match(r"^(\-|−|\+?)([0-9]*)\.([0-9]+)$", str)
    if !isnothing(m)
        # 123.45
        # .45
        # +123.45
        # +.45
        # -123.45
        # -.45
        # −123.45
        # −.45
        sign_str, integer_str, decimal_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, "0")
    end
    m = match(r"^(\-|−|\+?)([0-9]+)\.([0-9]*)r([0-9]+)$", str)
    if !isnothing(m)
        # 1.234r56
        # 1.r23
        sign_str, integer_str, decimal_str, repeat_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, repeat_str)
    end
    m = match(r"^(\-|−|\+?)\.([0-9]*)r([0-9]+)$", str)
    if !isnothing(m)
        # .234r56
        # .r123
        sign_str, decimal_str, repeat_str = m.captures
        return _repeating_decimal_from_strings(sign_str, "", decimal_str, repeat_str)
    end
    m = match(r"^(\-|−|\+?)([0-9]+)\.([0-9]*)e((\-|−|\+)?[0-9]+)$", str)
    if !isnothing(m)
        # 1.234e56
        # 1.e23
        sign_str, integer_str, decimal_str, exponent_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, "0", exponent_str)
    end
    m = match(r"^(\-|−|\+?)\.([0-9]+)e((\-|−|\+)?[0-9]+)$", str)
    if !isnothing(m)
        # .234e56
        sign_str, decimal_str, exponent_str = m.captures
        return _repeating_decimal_from_strings(sign_str, "", decimal_str, "0", exponent_str)
    end
    m = match(r"^(\-|−|\+?)([0-9]*)\.([0-9]*)r([0-9]+)e((\-|−|\+)?[0-9]+)$", str)
    if !isnothing(m)
        # 1.234r56e2
        # 1.r23e2
        sign_str, integer_str, decimal_str, repeat_str, exponet_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, repeat_str, exponet_str)
    end
    error("invalid input!")
end
