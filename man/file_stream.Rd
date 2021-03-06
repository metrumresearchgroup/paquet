% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stream-file.R
\name{file_stream}
\alias{file_stream}
\title{Create a stream of files}
\usage{
file_stream(
  n,
  locker = NULL,
  format = NULL,
  where = NULL,
  ask = FALSE,
  noreset = FALSE,
  ...
)
}
\arguments{
\item{n}{The number of file names to generate; must be a single numeric
value greater than or equal to 1.}

\item{locker}{Passed to \code{\link[=setup_locker]{setup_locker()}} as \code{dir}; important to note that the
directory will be unlinked if it exists and is an established locker
directory.}

\item{format}{Passed to \code{\link[=format_stream]{format_stream()}}.}

\item{where}{An optional file path; this is replaced by \code{locker} if it is
also passed.}

\item{ask}{If \code{TRUE}, then \code{\link[=config_locker]{config_locker()}} will be called on the
locker space; once this is called, all future attempts to reset the locker
contents will require user confirmation via \code{\link[utils:askYesNo]{utils::askYesNo()}}; the
\code{ask} requirement can be revoked by calling \code{\link[=config_locker]{config_locker()}}.}

\item{noreset}{If \code{TRUE} then \code{\link[=config_locker]{config_locker()}} will be called on the
locker directory with \code{noreset = TRUE} to prevent future resets; note that
this is essentially
a dead end; there is no way to make the locker space writable using public
api; use this option if you \strong{really} want to safeguard the output and
assume complete control over the fate of these files.}

\item{...}{Additional arguments passed to \code{\link[=file_set]{file_set()}}.}
}
\description{
Optionally, setup a locker storage space on disk with a specific file
format (e.g. \code{fst} or \code{feather}).
}
\details{
The user is encouraged to \strong{read the documentation} and understand the \code{ask}
and \code{noreset} arguments. These may be important tools for you to use to
ensure the safety of outputs stored in locker space.

Pass \code{locker} to set up locker space for saving outputs; this involves
clearing the \code{locker} directory (see \code{\link[=setup_locker]{setup_locker()}} for details). Passing
\code{locker} also sets the path for output files. If you want to set up the path
for output files without setting up \code{locker} space, pass \code{where}.
}
\examples{
x <- file_stream(3, locker = temp_ds("foo"), format = "fst")
x[[1]]

}
\seealso{
\code{\link[=format_stream]{format_stream()}}, \code{\link[=locate_stream]{locate_stream()}}, \code{\link[=ext_stream]{ext_stream()}}, \code{\link[=new_stream]{new_stream()}},
\code{\link[=file_set]{file_set()}}
}
