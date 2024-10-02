library(dplyr)

# cleaning keywords
usc_pwg_keywords <- read.csv("data_raw/USC_PWG-E_Keywords_5_16_24_fixed_char_err.csv")

# check color
usc_pwg_keywords %>% select(goal, color) %>% distinct()

# # causes errors
usc_pwg_keywords <- usc_pwg_keywords[-grep("#", usc_pwg_keywords$keyword),]
# remove punctuation
usc_pwg_keywords$keyword <- gsub("[^[:alnum:][:space:]]", " ", usc_pwg_keywords$keyword)
# lowercase
usc_pwg_keywords$keyword <- tolower(usc_pwg_keywords$keyword)
# remove duplicates bc otherwise text2sdg will count the word twice
usc_pwg_keywords <- usc_pwg_keywords[!duplicated(usc_pwg_keywords),]

# save
write.csv(usc_pwg_keywords,
          "streamlined_data/generated_shiny_app_data/usc_keywords.csv",
          row.names = FALSE)
