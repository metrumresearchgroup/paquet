# Check if an object inherits from file_stream

Check if an object inherits from file_stream

## Usage

``` r
is.file_stream(x)
```

## Arguments

- x:

  An object.

## Value

Logical value indicating if `x` inherits from `file_stream`.

## Examples

``` r
x <- new_stream(2)
is.file_stream(x)
#> [1] TRUE
```
