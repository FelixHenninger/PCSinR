<!-- README.md is generated from README.Rmd. Please edit that file -->
PCSinR
======

**The PCSinR package contains all necessary functions for building and simulation Parallel Constraint Satisfaction (PCS) network models within R.**

PCS models are an increasingly used framework throughout psychology: They provide quantitative predictions in a variety of paradigms, ranging from word and letter recognition, for which they were originally developed (McClelland & Rumelhart, 1981; Rumelhart & McClelland, 1982), to complex judgments and decisions (Glöckner & Betsch, 2008; Glöckner, Hilbig, & Jekel, 2014), and many other applications besides.

Installation
------------

-   The current stable version is available via CRAN, and can be installed by running `install.packages("PCSinR")`.
-   You can install the latest development version directly from GitHub with the `devtools` package. To do so, please run `devtools::install_github("felixhenninger/PCSinR@master")`.

Usage
-----

The functions in this package simulate a PCS network, given an interconnection matrix. Methods for creating such a matrix from the most common models are forthcoming.

Once a connection matrix has been specified, the model can be simulated easily using the most common parameter set.

``` r
require(PCSinR)
#> Loading required package: PCSinR

interconnections <- matrix(
  c( 0.0000,  0.1015,  0.0470,  0.0126,  0.0034,  0.0000,  0.0000,
     0.1015,  0.0000,  0.0000,  0.0000,  0.0000,  0.0100, -0.0100,
     0.0470,  0.0000,  0.0000,  0.0000,  0.0000,  0.0100, -0.0100,
     0.0126,  0.0000,  0.0000,  0.0000,  0.0000,  0.0100, -0.0100,
     0.0034,  0.0000,  0.0000,  0.0000,  0.0000, -0.0100,  0.0100,
     0.0000,  0.0100,  0.0100,  0.0100, -0.0100,  0.0000, -0.2000,
     0.0000, -0.0100, -0.0100, -0.0100,  0.0100, -0.2000,  0.0000 ),
  nrow=7
)

result <- PCS_run_from_interconnections(interconnections)
```

A common simulation result concerns the number of iterations needed until convergence is reached.

``` r
result$convergence
#> default 
#>     116
```

The output also contains a log of the model states across all iterations. Here, we examine just the final state.

``` r
result$iterations[nrow(result$iterations),]
#>     iteration     energy node_1    node_2    node_3    node_4      node_5    node_6     node_7
#> 117       116 -0.2916358      1 0.5293124 0.3669084 0.1906411 -0.07023219 0.5477614 -0.5477614
```

General Information
-------------------

The `PCSinR` package is developed and maintained by Felix Henninger. It is published under the GNU General Public License (version 3 or later). The [NEWS file](NEWS.md) documents the most recent changes.

This work was supported by the University of Mannheim’s Graduate School of Economic and Social Sciences, which is funded by the German Research Foundation.
