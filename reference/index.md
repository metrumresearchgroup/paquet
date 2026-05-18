# Package index

## Chunking data frames

- [`chunk_by_id()`](https://metrumresearchgroup.github.io/paquet/reference/chunk_data_frame.md)
  [`chunk_by_cols()`](https://metrumresearchgroup.github.io/paquet/reference/chunk_data_frame.md)
  [`chunk_by_row()`](https://metrumresearchgroup.github.io/paquet/reference/chunk_data_frame.md)
  : Chunk a data frame

## Locker functions

- [`config_locker()`](https://metrumresearchgroup.github.io/paquet/reference/config_locker.md)
  : Configure a locker directory
- [`setup_locker()`](https://metrumresearchgroup.github.io/paquet/reference/setup_locker.md)
  : Set up a data storage locker
- [`reset_locker()`](https://metrumresearchgroup.github.io/paquet/reference/reset_locker.md)
  : Initialize the locker directory
- [`version_locker()`](https://metrumresearchgroup.github.io/paquet/reference/version_locker.md)
  : Version locker contents
- [`is_locker_dir()`](https://metrumresearchgroup.github.io/paquet/reference/is_locker_dir.md)
  : Check if a directory is dedicated locker space
- [`temp_ds()`](https://metrumresearchgroup.github.io/paquet/reference/temp_ds.md)
  : Create a path to a dataset in tempdir

## File stream

- [`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md)
  : Create a stream of outputs and inputs
- [`is.locker_stream()`](https://metrumresearchgroup.github.io/paquet/reference/is.locker_stream.md)
  : Check if an object inherits from locker_stream
- [`locate_stream()`](https://metrumresearchgroup.github.io/paquet/reference/locate_stream.md)
  : Set or change the directory for file_stream objects
- [`ext_stream()`](https://metrumresearchgroup.github.io/paquet/reference/ext_stream.md)
  : Set or change the file extension on file_stream names
- [`seed_stream()`](https://metrumresearchgroup.github.io/paquet/reference/seed_stream.md)
  : Assign reproducible RNG seeds to a file stream
- [`set_stream_seed()`](https://metrumresearchgroup.github.io/paquet/reference/set_stream_seed.md)
  : Set the RNG seed on a worker from a seeded stream item
- [`format_stream()`](https://metrumresearchgroup.github.io/paquet/reference/format_stream.md)
  : Set the format for a stream_file object
- [`format_is_set()`](https://metrumresearchgroup.github.io/paquet/reference/format_is_set.md)
  [`is.stream_format()`](https://metrumresearchgroup.github.io/paquet/reference/format_is_set.md)
  : Check format status of file set item
- [`file_stream()`](https://metrumresearchgroup.github.io/paquet/reference/file_stream.md)
  : Create a stream of files
- [`is.file_stream()`](https://metrumresearchgroup.github.io/paquet/reference/is.file_stream.md)
  : Check if an object inherits from file_stream
- [`is.file_set_item()`](https://metrumresearchgroup.github.io/paquet/reference/is.file_set_item.md)
  : Check if an object is a file_set_item
- [`file_set()`](https://metrumresearchgroup.github.io/paquet/reference/file_set.md)
  : Generate a sequence of file objects

## Write outputs by format

- [`write_stream()`](https://metrumresearchgroup.github.io/paquet/reference/write_stream.md)
  : Writer functions for stream_file objects

## Handle fst outputs

- [`internalize_fst()`](https://metrumresearchgroup.github.io/paquet/reference/internalize_fst.md)
  [`get_fst()`](https://metrumresearchgroup.github.io/paquet/reference/internalize_fst.md)
  : Get the contents of an fst file set
- [`head_fst()`](https://metrumresearchgroup.github.io/paquet/reference/head_fst.md)
  : Get the head of an fst file set
- [`list_fst()`](https://metrumresearchgroup.github.io/paquet/reference/list_fst.md)
  : List all output files in a fst file set
