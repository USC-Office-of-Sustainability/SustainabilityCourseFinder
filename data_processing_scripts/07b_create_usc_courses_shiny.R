source("data_processing_scripts/config.R")

library(dplyr)

# Read the complete categorized course data
usc_courses_full <- read.csv(
  S_07_using_text2sdg_OUTPUT_USC_COURSES_FULL_FILE_PATH
)

# Identify whether each row is from Summer, Fall, or Spring
semester_check <- usc_courses_full %>%
  mutate(
    year_number = as.integer(sub("AY", "", year)),
    semester_type = case_when(
      grepl("^SU", semester) ~ "Summer",
      grepl("^F", semester)  ~ "Fall",
      grepl("^SP", semester) ~ "Spring",
      TRUE                   ~ NA_character_
    )
  ) %>%
  filter(!is.na(year_number), !is.na(semester_type)) %>%
  distinct(year, year_number, semester_type)

# Find academic years that contain all three semesters
full_academic_years <- semester_check %>%
  group_by(year, year_number) %>%
  summarize(
    semester_count = n_distinct(semester_type),
    .groups = "drop"
  ) %>%
  filter(semester_count == 3) %>%
  arrange(year_number)

# Make sure the data contains at least five complete academic years
if (nrow(full_academic_years) < 5) {
  stop("The data does not contain five complete academic years.")
}

# Select the five most recent complete academic years
five_recent_full_years <- full_academic_years %>%
  slice_tail(n = 5)

latest_full_year <- max(five_recent_full_years$year_number)

# Include the five complete years and any newer partial academic years
years_to_keep <- semester_check %>%
  filter(
    year_number %in% five_recent_full_years$year_number |
      year_number > latest_full_year
  ) %>%
  distinct(year) %>%
  pull(year)

# Filter the data for the Shiny app
usc_courses_shiny <- usc_courses_full %>%
  filter(year %in% years_to_keep)

# Save the filtered data
write.csv(
  usc_courses_shiny,
  S_07b_create_usc_courses_shiny_OUTPUT_FILE_PATH,
  row.names = FALSE
)

# Display the academic years included in the output
print(sort(unique(usc_courses_shiny$year)))