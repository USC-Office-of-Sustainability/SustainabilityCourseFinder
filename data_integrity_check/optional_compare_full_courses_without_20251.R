# Load necessary library
library(dplyr)

# Read the CSV files
csv1 <- read.csv("shiny_app/usc_courses_full.csv", stringsAsFactors = FALSE)
csv2 <- read.csv("shiny_app/usc_courses_full_old.csv", stringsAsFactors = FALSE)

# Filter out rows where semester is "SP25" from csv1
csv1 <- csv1 %>% filter(semester != "SP25")
csv2 <- csv2 %>% filter(total_enrolled != 0 | semester == "F24")



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


# complete column headers:
# columns_to_compare <- c(
#   "courseID", "course_title", "document", "section", "school",
#   "session", "instructor", "course_description", "section_name",
#   "department", "origin", "total_enrolled", "N.Sections",
#   "semester", "course_desc", "year", "all_semesters",
#   "course_level", "clean_course_desc", "text", "all_keywords",
#   "all_goals", "sustainability_classification"
# )

# excluding total_enrolled and all_semesters and document and N.Sections
columns_to_compare <- c(
  "courseID", "course_title", "section", "school",
  "session", "instructor", "course_description", "section_name",
  "department", "origin",
  "semester", "course_desc", "year",
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
write.csv(diff_rows, "data_integrity_check/compare_full_courses_res.csv", row.names = FALSE)
# Output the result
print(head(diff_rows))
