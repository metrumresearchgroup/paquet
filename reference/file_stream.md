# Create a stream of files

Optionally, setup a locker storage space on disk with a specific file
format (e.g. `fst` or `feather`).

## Usage

``` r
file_stream(
  n,
  locker = NULL,
  format = NULL,
  where = NULL,
  ask = FALSE,
  noreset = FALSE,
  ...
)
```

## Arguments

- n:

  The number of file names to generate; must be a single numeric value
  greater than or equal to 1.

- locker:

  Passed to
  [`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md)
  as `dir`; important to note that the directory will be unlinked if it
  exists and is an established locker directory.

- format:

  Passed to
  [`format_stream()`](https://metrumresearchgroup.github.io/paquet/reference/format_stream.md).

- where:

  An optional file path; this is replaced by `locker` if it is also
  passed.

- ask:

  If `TRUE`, then
  [`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md)
  will be called on the locker space; once this is called, all future
  attempts to reset the locker contents will require user confirmation
  via [`utils::askYesNo()`](https://rdrr.io/r/utils/askYesNo.html); the
  `ask` requirement can be revoked by calling
  [`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md).

- noreset:

  If `TRUE` then
  [`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md)
  will be called on the locker directory with `noreset = TRUE` to
  prevent future resets; note that this is essentially a dead end; there
  is no way to make the locker space writable using public api; use this
  option if you **really** want to safeguard the output and assume
  complete control over the fate of these files.

- ...:

  Additional arguments passed to
  [`file_set()`](https://metrumresearchgroup.github.io/paquet/reference/file_set.md).

## Details

The user is encouraged to **read the documentation** and understand the
`ask` and `noreset` arguments. These may be important tools for you to
use to ensure the safety of outputs stored in locker space.

Pass `locker` to set up locker space for saving outputs; this involves
clearing the `locker` directory (see
[`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md)
for details). Passing `locker` also sets the path for output files. If
you want to set up the path for output files without setting up `locker`
space, pass `where`.

## See also

[`format_stream()`](https://metrumresearchgroup.github.io/paquet/reference/format_stream.md),
[`locate_stream()`](https://metrumresearchgroup.github.io/paquet/reference/locate_stream.md),
[`ext_stream()`](https://metrumresearchgroup.github.io/paquet/reference/ext_stream.md),
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md),
[`file_set()`](https://metrumresearchgroup.github.io/paquet/reference/file_set.md)

## Examples

``` r
x <- file_stream(3, locker = temp_ds("foo"), format = "fst")
x[[1]]
#> $i
#> [1] 1
#> 
#> $file
#> [1] "/tmp/Rtmp2vkPfo/foo/1-3.fst"
#> 
#> attr(,"file_set_item")
#> [1] TRUE
#> attr(,"class")
#> [1] "stream_format_fst" "list"             
```
