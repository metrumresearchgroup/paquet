
Sys.setenv("R_TESTS" = "")

library(testthat)
library(paquet)
test_check("paquet", reporter="summary")
