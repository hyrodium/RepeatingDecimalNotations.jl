using Test
using Aqua
using RepeatingDecimalNotations
import RepeatingDecimalNotations: rationalify, stringify

Aqua.test_all(RepeatingDecimalNotations)

@testset "@rd_str macro" begin
    @test rd"1.0"    === 1//1
    @test rd"0.(9)"  === 1//1
    @test rd"1.(0)"  === 1//1
    @test rd"0.(3)"  === 1//3
    @test rd".(3)"   === 1//3
    @test rd".(66)"  === 2//3
    @test rd"−1"     === -1//1
    @test rd"-.(09)" === -1//11

    @test rd".45" === rd"0.45"
    @test rd".45(678)" === rd"0.45(678)"
    @test rd".(45)" === rd"0.(45)"

    @test rd"9223372036854775807" === 9223372036854775807//1 isa Rational{Int64}
    @test rd"9223372036854775808" === 9223372036854775808//1 isa Rational{Int128}
    @test rd"-9223372036854775808" === -9223372036854775808//1 isa Rational{Int64}
    @test rd"-9223372036854775809" === -9223372036854775809//1 isa Rational{Int128}
    @test rd"170141183460469231731687303715884105727" === 170141183460469231731687303715884105727//1 isa Rational{Int128}
    @test rd"170141183460469231731687303715884105728" == 170141183460469231731687303715884105728//1 isa Rational{BigInt}
    @test rd"-170141183460469231731687303715884105728" === -170141183460469231731687303715884105728//1 isa Rational{Int128}
    @test rd"-170141183460469231731687303715884105729" == -170141183460469231731687303715884105729//1 isa Rational{BigInt}
end

@testset "stringify" begin
    @test stringify(rd"1.0")           == "1"
    @test stringify(rd"1.01")          == "1.01"
    @test stringify(rd"2.01(44)")      == "2.01(4)"
    @test stringify(rd"2.01(9)")       == "2.02"
    @test stringify(rd"2.01(999)")     == "2.02"
    @test stringify(rd"2.0(999)")      == "2.1"
    @test stringify(rd"2.9(999)")      == "3"
    @test stringify(rd"2.98(999)")     == "2.99"
    @test stringify(rd"2.(999)")       == "3"
    @test stringify(rd"2.00(999)")     == "2.01"
    @test stringify(rd"123.00(45)")    == "123.00(45)"
    @test stringify(rd"123.101(0500)") == "123.101(0500)"
    @test stringify(rd"123.(123123)")  == "123.(123)"
    @test stringify(rd".(123123)")     == "0.(123)"

    @test stringify(1//97) == "0.(010309278350515463917525773195876288659793814432989690721649484536082474226804123711340206185567)"

    @test stringify(ParenthesesNotation(), RepeatingDecimal(1//1)) == "1"
    @test stringify(ParenthesesNotation(), 1//1) == "1"
end

@testset "rationalify" begin
    @test rationalify("1") === 1//1
    @test rationalify("0.1(6)") === 1//6
end

@testset "notations" begin
    @testset "ParenthesesNotation" begin
        no = ParenthesesNotation()
        @test stringify(no, RepeatingDecimal(rd"-123"))        == "-123"
        @test stringify(no, RepeatingDecimal(rd"-123.45"))     == "-123.45"
        @test stringify(no, RepeatingDecimal(rd"123.45(678)")) == "123.45(678)"
        @test stringify(no, RepeatingDecimal(rd"123.(45)"))    == "123.(45)"
        @test stringify(no, RepeatingDecimal(rd".45"))         == "0.45"
        @test stringify(no, RepeatingDecimal(rd".45(678)"))    == "0.45(678)"
        @test stringify(no, RepeatingDecimal(rd".(45)"))       == "0.(45)"

        @test rationalify(RepeatingDecimal(no, "-123"))        == rd"-123"
        @test rationalify(RepeatingDecimal(no, "-123.45"))     == rd"-123.45"
        @test rationalify(RepeatingDecimal(no, "123.45(678)")) == rd"123.45(678)"
        @test rationalify(RepeatingDecimal(no, "123.(45)"))    == rd"123.(45)"
        @test rationalify(RepeatingDecimal(no, ".45"))         == rd".45"
        @test rationalify(RepeatingDecimal(no, ".45(678)"))    == rd".45(678)"
        @test rationalify(RepeatingDecimal(no, ".(45)"))       == rd".(45)"
    end

    @testset "ScientificNotation" begin
        no = ScientificNotation()
        @test stringify(no, RepeatingDecimal(rd"-123"))        == "-123"
        @test stringify(no, RepeatingDecimal(rd"-123.45"))     == "-123.45"
        @test stringify(no, RepeatingDecimal(rd"123.45(678)")) == "123.45r678"
        @test stringify(no, RepeatingDecimal(rd"123.(45)"))    == "123.r45"
        @test stringify(no, RepeatingDecimal(rd".45"))         == "0.45"
        @test stringify(no, RepeatingDecimal(rd".45(678)"))    == "0.45r678"
        @test stringify(no, RepeatingDecimal(rd".(45)"))       == "0.r45"

        @test rationalify(RepeatingDecimal(no, "-123"))       == rd"-123"
        @test rationalify(RepeatingDecimal(no, "-123.45"))    == rd"-123.45"
        @test rationalify(RepeatingDecimal(no, "123.45r678")) == rd"123.45(678)"
        @test rationalify(RepeatingDecimal(no, "123.r45"))    == rd"123.(45)"
        @test rationalify(RepeatingDecimal(no, ".45"))        == rd".45"
        @test rationalify(RepeatingDecimal(no, ".45r678"))    == rd".45(678)"
        @test rationalify(RepeatingDecimal(no, ".r45"))       == rd".(45)"
    end
end
