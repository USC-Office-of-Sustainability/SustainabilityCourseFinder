source("data_processing_scripts/config.R")

library(dplyr)

# cleaning keywords
usc_pwg_keywords_origin <- read.csv(S_06_cleaning_keywords_INPUT_USC_PWG_E_Keywords_FILE_PATH)

# check color
usc_pwg_keywords_origin %>% select(goal, color) %>% distinct()

# # causes errors
usc_pwg_keywords_without_errors <- usc_pwg_keywords_origin[-grep("#", usc_pwg_keywords_origin$keyword),]
print(nrow(usc_pwg_keywords_without_errors))
missing_rows <- usc_pwg_keywords_origin[!usc_pwg_keywords_origin$keyword %in% usc_pwg_keywords_without_errors$keyword, ]

# View the missing rows
print(missing_rows)

# remove punctuation
usc_pwg_keywords_without_errors$keyword <- gsub("[^[:alnum:][:space:]]", " ", usc_pwg_keywords_without_errors$keyword)
# lowercase
usc_pwg_keywords_without_errors$keyword <- tolower(usc_pwg_keywords_without_errors$keyword)
# remove duplicates bc otherwise text2sdg will count the word twice
usc_pwg_keywords_removed_duplicates <- usc_pwg_keywords_without_errors[!duplicated(usc_pwg_keywords_without_errors),]

# save
write.csv(usc_pwg_keywords_removed_duplicates,
          S_06_cleaning_keywords_OUTPUT_FILE_PATH,
          row.names = FALSE)
