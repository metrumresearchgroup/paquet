# Set the RNG seed on a worker from a seeded stream item

Called inside a worker function to restore the pre-assigned
L'Ecuyer-CMRG seed stored in a `file_set_item` by
[`seed_stream()`](https://metrumresearchgroup.github.io/paquet/reference/seed_stream.md);
errors if the item has no `seed` element.

## Usage

``` r
set_stream_seed(x)
```

## Arguments

- x:

  a `file_set_item`, typically a single element of a `file_stream`.

## Value

`x` invisibly.

## See also

[`seed_stream()`](https://metrumresearchgroup.github.io/paquet/reference/seed_stream.md)

## Examples

``` r
s <- new_stream(4)
s <- seed_stream(s, seed = 123)
set_stream_seed(s[[1]])
runif(1)
#> [1] 0.1663742
```
