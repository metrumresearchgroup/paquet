#' @importFrom fst read_fst write_fst
#' @importFrom tools file_path_sans_ext file_ext
#' @importFrom utils askYesNo
NULL

#' @keywords internal
"_PACKAGE"

.pkgenv <- new.env(parent = emptyenv())
stream_types <- c("fst", "feather", "qs", "rds")
stream_format_classes <- paste0("stream_format_", stream_types)
names(stream_format_classes) <- stream_types
.pkgenv$stream_format_classes <- stream_format_classes
.pkgenv$stream_types <- stream_types
# nocov end
