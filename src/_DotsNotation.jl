"""
    DotsNotation <: RepeatingDecimalNotation

A type to represent a repeating decial with parentheses notation like "0.1(6)".
```jldoctest
julia> rd"123.456̇78̇"
4111111//33300

julia> no = DotsNotation()
DotsNotation()

julia> stringify(no, 1//11)
"0.0̇9̇"

julia> rationalify(no, "123.456̇78̇")
4111111//33300
```
"""
struct DotsNotation <: RepeatingDecimalNotation end

function isvalidnotaiton(::DotsNotation, str::AbstractString)
    str = _remove_underscore(str)
    isnothing(match(r"^(\-|−|\+?)([0-9]+)\.?$", str))                       || return true
    isnothing(match(r"^(\-|−|\+?)([0-9]*)\.([0-9]+)$", str))                || return true
    isnothing(match(r"^(\-|−|\+?)([0-9]*)\.([0-9]*)([0-9])̇([0-9]+)̇$", str)) || return true
    isnothing(match(r"^(\-|−|\+?)([0-9]*)\.([0-9]*)([0-9])̇$", str))         || return true
    return false
end

function stringify(::DotsNotation, rd::RepeatingDecimal)
    integer_str = string(rd.finite_part)[begin:end-rd.point_position]
    finite_decimal_str = string(rd.finite_part)[end-rd.point_position+1:end]
    if integer_str == ""
        integer_str = "0"
    end
    if rd.period == 0
        rep_str = ""
    elseif rd.period == 1
        rep_str = "$(lpad(string(rd.repeat_part), rd.period, '0'))"
        rep_str = rep_str * '\u0307'
    else
        rep_str = "$(lpad(string(rd.repeat_part), rd.period, '0'))"
        rep_str = rep_str[1] * '\u0307' * rep_str[2:end] * '\u0307'
    end
    decimal_part = "$finite_decimal_str$rep_str"
    sign_str = rd.sign ? "" : "-"
    if decimal_part == ""
        return "$sign_str$integer_str"
    else
        return "$sign_str$integer_str.$decimal_part"
    end
end

function RepeatingDecimal(::DotsNotation, str::AbstractString)
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
    # ⋅⇒\dot r"^(\-|−|\+?)([0-9]*)\.([0-9]*)([0-9])⋅([0-9]+)⋅$"
    m = match(r"^(\-|−|\+?)([0-9]*)\.([0-9]*)([0-9])̇([0-9]+)̇$", str)
    if !isnothing(m)
        # 1.2345̇6̇
        # 1.2̇3̇
        sign_str, integer_str, decimal_str, repeat_str1, repeat_str2 = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, repeat_str1 * repeat_str2)
    end
    # ⋅⇒\dot r"^(\-|−|\+?)([0-9]*)\.([0-9]*)([0-9])⋅$"
    m = match(r"^(\-|−|\+?)([0-9]*)\.([0-9]*)([0-9])̇$", str)
    if !isnothing(m)
        # 1.2345̇
        # 1.2̇
        sign_str, integer_str, decimal_str, repeat_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, repeat_str)
    end
    error("invalid input!")
end
