library(spelling)

path <- c(
  "inst/validation/stories.yaml",
  "README.Rmd", 
  "vignettes/file-stream.Rmd"
  
)

message("checking package")
spell_check_package()
ignore <- readLines("inst/WORDLIST")
#message("checking other files")
#spell_check_files(path, ignore)
