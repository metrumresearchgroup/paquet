# Check if an object is a file_set_item

Check if an object is a file_set_item

## Usage

``` r
is.file_set_item(x)
```

## Arguments

- x:

  An object.

## Value

Logical value indicating if `x` has the `file_set_item` attribute set..

## Examples

``` r
x <- new_stream(2)
is.file_set_item(x[[2]])
#> [1] TRUE
```
