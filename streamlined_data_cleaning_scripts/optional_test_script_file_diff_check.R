# Load necessary library
library(dplyr)

# Read the CSV files
csv1 <- read.csv("streamlined_data/prev_cleaned_SOC_files/20213.csv", stringsAsFactors = FALSE)
csv2 <- read.csv("streamlined_data/cleaned_SOC_files/20213.csv", stringsAsFactors = FALSE)

# Subset both dataframes to only keep the specified columns
csv1_subset <- csv1
csv2_subset <- csv2

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
