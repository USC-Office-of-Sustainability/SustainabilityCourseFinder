# after manual fixes
reviewed <- read.csv("USC_AY20-24_Sustainability_Courses_four_categories_1_28_24.csv")

# together <- merge(single_rows, reviewed, all.x = TRUE)
# together[which(is.na(together$Corrected_Sustainability_Classification)),] -> missing

# each file needs to be updated to new classifications
# except course_sdg_data doesn't have sustainability classification
prev_ge <- read.csv("ge_data_any_2_keywords.csv")
new_ge <- merge(prev_ge, reviewed) # all exist since using most recent semester
new_ge$sustainability_classification <- new_ge$Corrected_Sustainability_Classification
new_ge %>%
  select(-Automated_Sustainability_Classification, 
         -Corrected_Sustainability_Classification) -> new_ge
write.csv(new_ge,
          "shiny_app/ge_data.csv",
          row.names = FALSE)

prev_recent <- read.csv("recent_courses_any_2_keywords.csv")
new_recent <- merge(prev_recent, reviewed) # missing some
new_recent$sustainability_classification <- new_recent$Corrected_Sustainability_Classification
new_recent %>%
  select(-Automated_Sustainability_Classification, 
         -Corrected_Sustainability_Classification) -> new_recent
write.csv(new_recent,
          "shiny_app/recent_courses.csv",
          row.names = FALSE)

prev_full <- read.csv("usc_courses_full_any_2_keywords.csv")
new_full <- merge(prev_full, reviewed)
new_full$sustainability_classification <- new_full$Corrected_Sustainability_Classification
new_full %>%
  select(-Automated_Sustainability_Classification, 
         -Corrected_Sustainability_Classification) -> new_full
write.csv(new_full,
          "shiny_app/usc_courses_full.csv",
          row.names = FALSE)



# should enrolled = 0 be shown in the dashboard?
