# check usc_courses_full.csv difference
# used to compare the process to reproduce prev shiny_app data

# Load necessary library
library(dplyr)

# Read the CSV files
csv1 <- read.csv("shiny_app/usc_courses_full.csv", stringsAsFactors = FALSE)
csv2 <- read.csv("shiny_app/old data 2019-2024/usc_courses_full.csv", stringsAsFactors = FALSE)

# Define a function to sort keywords
sort_keywords <- function(keywords) {
  # Split the string into a vector of words, trim spaces, and sort
  sorted_words <- sort(trimws(unlist(strsplit(keywords, ","))))
  # Combine the sorted words back into a single string
  paste(sorted_words, collapse = ",")
}

# Apply the function to the 'all_keywords' column of each CSV
csv1$all_keywords <- sapply(csv1$all_keywords, sort_keywords)
csv2$all_keywords <- sapply(csv2$all_keywords, sort_keywords)


# Define the column names as a vector
# columns_to_compare <- c(
#   "courseID", "course_title", "section", "school",
#   "instructor", "course_description", "section_name", "department", "origin",
#   "N.Sections", "semester", "course_desc", "year",
#    "course_level", "clean_course_desc", "text",
#   "all_goals", "sustainability_classification"
# )

columns_to_compare <- c(
  "courseID", "course_title", "document", "section", "school", 
  "session", "instructor", "course_description", "section_name", 
  "department", "origin", "total_enrolled", "N.Sections", 
  "semester", "course_desc", "year", "all_semesters", 
  "course_level", "clean_course_desc", "text", "all_keywords", 
  "all_goals", "sustainability_classification"
)

print(colnames(csv1))
print(colnames(csv2))
print(columns_to_compare)

# Subset both dataframes to only keep the specified columns
csv1_subset <- csv1[, columns_to_compare]
csv2_subset <- csv2[, columns_to_compare]


# Find rows that are different in either direction (symmetric difference)
diff_rows_csv1 <- anti_join(csv1_subset, csv2_subset) # Rows in csv1 but not in csv2
diff_rows_csv2 <- anti_join(csv2_subset, csv1_subset) # Rows in csv2 but not in csv1

# Now, add a column identifying the origin of each row
diff_rows_csv1 <- diff_rows_csv1 %>% mutate(source = "csv1")
diff_rows_csv2 <- diff_rows_csv2 %>% mutate(source = "csv2")

# Combine the different rows from both sources
diff_rows <- bind_rows(diff_rows_csv1, diff_rows_csv2)

# Output the result
print(diff_rows)

# Optional: Save the result to a new CSV file
write.csv(diff_rows, "difference_rows_with_source.csv", row.names = FALSE)
# Output the result
print(head(diff_rows))
