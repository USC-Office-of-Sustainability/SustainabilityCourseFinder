# this script is used to summarize the course data by year, course level, and sustainability classification
# e.g.
#    year  course_level  sustainability_classification total_courses total_sections
#  1 AY20  Undergraduate Not Related                            2209           5800
#  2 AY20  Undergraduate SDG-Related                            1494           3542
#  3 AY20  Undergraduate Sustainability-Focused                  103            280
#  4 AY20  Undergraduate Sustainability-Inclusive                743           1609
#  5 AY20  graduate      Not Related                            1667           2852
#  6 AY20  graduate      SDG-Related                            2168           4676
#  7 AY20  graduate      Sustainability-Focused                   81            107
#  8 AY20  graduate      Sustainability-Inclusive               1012           2396


# Load necessary libraries
library(dplyr)

# Source configuration file (update the path if necessary)
source("data_processing_scripts/config.R")

# Read the dataset (update the path if necessary)
data <- read.csv(S_07_using_text2sdg_OUTPUT_USC_COURSES_FULL_FILE_PATH)

# Adjust course levels: Combine undergrad lower and upper divisions into 'Undergraduate'
data <- data %>%
  mutate(course_level = case_when(
    course_level %in% c("undergrad lower division", "undergrad upper division") ~ "Undergraduate",
    TRUE ~ course_level  # Keep the other levels as is
  ))

# Grouping data by year, course level, and sustainability classification
course_analysis <- data %>%
  group_by(year, course_level, sustainability_classification) %>%
  summarise(
    total_courses = n(),
    total_sections = sum(N.Sections, na.rm = TRUE)
  ) %>%
  arrange(year, course_level, sustainability_classification)

# Write the summarized analysis to a CSV file
write.csv(course_analysis, "data_integrity_check/course_data_summary.csv", row.names = FALSE)

# Print the first few rows to verify the output
print(course_analysis)
