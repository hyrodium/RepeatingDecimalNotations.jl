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
