# add/replace courses after adding school column
# add course from spreadsheet
library(readxl)
library(dplyr)
courses <- read.csv("usc_courses_updated_with_school.csv")
courses_to_update <- read_excel("Courses_to_add_to_SOC_20241.xlsx")

courses_to_add <- courses_to_update %>% filter(Data_Instructions == "Add")
courses_to_add$department <- sapply(courses_to_add$courseID, function(x) {
  strsplit(x, "-")[[1]][1]
})

courses_to_replace <- courses_to_update %>% filter(Data_Instructions == "Replace")
courses_new <- rbind(courses, courses_to_add[,names(courses)])
for (i in 1:nrow(courses_to_replace)) {
  j <- which(courses_new$courseID == courses_to_replace$courseID[i] &
               courses_new$semester == courses_to_replace$semester[i])
  courses_new[j,] <- courses_to_replace[i,names(courses_new)]
  courses_new[j,]$department <- strsplit(courses_new[j,]$courseID, "-")[[1]][1]
}

# arrange semesters in order then create all_semesters column
courses_new$semester <- factor(courses_new$semester, 
                               levels = c("SU19","F19",
                                          "SP20","SU20","F20",
                                          "SP21","SU21","F21",
                                          "SP22","SU22","F22",
                                          "SP23","SU23","F23",
                                          "SP24"))
courses_new <- courses_new %>%
  arrange(courseID, semester) %>%
  group_by(courseID) %>%
  mutate(all_semesters = paste(unique(semester), collapse = ", ")) %>%
  ungroup()

write.csv(courses_new,
          "usc_courses_updated_with_school_updated.csv",
          row.names = FALSE)
