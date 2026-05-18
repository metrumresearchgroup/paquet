# Version locker contents

Version locker contents

## Usage

``` r
version_locker(where, version = "save", overwrite = FALSE, noreset = FALSE)
```

## Arguments

- where:

  The locker location.

- version:

  A tag to be appended to `where` for creating a backup of the locker
  contents.

- overwrite:

  If `TRUE`, the new location will be removed with
  [`unlink()`](https://rdrr.io/r/base/unlink.html) if it exists.

- noreset:

  If `TRUE`,
  [`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md)
  is called **on the new version** to mark the space `noreset`.

## Value

A logical value indicating whether or not all files were successfully
copied to the backup, invisibly.

## See also

[`reset_locker()`](https://metrumresearchgroup.github.io/paquet/reference/reset_locker.md),
[`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md)

## Examples

``` r
locker <- file.path(tempdir(), "version-locker-example")

if(dir.exists(locker)) unlink(locker, recursive = TRUE)

x <- new_stream(1, locker = locker)

cat("test", file = file.path(locker, "1-1"))

dir.exists(locker)
#> [1] TRUE

list.files(locker, all.files = TRUE)
#> [1] "."                  ".."                 ".paquet-locker-dir"
#> [4] "1-1"               

y <- version_locker(locker, version = "y")

y
#> [1] "/tmp/Rtmp2vkPfo/version-locker-example-y"

list.files(y, all.files = TRUE)
#> [1] "."                  ".."                 ".paquet-locker-dir"
#> [4] "1-1"               
```
