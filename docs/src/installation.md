# Installing RCall.jl

RCall.jl requires either a local R installation, or the `RCALL_CONDA` environment variable be set to `TRUE`. It can then be installed via [the Julia package manager](https://docs.julialang.org/en/v1/stdlib/Pkg/index.html).

## Customizing the R installation

During package the package build, RCall.jl will check the following to find the location of the R installation:

1. `RCALL_CONDA` environment variable:  if set to `TRUE`, it will install the [`r-base` package](https://anaconda.org/r/r-base) via [Conda.jl](https://github.com/JuliaPy/Conda.jl).
2. `R_HOME` environment variable.
3. `R RHOME` command.
4. Windows registry (Windows only)

To manually specify which R installation is used, the easiest option is to set the `R_HOME` environment variable
and run `Pkg.build("RCall")`.

You can set `R_HOME` to the empty string `""` to force `Pkg.build` to re-run the
`R HOME` command, e.g. if you change your PATH:
```julia
ENV["R_HOME"]=""
Pkg.build("RCall")
```

Should you experience problems with any of these methods, please [open an issue](https://github.com/JuliaStats/RCall.jl/issues/new).

## Standard installations

The following options have been tested and are supported:

### Windows
The current [Windows binary from CRAN](https://cran.r-project.org/bin/windows/base/).

### OS X
The [CRAN .pkg](https://cran.r-project.org/bin/macosx/) or the [homebrew/science](https://github.com/Homebrew/homebrew-science) tap.

### Linux
Most Linux distributions allow installation of R from their package manager, however these are often out of date, and may not work with RCall.jl. We recommend that you use the updated repositories from [CRAN](https://cran.r-project.org/bin/linux/).

#### Ubuntu
The following will update R on recent versions of Ubuntu:

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
    sudo add-apt-repository -y "deb http://cran.rstudio.com/bin/linux/ubuntu $(lsb_release -s -c)/"
    sudo apt-get update -y
    sudo apt-get install -y r-base r-base-dev

### Other methods

If you have installed R by some other method (e.g. building from scratch, or files copied but not installed in the usual manner), which often happens on cluster installations, then you may need to set `R_HOME` or your `PATH` as described above before running `Pkg.build("RCall")` in order for the build script to find your R installation. RCall requries R to be installed with its shared library. It could be done with the flag `--enable-R-shlib`, consult your server administrator if see if it was the caase.

For some environments, you might also need to specify `LD_LIBRARY_PATH`
```sh
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:`R RHOME`/lib"
```

## Updating R

If you have updated your R installation, you may need to re-run `Pkg.build("RCall")`
as described above, possibly changing the `R_HOME` environment variable first.
