# Changelog

## paquet 0.2.0

- Add support for parquet format locker storage via the arrow package
  ([\#11](https://github.com/metrumresearchgroup/paquet/issues/11),
  [\#12](https://github.com/metrumresearchgroup/paquet/issues/12)).
- Optionally set a random seed for each item in the stream
  ([\#15](https://github.com/metrumresearchgroup/paquet/issues/15)).
  - Use
    [`seed_stream()`](https://metrumresearchgroup.github.io/paquet/reference/seed_stream.md)
    to assign a seed to each position in the stream.
  - Call
    [`set_stream_seed()`](https://metrumresearchgroup.github.io/paquet/reference/set_stream_seed.md)
    on the worker to use the assigned seed.
- `qs` file format no longer supported; add `qdata` format as a
  replacement via the `qs2` package
  ([\#16](https://github.com/metrumresearchgroup/paquet/issues/16)).
- Add `$` extraction from file stream lists to retrieve fields as a
  vector or list
  ([\#18](https://github.com/metrumresearchgroup/paquet/issues/18)).

## paquet 0.1.0

- Initial release
