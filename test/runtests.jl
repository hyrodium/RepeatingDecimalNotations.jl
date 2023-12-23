using Test
using Aqua
using RepeatingDecimalNotations
import RepeatingDecimalNotations: rationalify, stringify
import RepeatingDecimalNotations: shift_decimal_point

Aqua.test_all(RepeatingDecimalNotations)

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

@testset "RepeatingDecimal" begin
    @testset "show" begin
        rd = RepeatingDecimal("14.5(64)")
        @test string(rd)*"\n" == """
                1|-|--|2
              +14.5(64)
        ----------- --------------
        Finite part Repeating part
        """

        rd = RepeatingDecimal("0.00145(64)")
        @test string(rd)*"\n" == """
            5|-----|--|2
           +0.00145(64)
        ----------- --------------
        Finite part Repeating part
        """

        rd = RepeatingDecimal("0")
        @test string(rd)*"\n" == """
                 0||-|1
                +0.(0)
        ----------- --------------
        Finite part Repeating part
        """

        rd = RepeatingDecimal("0.001")
        @test string(rd)*"\n" == """
              3|---|-|1
             +0.001(0)
        ----------- --------------
        Finite part Repeating part
        """

        rd = RepeatingDecimal(1//7)
        @test string(rd)*"\n" == """
                 0||------|6
                +0.(142857)
        ----------- --------------
        Finite part Repeating part
        """
    end

    @testset "shift_decimal_point" begin
        @testset for rd in [
            RepeatingDecimal("14.5(64)")
            RepeatingDecimal("0.00145(64)")
            RepeatingDecimal("0")
            RepeatingDecimal("0.001")
            RepeatingDecimal(1//7)
        ]
            @testset for n in -5:5
                _rd = shift_decimal_point(rd, n)
                @test rationalify(_rd) == rationalify(rd)*(10//1)^n
            end
        end
    end
end

@testset "notations" begin
    @testset "integer" begin
        @testset for no in (ParenthesesNotation(), ScientificNotation(), EllipsisNotation())
            @test stringify(no, RepeatingDecimal(rd"123"))   == "123"
            @test stringify(no, RepeatingDecimal(rd"123."))  == "123"
            @test stringify(no, RepeatingDecimal(rd"+123"))  == "123"
            @test stringify(no, RepeatingDecimal(rd"+123.")) == "123"
            @test stringify(no, RepeatingDecimal(rd"-123"))  == "-123"
            @test stringify(no, RepeatingDecimal(rd"-123.")) == "-123"
            @test stringify(no, RepeatingDecimal(rd"−123"))  == "-123"
            @test stringify(no, RepeatingDecimal(rd"−123.")) == "-123"

            @test rationalify(RepeatingDecimal(no, "123"))   == 123//1
            @test rationalify(RepeatingDecimal(no, "123."))  == 123//1
            @test rationalify(RepeatingDecimal(no, "+123"))  == 123//1
            @test rationalify(RepeatingDecimal(no, "+123.")) == 123//1
            @test rationalify(RepeatingDecimal(no, "-123"))  == -123//1
            @test rationalify(RepeatingDecimal(no, "-123.")) == -123//1
            @test rationalify(RepeatingDecimal(no, "−123"))  == -123//1
            @test rationalify(RepeatingDecimal(no, "−123.")) == -123//1
        end
    end

    @testset "non-repeating decimal" begin
        @testset for no in (ParenthesesNotation(), ScientificNotation(), EllipsisNotation())
            @test stringify(no, RepeatingDecimal(rd"123.45"))  == "123.45"
            @test stringify(no, RepeatingDecimal(rd".45"))     == "0.45"
            @test stringify(no, RepeatingDecimal(rd"+123.45")) == "123.45"
            @test stringify(no, RepeatingDecimal(rd"+.45"))    == "0.45"
            @test stringify(no, RepeatingDecimal(rd"-123.45")) == "-123.45"
            @test stringify(no, RepeatingDecimal(rd"-.45"))    == "-0.45"
            @test stringify(no, RepeatingDecimal(rd"−123.45")) == "-123.45"
            @test stringify(no, RepeatingDecimal(rd"−.45"))    == "-0.45"

            @test rationalify(RepeatingDecimal(no, "123.45"))  == 12345//100
            @test rationalify(RepeatingDecimal(no, ".45"))     == 45//100
            @test rationalify(RepeatingDecimal(no, "+123.45")) == 12345//100
            @test rationalify(RepeatingDecimal(no, "+.45"))    == 45//100
            @test rationalify(RepeatingDecimal(no, "-123.45")) == -12345//100
            @test rationalify(RepeatingDecimal(no, "-.45"))    == -45//100
            @test rationalify(RepeatingDecimal(no, "−123.45")) == -12345//100
            @test rationalify(RepeatingDecimal(no, "−.45"))    == -45//100
        end
    end

    @testset "invalid non-repeating decimal" begin
        @testset for no in (ParenthesesNotation(), ScientificNotation(), EllipsisNotation())
            @test_throws ErrorException RepeatingDecimal(no, "123.4.5")
            @test_throws ErrorException RepeatingDecimal(no, "++1235")
            @test_throws ErrorException RepeatingDecimal(no, "12__3")
            @test_throws ErrorException RepeatingDecimal(no, "1_2_3_")
            @test_throws ErrorException RepeatingDecimal(no, "_1_2_3")
            @test_throws ErrorException RepeatingDecimal(no, "1_2._3")
            @test_throws ErrorException RepeatingDecimal(no, "1_2_.3")
            @test_throws ErrorException RepeatingDecimal(no, " 123")
            @test_throws ErrorException RepeatingDecimal(no, " 123 ")
            @test_throws ErrorException RepeatingDecimal(no, "..45")
            @test_throws ErrorException RepeatingDecimal(no, "-+123.45")
            @test_throws ErrorException RepeatingDecimal(no, "-.")
            @test_throws ErrorException RepeatingDecimal(no, "−−123.45")
        end
    end

    @testset "ParenthesesNotation" begin
        no = ParenthesesNotation()
        @testset "basic repeating decimal" begin
            @test stringify(no, RepeatingDecimal(rd"123.45(678)")) == "123.45(678)"
            @test stringify(no, RepeatingDecimal(rd"123.(45)"))    == "123.(45)"
            @test stringify(no, RepeatingDecimal(rd".45(678)"))    == "0.45(678)"
            @test stringify(no, RepeatingDecimal(rd".(45)"))       == "0.(45)"
            @test rationalify(RepeatingDecimal(no, "123.45(678)")) == rd"123.45(678)"
            @test rationalify(RepeatingDecimal(no, "123.(45)"))    == rd"123.(45)"
            @test rationalify(RepeatingDecimal(no, ".45(678)"))    == rd".45(678)"
            @test rationalify(RepeatingDecimal(no, ".(45)"))       == rd".(45)"
        end
        @testset "one-digit-repeating" begin
            @test stringify(no, 1//3) == "0.(3)"
            @test stringify(no, 0//1) == "0"
            @test stringify(no, 1//1) == "1"
            @test rationalify(RepeatingDecimal(no, ".(3)")) == 1//3
            @test rationalify(RepeatingDecimal(no, ".(0)")) == 0
            @test rationalify(RepeatingDecimal(no, ".(9)")) == 1
            @test rationalify(RepeatingDecimal(no, "0.(3)")) == 1//3
            @test rationalify(RepeatingDecimal(no, "0.(0)")) == 0
            @test rationalify(RepeatingDecimal(no, "0.(9)")) == 1
        end
        @testset "invalid repeating decimal" begin
            @test_throws ErrorException RepeatingDecimal(no, "123.4()")
            @test_throws ErrorException RepeatingDecimal(no, "123.()")
            @test_throws ErrorException RepeatingDecimal(no, "123..()")
            @test_throws ErrorException RepeatingDecimal(no, "123.(4.5)")
            @test_throws ErrorException RepeatingDecimal(no, "123(4.5)")
            @test_throws ErrorException RepeatingDecimal(no, ".(4.5)")
            @test_throws ErrorException RepeatingDecimal(no, ".(45)3")
            @test_throws ErrorException RepeatingDecimal(no, "12.(453")
            @test_throws ErrorException RepeatingDecimal(no, "12.453)")
            @test_throws ErrorException RepeatingDecimal(no, "12(.)453")
            @test_throws ErrorException RepeatingDecimal(no, "()12453")
        end
    end

    @testset "ScientificNotation" begin
        no = ScientificNotation()
        @testset "basic repeating decimal" begin
            @test stringify(no, RepeatingDecimal(rd"123.45(678)")) == "123.45r678"
            @test stringify(no, RepeatingDecimal(rd"123.(45)"))    == "123.r45"
            @test stringify(no, RepeatingDecimal(rd".45(678)"))    == "0.45r678"
            @test stringify(no, RepeatingDecimal(rd".(45)"))       == "0.r45"
            @test rationalify(RepeatingDecimal(no, "123.45r678")) == rd"123.45(678)"
            @test rationalify(RepeatingDecimal(no, "123.r45"))    == rd"123.(45)"
            @test rationalify(RepeatingDecimal(no, ".45r678"))    == rd".45(678)"
            @test rationalify(RepeatingDecimal(no, ".r45"))       == rd".(45)"
        end
        @testset "one-digit-repeating" begin
            @test stringify(no, 1//3) == "0.r3"
            @test stringify(no, 0//1) == "0"
            @test stringify(no, 1//1) == "1"
            @test rationalify(RepeatingDecimal(no, ".r3")) == 1//3
            @test rationalify(RepeatingDecimal(no, ".r0")) == 0
            @test rationalify(RepeatingDecimal(no, ".r9")) == 1
            @test rationalify(RepeatingDecimal(no, "0.r3")) == 1//3
            @test rationalify(RepeatingDecimal(no, "0.r0")) == 0
            @test rationalify(RepeatingDecimal(no, "0.r9")) == 1
        end
        @testset "invalid repeating decimal" begin
            @test_throws ErrorException RepeatingDecimal(no, "123.4r")
            @test_throws ErrorException RepeatingDecimal(no, "123.r")
            @test_throws ErrorException RepeatingDecimal(no, "123..r")
            @test_throws ErrorException RepeatingDecimal(no, "123.r4.5")
            @test_throws ErrorException RepeatingDecimal(no, "123r4.5)")
            @test_throws ErrorException RepeatingDecimal(no, ".r4.5")
            @test_throws ErrorException RepeatingDecimal(no, ".r45r3")
            @test_throws ErrorException RepeatingDecimal(no, "12.r_453")
            @test_throws ErrorException RepeatingDecimal(no, "12.453r_")
            @test_throws ErrorException RepeatingDecimal(no, "12r.453")
            @test_throws ErrorException RepeatingDecimal(no, "r12453")
        end
        @testset "exponent term" begin
            @testset for str in [
                ".234r56"
                ".r56"
                "1.234r56"
                "1.r23"
            ]
                @testset for i in 0:5
                    @test rationalify(RepeatingDecimal(no, "$(str)e$(i)"))  == rationalify(RepeatingDecimal(no, str)) * (10//1)^i
                    @test rationalify(RepeatingDecimal(no, "$(str)e+$(i)"))  == rationalify(RepeatingDecimal(no, str)) * (10//1)^i
                    @test rationalify(RepeatingDecimal(no, "$(str)e-$(i)"))  == rationalify(RepeatingDecimal(no, str)) * (1//10)^i
                    @test rationalify(RepeatingDecimal(no, "$(str)e−$(i)"))  == rationalify(RepeatingDecimal(no, str)) * (1//10)^i
                end
            end
        end
    end

    @testset "EllipsisNotation" begin
        no = EllipsisNotation()
        @testset "basic repeating decimal" begin
            @test stringify(no, RepeatingDecimal(rd"123.45(678)")) == "123.45678678..."
            @test stringify(no, RepeatingDecimal(rd"123.(45)"))    == "123.4545..."
            @test stringify(no, RepeatingDecimal(rd".45(678)"))    == "0.45678678..."
            @test stringify(no, RepeatingDecimal(rd".(45)"))       == "0.4545..."
            @test rationalify(RepeatingDecimal(no, "123.45678678...")) == rd"123.45(678)"
            @test rationalify(RepeatingDecimal(no, "123.4545..."))     == rd"123.(45)"
            @test rationalify(RepeatingDecimal(no, ".45678678..."))    == rd".45(678)"
            @test rationalify(RepeatingDecimal(no, ".4545..."))        == rd".(45)"
        end
        @testset "one-digit-repeating" begin
            @test stringify(no, 1//3) == "0.333..."
            @test stringify(no, 0//1) == "0"
            @test stringify(no, 1//1) == "1"
            @test rationalify(RepeatingDecimal(no, ".333...")) == 1//3
            @test rationalify(RepeatingDecimal(no, ".000...")) == 0
            @test rationalify(RepeatingDecimal(no, ".999...")) == 1
            @test rationalify(RepeatingDecimal(no, "0.333...")) == 1//3
            @test rationalify(RepeatingDecimal(no, "0.000...")) == 0
            @test rationalify(RepeatingDecimal(no, "0.999...")) == 1
        end
        @testset "invalid repeating decimal" begin
            @test_throws ErrorException RepeatingDecimal(no, "123.4...")
            @test_throws ErrorException RepeatingDecimal(no, "123....")
            @test_throws ErrorException RepeatingDecimal(no, "123...")
            @test_throws ErrorException RepeatingDecimal(no, "123.44...5")
            @test_throws ErrorException RepeatingDecimal(no, "123...4.5)")
            @test_throws ErrorException RepeatingDecimal(no, "123.12345...")
            @test_throws ErrorException RepeatingDecimal(no, ".4545...3")
            @test_throws ErrorException RepeatingDecimal(no, "12.453.453...")
            @test_throws ErrorException RepeatingDecimal(no, "12.453_...")
            @test_throws ErrorException RepeatingDecimal(no, "12.453_453....")
            @test_throws ErrorException RepeatingDecimal(no, "12.4.5353...")
        end

        @testset "float to rational" begin
            @testset for f in [12/7, 5/3, 97/11, 45/13, 1/9]
                @test rationalify(no, string(f)[1:end-1]*"...") === rationalize(f)
            end
        end
    end
end

@testset "@rd_str macro" begin
    @test rd"1.0"    === 1//1
    @test rd"−1"     === -1//1
    @test rd".45"    === 45//100

    @testset "ParenthesesNotation" begin
        @test rd"0.9(9)" === 1//1
        @test rd"1.(0)"  === 1//1
        @test rd"0.(3)"  === 1//3
        @test rd".(3)"   === 1//3
        @test rd".(66)"  === 2//3
        @test rd"-.(09)" === -1//11
        @test rd".(45)"  === 5//11
        @test rd"0.(45)" === 5//11
        @test rd".45(6)" === 137//300
    end

    @testset "ScientificNotation" begin
        @test rd"0.9r9" === 1//1
        @test rd"1.r0"  === 1//1
        @test rd"0.r3"  === 1//3
        @test rd".r3"   === 1//3
        @test rd".r66"  === 2//3
        @test rd"-.r09" === -1//11
        @test rd".r45"  === 5//11
        @test rd"0.r45" === 5//11
        @test rd".45r6" === 137//300
    end

    @testset "EllipsisNotation" begin
        @test rd"0.999..."  === 1//1
        @test rd"1.000..."  === 1//1
        @test rd"0.333..."  === 1//3
        @test rd".3333..."  === 1//3
        @test rd".666..."   === 2//3
        @test rd"-.0909..." === -1//11
        @test rd".4545..."  === 5//11
        @test rd"0.4545..." === 5//11
        @test rd".45666..." === 137//300
    end

    @testset "Int64-Int128-BigInt" begin
        @test rd"9223372036854775807" === 9223372036854775807//1 isa Rational{Int64}
        @test rd"9223372036854775808" === 9223372036854775808//1 isa Rational{Int128}
        @test rd"-9223372036854775808" === -9223372036854775808//1 isa Rational{Int64}
        @test rd"-9223372036854775809" === -9223372036854775809//1 isa Rational{Int128}
        @test rd"170141183460469231731687303715884105727" === 170141183460469231731687303715884105727//1 isa Rational{Int128}
        @test rd"170141183460469231731687303715884105728" == 170141183460469231731687303715884105728//1 isa Rational{BigInt}
        @test rd"-170141183460469231731687303715884105728" === -170141183460469231731687303715884105728//1 isa Rational{Int128}
        @test rd"-170141183460469231731687303715884105729" == -170141183460469231731687303715884105729//1 isa Rational{BigInt}
    end
end
