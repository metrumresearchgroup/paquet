# Set or change the directory for file_stream objects

Add or update the directory location for items in a `file_stream`
object. If a directory path already exists, it is removed first.

## Usage

``` r
locate_stream(x, where, initialize = FALSE, ask = FALSE)
```

## Arguments

- x:

  A `file_stream` object.

- where:

  The new location.

- initialize:

  If `TRUE`, then the `where` directory is passed to a call to
  [`reset_locker()`](https://metrumresearchgroup.github.io/paquet/reference/reset_locker.md).

- ask:

  If `TRUE`, then
  [`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md)
  will be called on the locker space; once this is called, all future
  attempts to reset the locker contents will require user confirmation
  via [`utils::askYesNo()`](https://rdrr.io/r/utils/askYesNo.html); the
  `ask` requirement can be revoked by calling
  [`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md).

## Details

When `initialize` is set to `TRUE`, the locker space is initialized
**or** reset. In order to initialize, `where` must not exist or it must
have been previously set up as locker space. See
[`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md)
for details.

## See also

[`format_stream()`](https://metrumresearchgroup.github.io/paquet/reference/format_stream.md),
[`ext_stream()`](https://metrumresearchgroup.github.io/paquet/reference/ext_stream.md),
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md),
[`file_stream()`](https://metrumresearchgroup.github.io/paquet/reference/file_stream.md),
[`file_set()`](https://metrumresearchgroup.github.io/paquet/reference/file_set.md)

## Examples

``` r
x <- new_stream(5)
x <- locate_stream(x, file.path(tempdir(), "foo"))
x[[1]]$file
#> [1] "/tmp/Rtmp2vkPfo/foo/1-5"
```
