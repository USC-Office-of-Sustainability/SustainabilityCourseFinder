source("streamlined_data_cleaning_scripts/config.R")

# cleaning the course descriptions for mapping

library(tidyverse)
library(stringr)
library(stringi)


usc_courses = read.csv(S_04_update_course_OUTPUT_FILE_PATH)
# usc_courses = read.csv("usc_courses.csv")

# context dependency
# replace certain phrases with new phrases
apply_context_dependency <- function(tt) {
  tt <- tolower(tt)
  corrections <- read.csv(S_05_cleaning_course_descriptions_INPUT_CONTEXT_DEPENDENCIES_FILE_PATH)
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

write.csv(usc_courses, S_05_cleaning_course_descriptions_OUTPUT_FILE_PATH, row.names = FALSE)

