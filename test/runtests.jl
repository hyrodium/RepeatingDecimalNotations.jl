using Test
using RepeatingDecimalNotations

@testset "@rd_str macro" begin
    @test rd"1"     === 1
    @test rd"1.0"   === 1//1
    @test rd"0.(9)" === 1//1
    @test rd"1.(0)" === 1//1
    @test rd"0.(3)" === 1//3
    @test rd".(3)"  === 1//3
    @test rd".(33)" === 1//3
end

@testset "repeating_decimal_notation" begin
    @test repeating_decimal_notation(RepeatingDecimal(rd"1.0")) == "1.(0)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"1.01")) == "1.01(0)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"2.01(44)")) == "2.01(4)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"2.01(9)")) == "2.02(0)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"2.01(999)")) == "2.02(0)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"2.0(999)")) == "2.1(0)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"2.9(999)")) == "3.(0)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"2.98(999)")) == "2.99(0)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"2.(999)")) == "3.(0)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"2.00(999)")) == "2.01(0)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"123.00(45)")) == "123.00(45)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"123.101(0500)")) == "123.101(0500)"
    @test repeating_decimal_notation(RepeatingDecimal(rd"123.(123123)")) == "123.(123)"
    @test repeating_decimal_notation(RepeatingDecimal(rd".(123123)")) == "0.(123)"
    @test repeating_decimal_notation(RepeatingDecimal(1//97)) == "0.(010309278350515463917525773195876288659793814432989690721649484536082474226804123711340206185567)"
end
