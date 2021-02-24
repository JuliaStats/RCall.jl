# Installing RCall.jl

RCall.jl can simply be installed with
```julia
Pkg.add("RCall")
```


## Customizing the R installation

The RCall build script (run by `Pkg.add`)
will check for an existing R installation by looking in the following locations,
in order.

* The `R_HOME` environment variable, if set, should be the location of the
  [R home directory](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Rhome.html). You could run
  `R.home()` in `R` to determine its location.
* Otherwise, it runs the `R RHOME` command, assuming `R` is located in your [`PATH`](https://en.wikipedia.org/wiki/PATH_(variable)).
* Otherwise, on Windows, it looks in the [Windows registry](https://cran.r-project.org/bin/windows/base/rw-FAQ.html#Does-R-use-the-Registry_003f).

To change which R installation is used for RCall, set the `R_HOME` environment variable
and run `Pkg.build("RCall")`.   Once this is configured, RCall remembers the location
of R in future updates, so you don't need to set `R_HOME` permanently.

```julia
ENV["R_HOME"] = "....directory of R home...."
Pkg.build("RCall")
```

When `R_HOME` is set to `"*"`, RCall.jl will automatically install R for you using [Conda](https://github.com/JuliaPy/Conda.jl).

Should you experience problems with any of these methods, please [open an issue](https://github.com/JuliaStats/RCall.jl/issues/new).

## Standard installations

If you want to install R yourself, rather than relying on the automatic Conda installation, you can use one of the following options:

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
    
### Julia ≤ 1.5: Failure on recent Linux distributions

The version of `libstdc++` shipped by Julia might be outdated if you are using a recent Linux distribution (e.g. Ubuntu 19.10) and make use of certain R packages (e.g. `Rcpp`). In this case RCall will fail with an error message looking similar to this:

    Error: package or namespace load failed for ‘package’ in dyn.load(file, DLLpath = DLLpath, ...):
    unable to load shared object '/home/user/R/x86_64-pc-linux-gnu-library/3.6/Rcpp/libs/Rcpp.so':
    /home/user/julia-1.3.1/bin/../lib/julia/libstdc++.so.6: version `GLIBCXX_3.4.26' not found 
    (required by /home/user/R/x86_64-pc-linux-gnu-library/3.6/Rcpp/libs/Rcpp.so)
    
Until this issue is fixed in Julia (see https://github.com/JuliaLang/julia/issues/34276) a workaround is to replace Julias `libstdc++` with the one of your OS:

    # works for Ubuntu 19.10 64bit - match your locations accordingly!
    cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6 $JULIA_HOME/lib/julia/
    
This problem doesn't affect Julia ≥ 1.6!

### Other methods

If you have installed R by some other method (e.g. building from scratch, or files copied but not installed in the usual manner), which often happens on cluster installations, then you may need to set `R_HOME` or your `PATH` as described above before running `Pkg.build("RCall")` in order for the build script to find your R installation. RCall requries R to be installed with its shared library. It could be done with the flag `--enable-R-shlib`, consult your server administrator if see if it was the caase.

For some environments, you might also need to specify `LD_LIBRARY_PATH`
```sh
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:`R RHOME`/lib"
```


## Updating R

If you have updated your R installation, you may need to re-run `Pkg.build("RCall")`
as described above, possibly changing the `R_HOME` environment variable first.
