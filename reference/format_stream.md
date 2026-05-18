# Set the format for a stream_file object

The format is set on the file objects inside the list so that the file
object can be used to call a write method. See
[`write_stream()`](https://metrumresearchgroup.github.io/paquet/reference/write_stream.md).

## Usage

``` r
format_stream(
  x,
  type = c("fst", "feather", "parquet", "qdata", "rds"),
  set_ext = TRUE,
  warn = FALSE
)
```

## Arguments

- x:

  a `file_stream` object.

- type:

  the file format type; if `parquet` or `feather` is chosen, then a
  check will be made to ensure the `arrow` package is loaded.

- set_ext:

  if `TRUE`, the existing extension (if it exists) is stripped and a new
  extension is added based on the value of `type`.

- warn:

  if `TRUE` a warning will be issued in case the output format is set
  but there is no directory path associated with the `file` spot in
  `x[[1]]`.

## Value

`x` is returned with a new class attribute reflecting the expected
output format (`fst`, `parquet` (arrow), `feather` (arrow), `qdata`, or
`rds`).

## See also

[`format_is_set()`](https://metrumresearchgroup.github.io/paquet/reference/format_is_set.md),
[`locate_stream()`](https://metrumresearchgroup.github.io/paquet/reference/locate_stream.md),
[`ext_stream()`](https://metrumresearchgroup.github.io/paquet/reference/ext_stream.md),
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md),
[`file_stream()`](https://metrumresearchgroup.github.io/paquet/reference/file_stream.md),
[`file_set()`](https://metrumresearchgroup.github.io/paquet/reference/file_set.md)

## Examples

``` r
fs <- new_stream(2)
fs <- format_stream(fs, "fst")
fs[[1]]
#> $i
#> [1] 1
#> 
#> $file
#> [1] "1-2.fst"
#> 
#> $x
#> [1] 1
#> 
#> attr(,"file_set_item")
#> [1] TRUE
#> attr(,"class")
#> [1] "stream_format_fst" "list"             

format_is_set(fs[[1]])  
#> [1] TRUE
 
```
