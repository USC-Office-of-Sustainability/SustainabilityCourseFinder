# read file of shiny_app/usc_courses_full.csv
# get unique values of the value in the column "semester"
library(dplyr)

data = read.csv("shiny_app/usc_courses_full.csv")
res = unique(data$semester)
# Data input
semesters <- res

# Create a data frame with separated semester prefix and year
df <- data.frame(
  semester = semesters,
  prefix = sub("(F|SU|SP)(\\d+)", "\\1", semesters),  # Extract prefix
  year = as.numeric(sub("(F|SU|SP)(\\d+)", "\\2", semesters))  # Extract year
)

prefix_order <- c("SP",  "SU", "F")

# Factor the prefix based on the custom order
df$prefix <- factor(df$prefix, levels = prefix_order)

# Sort the data frame by year and then by the custom-ordered prefix
sorted_df <- df[order(df$year, df$prefix), ]

# Extract the sorted semesters
sorted_semesters <- sorted_df$semester

# Display the sorted semesters
print(sorted_semesters)

# save sorted_semesters to csv
write.csv(sorted_semesters, "shiny_app/sorted_semesters.csv", row.names = FALSE, col.names = FALSE)

