locker_tag <- function(locker) {
  basename(locker)
}

.locker_file_name <- ".paquet-locker-dir" 
.locker_ask_name <- ".paquet-locker-ask"
.locker_noreset_name <- ".paquet-locker-noreset"

#' Check if a directory is dedicated locker space
#' 
#' @param where The locker location.
#' 
#' @export
is_locker_dir <- function(where) {
  file.exists(file.path(where, .locker_file_name))  
}

#' Find out if we need to ask before resetting
#' 
#' @param where The locker location; a directory name.
#' 
#' @details
#' The implementation right now is to keep a hidden file that indicates if we
#' should ask first or not. This function checks if that file exists. This may
#' be changed in the future if we decide we want additional meta data to be 
#' stored for the locker space.
#' 
#' @return Logical indicating if we need to ask first.
#' @keywords internal
#' @noRd
marked_ask_locker <- function(where) {
  file.exists(file.path(where, .locker_ask_name))  
}

#' Ask if it is ok to reset the locker
#' 
#' @param where The locker space.
#' 
#' @return Error if ask is required and user declines; otherwise `TRUE`.
#' @keywords internal
#' @noRd
ask_to_clear_locker <- function(where) {
  ask <- marked_ask_locker(where)
  if(isTRUE(ask)) {
    question <- "Resetting locker and removing all files; Are you sure?"
    ans <- askYesNo(question, default = FALSE)
    if(!isTRUE(ans)) {
      stop("User declined to reset the locker; stopping.", call. = FALSE)  
    }
  }
  return(invisible(TRUE))
}

#' Manage ask status for a locker space
#' 
#' Use `require_ask_locker` to place a hidden file which will require user
#' confirmation every time a locker reset attempt is made. Use `no_ask_locker`
#' to remove that file so that the user will no longer be asked.
#' 
#' @param where The locker directory.
#' 
#' @details
#' An error will be generated if `where` isn't already a valid locker space.
#' 
#' @return 
#' Invisible `NULL`.
#' 
#' @examples
#' dir <- file.path(tempdir(), "my-locker")
#' reset_locker(dir)
#' require_ask_locker(dir)
#' list.files(dir)
#' 
#' no_ask_locker(dir)
#' list.files(dir)
#' 
#' @export
require_ask_locker <- function(where) {
  if(!is_locker_dir(where)) {
    stop("`where` does not appear to be a locker space.")  
  }
  ask_path <- file.path(where, .locker_ask_name)
  cat(file = ask_path, "#")
  return(invisible(NULL))
}
#' @rdname require_ask_locker
#' @export
no_ask_locker <- function(where) {
  if(!is_locker_dir(where)) {
    stop("`where` does not appear to be a locker space.")  
  }
  ask_path <- file.path(where, .locker_ask_name)
  if(file.exists(ask_path)) {
    file.remove(ask_path)  
  }
  return(invisible(NULL))
}

#' Test that the locker location is valid
#' 
#' @details
#' The location is valid if `.locker_file_name` exists in that directory.
#' 
#' @param where The candidate locker directory.
#' @return Error if the space is not valid locker; `TRUE` otherwise.
#' @keywords internal
#' @noRd
validate_dir_locker <- function(where) {
  target <- file.path(where, .locker_file_name)
  if(!file.exists(target)) {
    msg <- c(
      "The dataset directory exists, but doesn't appear to be a valid ",
      "locker location; please manually remove the folder or specify a new ",
      "folder and try again."
    )
    stop(msg)
  }  
  return(invisible(TRUE))
}

#' Clears the locker space 
#' 
#' @details
#' Because this actually clears files, we validate here to make sure this
#' isn't called by accident on the wrong directory.
#' 
#' @param where The locker directory.
#' @param pattern A regular expression for selecting files to clear.
#' 
#' 
#' @keywords internal
#' @noRd
clear_locker <- function(where, pattern) {
  validate_dir_locker(where)
  if(!is.character(pattern)) {
    pattern <- "\\.(fst|feather|csv|qs|rds|ext)$"
  } 
  files <- list.files(
    where, 
    pattern = pattern, 
    full.names = TRUE
  )
  unlink(files, recursive = TRUE)  
  if(length(list.files(where)) > 0) {
    msg <- c(
      "Could not clear locker directory; ", 
      "use unlink(\"locker/location\", recursive = TRUE) to manually clear 
        the files or select a different location."
    )
    warning(msg)  
  }
}

