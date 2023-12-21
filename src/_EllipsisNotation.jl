struct EllipsisNotation <: RepeatingDecimalNotation end

m = match(r"^(-|−?)(\d+)\.(\d*)(\d\d+)\4{1,}\.\.\.$", "-12.12341234...")

function isvalidnotaiton(::EllipsisNotation, str::AbstractString)
    str = _remove_underscore(str)
    m = match(r"^(\-|−?)(\d+)$", str)
    isnothing(m) || return true
    m = match(r"^(\-|−?)(\d*)\.(\d+)$", str)
    isnothing(m) || return true
    m = match(r"^(\-|−?)(\d*)\.(\d*)(\d\d+)\4{1,}\.\.\.$", str)
    isnothing(m) || return true
    m = match(r"^(\-|−?)(\d*)\.(\d*)(\d)\4{2,}\.\.\.$", str)
    isnothing(m) || return true
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
    m = match(r"^(\-|−?)(\d+)$", str)
    if !isnothing(m)
        # "-1234"
        sign_str, integer_str = m.captures
        period = 1
        point_position = 0
        r_finite = parse(BigInt, integer_str)
        r_repeat = 0
        sign = sign_str==""
        return RepeatingDecimal(sign, r_finite, r_repeat, point_position, period)
    end
    m = match(r"^(\-|−?)(\d*)\.(\d+)$", str)
    if !isnothing(m)
        # "-123.4"
        sign_str, integer_str, decimal_str = m.captures
        period = 1
        point_position = length(decimal_str)
        r_finite = parse(BigInt, '0'*integer_str*decimal_str)
        r_repeat = 0
        sign = sign_str==""
        return RepeatingDecimal(sign, r_finite, r_repeat, point_position, period)
    end
    m = match(r"^(\-|−?)(\d*)\.(\d*)(\d\d+)\4{1,}\.\.\.$", str)
    if !isnothing(m)
        # "-123.45656..."
        sign_str, integer_str, decimal_str, repeat_str = m.captures
        period = length(repeat_str)
        point_position = length(decimal_str)
        r_finite = parse(BigInt, '0'*integer_str*decimal_str)
        r_repeat = parse(BigInt, repeat_str)
        sign = sign_str==""
        return RepeatingDecimal(sign, r_finite, r_repeat, point_position, period)
    end
    m = match(r"^(\-|−?)(\d*)\.(\d*)(\d)\4{2,}\.\.\.$", str)
    if !isnothing(m)
        # "-123.4333..."
        sign_str, integer_str, decimal_str, repeat_str = m.captures
        period = length(repeat_str)
        point_position = length(decimal_str)
        r_finite = parse(BigInt, '0'*integer_str*decimal_str)
        r_repeat = parse(BigInt, repeat_str)
        sign = sign_str==""
        return RepeatingDecimal(sign, r_finite, r_repeat, point_position, period)
    end
    error("invalid input!")
end
