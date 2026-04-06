
require_arrow <- function() {
  if(!requireNamespace("arrow")) {
    stop("the arrow package must be installed to complete this task.")  
  }
}
arrow_installed <- function() requireNamespace("arrow")
require_qs <- function() {
  if(!requireNamespace("qs")) {
    stop("the qs package must be installed to complete this task.")  
  }
}
require_qs2 <- function() {
  if(!requireNamespace("qs2")) {
    stop("the qs2 package must be installed to complete this task.")  
  }
}
qs_installed <- function() requireNamespace("qs")
qs2_installed <- function() requireNamespace("qs2")
fst_installed <- function() requireNamespace("fst")

#' Create a path to a dataset in tempdir
#' 
#' @param tag The dataset subdirectory.
#' 
#' @export
temp_ds <- function(tag) file.path(tempdir(), tag)
