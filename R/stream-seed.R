
#' Assign reproducible RNG seeds to a file stream
#'
#' Seeds each item in a `file_stream` list with an independent L'Ecuyer-CMRG
#' RNG stream so that parallel workers produce fully reproducible results. Call
#' [set_stream_seed()] inside the worker function to activate the seed before
#' running any stochastic code.
#'
#' @details
#' Internally calls `set.seed(seed, kind = "L'Ecuyer-CMRG")` and then advances
#' the RNG state across items using [parallel::nextRNGStream()].
#'
#' @param x a `file_stream` object.
#' @param seed a single integer passed to [set.seed()].
#'
#' @return
#' `x` is returned with a `seed` element added to every item.
#'
#' @examples
#' s <- new_stream(4)
#' s <- seed_stream(s, seed = 123)
#' length(s[[1]]$seed)
#'
#' @seealso [set_stream_seed()], [new_stream()]
#'
#' @export
seed_stream <- function(x, seed) {
  if (!is.file_stream(x)) {
    stop("`x` must be a file_stream object.")
  }
  set.seed(seed, kind = "L'Ecuyer-CMRG")
  current <- .Random.seed
  for (i in seq_along(x)) {
    x[[i]]$seed <- current
    current <- parallel::nextRNGStream(current)
  }
  x
}

#' Set the RNG seed on a worker from a seeded stream item
#'
#' Called inside a worker function to restore the pre-assigned L'Ecuyer-CMRG
#' seed stored in a `file_set_item` by [seed_stream()]; errors if the item has
#' no `seed` element.
#'
#' @param x a `file_set_item`, typically a single element of a `file_stream`.
#'
#' @return `x` invisibly.
#'
#' @examples
#' s <- new_stream(4)
#' s <- seed_stream(s, seed = 123)
#' set_stream_seed(s[[1]])
#' runif(1)
#'
#' @seealso [seed_stream()]
#'
#' @export
set_stream_seed <- function(x) {
  if (!is.integer(x$seed) || length(x$seed) != 7L) {
    stop("`x$seed` must be an integer vector of length 7; call `seed_stream()` before running this stream.")
  }
  assign(".Random.seed", x$seed, envir = .GlobalEnv)
  invisible(x)
}
