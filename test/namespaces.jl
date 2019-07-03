# library
# Since @rimport and @rlibrary create module objects which may be conflict with other objects,
# it is safer to place them at the end of the tests.

module NamespaceTests
    using RCall
    using Test

    @rimport stats
    @test rcopy(stats.qbirthday()) == 23
    @rimport stats as Rstats
    @test rcopy(Rstats.qbirthday(coincident = 4)) == 187
    @rlibrary stats
    @test rcopy(pbirthday(23, coincident = 3)) ≈ 0.014415406155024258
end
