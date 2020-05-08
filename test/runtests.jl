using Test

hd = homedir()

if Sys.iswindows()
    Rhome = if haskey(ENV,"R_HOME")
        ENV["R_HOME"]
    else
        using WinReg
        WinReg.querykey(WinReg.HKEY_LOCAL_MACHINE, "Software\\R-Core\\R","InstallPath")
    end
    Rscript = joinpath(Rhome,"bin",Sys.WORD_SIZE==64 ? "x64" : "i386", "Rscript")
else
    Rscript = "Rscript"
end

libpaths = readlines(`$Rscript -e "writeLines(.libPaths())"`)

using RCall
if VERSION ≤ v"1.1.1"
    using Missings
end
using Dates
import Base.VersionNumber

Rversion = VersionNumber(rcopy(R"as.character(getRversion())"))

println(R"sessionInfo()")

println(R"l10n_info()")

# https://github.com/JuliaStats/RCall.jl/issues/68
@test hd == homedir()

# https://github.com/JuliaInterop/RCall.jl/issues/206
if strip(read(`R RHOME`, String)) == RCall.Rhome
    @test rcopy(Vector{String}, reval(".libPaths()")) == libpaths
end

tests = ["basic",
         "convert/base",
         "convert/missing",
         "convert/datetime",
         "convert/dataframe",
         "convert/categorical",
         "convert/formula",
         # "convert/axisarray",
         "macros",
         "namespaces",
         "repl",
         ]

println("Running tests:")

for t in tests
    println(t)
    tfile = string(t, ".jl")
    include(tfile)
end

@test unsafe_load(cglobal((:R_PPStackTop, RCall.libR), Int)) == 0

# test jupyter integration
nbconvert = "jupyter nbconvert"
try
    run(`$nbconvert --version`)
catch e
    try
        using Conda
        Conda.add("nbconvert")
        nbconvert = abspath(Conda.SCRIPTDIR,"jupyter-nbconvert")
        run(`$nbconvert --version`)
    catch e
        error("Could not find `jupyter-nbconvert`")
    end
end
run(`$nbconvert --execute test.ipynb --to notebook --output=test_run.ipynb`)
