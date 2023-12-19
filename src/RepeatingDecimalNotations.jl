module RepeatingDecimalNotations

export @rd_str

macro rd_str(str)
    str = replace(str, r"(\d)_(\d)" => s"\1\2")
    str = replace(str, r"(\d)_(\d)" => s"\1\2")
    if !isnothing(match(r"^\d+$", str))
        # "123"
        integer_part = str
        num = parse(Int, integer_part)
        return num
    elseif !isnothing(match(r"^\d*\.\d+$", str))
        # "123.45"
        dot_index = findfirst(==('.'), str)
        integer_part = str[1:dot_index-1]
        decimal_part = str[dot_index+1:end]
        return _int_dec_rep(integer_part, decimal_part, "0")
    elseif !isnothing(match(r"^\d*\.\d+\(\d+\)$", str))
        # "123.45(678)"
        dot_index = findfirst(==('.'), str)
        left_index = findfirst(==('('), str)
        integer_part = str[1:dot_index-1]
        decimal_part = str[dot_index+1:left_index-1]
        repeat_part = str[left_index+1:end-1]
        return _int_dec_rep(integer_part, decimal_part, repeat_part)
    elseif !isnothing(match(r"^\d+\.\(\d+\)$", str))
        # "123.(45)"
        dot_index = findfirst(==('.'), str)
        left_index = findfirst(==('('), str)
        integer_part = str[1:dot_index-1]
        repeat_part = str[left_index+1:end-1]
        return _int_rep(integer_part, repeat_part)
    elseif !isnothing(match(r"^\.\(\d+\)$", str))
        # ".(45)"
        repeat_part = str[3:end-1]
        return _int_rep("0", repeat_part)
    else
        error("invalid input!")
    end
end

function _int_dec_rep(integer_part::AbstractString, decimal_part::AbstractString, repeat_part::AbstractString)
    decimal_digits = length(decimal_part)
    repeat_digits = length(repeat_part)
    integer_num = parse(Int, integer_part)
    decimal_num = parse(Int, decimal_part)
    repeat_num = parse(Int, repeat_part)//(10^repeat_digits-1)
    num = integer_num
    num += decimal_num//(10^decimal_digits)
    num += repeat_num//(10^decimal_digits)
    return num
end

function _int_rep(integer_part::AbstractString, repeat_part::AbstractString)
    repeat_digits = length(repeat_part)
    integer_num = parse(Int, integer_part)
    repeat_num = parse(Int, repeat_part)//(10^repeat_digits-1)
    num = integer_num
    num += repeat_num
    return num
end

end # module RepeatingDecimalNotations
