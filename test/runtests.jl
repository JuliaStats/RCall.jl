using Test

hd = homedir()

include("../deps/deps.jl")

if Sys.iswindows()    
    libpaths = withenv("PATH" => join(vcat(ENV["PATH"], PATH_append), ';')) do
        readlines(`Rscript -e "writeLines(.libPaths())"`)
    end
else
    Rscript = joinpath(Rhome, "bin", "Rscript")
    libpaths = readlines(`$Rscript -e "writeLines(.libPaths())"`)
end   

using RCall
using Missings
using Dates

println(R"sessionInfo()")

println(R"l10n_info()")

# https://github.com/JuliaStats/RCall.jl/issues/68
@test hd == homedir()

# https://github.com/JuliaInterop/RCall.jl/issues/206
@test rcopy(Vector{String}, reval(".libPaths()")) == libpaths

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

@test unsafe_load(cglobal((:R_PPStackTop, RCall.libR), Cint)) == 0
