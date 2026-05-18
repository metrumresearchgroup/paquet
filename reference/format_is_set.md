# Check format status of file set item

This can be used to check if a file set item has been assigned an output
format (e.g. `fst`, `parquet`, `feather`, `qdata`, or `rds`). If the
than calling
[`write_stream()`](https://metrumresearchgroup.github.io/paquet/reference/write_stream.md).

## Usage

``` r
format_is_set(x)

is.stream_format(x)
```

## Arguments

- x:

  An object, usually a `file_set_item`.

## Value

Logical indicating if `x` inherits from one of the stream format
classes. .
