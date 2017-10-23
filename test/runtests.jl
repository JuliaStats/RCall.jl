using Base.Test
hd = homedir()
pd = Pkg.dir()

libpaths = readlines(`Rscript -e "writeLines(.libPaths())"`)

using RCall
using Compat

# https://github.com/JuliaStats/RCall.jl/issues/68
@test hd == homedir()
@test pd == Pkg.dir()

# https://github.com/JuliaInterop/RCall.jl/issues/206
@test rcopy(Vector{String}, reval(".libPaths()")) == libpaths

tests = ["basic",
         "convert/base",
         "convert/dataframe",
         # "convert/datatable",
         "convert/datetime",
         "convert/axisarray",
         "convert/namedarray",
         "render",
         "namespaces",
         "repl",
         ]

println("Running tests:")

for t in tests
    tfile = string(t, ".jl")
    println(" * $(tfile) ...")
    include(tfile)
end
