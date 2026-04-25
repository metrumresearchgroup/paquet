library(testthat)

context("test-stream-seed")

test_that("seed_stream errors if x is not a file_stream", {
  expect_error(
    seed_stream(list(a = 1), seed = 1),
    regexp = "`x` must be a file_stream object.",
    fixed = TRUE
  )
})

test_that("seed_stream adds an integer seed to every item", {
  x <- seed_stream(new_stream(4), seed = 42)
  for (i in seq_along(x)) {
    expect_true(is.integer(x[[i]]$seed))
  }
})

test_that("seed_stream assigns distinct seeds to each item", {
  x <- seed_stream(new_stream(4), seed = 42)
  for (i in seq_along(x)[-1]) {
    expect_false(identical(x[[i]]$seed, x[[i - 1]]$seed))
  }
})

test_that("seed_stream is reproducible across calls", {
  x1 <- seed_stream(new_stream(4), seed = 99)
  x2 <- seed_stream(new_stream(4), seed = 99)
  for (i in seq_along(x1)) {
    expect_identical(x1[[i]]$seed, x2[[i]]$seed)
  }
})

test_that("seed_stream works with a single-item stream", {
  x <- seed_stream(new_stream(1), seed = 7)
  expect_true(is.integer(x[[1]]$seed))
})

test_that("set_stream_seed errors if seed element is not a valid L'Ecuyer seed", {
  x <- new_stream(3)
  expect_error(
    set_stream_seed(x[[1]]),
    regexp = "`x$seed` is not a L'Ecuyer seed",
    fixed = TRUE
  )
})

test_that("set_stream_seed sets .Random.seed and returns x invisibly", {
  x <- seed_stream(new_stream(2), seed = 5)
  out <- set_stream_seed(x[[1]])
  expect_identical(out, x[[1]])
  expect_identical(.Random.seed, x[[1]]$seed)
})

test_that("set_stream_seed produces reproducible random draws", {
  x <- seed_stream(new_stream(3), seed = 100)
  set_stream_seed(x[[2]])
  draw1 <- runif(5)
  set_stream_seed(x[[2]])
  draw2 <- runif(5)
  expect_identical(draw1, draw2)
})
