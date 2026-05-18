# File Stream Workflow

## Introduction

File streams are objects you can create to help in organizing larger
simulations which are naturally broken in to a series of smaller
simulations. One example is a set of replicate simulations which are
performed as a part of simulation-based model checking. Another example
would be a large number of doses which need to be evaluated in a
population context. In this case, one *very* large data set is assembled
and then broken into `chunks` to be simulated in parallel. In both
cases, it is assumed that the outputs (and maybe the inputs) are very
large and would benefit from an extra layer of organization, including a
consideration of how the simulations are stored on disk and accessed at
a later time.

The emphasis in these use cases is better management of very large
simulation outputs. However, given this is a package vignette, we will
illustrate the setup and implementation with problems of a (much)
smaller scale.

## File stream basics

``` r
library(dplyr)
library(paquet)
library(mrgsolve)
```

In the simplest use case, we might want to simulate some large number of
replicates. We can start to manage this simulation by creating a file
stream

``` r
x <- new_stream(10)
```

This creates a file stream, which is just a list with one position
representing each replicate that we want to do

``` r
x
```

    . Length: 10
    . Type: integer
    . Format: list
    . File[1]: 01-10
    . Seed: FALSE
    . Locker: FALSE

Each slot holds another list containing information for the `ith`
replicate. Looking at replicate 5 we have

``` r
x[[5]]
```

    . $i
    . [1] 5
    . 
    . $file
    . [1] "05-10"
    . 
    . $x
    . [1] 5
    . 
    . attr(,"file_set_item")
    . [1] TRUE

There are three named positions

1.  `i` the replicate number
2.  `file` the stem of the output file for this replicate
3.  `x` the data payload for this replicate; in this case it is just `i`

These can be extracted with the `$` operator.

``` r
x$x
```

    .  [1]  1  2  3  4  5  6  7  8  9 10

``` r
x$file
```

    .  [1] "01-10" "02-10" "03-10" "04-10" "05-10" "06-10" "07-10" "08-10" "09-10"
    . [10] "10-10"

The stem of the output file is named with the current replicate number
(`05`) and the total number of replicates in the set (`10`). The file
stem will always be configured to have the format `n` of `N`; but can be
customized with a prefix or to use a different separator character (see
below).

If we had a model and data set to be simulated in replicate

``` r
mod <- house(rtol = 1e-4, outvars = "DV")

data <- expand.ev(amt = 100, ID = 10)
```

we could use the file stream object to structure the simulation

``` r
out <- lapply(x, function(fs) {
  mrgsim(mod, data) %>% mutate(i = fs$i)
}) %>% bind_rows()
```

We have used the replicate number (`fs$i`) to tag the output of the
simulation. This is a simple example to get started on the basic idea.
We could have easily done the same simulation by calling

``` r
out <- lapply(1:10, function(i) {
  mrgsim(mod, data) %>% mutate(i = i)
}) %>% bind_rows()
```

It would give identical results and using the file stream would have
been overkill. So let’s use the file stream object to help us save these
simulations to a file in an efficient and organized way.

## Use file stream to create a data set on disk

To do this we’ll add two arguments to the call to
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md)

1.  `locker` a directory that is reserved for this set of simulation
    output (only)
2.  `format` the output format for saving the files

``` r
locker <- file.path(tempdir(), "replicate1")

x <- new_stream(10, locker = locker, format = "fst")
```

