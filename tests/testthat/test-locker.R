library(testthat)

context("locker")

test_that("set up locker [PQT-LOCK-001]", {
  x <- setup_locker(tempdir(), "foo")
  expect_length(x, 1)
  expect_is(x, "character")
})

test_that("reset locker [PQT-LOCK-002]", {
  x <- setup_locker(tempdir(), "foo")
  cat("...", file = file.path(x, "foo.fst"))
  y <- reset_locker(file.path(tempdir(), "foo"))
  expect_equal(basename(x), "foo")
  expect_true(is.null(y))
  expect_length(list.files(x), 0)
})

test_that("warn if directory isn't empty on reset [PQT-LOCK-003]", {
  unlink(temp_ds("foo"), recursive = TRUE)
  x <- new_stream(1, locker = temp_ds("foo"))
  cat(letters, file = file.path(temp_ds("foo"), "letters.txt"))
  expect_warning(
    new_stream(2, locker = temp_ds("foo")), 
    regexp="Could not clear locker directory"
  )
})

test_that("retire a locker [PQT-LOCK-004]", {
  locker <- temp_ds("foo")
  unlink(locker, recursive = TRUE)
  x <- new_stream(5, locker = locker)
  x <- new_stream(5, locker = locker)
  x <- new_stream(5, locker = locker)
  ans <- config_locker(locker, noreset = TRUE)
  expect_true(ans$noreset)
  cat("foo", file = file.path(locker, 'foo.fst'))
  expect_error(
    new_stream(5, locker = locker), 
    regexp = "The locker space has been marked noreset"
  )
  expect_equal(list.files(locker), "foo.fst")
  ans <- config_locker(locker, noreset = FALSE)
  expect_false(paquet:::marked_noreset_locker(locker))
})

test_that("retire a locker on create [PQT-LOCK-005]", {
  locker <- temp_ds("foo")
  unlink(locker, recursive = TRUE)
  expect_message(
    x <- new_stream(5, locker = locker, noreset = TRUE), 
    regexp="Making the locker non-resettable"
  )
  cat("foo", file = file.path(locker, 'foo.fst'))
  expect_error(
    new_stream(5, locker = locker), 
    regexp = "The locker space has been marked noreset"
  )
  expect_equal(list.files(locker), "foo.fst")
})

test_that("version a locker [PQT-LOCK-006]", {
  locker <- temp_ds("foo")  
  if(dir.exists(locker)) unlink(locker, recursive = TRUE)
  new_locker <- temp_ds("foo-v33")
  if(dir.exists(new_locker)) unlink(new_locker, recursive = TRUE)
  x <- setup_locker(locker)
  cat("...", file = file.path(locker, "1-1.fst"))
  x <- version_locker(locker, version = "v33")
  expect_true(dir.exists(x))
  expect_error(
    version_locker(locker, version = "v33"), 
    regexp = "A directory already exists"
  )
  unlink(x, recursive = TRUE)
  x <- version_locker(locker, version = "v33", overwrite = TRUE)
  expect_true(dir.exists(x))
  x <- version_locker(locker, version = "v33", overwrite = TRUE, noreset = TRUE)
  expect_true(paquet:::is_locker_dir(x))
  expect_true(paquet:::marked_noreset_locker(x))
})

test_that("ask before reset [PQT-LOCK-007]", {
  skip_if(interactive())
  locker <- temp_ds("foo")  
  if(dir.exists(locker)) unlink(locker, recursive = TRUE)
  x <- new_stream(10, locker = locker, ask = TRUE)
  ans <- try(x <- capture.output(new_stream(10, locker = locker)), silent=TRUE)
  expect_is(ans, "try-error")
  expect_equal(ans[1], "Error : User declined to reset the locker; stopping.\n")
  
  ans <- config_locker(locker, ask = FALSE)
  expect_false(paquet:::marked_ask_locker(locker))
  ans <- config_locker(locker, ask = TRUE)
  expect_true(paquet:::marked_ask_locker(locker))

})
