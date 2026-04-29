# paquet 0.2.0

- Add support for parquet format locker storage via the arrow package 
  (#11, #12).
- Optionally set a random seed for each item in the stream (#15).
  - Use `seed_stream()` to assign a seed to each position in the stream.
  - Call `set_stream_seed()` on the worker to use the assigned seed.
- `qs` file format no longer supported; add `qdata` format as a replacement 
  via the `qs2` package (#16).
- Add `$` extraction from file stream lists to retrieve fields as a vector 
  or list (#18).

# paquet 0.1.0

- Initial release