#' Initialize the locker directory
#' 
#' This function is called by [setup_locker()] to initialize and 
#' re-initialize a locker directory. We call it `reset_locker` because it is 
#' expected that the locker space is created once and then repeatedly 
#' reset and simulations are run and re-run. 
#' 
#' @details
#' If user confirmation for reset was previously requested via [setup_locker()]
#' or [require_ask_locker()], then the user will be asked to confirm prior
#' to reset.
#' 
#' For the locker space to be initialized, the `where` directory must not 
#' exist; if it exists, there will be an error. It is also an error for 
#' `where` to exist and not contain a particular hidden locker file name
#' that marks the directory as established locker space. 
#' 
#' __NOTE__: when the locker is reset, all contents are cleared according 
#' to the files matched by `pattern`. If any un-matched files exist after
#' clearing the directory, a warning will be issued. 
#' 
#' @param where The full path to the locker. 
#' @param pattern A regular expression for finding files to clear from the 
#' locker directory.
#' 
#' @seealso [setup_locker()], [noreset_locker()], [version_locker()]
#' 
#' @export
reset_locker <- function(where, pattern = NULL) {
  stopifnot_resettable_locker(where)
  if(dir.exists(where)) {
    clear_locker(where, pattern)
  } else {
    dir.create(where, recursive = TRUE)
  }
  locker_path <- file.path(where, .locker_file_name)
  cat(file = locker_path, "#\n")
  return(invisible(NULL))
}

#' Set up a data storage locker
#' 
#' A locker is a directory structure where an enclosing folder contains 
#' subfolders that in turn contain the results of different simulation runs. 
#' When the number of simulation result sets is known, a stream of file names
#' is returned. This function is mainly called by other functions; an exported
#' function and documentation is provided in order to better communicate how
#' the locker works.
#'  
#' @details
#' The user is encouraged to __read the documentation__ and understand the `ask` 
#' and `noreset` arguments. These may be important tools for you to use to 
#' ensure the safety of outputs stored in locker space.  
#'  
#' `where` must exist when setting up the locker. The directory `tag` will be 
#' created under `where` and must not exist except if it had previously been 
#' set up using `setup_locker`. Existing `tag` directories will have a 
#' hidden file in them indicating that they are established simulation output
#' folders. 
#' 
#' When recreating the `tag` directory, it will be unlinked and created new.
#' To not try to set up a locker directory that already contains outputs that 
#' need to be preserved. You can call [noreset_locker()] on that directory
#' to prevent future resets. 
#' 
#' @param where The directory that contains tagged directories of run 
#' results.
#' @param tag The name of a folder under `where`; this directory must not 
#' exist the first time the locker is set up and __will be deleted__ and 
#' re-created each time it is used to store output from a new simulation run.
#' @param ask If `TRUE`, then [require_ask_locker()] will be called on the 
#' locker space; once this is called, all future attempts to reset the locker
#' contents will require user confirmation via [utils::askYesNo()]; the 
#' `ask` requirement can be revoked by calling [no_ask_locker()].
#' @param noreset If `TRUE` then [noreset_locker()] will be called on the 
#' locker directory to prevent future resets; note that this is essentially 
#' a dead end; there is no way to make the locker space writable using public
#' api; use this option if you __really__ want to safeguard the output and 
#' assume complete control over the fate of these files.
#' 
#' @return
#' The locker location.
#' 
#' @examples
#' x <- setup_locker(tempdir(), tag = "my-sims")
#' x
#' 
#' @seealso 
#' [reset_locker()], [noreset_locker()], [version_locker()], 
#' [require_ask_locker()], [no_ask_locker()]
#' 
#' @export
setup_locker <- function(where, tag = locker_tag(where), ask = FALSE, 
                         noreset = FALSE) {
  if(missing(tag)) {
    output_folder <- where
    where <- dirname(where)
  } else {
    output_folder <- file.path(where, tag)
  }
  if(!dir.exists(where)) {
    dir.create(where, recursive = TRUE)
  } else {
    if(isTRUE(ask)) {
      require_ask_locker(output_folder)
      ask <- FALSE
    }  
  }
  reset_locker(output_folder)
  if(isTRUE(ask)) {
    require_ask_locker(output_folder)
  }
  if(isTRUE(noreset)) {
    message("Making the locker non-resettable.")
    noreset_locker(output_folder)
  }
  return(invisible(output_folder))
}

