module RepeatingDecimalNotations

export @rd_str
export repeating_decimal_notation
export ParenthesesNotation
export RepeatingDecimal

abstract type RepeatingDecimalNotation end

struct ParenthesesNotation <: RepeatingDecimalNotation end

struct RepeatingDecimal{T<:Integer}
    sign::Bool  # sign
    int::BigInt  # Integer part
    dec::BigInt  # decimal part
    rep::BigInt  # repeating part
    m::Int  # digits of decimal part
    n::Int  # digits of repeating part
end

function RepeatingDecimal(r::Rational)
    int = big(floor(Int, r))
    frac = r - int
    cof = 1//1
    num = big(frac.num)
    den = big(frac.den)
    while true
        if rem(den,10) == 0
            den = den ÷ 10
            cof //= 10
        end
        rem(den,10) ≠ 0 && break
    end
    while true
        if rem(den,5) == 0
            num *= 2
            den ÷= 5
            cof //= 10
        end
        if rem(den,2) == 0
            num *= 5
            den ÷= 2
            cof //= 10
        end
        rem(den,2) ≠ 0 && rem(den,5) ≠ 0 && break
    end
    m = Int(log10(inv(cof)))
    n = 1
    while true
        rem(big(10)^n-1, den)==0 && break
        n = n+1
    end
    num *= div(big(10)^n-1, den)
    den *= div(big(10)^n-1, den)
    dec, rep = divrem(num,den)
    return RepeatingDecimal(true, int, dec, rep, m, n)
end

# Defaults to `ParenthesesNotation`
repeating_decimal_notation(rd::RepeatingDecimal) = repeating_decimal_notation(ParenthesesNotation(), rd)
repeating_decimal_notation(r::Union{Integer, Rational}) = repeating_decimal_notation(RepeatingDecimal(r))

function repeating_decimal_notation(::ParenthesesNotation, rd::RepeatingDecimal)
    int = rd.int
    dec = rd.dec
    rep = rd.rep
    m = rd.m
    n = rd.n
    int_str = string(int)
    if dec == 0 && m == 0
        dec_str = ""
    else
        dec_str = lpad(string(dec), m, '0')
    end
    rep_str = lpad(string(rep), n, '0')

    "$int_str.$dec_str($rep_str)"
end

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
