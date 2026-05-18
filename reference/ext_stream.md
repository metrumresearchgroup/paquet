# Set or change the file extension on file_stream names

Add or update the file extension for items in a `file_stream` object. If
a file extension exists, it is removed first.

## Usage

``` r
ext_stream(x, ext)
```

## Arguments

- x:

  A `file_stream` object.

- ext:

  The new extension.

## See also

[`format_stream()`](https://metrumresearchgroup.github.io/paquet/reference/format_stream.md),
[`locate_stream()`](https://metrumresearchgroup.github.io/paquet/reference/locate_stream.md),
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md),
[`file_stream()`](https://metrumresearchgroup.github.io/paquet/reference/file_stream.md),
[`file_set()`](https://metrumresearchgroup.github.io/paquet/reference/file_set.md)

## Examples

``` r
x <- new_stream(3)
x <- ext_stream(x, "parquet")
x[[1]]$file
#> [1] "1-3parquet"
```
