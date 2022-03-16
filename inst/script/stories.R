stopifnot(require("dplyr"))
stopifnot(require("stringr"))
stopifnot(require("testthat"))
stopifnot(require("yaml"))
stopifnot(require("knitr"))
stopifnot(require("readr"))

stopifnot(file.exists("inst/validation/tests.csv"))

test <- read_csv("inst/validation/tests.csv", show_col_types=FALSE)
test$testid <- str_match(test$test, ".* \\[(.*)\\]$")[, 2]

stories <- yaml.load_file("inst/validation/stories.yaml")

story <- Map(stories, names(stories), f = function(story, storylabel) {
  tibble(
    STID = storylabel,
    STORY = story$description,
    test = story$tests
  )
})

story <- bind_rows(story)

all <- left_join(story, select(test, -c("test")),
                 by = c("test" = "testid"))

if(any(is.na(all$failed))) {
  warning("some NA found")  
}

write_csv(all, "inst/validation/stories-tests.csv")

x <- kable(all, format = "markdown")

writeLines(x, con = "inst/validation/stories.md")
