# Create a stream of outputs and inputs

By stream we mean a list that pre-specifies the output file names,
replicate numbers and possibly input objects for a simulation. Passing
`locker` initiates a call to
[`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md),
which sets up or resets the output directories. **It is the
responsibility of the user to take advantage of the features provided by
paquet to ensure the safety of outputs stored in locker space**.

## Usage

``` r
new_stream(x, ...)

# S3 method for class 'list'
new_stream(x, locker = NULL, format = NULL, ask = FALSE, noreset = FALSE, ...)

# S3 method for class 'data.frame'
new_stream(
  x,
  nchunk,
  cols = "ID",
  locker = NULL,
  format = NULL,
  ask = FALSE,
  noreset = FALSE,
  ...
)

# S3 method for class 'numeric'
new_stream(x, ...)

# S3 method for class 'character'
new_stream(x, ...)
```

## Arguments

- x:

  A list or vector to template the stream; for the `numeric` method,
  passing a single number will fill `x` with a sequence of that length.

- ...:

  Additional arguments passed to
  [`file_set()`](https://metrumresearchgroup.github.io/paquet/reference/file_set.md).

- locker:

  Passed to
  [`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md)
  as `dir`; important to note that the directory will be unlinked if it
  exists and is an established locker directory.

- format:

  Passed to
  [`format_stream()`](https://metrumresearchgroup.github.io/paquet/reference/format_stream.md).

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

- nchunk:

  The number of chunks.

- cols:

  The name(s) of the column(s) specifying unique IDs to use to split the
  `data.frame` into chunks; this could be a unique `ID` or a combination
  of columns that when pasted together form a unique ID.

## Value

A list with the following elements:

- `i` the position number

- `file` the output file name

- `x` the input object.

The list has class `file_stream` as well as `locker_stream` (if `locker`
was passed) and a class attribute for the output if `format` was passed.

## Details

All methods contain `ask` and `noreset` arguments which get passed to
[`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md).
Set `ask` to `TRUE` in order to require confirmation (using
[`utils::askYesNo()`](https://rdrr.io/r/utils/askYesNo.html)) every time
the command is run again; set `noreset` to `TRUE` to immediately revoke
permission to reset the locker space. Be sure to **consider using these
options** to prevent accidentally resetting the locker space.

For the `data.frame` method, the data are chunked into a list by columns
listed in `cols`. Ideally, this is a single column that operates as a
unique `ID` across the data set and is used by
[`chunk_by_id()`](https://metrumresearchgroup.github.io/paquet/reference/chunk_data_frame.md)
to form the chunks. Alternatively, `cols` can be multiple column names
which are pasted together to form a unique `ID` that is used for
splitting via
[`chunk_by_cols()`](https://metrumresearchgroup.github.io/paquet/reference/chunk_data_frame.md).

## See also

[`format_stream()`](https://metrumresearchgroup.github.io/paquet/reference/format_stream.md),
[`locate_stream()`](https://metrumresearchgroup.github.io/paquet/reference/locate_stream.md),
[`ext_stream()`](https://metrumresearchgroup.github.io/paquet/reference/ext_stream.md),
[`file_stream()`](https://metrumresearchgroup.github.io/paquet/reference/file_stream.md),
[`file_set()`](https://metrumresearchgroup.github.io/paquet/reference/file_set.md),
[`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md)

## Examples

``` r
x <- new_stream(3)
x[[1]]
#> $i
#> [1] 1
#> 
#> $file
#> [1] "1-3"
#> 
#> $x
#> [1] 1
#> 
#> attr(,"file_set_item")
#> [1] TRUE

new_stream(2, locker = file.path(tempdir(), "foo"))
#> Length: 2
#> Type: integer
#> Format: list
#> File[1]: /tmp/Rtmp2vkPfo/foo/1-2
#> Seed: FALSE
#> Locker: TRUE

df <- data.frame(ID = c(1,2,3,4))
x <- new_stream(df, nchunk = 2)
x[[2]]
#> $i
#> [1] 2
#> 
#> $file
#> [1] "2-2"
#> 
#> $x
#>   ID
#> 3  3
#> 4  4
#> 
#> attr(,"file_set_item")
#> [1] TRUE

format_is_set(x[[2]])
#> [1] FALSE

x <- new_stream(3, format = "fst")
format_is_set(x[[2]])
#> [1] TRUE
```
