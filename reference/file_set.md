# Generate a sequence of file objects

File names have a numbered core that communicates the current file
number as well as the total number of files in the set. For example,
`02-20` would indicate the second file in a set of 20. Other
customizations can be added.

## Usage

``` r
file_set(n, where = NULL, prefix = NULL, pad = TRUE, sep = "-", ext = "")
```

## Arguments

- n:

  The number of file names to create.

- where:

  An optional output file path.

- prefix:

  A character prefix for the file name.

- pad:

  If `TRUE`, numbers will be padded with zeros.

- sep:

  Separator character.

- ext:

  A file extension, including the dot.

## Value

By default a list length `n` of lists length 2; each sublist contains
the integer file number as `i` and the file name as `file`.

## See also

[`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md)

## Examples

``` r
x <- file_set(3, where = "foo/bar")
length(x)
#> [1] 3
x[2]
#> [1] "foo/bar/2-3"

x <- file_set(25, ext = ".feather")
x[17]
#> [1] "17-25.feather"
```
