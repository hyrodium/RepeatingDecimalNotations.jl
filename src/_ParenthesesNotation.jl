struct ParenthesesNotation <: RepeatingDecimalNotation end

function stringify(::ParenthesesNotation, rd::RepeatingDecimal)
    integer_str = string(rd.finite_part)[begin:end-rd.point_position]
    finite_decimal_str = string(rd.finite_part)[end-rd.point_position+1:end]
    if integer_str == ""
        integer_str = "0"
    end
    if rd.period == 0
        rep_str = ""
    else
        rep_str = "($(lpad(string(rd.repeat_part), rd.period, '0')))"
    end
    decimal_part = "$finite_decimal_str$rep_str"
    sign_str = rd.sign ? "" : "-"
    if decimal_part == ""
        return "$sign_str$integer_str"
    else
        return "$sign_str$integer_str.$decimal_part"
    end
end

function RepeatingDecimal(::ParenthesesNotation, str::AbstractString)
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
    elseif !isnothing(match(r"^\d+\.\d+\(\d+\)$", str))
        # "123.45(678)"
        dot_index = findfirst(==('.'), str)
        left_index = findfirst(==('('), str)
        integer_part = str[1:dot_index-1]
        finite_part = str[dot_index+1:left_index-1]
        repeating_part = str[left_index+1:end-1]
        r_repeating = parse(BigInt, repeating_part)
        r_finite = parse(BigInt, integer_part*finite_part)
        return RepeatingDecimal(sign, r_finite, r_repeating, length(finite_part), length(repeating_part))
    elseif !isnothing(match(r"^\d+\.\(\d+\)$", str))
        # "123.(45)"
        dot_index = findfirst(==('.'), str)
        left_index = findfirst(==('('), str)
        integer_part = str[1:dot_index-1]
        repeating_part = str[left_index+1:end-1]
        r_integer = parse(BigInt, integer_part)
        r_repeating = parse(BigInt, repeating_part)
        r_finite = r_integer
        return RepeatingDecimal(sign, r_finite, r_repeating, 0, length(repeating_part))
    elseif !isnothing(match(r"^\.\d+$", str))
        # ".45"
        finite_part = str[2:end]
        r_finite = parse(BigInt, finite_part)
        return RepeatingDecimal(sign, r_finite, big(0), length(finite_part), 1)
    elseif !isnothing(match(r"^\.\d+\(\d+\)$", str))
        # ".45(678)"
        left_index = findfirst(==('('), str)
        finite_part = str[2:left_index-1]
        repeating_part = str[left_index+1:end-1]
        r_finite = parse(BigInt, finite_part)
        r_repeating = parse(BigInt, repeating_part)
        return RepeatingDecimal(sign, r_finite, r_repeating, length(finite_part), length(repeating_part))
    elseif !isnothing(match(r"^\.\(\d+\)$", str))
        # ".(45)"
        repeating_part = str[3:end-1]
        r_repeating = parse(BigInt, repeating_part)
        return RepeatingDecimal(sign, big(0), r_repeating, 0, length(repeating_part))
    else
        error("invalid input!")
    end
end
