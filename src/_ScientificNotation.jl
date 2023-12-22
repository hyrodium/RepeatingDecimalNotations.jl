struct ScientificNotation <: RepeatingDecimalNotation end

function isvalidnotaiton(::ScientificNotation, _str::AbstractString)
    str = _remove_underscore(_str)
    i = firstindex(str)
    if str[i] == '-' || str[i] == '−'
        str = str[nextind(str, i):end]
    end
    if !isnothing(match(r"^(\-|−?)(\d+)$", _str))
        # "123"
        return true
    elseif !isnothing(match(r"^\d+\.\d+$", str))
        # "123.45"
        return true
    elseif !isnothing(match(r"^\d+\.\d+r\d+$", str))
        # "123.45r678"
        return true
    elseif !isnothing(match(r"^\d+\.r\d+$", str))
        # "123.r45"
        return true
    elseif !isnothing(match(r"^\.\d+$", str))
        # ".45"
        return true
    elseif !isnothing(match(r"^\.\d+r\d+$", str))
        # ".45r678"
        return true
    elseif !isnothing(match(r"^(\-|−?)\.r(\d+)$", _str))
        # ".r45"
        return true
    elseif !isnothing(match(r"^(\-|−?)\.(\d+)r(\d+)e(-?\d)$", _str))
        return true
    elseif !isnothing(match(r"^(\-|−?)(\d+)\.(\d*)r(\d+)e(-?\d)$", _str))
        return true
    else
        return false
    end
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

function RepeatingDecimal(::ScientificNotation, _str::AbstractString)
    str = _remove_underscore(_str)
    i = firstindex(str)
    local sign
    if str[i] == '-' || str[i] == '−'
        sign = false
        str = str[nextind(str, i):end]
    else
        sign = true
    end
    m = match(r"^(\-|−?)(\d+)$", _str)
    if !isnothing(m)
        # "123"
        sign_str, integer_str = m.captures
        return _repeating_decimal_from_strings(sign_str, integer_str, "", "0")
    end
    if !isnothing(match(r"^\d+\.\d+$", str))
        # "123.45"
        dot_index = findfirst(==('.'), str)
        integer_part = str[1:dot_index-1]
        finite_part = str[dot_index+1:end]
        r_finite = parse(BigInt, integer_part*finite_part)
        return RepeatingDecimal(sign, r_finite, big(0), length(finite_part), 1)
    elseif !isnothing(match(r"^\d+\.\d+r\d+$", str))
        # "123.45r678"
        dot_index = findfirst(==('.'), str)
        left_index = findfirst(==('r'), str)
        integer_part = str[1:dot_index-1]
        finite_part = str[dot_index+1:left_index-1]
        repeating_part = str[left_index+1:end]
        r_repeating = parse(BigInt, repeating_part)
        r_finite = parse(BigInt, integer_part*finite_part)
        return RepeatingDecimal(sign, r_finite, r_repeating, length(finite_part), length(repeating_part))
    elseif !isnothing(match(r"^\d+\.r\d+$", str))
        # "123.r45"
        dot_index = findfirst(==('.'), str)
        left_index = findfirst(==('r'), str)
        integer_part = str[1:dot_index-1]
        repeating_part = str[left_index+1:end]
        r_integer = parse(BigInt, integer_part)
        r_repeating = parse(BigInt, repeating_part)
        r_finite = r_integer
        return RepeatingDecimal(sign, r_finite, r_repeating, 0, length(repeating_part))
    elseif !isnothing(match(r"^\.\d+$", str))
        # ".45"
        finite_part = str[2:end]
        r_finite = parse(BigInt, finite_part)
        return RepeatingDecimal(sign, r_finite, big(0), length(finite_part), 1)
    elseif !isnothing(match(r"^\.\d+r\d+$", str))
        # ".45r678"
        left_index = findfirst(==('r'), str)
        finite_part = str[2:left_index-1]
        repeating_part = str[left_index+1:end]
        r_finite = parse(BigInt, finite_part)
        r_repeating = parse(BigInt, repeating_part)
        return RepeatingDecimal(sign, r_finite, r_repeating, length(finite_part), length(repeating_part))
    end
    m = match(r"^(\-|−?)\.r(\d+)$", _str)
    if !isnothing(m)
        # .234r56
        sign_str, repeat_str, = m.captures
        return _repeating_decimal_from_strings(sign_str, "", "", repeat_str)
    end
    m = match(r"^(\-|−?)\.(\d+)r(\d+)e(-?\d)$", _str)
    if !isnothing(m)
        # .234r56e2
        sign_str, decimal_str, repeat_str, exponet_str = m.captures
        return _repeating_decimal_from_strings(sign_str, "", decimal_str, repeat_str, exponet_str)
    end
    m = match(r"^(\-|−?)(\d+)\.(\d*)r(\d+)e(-?\d)$", _str)
    if !isnothing(m)
        # 1.234r56e2
        # 1.r23e2
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
