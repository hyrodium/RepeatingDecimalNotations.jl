struct ScientificNotation <: RepeatingDecimalNotation end

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
    i = firstindex(str)
    local sign
    if str[i] == '-' || str[i] == '−'
        sign = false
        str = str[nextind(str, i):end]
    else
        sign = true
    end
    if !isnothing(match(r"^\d+$", str))
        # "123"
        integer_part = str
        r_integer = parse(BigInt, integer_part)
        return RepeatingDecimal(sign, r_integer, big(0), 0, 1)
    elseif !isnothing(match(r"^\d+\.\d+$", str))
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
    elseif !isnothing(match(r"^\.r\d+$", str))
        # ".r45"
        repeating_part = str[3:end]
        r_repeating = parse(BigInt, repeating_part)
        return RepeatingDecimal(sign, big(0), r_repeating, 0, length(repeating_part))
    else
        error("invalid input!")
    end
end
