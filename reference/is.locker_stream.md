# Check if an object inherits from locker_stream

Check if an object inherits from locker_stream

## Usage

``` r
is.locker_stream(x)
```

## Arguments

- x:

  An object.

## Value

Logical value indicating if `x` inherits from `locker_stream`.

## Examples

``` r
x <- new_stream(2, locker = temp_ds("locker-stream-example"))
is.locker_stream(x)
#> [1] TRUE
```
