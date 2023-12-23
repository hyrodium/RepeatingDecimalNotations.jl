"""
    EllipsisNotation <: RepeatingDecimalNotation

A type to represent a repeating decial with ellipsis notation like "0.1666...".
```jldoctest
julia> rd"123.45678678..."
4111111//33300

julia> no = EllipsisNotation()
EllipsisNotation()

julia> stringify(no, 1//11)
"0.0909..."

julia> rationalify(no, "123.45678678...")
4111111//33300

julia> rd"0.4545..."      # Same as 0.(45), repeating [45] two times
5//11

julia> rd"0.333..."       # Same as 0.(3), repeating one digit [3] three times
1//3

julia> rd"0.13331333..."  # Same as 0.(1333), repeating [1333] has priority over repeating [3]
1333//9999

julia> rd"0.133313333..." # Same as 0.13331(3), adding additional [3] resolves the ambiguity.
19997//150000
```
"""
struct EllipsisNotation <: RepeatingDecimalNotation end

function isvalidnotaiton(::EllipsisNotation, str::AbstractString)
    str = _remove_underscore(str)
    isnothing(match(r"^(\-|−|\+?)(\d+)$", str))                           || return true
    isnothing(match(r"^(\-|−|\+?)(\d*)\.(\d+)$", str))                    || return true
    isnothing(match(r"^(\-|−|\+?)(\d*)\.(\d*)(\d\d+)\4{1,}\.\.\.$", str)) || return true
    isnothing(match(r"^(\-|−|\+?)(\d*)\.(\d*)(\d)\4{2,}\.\.\.$", str))    || return true
    return false
end

function stringify(::EllipsisNotation, rd::RepeatingDecimal)
    integer_str = string(rd.finite_part)[begin:end-rd.point_position]
    finite_decimal_str = string(rd.finite_part)[end-rd.point_position+1:end]
    if integer_str == ""
        integer_str = "0"
    end
    if rd.period == 0
        rep_str = ""
    elseif rd.period == 1
        tmp = rd.repeat_part
        rep_str = "$tmp$tmp$tmp..."
    else
        tmp = lpad(string(rd.repeat_part), rd.period, '0')
        rep_str = "$tmp$tmp..."
    end
    decimal_part = "$finite_decimal_str$rep_str"
    sign_str = rd.sign ? "" : "-"
    if decimal_part == ""
        return "$sign_str$integer_str"
    else
        return "$sign_str$integer_str.$decimal_part"
    end
end

function RepeatingDecimal(::EllipsisNotation, str::AbstractString)
    str = _remove_underscore(str)
    m = match(r"^(\-|−|\+?)(\d+)\.?$", str)
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
    m = match(r"^(\-|−|\+?)(\d*)\.(\d+)$", str)
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
    m = match(r"^(\-|−|\+?)(\d*)\.(\d*)(\d\d+)\4{1,}\.\.\.$", str)
    if !isnothing(m)
        # "-123.45656..."
        sign_str, integer_str, decimal_str, repeat_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, repeat_str)
    end
    m = match(r"^(\-|−|\+?)(\d*)\.(\d*)(\d)\4{2,}\.\.\.$", str)
    if !isnothing(m)
        # "-123.4333..."
        sign_str, integer_str, decimal_str, repeat_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, repeat_str)
    end
    error("invalid input!")
end
