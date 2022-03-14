
<!-- README.md is generated from README.Rmd. Please edit that file -->

# paquet

<!-- badges: start -->
<!-- badges: end -->

paquet helps you create and manage file streams for saving large outputs
which are created in chunks or packets.

For example, large simulation job might be split up into packets to be
processed in parallel. Using paquet, each worker can get a unique output
file name for saving the result of that packet to a reserved space on
disk so that large simulation results are not returned to the head node.
Results are stored in a way that allows efficient handling with fst file
format or feather / arrow data sets.

## Installation

You can install the development version of paquet from
[GitHub](https://github.com/metrumresearchgroup/paquet) with:

``` r
# install.packages("devtools")
devtools::install_github("metrumresearchgroup/paquet")
```

## Example

We will illustrate paquet by doing a simulation with mrgsolve. Let’s
create an input data set to simulate.

``` r
library(paquet)
library(dplyr)
library(mrgsolve)

data <- expand.ev(
  ID = seq(100), 
  amt = c(100, 300, 1000), 
  ii = 24, 
  addl = 9
) %>% as_tibble() %>% mutate(dose = amt)
```

This isn’t huge, but we’re just illustrating

``` r
data
. # A tibble: 300 × 8
.       ID  time   amt    ii  addl   cmt  evid  dose
.    <int> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
.  1     1     0   100    24     9     1     1   100
.  2     2     0   100    24     9     1     1   100
.  3     3     0   100    24     9     1     1   100
.  4     4     0   100    24     9     1     1   100
.  5     5     0   100    24     9     1     1   100
.  6     6     0   100    24     9     1     1   100
.  7     7     0   100    24     9     1     1   100
.  8     8     0   100    24     9     1     1   100
.  9     9     0   100    24     9     1     1   100
. 10    10     0   100    24     9     1     1   100
. # … with 290 more rows
```

A workflow might be to create chunks to process in parallel on a worker
node. To do this, we’ll create a file stream based on chunks of the
input data

``` r
fs <- new_stream(data, nchunk = 5, locker = "foo/mrgsolve", format = "feather")
```

This returns a list of data chunks

``` r
fs[[5]]
. $i
. [1] 5
. 
. $file
. [1] "foo/mrgsolve/5-5.feather"
. 
. $x
. # A tibble: 60 × 8
.       ID  time   amt    ii  addl   cmt  evid  dose
.    <int> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
.  1   241     0  1000    24     9     1     1  1000
.  2   242     0  1000    24     9     1     1  1000
.  3   243     0  1000    24     9     1     1  1000
.  4   244     0  1000    24     9     1     1  1000
.  5   245     0  1000    24     9     1     1  1000
.  6   246     0  1000    24     9     1     1  1000
.  7   247     0  1000    24     9     1     1  1000
.  8   248     0  1000    24     9     1     1  1000
.  9   249     0  1000    24     9     1     1  1000
. 10   250     0  1000    24     9     1     1  1000
. # … with 50 more rows
. 
. attr(,"file_set_item")
. [1] TRUE
. attr(,"class")
. [1] "stream_format_feather" "list"
```

For example, the 5th chunk will be saved to

    . [1] "foo/mrgsolve/5-5.feather"

in `feather` format.

We create a function to generate the outputs and then call
`write_stream()` to write the outputs to file

``` r
mod <- modlib("popex")

simulate_chunk <- function(x) {
  
  out <- mrgsim_df(mod, data = x$x, carry_out = "dose")  
  
  write_stream(x, out)
  
  return(x$file)
}

out <- lapply(fs, simulate_chunk)
```

Now all of our outputs are safely stored in `feather` format

``` r
list.files("foo/mrgsolve")
. [1] "1-5.feather" "2-5.feather" "3-5.feather" "4-5.feather" "5-5.feather"
```

And we have the file names in `out` since we returned the file names
rather than the simulated data

``` r
out
. [[1]]
. [1] "foo/mrgsolve/1-5.feather"
. 
. [[2]]
. [1] "foo/mrgsolve/2-5.feather"
. 
. [[3]]
. [1] "foo/mrgsolve/3-5.feather"
. 
. [[4]]
. [1] "foo/mrgsolve/4-5.feather"
. 
. [[5]]
. [1] "foo/mrgsolve/5-5.feather"
```

## Using `arrow` to read paquet outputs

Apache arrow is an advance platform for handling very large data sets.
While there is no formal connection between paquet and arrow, paquet has
been designed to set up output files in a way that makes it easy to
access with arrow.

We used `format = "feather"` in the mrgsolve simulation above and saved
the files out to a locker space on disk. We can read these simulations
using the `open_dataset()` function provided by arrow

``` r
library(arrow)

ds <- open_dataset("foo/mrgsolve", format = "feather")

ds
. FileSystemDataset with 5 Feather files
. ID: double
. time: double
. dose: double
. GUT: double
. CENT: double
. CL: double
. V: double
. ECL: double
. IPRED: double
. DV: double
. 
. See $metadata for additional Schema metadata
```

This doesn’t read in the data, but just gets a handle on what is there.
Using arrow, we can filter and select the data that we want from the
feather files **before** actually reading the files so that we don’t
have to read data that we don’t ultimately want

``` r
sims <- 
  ds %>%
  filter(dose == 100) %>% 
  select(ID, time, DV) %>% 
  as_tibble()

sims
. # A tibble: 48,200 × 3
.       ID  time    DV
.    <dbl> <dbl> <dbl>
.  1     1   0   0    
.  2     1   0   0    
.  3     1   0.5 0.613
.  4     1   1   1.12 
.  5     1   1.5 1.53 
.  6     1   2   1.86 
.  7     1   2.5 2.13 
.  8     1   3   2.35 
.  9     1   3.5 2.52 
. 10     1   4   2.64 
. # … with 48,190 more rows
```

## Using `fst` to save and read outputs

In the previous example, we used the `feather` format to save simulated
outputs and interacted with the outputs using `arrow::open_dataset()`.
We can use the *same* simulation function and save files to fst format
instead

``` r
fs2 <- new_stream(data, nchunk = 5, format = "fst", locker = "foo/fst-output")
```

Note we have requested fst formatted outputs and have pointed to a new
space on disk. We simulate again using `simulate_chunk`

``` r
out <- lapply(fs2, simulate_chunk)
```

Now we *can’t* use arrow to read these files, but we can use fst. paquet
provides tools for internalizing `fst` outputs

``` r
sims2 <- internalize_fst("foo/fst-output") %>% bind_rows()

head(sims2)
.   ID time dose       GUT      CENT        CL        V        ECL     IPRED
. 1  1  0.0  100   0.00000  0.000000 0.4980566 18.19345 -0.6970415 0.0000000
. 2  1  0.0  100 100.00000  0.000000 0.4980566 18.19345 -0.6970415 0.0000000
. 3  1  0.5  100  93.62459  6.331495 0.4980566 18.19345 -0.6970415 0.3480096
. 4  1  1.0  100  87.65565 12.173258 0.4980566 18.19345 -0.6970415 0.6691012
. 5  1  1.5  100  82.06725 17.557681 0.4980566 18.19345 -0.6970415 0.9650552
. 6  1  2.0  100  76.83513 22.515076 0.4980566 18.19345 -0.6970415 1.2375377
.          DV
. 1 0.0000000
. 2 0.0000000
. 3 0.3480096
. 4 0.6691012
. 5 0.9650552
. 6 1.2375377
```

as well as tooling to process them sequentially.

``` r
library(data.table)
library(fst)

files <- list_fst("foo/fst-output")

sims3 <- lapply(files, function(file) {
  
  result <- read_fst(file, as.data.table = TRUE)
  
  result[dose == 100, c("ID", "time", "DV")]

}) %>% rbindlist()
```

While the fst package is configured to work with `data.table`, it is not
required. However, it might be recommended if processing very large
outputs.

``` r
sims3
.         ID  time        DV
.     1:   1   0.0 0.0000000
.     2:   1   0.0 0.0000000
.     3:   1   0.5 0.3480096
.     4:   1   1.0 0.6691012
.     5:   1   1.5 0.9650552
.    ---                    
. 48196: 100 238.0 2.2335566
. 48197: 100 238.5 2.2019796
. 48198: 100 239.0 2.1705395
. 48199: 100 239.5 2.1392625
. 48200: 100 240.0 2.1081727
```