#' Prohibit a locker space from being reset
#' 
#' This function designates a locker directory to be non-resettable.
#' as a locker. Once the locker is modified this way, it cannot be reset again 
#' by calling [setup_locker()] or [new_stream()]. 
#' 
#' @param where The locker location. 
#' 
#' @return
#' Logical indicating if write ability was successfully revoked. 
#' 
#' @seealso [setup_locker()], [reset_locker()], [version_locker()]
#' 
#' @export
noreset_locker <- function(where) {
  locker_file <- file.path(where, .locker_file_name)
  if(!file.exists(locker_file)) {
    stop("`where` does not appear to be a locker.")  
  }
  file <- file.path(where, .locker_noreset_name)
  cat(file = file, "#\n")
  return(invisible(file.exists(file)))
}

#' Remove noreset status on a locker
#' 
#' @param where The locker location.
#' @return 
#' Logical indicating that noreset status has been removed.
#' @export
ok_reset_locker <- function(where) {
  validate_dir_locker(where)
  file <- file.path(where, .locker_noreset_name)
  ans <- TRUE
  if(file.exists(file)) {
    message("Making the locker resettable.")
    ans <- file.remove(file)
  }
  return(invisible(ans))
}

#' Find if a locker is resettable
#' 
#' @details
#' 1. It has not been marked non-resettable.
#' 2. If ask is required, user has confirmed.
#' 
#' @param where The locker location.
#' @return Logical indicating if it is noreset
#' @noRd
stopifnot_resettable_locker <- function(where) {
  marked_noreset <- marked_noreset_locker(where)
  if(marked_noreset) {
    stop("The locker space has been marked noreset.")  
  }
  ask_to_clear_locker(where)
  return(invisible(TRUE))
}

marked_noreset_locker <- function(where) {
  file.exists(file.path(where, .locker_noreset_name))  
}

#' Version locker contents
#' 
#' @param where The locker location. 
#' @param version A tag to be appended to `where` for creating a backup of the 
#' locker contents.
#' @param overwrite If `TRUE`, the new location will be removed with [unlink()]
#' if it exists.
#' @param noreset If `TRUE`, [noreset_locker()] is called **on the new version**.
#' 
#' @return
#' A logical value indicating whether or not all files were successfully copied
#' to the backup, invisibly. 
#' 
#' @examples
#' locker <- file.path(tempdir(), "version-locker-example")
#' 
#' if(dir.exists(locker)) unlink(locker, recursive = TRUE)
#' 
#' x <- new_stream(1, locker = locker)
#' 
#' cat("test", file = file.path(locker, "1-1"))
#' 
#' dir.exists(locker)
#' 
#' list.files(locker, all.files = TRUE)
#' 
#' y <- version_locker(locker, version = "y")
#' 
#' y
#' 
#' list.files(y, all.files = TRUE)
#' 
#' @seealso [reset_locker()], [noreset_locker()], [setup_locker()]
#' @export
version_locker <- function(where, version = "save", overwrite = FALSE, 
                           noreset = FALSE) {
  if(!is_locker_dir(where)) {
    stop("`where` does not appear to be a locker.")  
  }
  saved <- paste0(where, "-", version)
  if(dir.exists(saved)) {
    if(isTRUE(overwrite)) {
      unlink(saved, recursive = TRUE)  
    } else {
      stop("A directory already exists with this version.")  
    }
  }
  dir.create(saved, recursive = TRUE)
  files <- list.files(where, full.names = TRUE, all.files = TRUE, no..=TRUE)
  ans <- file.copy(files, saved)
  if(!all(ans)) stop("There was a problem copying files to new version.")
  if(isTRUE(noreset)) noreset_locker(saved)
  return(invisible(saved))
}
