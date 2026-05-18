# Set up a data storage locker

A locker is a directory structure where an enclosing folder contains
subfolders that in turn contain the results of different simulation
runs. When the number of simulation result sets is known, a stream of
file names is returned. This function is mainly called by other
functions; an exported function and documentation is provided in order
to better communicate how the locker works.

## Usage

``` r
setup_locker(where, tag = locker_tag(where), ask = FALSE, noreset = FALSE)
```

## Arguments

- where:

  The directory that contains tagged directories of run results.

- tag:

  The name of a folder under `where`; this directory must not exist the
  first time the locker is set up and **will be deleted** and re-created
  each time it is used to store output from a new simulation run.

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

## Value

The locker location.

## Details

The user is encouraged to **read the documentation** and understand the
`ask` and `noreset` arguments. These may be important tools for you to
use to ensure the safety of outputs stored in locker space.

`where` must exist when setting up the locker. The directory `tag` will
be created under `where` and must not exist except if it had previously
been set up using `setup_locker`. Existing `tag` directories will have a
hidden file in them indicating that they are established simulation
output folders.

When recreating the `tag` directory, it will be unlinked and created
new. To not try to set up a locker directory that already contains
outputs that need to be preserved. You can call
[`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md)
on that directory with `noreset = TRUE` to prevent future resets.

## See also

[`reset_locker()`](https://metrumresearchgroup.github.io/paquet/reference/reset_locker.md),
[`version_locker()`](https://metrumresearchgroup.github.io/paquet/reference/version_locker.md),
[`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md)

## Examples

``` r
x <- setup_locker(tempdir(), tag = "my-sims")
x
#> [1] "/tmp/Rtmp2vkPfo/my-sims"
```
