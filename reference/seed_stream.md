# Assign reproducible RNG seeds to a file stream

Seeds each item in a `file_stream` list with an independent
L'Ecuyer-CMRG RNG stream so that parallel workers produce fully
reproducible results. Call
[`set_stream_seed()`](https://metrumresearchgroup.github.io/paquet/reference/set_stream_seed.md)
inside the worker function to activate the seed before running any
stochastic code.

## Usage

``` r
seed_stream(x, seed)
```

## Arguments

- x:

  a `file_stream` object.

- seed:

  a single integer passed to
  [`set.seed()`](https://rdrr.io/r/base/Random.html).

## Value

`x` is returned with a `seed` element added to every item.

## Details

Internally calls `set.seed(seed, kind = "L'Ecuyer-CMRG")` and then
advances the RNG state across items using
[`parallel::nextRNGStream()`](https://rdrr.io/r/parallel/RngStream.html).
The caller's `.Random.seed` (both kind and state) is restored on, so the
parent process RNG is unaffected.

## See also

[`set_stream_seed()`](https://metrumresearchgroup.github.io/paquet/reference/set_stream_seed.md),
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md)

## Examples

``` r
s <- new_stream(4)
s <- seed_stream(s, seed = 123)
length(s[[1]]$seed)
#> [1] 7
```
