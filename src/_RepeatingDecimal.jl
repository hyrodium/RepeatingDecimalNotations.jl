"""
    RepeatingDecimal

Intermediate struct to represent a repeating decimal number.

# Examples
```julia-repl
julia> RepeatingDecimal(false, 12743, 857142, 2, 6)
       2|--|------|6
    -127.43(857142)
----------- --------------
Finite part Repeating part

julia> RepeatingDecimal(1//17)
         0||----------------|16
        +0.(0588235294117647)
----------- -------------------
Finite part Repeating part
```
"""
struct RepeatingDecimal
    sign::Bool  # true/false corresponds to +/-
    finite_part::BigInt  # Finite part, including both integer and decimal parts
    repeat_part::BigInt  # Repeating decimal part, easily overflows in Int64. (e.g. 1//97)
    point_position::Int  # digits of decimal part
    period::Int  # digits of repeating part
end

function RepeatingDecimal(sign::Bool, finite_part::Integer, repeating_part::Integer, m::Integer, n::Integer)
    RepeatingDecimal(sign, BigInt(finite_part), BigInt(repeating_part), Int(m), Int(n))
end

function Base.:(==)(rd1::RepeatingDecimal, rd2::RepeatingDecimal)
    return (rd1.sign == rd2.sign)&(rd1.finite_part == rd2.finite_part)&(rd1.repeat_part == rd2.repeat_part)&(rd1.point_position == rd2.point_position)&(rd1.period == rd2.period)
end

function Base.show(io::IO, rd::RepeatingDecimal)
    sign = rd.sign
    finite_part = rd.finite_part
    repeat_part = rd.repeat_part
    point_position = rd.point_position
    period = rd.period

    integer_str = string(finite_part)[begin:end-point_position]
    integer_str = integer_str=="" ? "0" : integer_str
    finite_decimal_str = string(finite_part)[max(end-point_position+1,1):end]
    finite_decimal_str = lpad(finite_decimal_str, point_position, '0')
    sign_str = sign ? "+" : "-"

    digits_str = "$point_position|"*'-'^point_position*'|'*'-'^period*"|$period"
    number_str = sign_str*integer_str*'.'*finite_decimal_str*"("*lpad(repeat_part,period,'0')[1:period]*")"
    description_str = "Finite part Repeating part"

    digits_left = point_position+3
    number_left = findfirst('(', number_str)
    description_left = 12
    digits_right = length(digits_str) - digits_left
    number_right = length(number_str) - number_left
    description_right = length(description_str) - description_left

    max_left = max(max(digits_left, number_left), description_left)
    max_right = max(max(digits_right, number_right), description_right)

    lines = [
        ' '^(max_left-digits_left)*digits_str
        ' '^(max_left-number_left)*number_str
        '-'^(max_left-1)*' '*'-'^(max_right)
        ' '^(max_left-description_left)*description_str
    ]
    print(io, join(lines, "\n"))
end

function RepeatingDecimal(r::Rational)
    if r < 0
        sign = false
        r = -r
    else
        sign = true
    end
    int = big(floor(Int, r))
    frac = r - int
    pow = 0
    num = big(frac.num)
    den = big(frac.den)
    while true
        if rem(den,10) == 0
            den = den ÷ 10
            pow += 1
        end
        rem(den,10) ≠ 0 && break
    end
    while true
        if rem(den,5) == 0
            num *= 2
            den ÷= 5
            pow += 1
        end
        if rem(den,2) == 0
            num *= 5
            den ÷= 2
            pow += 1
        end
        rem(den,2) ≠ 0 && rem(den,5) ≠ 0 && break
    end
    n = 1
    while true
        rem(big(10)^n-1, den)==0 && break
        n = n+1
    end
    num *= div(big(10)^n-1, den)
    den *= div(big(10)^n-1, den)
    dec, rep = divrem(num,den)
    if rep == 0
        n = 0
    end
    finite = int*10^pow + dec
    return RepeatingDecimal(sign, finite, rep, pow, n)
end

function RepeatingDecimal(str::AbstractString)
    for no in (ParenthesesNotation(), DotsNotation(), ScientificNotation(), EllipsisNotation())
        if isvalidnotaiton(no, str)
            return RepeatingDecimal(no, str)
        end
    end
    error("input string $str is not valid!")
end

function shift_decimal_point(rd::RepeatingDecimal, i::Integer)
    sign = rd.sign
    finite_part = rd.finite_part
    repeat_part = rd.repeat_part
    point_position = rd.point_position
    period = rd.period
    if i == 0
        return rd
    elseif i ≤ point_position
        point_position = point_position - i
        rd = RepeatingDecimal(sign, finite_part, repeat_part, point_position, period)
        return rd
    else
        n = i - point_position
        finite_part *= big(10)^n
        finite_part += parse(BigInt, join([lpad(repeat_part, period, '0')[mod(i, 1:period)] for i in 1:n]))
        repeat_part = parse(BigInt, join([lpad(repeat_part, period, '0')[mod(i+n, 1:period)] for i in 1:period]))
        rd = RepeatingDecimal(sign, finite_part, repeat_part, 0, period)
        return rd
    end
end
