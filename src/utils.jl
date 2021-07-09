"""
    # install one package
    install_packages("disk.frame")

    # install multiple packages
    install_packages(["dplyr", "disk.frame"])

    # choose a different CRAN repo
    install_packages(["dplyr", "disk.frame"], "http://cran.rstudio.com")

A utility function to help install packages. This is needed because
R"install.packages(pkgs)" doesn't work.
"""
function install_packages(pkg, repos = "https://cran.rstudio.com")
    run(`R -e "install.packages('$pkg', repos = '$repos')"`)
end


function install_packages(pkgs::AbstractVector, repos = "https://cran.rstudio.com")
    pkgs_vec = reduce((x,y)->"$x,$y", ["'$p'" for p in pkgs])
    pkgs_str = "c($pkgs_vec)"
    run(`R -e "install.packages($(pkgs_str), repos = '$repos')"`)
end
