stopifnot(require("dplyr"))
stopifnot(require("testthat"))
stopifnot(require("knitr"))
stopifnot(require("readr"))
stopifnot(require("paquet"))

x <- test_dir("tests/testthat/")
x <- as_tibble(x)
x$result <- NULL
x$user <- NULL
x$system <- NULL
x$real <- NULL
write_csv(x = x, file = "inst/validation/tests.csv")
