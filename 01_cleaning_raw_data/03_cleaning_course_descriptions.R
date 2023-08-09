# cleaning the course descriptions for mapping

library(tidyverse)
library(stringr)
library(stringi)

usc_courses = read.csv("usc_courses_updated_with_school.csv")
# usc_courses = read.csv("usc_courses.csv")

# context dependency
# replace certain phrases with new phrases
apply_context_dependency <- function(tt) {
  tt <- tolower(tt)
  corrections <- read.csv("context_dependencies_06_30_23.csv")
  corrections$before <- tolower(corrections$before)
  corrections$after <- tolower(corrections$after)
  tt <- stri_replace_all_regex(tt,
                               pattern = corrections$before,
                               replacement = corrections$after,
                               vectorize = FALSE)
  tt
}

# remove all punctuation except '
remove_punctuation <- function(tt) {
  gsub("[^[:alnum:][:space:]']", " ", tt)
}

usc_courses$clean_course_desc <- 
  apply_context_dependency(remove_punctuation(usc_courses$course_desc))

write.csv(usc_courses, "usc_courses_cleaned_with_school.csv", row.names = FALSE)

