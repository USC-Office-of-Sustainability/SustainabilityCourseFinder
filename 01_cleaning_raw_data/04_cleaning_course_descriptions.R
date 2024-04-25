# cleaning the course descriptions for mapping

library(tidyverse)
library(stringr)
library(stringi)

usc_courses = read.csv("usc_courses_with_school_updated_20243.csv")
# usc_courses = read.csv("usc_courses.csv")

# context dependency
# replace certain phrases with new phrases
apply_context_dependency <- function(tt) {
  tt <- tolower(tt)
  corrections <- read.csv("context_dependencies/context_dependencies_01_19_24.csv")
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

# fix typo
usc_courses$course_desc <- gsub("parient", "patient", usc_courses$course_desc)
usc_courses$course_desc <- gsub("&", "and", usc_courses$course_desc)
usc_courses$course_desc <- gsub("[sS]usta?i?na?bi?li?ty", "sustainability", usc_courses$course_desc)

usc_courses$clean_course_desc <- 
  apply_context_dependency(remove_punctuation(usc_courses$course_desc))

write.csv(usc_courses, "usc_courses_cleaned_with_school_20243.csv", row.names = FALSE)

