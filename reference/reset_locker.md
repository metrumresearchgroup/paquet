# Initialize the locker directory

This function is called by
[`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md)
to initialize and re-initialize a locker directory. We call it
`reset_locker` because it is expected that the locker space is created
once and then repeatedly reset and simulations are run and re-run.

## Usage

``` r
reset_locker(where, pattern = NULL)
```

## Arguments

- where:

  The full path to the locker.

- pattern:

  A regular expression for finding files to clear from the locker
  directory.

## Details

If user confirmation for reset was previously requested via
[`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md)
or
[`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md),
then the user will be asked to confirm prior to reset.

For the locker space to be initialized, the `where` directory must not
exist; if it exists, there will be an error. It is also an error for
`where` to exist and not contain a particular hidden locker file name
that marks the directory as established locker space.

**NOTE**: when the locker is reset, all contents are cleared according
to the files matched by `pattern`. If any un-matched files exist after
clearing the directory, a warning will be issued.

## See also

[`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md),
[`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md),
[`version_locker()`](https://metrumresearchgroup.github.io/paquet/reference/version_locker.md)