Since this is a package vignette, we are saving the outputs to
[`tempdir()`](https://rdrr.io/r/base/tempfile.html), not something that
we’d recommend in production work, where simulations should be saved
locally. We also specified `format` to be `fst`, which uses the package
of the same name to save the data in an efficient format.

Now let’s look at the object for the 5th replicate

``` r
x[[5]]
```

    . $i
    . [1] 5
    . 
    . $file
    . [1] "/tmp/RtmpphnZEV/replicate1/05-10.fst"
    . 
    . $x
    . [1] 5
    . 
    . attr(,"file_set_item")
    . [1] TRUE
    . attr(,"class")
    . [1] "stream_format_fst" "list"

We still have `i` (the replicate number). But now `file` is populated
with a complete path to the output file. What can’t be seen here is that
the `replicate` directory has been created

``` r
dir.exists(dirname(x[[5]]$file))
```

    . [1] TRUE

When the file stream was created, so was the directory where the files
would be saved. Details about the storage `locker` are provided below.

Also notice that the object has a new attribute

``` r
class(x[[5]])
```

    . [1] "stream_format_fst" "list"

This indicates that the file

``` r
basename(x[[5]]$file)
```

    . [1] "05-10.fst"

will be saved in `fst` format when the time comes. `fst` a very
efficient format for storing data frames in R; but you can choose other
formats, like `parquet` (also for data frames) or `qdata` or `rds` for
saving any R object.

To save the `ith` replicate to its pre-defined file location, we call
the function
[`write_stream()`](https://metrumresearchgroup.github.io/paquet/reference/write_stream.md)
inside our simulation loop

``` r
out <- lapply(x, function(fs) {
  ans <- mrgsim(mod, data) %>% mutate(i = fs$i)
  write_stream(fs, ans)
  return(fs$file)
})
```

Notice in the previous that we didn’t return the data; that’s part of
the strategy where we write the data to disk rather than return a
potentially massive amount of data that could easily swamp our R
session. But we did return the `location` of each file that we wrote out

``` r
out[1:3]
```

    . [[1]]
    . [1] "/tmp/RtmpphnZEV/replicate1/01-10.fst"
    . 
    . [[2]]
    . [1] "/tmp/RtmpphnZEV/replicate1/02-10.fst"
    . 
    . [[3]]
    . [1] "/tmp/RtmpphnZEV/replicate1/03-10.fst"

This makes it easy to read the data back in

``` r
library(fst)
sims <- lapply(out, read_fst) 
head(sims[[8]])
```

`paquet` provides a helper function for reading in a set of `fst` files

``` r
sims <- internalize_fst(locker)
str(sims)
```

By default, `internalize_fst` returns a single data frame with all of
your simulations. You can also run a head of the file set

``` r
head_fst(locker, n = 8)
```

    .   ID time       DV i
    . 1  1 0.00 0.000000 1
    . 2  1 0.00 0.000000 1
    . 3  1 0.25 1.287443 1
    . 4  1 0.50 2.225213 1
    . 5  1 0.75 2.904149 1
    . 6  1 1.00 3.391513 1
    . 7  1 1.25 3.737158 1
    . 8  1 1.50 3.978021 1

Or get a list of the files

``` r
fst <- list_fst(locker)
fst[2]
```

    . [1] "/tmp/RtmpphnZEV/replicate1/02-10.fst"

## Alternate (better) file formats

`fst` is an excellent file format and very fast to read and write. But
notice with the
[`internalize_fst()`](https://metrumresearchgroup.github.io/paquet/reference/internalize_fst.md)
call, we are still reading in all the data back into the R session. We
don’t *have* to do that; we could have just read the first 5 files

``` r
sims <- list_fst(locker)[1:5] %>% lapply(read_fst) %>% bind_rows()
```

But we want better value for the price that was paid to write the
outputs to disk.

This is where the `arrow` package comes in. Apache Arrow is “a
cross-language development platform for in-memory data.” Basically, you
can have a huge amount of data on disk in an arrow data set and work
with it as if it is loaded in memory.

The following examples will only be run if the arrow package is
installed when this vignette is built.

First, re-create the file stream with format `parquet`

``` r
x <- new_stream(10, format = "parquet", locker = locker)
```

Now, the files are ready to be stored in `parquet` format

``` r
basename(x[[5]]$file)
```

    . [1] "05-10.parquet"

``` r
class(x[[5]])
```

    . [1] "stream_format_parquet" "list"

and when we re-run the simulation, we’ll have a set of `parquet` files
rather than `fst` files

``` r
out <- lapply(x, function(fs) {
  ans <- mrgsim(mod, data) %>% mutate(i = fs$i)
  write_stream(fs, ans)
  return(fs$file)
})
```

Notice that there is no change to the simulation code; we still call
[`write_stream()`](https://metrumresearchgroup.github.io/paquet/reference/write_stream.md)
and because `fs[[i]]` is set up with `parquet` output, we get that
method when writing.

Now we don’t need a helper function to read the files; we’ll use
[`arrow::open_dataset()`](https://arrow.apache.org/docs/r/reference/open_dataset.html)

``` r
library(arrow)

ds <- arrow::open_dataset(locker, format = "parquet")
```

This `ds` object is a pointer to the data; it hasn’t actually been
loaded but we can take a peek at it

``` r
head(ds)
```

    . Table
    . 6 rows x 4 columns
    . $ID <double>
    . $time <double>
    . $DV <double>
    . $i <int32>

Once we have the data set open, we can `filter` and `select` the rows
and columns that we want, and then call
[`as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)
to collect the results

``` r
sims <- filter(ds, time > 12, i < 5) %>% as_tibble()
```

Now we have only the part of the simulated data that we need to work
with right now

``` r
head(sims)
```

    .  [38;5;246m# A tibble: 6 × 4 [39m
    .      ID  time    DV     i
    .    [3m [38;5;246m<dbl> [39m [23m  [3m [38;5;246m<dbl> [39m [23m  [3m [38;5;246m<dbl> [39m [23m  [3m [38;5;246m<int> [39m [23m
    .  [38;5;250m1 [39m     1  12.2  2.83     1
    .  [38;5;250m2 [39m     1  12.5  2.79     1
    .  [38;5;250m3 [39m     1  12.8  2.76     1
    .  [38;5;250m4 [39m     1  13    2.72     1
    .  [38;5;250m5 [39m     1  13.2  2.69     1
    .  [38;5;250m6 [39m     1  13.5  2.66     1

``` r
dim(sims)
```

    . [1] 1728    4

## Manipulating file streams

In the most basic example, we created a file stream like this

``` r
x <- new_stream(10)
```

Once the file stream is created, we can indicate the output format after
the fact

``` r
x <- format_stream(x, "fst")
```

This will put the proper class on the `file_stream` object and set the
file extension

``` r
x[[3]]$file
```

    . [1] "03-10.fst"

``` r
class(x[[3]])
```

    . [1] "stream_format_fst" "list"

There are also functions for adding an output file path

``` r
x <- locate_stream(x, locker)
x[[2]]$file
```

    . [1] "/tmp/RtmpphnZEV/replicate1/02-10.fst"

[`locate_stream()`](https://metrumresearchgroup.github.io/paquet/reference/locate_stream.md)
comes with an argument called `initialize` which can be used to
initialize the locker space if it hasn’t already been initialized or
reset.

Finally, you can manipulate the file extension

``` r
x <- ext_stream(x, "")
x[[4]]$file
```

    . [1] "/tmp/RtmpphnZEV/replicate1/04-10"

Here we just removed the file extension. If you are adding a file
extension, be sure to include the dot `(.)`.

paquet lets you add a unique seed to each spot in the stream:

``` r
x <- new_stream(5)
x <- seed_stream(x, 12345)
```

Now, each position in `x` has reproducible seed that can be used to set
up the random number generator on the worker

``` r
x[[2]]$seed
```

    . [1]       10407 -1645818963   548746318   440099794   143370804  -548492161
    . [7]   249546247

``` r
x[[2]]$seed[[1]]
```

    . [1] 10407

The value of `seed` indicates the following:

- `kind = "L'Ecuyer-CMRG"`
- `normal.kind = "Inversion"`
- `sample.kind = "Rejection"`

You can set the seed by calling
[`set_stream_seed()`](https://metrumresearchgroup.github.io/paquet/reference/set_stream_seed.md).

``` r
set_stream_seed(x[[2]])

random <- lapply(x, function(xi) {
  set_stream_seed(xi)
  rnorm(10)
})
```

## Pass objects via file stream

In the simple example, we just numbered each spot in the file stream
object. Passing a single number will create a sequence of that length

``` r
x <- new_stream(100)
```

Otherwise, we can create a custom sequence

``` r
x <- new_stream(seq(1, 100, 4))
x[[2]]
```

    . $i
    . [1] 2
    . 
    . $file
    . [1] "02-25"
    . 
    . $x
    . [1] 5
    . 
    . attr(,"file_set_item")
    . [1] TRUE

If we have a large data set, we can chunk that up and pass that in.
Illustrating with a toy example

``` r
data <- expand.ev(amt = 100, ID = seq(10))
head(data)
```

    .   ID time amt cmt evid
    . 1  1    0 100   1    1
    . 2  2    0 100   1    1
    . 3  3    0 100   1    1
    . 4  4    0 100   1    1
    . 5  5    0 100   1    1
    . 6  6    0 100   1    1

chunk the data frame into a list

``` r
chunked <- chunk_by_row(data, nchunk = 5)
```

And then pass that in

``` r
x <- new_stream(chunked)

length(x)
```

    . [1] 5

``` r
x[[3]]
```

    . $i
    . [1] 3
    . 
    . $file
    . [1] "3-5"
    . 
    . $x
    .   ID time amt cmt evid
    . 5  5    0 100   1    1
    . 6  6    0 100   1    1
    . 
    . attr(,"file_set_item")
    . [1] TRUE

Now he `x` position has only the “chunk” of data that we need for the
current simulation; this prevents the entire data frame from getting
passed to every worker.

## The locker system

There are important things to know about the locker system; this is what
really makes the arrow data sets work well.

When you first create a file stream with a `locker` location, you need
to specify a directory that does not exist; if the directory exists,
you’ll get an error.

Once you create a locker space, that space is reserved for storing
output files and should **only** be used for storing files that are
saved using
[`write_stream()`](https://metrumresearchgroup.github.io/paquet/reference/write_stream.md).
The locker space is marked by a hidden file that tells `paquet` that
this is a locker space

``` r
x <- new_stream(3, locker = locker)
list.files(locker, all.files = TRUE)
```

    . [1] "."                  ".."                 ".paquet-locker-dir"

Because this is a marked and reserved space, whenever the file stream is
initiated, the locker space is **completely** cleared of files. That is
to say, all the files in the locker space will be blown away at the time
the file stream is created or re-created. To say it another way,
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md)
called with a locker creates the locker space the first time it is
called and **completely clears the space** at any subsequent call with
that locker name. This is really important to remember that the process
renews / resets at the time that
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md)
is called; it is equivalent to over writing existing files except that
it happens in two steps: first all existing files are removed and then
new files are created. Thus, the locker world works mainly in terms of
directories rather than files (although obviously files are also
involved).

**WHY?** The reason for this is to be able to support arrow data sets.
Using `arrow::open_dataset(lockername)` is a very efficient way to
access very large data stored on disk. In order for this to work, all of
the files in the directory must be contributing members of that data
set. The only way to do this is to reset the data set space whenever the
data set is re-written and that happens at the time the file set is
created.

### Safety considerations

Note that `locker` is meant to be a folder on your disk that is
resettable. The say way you can call `write.csv("my-data.csv")` when
`my-data.csv` already exists, we expect that calling
`new_stream(..., locker = "foo/bar")` will (eventually) overwrite the
files in `foo/bar`. There is really no difference except that we must
clear out the `locker` prior to writing the files.

That said, we understand that lockers can store very large files that
are expensive to generate. So, we have given the user several options to
safeguard the locker space the next time paquet tries to reset the the
space. This is equivalent to calling

``` r
write.csv("my-data.csv")
```

and getting an error or asking for confirmation if `my-data.csv` exists.
The user is encouraged to understand how
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md)
works and how to effectively use the safeguards outlined here. Only you
can properly safeguard the data; we give you the tools and it is up to
you to use them. If you do choose to use these tools, you are
responsible for all intended and un-intended consequences. The safety
tools are only in place to prevent accidental removal of files in the
locker space and there is no guarantee that the locker space will at any
point only contain the files that you intended to retain; you own that
responsibility when you opt in to these tools.

Several approaches are available to secure future or existing files
which may be stored in locker space:

1.  `ask`: set up locker space so that you are asked every time a locker
    reset is requested
2.  `noreset`: make the locker non-resettable; this can be done at the
    time the locker space is created or after the fact
3.  `version`: create a versioned back up of existing simulations

#### Ask

This code is not executed, but provided as example for you. To require
user confirmation for locker reset, pass `ask = TRUE` when creating a
new file stream

``` r
x <- new_stream(100, locker = "foo/bar", ask = TRUE)
```

This command creates a locker space in `foo/bar` and marks that
directory so that every time you try to reset the locker space (clear
the output files), you will be prompted to confirm the reset using
[`utils::askYesNo`](https://rdrr.io/r/utils/askYesNo.html).

You can also convert an existing locker space so that you are asked
every time locker reset is attempted using

``` r
config_locker("foo/bar", ask = TRUE)
```

You can remove the ask requirement with

``` r
config_locker("foo/bar", ask = FALSE)
```

Please read and understand the documentation for `setup_locker`; if
anything is not clear, please ask.

#### No Reset

You can mark a locker space un-resettable. This can be done when a file
stream is created

``` r
x <- new_stream(100, locker = "foo/bar", noreset = TRUE)
```

This command creates locker space and immediately revokes the ability to
reset the space. You can also take an existing locker space and revoke
with

``` r
config_locker("foo/bar", noreset = TRUE)
```

One this is called, the space can no longer be reset. To restore
reset-ability:

``` r
config_locker("foo/bar", noreset = FALSE)
```

#### Versions

To save a version of some simulations, call
[`version_locker()`](https://metrumresearchgroup.github.io/paquet/reference/version_locker.md)

``` r
y <- version_locker(locker, version = "v000")
```

This creates a new directory named according to the existing locker
name, but with a “version” tag attached, and copies all the locker files
to this new directory.

See the help topic
[`?version_locker`](https://metrumresearchgroup.github.io/paquet/reference/version_locker.md)
for more options around this versioning process. New versions are not
automatically incremented (e.g. “locker-001”, “locker-002”) by design.
The intent behind the locker system is to create a re-writable space.
Versioning an existing locker is just a convenient way to stash existing
simulations under a similar name. Note that you can also create a new
version at your call to
[`new_stream()`](https://metrumresearchgroup.github.io/paquet/reference/new_stream.md)

``` r
x <- new_stream(100, locker = "existing/locker-v2")
```

Going forward, simulations will be saved to “version 2” of a locker
location that already exists. There is nothing special about this setup;
just some creativity in naming output directories.

Caution is advised: the locker system was created to save very large
simulation outputs; by continuously creating new versions, you could
quickly overrun your disk space. This should be used with care.
