library(dplyr)

# cleaning keywords
usc_pwg_keywords <- read.csv("USC_PWG-E_2023Keywords_06_29_23.csv")

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
          "shiny_app/usc_keywords.csv",
          row.names = FALSE)