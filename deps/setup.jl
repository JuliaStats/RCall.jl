using Libdl

"""
    validate_libR(libR; raise=true)

Checks that the R library `libR` can be loaded and is satisfies version requirements.

If `raise` is set to `false`, then returns a boolean indicating success rather
than throwing exceptions.
"""
function validate_libR(libR; raise=true)
    if !isfile(libR)
        raise || return false
        error("Could not find library $libR. Make sure that R shared library exists.")
    end
    # Issue #143
    # On linux, sometimes libraries linked from libR (e.g. libRblas.so) won't open unless LD_LIBRARY_PATH is set correctly.
    libptr = try
        withenv("PATH" => join(vcat(ENV["PATH"], PATH_append), ';')) do
            Libdl.dlopen(libR)
        end
    catch er
        raise || return false
        Base.with_output_color(:red, stderr) do io
            print(io, "ERROR: ")
            showerror(io, er)
            println(io)
        end
        if Sys.iswindows()
            error("Try adding $(dirname(libR)) to the \"PATH\" environmental variable and restarting Julia.")
        else
            error("Try adding $(dirname(libR)) to the \"LD_LIBRARY_PATH\" environmental variable and restarting Julia.")
        end
    end
    # R_tryCatchError is only available on v3.4.0 or later.
    if Libdl.dlsym_e(libptr, "R_tryCatchError") == C_NULL
        msg = "R library $libR appears to be too old. RCall.jl requires R 3.4.0 or later."
        if raise
            error(msg)
        else
            @info msg
            return false
        end
    end
    Libdl.dlclose(libptr)
    return true
end

function locate_libR(Rhome; raise=true)
    @static if Sys.iswindows()
        libR = joinpath(Rhome, "bin", Sys.WORD_SIZE==64 ? "x64" : "i386", "R.dll")
    else
        libR = joinpath(Rhome, "lib", "libR.$(Libdl.dlext)")
    end
    return validate_libR(libR; raise=raise) ? libR : ""
end
