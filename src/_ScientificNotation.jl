struct ScientificNotation <: RepeatingDecimalNotation end

function isvalidnotaiton(::ScientificNotation, str::AbstractString)
    str = _remove_underscore(str)
    m = match(r"^(\-|−?)(\d+)$", str)
    if !isnothing(m)
        # 123
        return true
    end
    m = match(r"^(\-|−?)(\d+)\.(\d*)$", str)
    if !isnothing(m)
        # 123.45, 123.
        return true
    end
    m = match(r"^(\-|−?)\.(\d+)$", str)
    if !isnothing(m)
        # .45
        return true
    end
    m = match(r"^(\-|−?)(\d+)\.(\d*)r(\d+)$", str)
    if !isnothing(m)
        # 123.45r678, 123.r45
        return true
    end
    m = match(r"^(\-|−?)(\d+)\.(\d*)r(\d+)$", str)
    if !isnothing(m)
        # 1.234r56, 1.r23
        return true
    end
    m = match(r"^(\-|−?)\.(\d*)r(\d+)$", str)
    if !isnothing(m)
        # .234r56, .r123
        return true
    end
    m = match(r"^(\-|−?)\.(\d*)r(\d+)e(-?\d)$", str)
    if !isnothing(m)
        # .234r56e2, .r56e2
        return true
    end
    m = match(r"^(\-|−?)(\d+)\.(\d*)r(\d+)e(-?\d)$", str)
    if !isnothing(m)
        # 1.234r56e2, 1.r23e2
        return true
    end
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
    m = match(r"^(\-|−?)(\d+)$", str)
    if !isnothing(m)
        # 123
        sign_str, integer_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, "", "0")
    end
    m = match(r"^(\-|−?)(\d+)\.(\d*)$", str)
    if !isnothing(m)
        # 123.45, 123.
        sign_str, integer_str, decimal_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, "0")
    end
    m = match(r"^(\-|−?)\.(\d+)$", str)
    if !isnothing(m)
        # .45
        sign_str, decimal_str, = m.captures
        return _repeating_decimal_from_strings(sign_str, "", decimal_str, "0")
    end
    m = match(r"^(\-|−?)(\d+)\.(\d*)r(\d+)$", str)
    if !isnothing(m)
        # 123.45r678, 123.r45
        sign_str, integer_str, decimal_str, repeat_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, repeat_str)
    end
    m = match(r"^(\-|−?)(\d+)\.(\d*)r(\d+)$", str)
    if !isnothing(m)
        # 1.234r56, 1.r23
        sign_str, integer_str, decimal_str, repeat_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, repeat_str)
    end
    m = match(r"^(\-|−?)\.(\d*)r(\d+)$", str)
    if !isnothing(m)
        # .234r56, .r123
        sign_str, decimal_str, repeat_str = m.captures
        return _repeating_decimal_from_strings(sign_str, "", decimal_str, repeat_str)
    end
    m = match(r"^(\-|−?)\.(\d*)r(\d+)e(-?\d)$", str)
    if !isnothing(m)
        # .234r56e2, .r56e2
        sign_str, decimal_str, repeat_str, exponet_str = m.captures
        return _repeating_decimal_from_strings(sign_str, "", decimal_str, repeat_str, exponet_str)
    end
    m = match(r"^(\-|−?)(\d+)\.(\d*)r(\d+)e(-?\d)$", str)
    if !isnothing(m)
        # 1.234r56e2, 1.r23e2
        sign_str, integer_str, decimal_str, repeat_str, exponet_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, decimal_str, repeat_str, exponet_str)
    end
    error("invalid input!")
end

function _repeating_decimal_from_strings(sign_str::AbstractString, integer_str::AbstractString, decimal_str::AbstractString, repeat_str::AbstractString, exponet_str::AbstractString)
    period = length(repeat_str)
    point_position = length(decimal_str)
    r_finite = parse(BigInt, '0'*integer_str*decimal_str)
    r_repeat = parse(BigInt, repeat_str)
    sign = sign_str==""
    rd = RepeatingDecimal(sign, r_finite, r_repeat, point_position, period)
    return shift_decimal_point(rd, parse(Int, exponet_str))
end

function _repeating_decimal_from_strings(sign_str::AbstractString, integer_str::AbstractString, decimal_str::AbstractString, repeat_str::AbstractString)
    period = length(repeat_str)
    point_position = length(decimal_str)
    r_finite = parse(BigInt, '0'*integer_str*decimal_str)
    r_repeat = parse(BigInt, repeat_str)
    sign = sign_str==""
    return RepeatingDecimal(sign, r_finite, r_repeat, point_position, period)
end
