# Writer functions for stream_file objects

This function will write out objects that have been assigned a format
with either
[`format_stream()`](https://metrumresearchgroup.github.io/paquet/reference/format_stream.md)
or the `format` argument to
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md).
See examples.

## Usage

``` r
write_stream(x, ...)

# Default S3 method
write_stream(x, data, ...)

# S3 method for class 'stream_format_fst'
write_stream(x, data, dir = NULL, ...)

# S3 method for class 'stream_format_feather'
write_stream(x, data, dir = NULL, ...)

# S3 method for class 'stream_format_parquet'
write_stream(x, data, dir = NULL, ...)

# S3 method for class 'stream_format_qs'
write_stream(x, data, dir = NULL, ...)

# S3 method for class 'stream_format_qdata'
write_stream(x, data, dir = NULL, ...)

# S3 method for class 'stream_format_rds'
write_stream(x, data, dir = NULL, ...)
```

## Arguments

- x:

  A `file_stream` object.

- ...:

  Not used.

- data:

  An object to write.

- dir:

  An optional directory location to be used if not already in the `file`
  spot in `x`.

## Value

A logical value indicating if the output was written or not.

## Details

The default method always returns `FALSE`; other methods which get
invoked if a `format` was set will return `TRUE`. So, the user can
always call `write_stream()` and check the return value: if `TRUE`, the
file was written to disk and the data to not need to be returned; a
`FALSE` return value indicates that no format was set and the data
should be returned.

Note the write methods can be invoked directly for a specific format if
no `format` was set (see examples).

## See also

[`format_stream()`](https://metrumresearchgroup.github.io/paquet/reference/format_stream.md),
[`ext_stream()`](https://metrumresearchgroup.github.io/paquet/reference/ext_stream.md),
[`locate_stream()`](https://metrumresearchgroup.github.io/paquet/reference/locate_stream.md),
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md),
[`file_stream()`](https://metrumresearchgroup.github.io/paquet/reference/file_stream.md)

## Examples

``` r
ds <- temp_ds("example")

fs <- new_stream(2, locker = ds, format = "fst")

data <- data.frame(x = rnorm(10))

x <- lapply(fs, write_stream, data = data)

list.files(ds)
#> [1] "1-2.fst" "2-2.fst"

reset_locker(ds)

fs <- format_stream(fs, "rds")

x <- lapply(fs, write_stream, data = data)

list.files(ds)
#> [1] "1-2.rds" "2-2.rds"
```
