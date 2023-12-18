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
        decimal_digits = length(decimal_part)
        integer_num = parse(Int, integer_part)
        decimal_num = parse(Int, decimal_part)
        num = integer_num + decimal_num//(10^decimal_digits)
        return num
    elseif !isnothing(match(r"^\d*\.\d+\(\d+\)$", str))
        # "123.45(678)"
        dot_index = findfirst(==('.'), str)
        left_index = findfirst(==('('), str)
        integer_part = str[1:dot_index-1]
        decimal_part = str[dot_index+1:left_index-1]
        repeat_part = str[left_index+1:end-1]
        decimal_digits = length(decimal_part)
        repeat_digits = length(repeat_part)
        integer_num = parse(Int, integer_part)
        decimal_num = parse(Int, decimal_part)
        repeat_num = parse(Int, repeat_part)//(10^repeat_digits-1)
        num = integer_num
        num += decimal_num//(10^decimal_digits)
        num += repeat_num//(10^decimal_digits)
        return num
    elseif !isnothing(match(r"^\d*\.\(\d+\)$", str))
        # "123.(45)"
        dot_index = findfirst(==('.'), str)
        left_index = findfirst(==('('), str)
        integer_part = str[1:dot_index-1]
        repeat_part = str[left_index+1:end-1]
        repeat_digits = length(repeat_part)
        integer_num = parse(Int, integer_part)
        repeat_num = parse(Int, repeat_part)//(10^repeat_digits-1)
        num = integer_num
        num += repeat_num
        return num
    else
        error("invalid input!")
    end
end

end # module RepeatingDecimalNotations
