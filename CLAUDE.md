# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Package Overview

`paquet` is an R package that provides tools for creating and managing
**file streams** — pre-specified lists of output file names used to save
large simulation outputs in chunks. It is designed for parallel
workflows where each worker saves its output directly to disk rather
than returning data to a head node.

Supported output formats: `fst`, `feather`, `parquet`, `qs`, `rds`. The
`arrow` package is required for `feather`/`parquet`; `qs` requires the
`qs` package. `fst` is a hard dependency (listed in `Imports`).

## Common Commands

``` bash
# Document (regenerate Rd files from roxygen)
make doc

# Build tarball (no vignettes)
make build

# Install
make install

# Build + install (full, with vignettes)
make package

# Run all tests
make test

# Run R CMD check
make check

# Generate coverage report
make covr

# Update tests.csv validation artifact
make unit-csv

# Generate stories/validation artifacts
make stories

# Regenerate README.md from README.Rmd
make readme
```

To run a single test file interactively in R:

``` r
testthat::test_file("tests/testthat/test-locker.R")
```

## Architecture

### Core Concepts

**File stream**: A list of `file_set_item` objects, each containing `i`
(chunk index), `file` (output path), and optionally `x` (input data
chunk). The list carries class attributes for `file_stream`, optionally
`locker_stream`, and a format class like `stream_format_fst`.

**Locker**: A managed output directory. Locker directories contain
hidden sentinel files (`.paquet-locker-dir`, `.paquet-locker-ask`,
`.paquet-locker-noreset`) that mark the directory as paquet-managed and
control reset behavior. Lockers can be configured to require user
confirmation before reset (`ask`) or made permanently non-resettable
(`noreset`).

### Source Files (`R/`)

| File             | Purpose                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `AAA.R`          | Package environment (`.pkgenv`) — defines `stream_format_classes` and `stream_types`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `stream.R`       | Core API: [`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md) (S3 generic for `numeric`, `list`, `data.frame`, `character`), [`file_stream()`](https://metrumresearchgroup.github.io/paquet/reference/file_stream.md), [`format_stream()`](https://metrumresearchgroup.github.io/paquet/reference/format_stream.md), [`locate_stream()`](https://metrumresearchgroup.github.io/paquet/reference/locate_stream.md), [`ext_stream()`](https://metrumresearchgroup.github.io/paquet/reference/ext_stream.md), [`write_stream()`](https://metrumresearchgroup.github.io/paquet/reference/write_stream.md) dispatch stubs, type-check helpers |
| `stream-write.R` | `write_stream` S3 methods for each format (`fst`, `feather`, `parquet`, `qs`, `rds`)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `stream-file.R`  | [`file_set()`](https://metrumresearchgroup.github.io/paquet/reference/file_set.md) (generates numbered file name vectors), [`file_stream()`](https://metrumresearchgroup.github.io/paquet/reference/file_stream.md) (builds the stream list), `summary.file_stream()`                                                                                                                                                                                                                                                                                                                                                                                                       |
| `locker.R`       | All locker management: [`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md), [`reset_locker()`](https://metrumresearchgroup.github.io/paquet/reference/reset_locker.md), [`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md), [`version_locker()`](https://metrumresearchgroup.github.io/paquet/reference/version_locker.md), [`is_locker_dir()`](https://metrumresearchgroup.github.io/paquet/reference/is_locker_dir.md), and internal helpers for ask/noreset sentinel files                                                                                                              |
| `chunk.R`        | Data frame chunking: [`chunk_by_id()`](https://metrumresearchgroup.github.io/paquet/reference/chunk_data_frame.md), [`chunk_by_row()`](https://metrumresearchgroup.github.io/paquet/reference/chunk_data_frame.md), [`chunk_by_cols()`](https://metrumresearchgroup.github.io/paquet/reference/chunk_data_frame.md)                                                                                                                                                                                                                                                                                                                                                         |
| `fst.R`          | fst convenience helpers: [`list_fst()`](https://metrumresearchgroup.github.io/paquet/reference/list_fst.md), [`internalize_fst()`](https://metrumresearchgroup.github.io/paquet/reference/internalize_fst.md), [`head_fst()`](https://metrumresearchgroup.github.io/paquet/reference/head_fst.md)                                                                                                                                                                                                                                                                                                                                                                           |
| `utils.R`        | [`temp_ds()`](https://metrumresearchgroup.github.io/paquet/reference/temp_ds.md) (path into [`tempdir()`](https://rdrr.io/r/base/tempfile.html)), `require_arrow()`, `require_qs()`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

### Typical Workflow

1.  **Create a stream**:
    `new_stream(data, nchunk = 5, locker = "path/to/locker", format = "feather")`
    — chunks a data frame, sets up the locker directory, and returns a
    list of file objects.
2.  **Worker function**: Each worker receives one list element (`x`),
    processes `x$x` (the data chunk), and calls
    `write_stream(x, result)` to save output to `x$file`.
3.  **Read outputs**: Use
    [`arrow::open_dataset()`](https://arrow.apache.org/docs/r/reference/open_dataset.html)
    for feather/parquet,
    [`internalize_fst()`](https://metrumresearchgroup.github.io/paquet/reference/internalize_fst.md)
    or
    [`list_fst()`](https://metrumresearchgroup.github.io/paquet/reference/list_fst.md)
    for fst, or standard R functions for rds/qs.

### File Naming Convention

File names encode chunk position and total count: `01-05.fst` = chunk 1
of 5. Generated by
[`file_set()`](https://metrumresearchgroup.github.io/paquet/reference/file_set.md)
with zero-padding controlled by the `pad` argument.

### Locker Safety

- A directory must not exist (or must already be a paquet locker) before
  [`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md)
  can use it.
- `config_locker(where, noreset = TRUE)` writes `.paquet-locker-noreset`
  to prevent future resets.
- `version_locker(where, version = "v2")` copies the locker to
  `where-v2` for archiving.

### Test IDs

Tests use bracketed IDs in their descriptions (e.g., `[PQT-LOCK-001]`).
These map to validation stories in `inst/validation/`. Running
`make stories` regenerates the validation CSV artifacts.
