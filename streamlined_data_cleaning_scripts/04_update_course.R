# courses with section names are fixed by new SOC files
# courses with different course descriptions are not fixed by new SOC files
# add/replace courses after adding school column
# add course from spreadsheet
library(readxl)
library(dplyr)
courses <- read.csv("streamlined_data/03_20251.csv")
courses_to_update <- read_excel("data_raw/Template_for_Adding_Courses_to_Sustainability_Course_Finder.xlsx")

# add and replace accordingly
# add new row
courses_to_add <- courses_to_update %>% filter(Data_Instructions == "Add")
courses_to_add$department <- sapply(courses_to_add$courseID, function(x) {
  strsplit(x, "-")[[1]][1]
})
courses_to_add$origin <- sapply(courses_to_add$semester, function(x) {
  letters <- gsub("[^A-Z]", "", x)
  numbers <- gsub("[^0-9]", "", x)
  if (letters == "F") {
    paste0("20", numbers, "3")
  } else if (letters == "SP") {
    paste0("20", numbers, "1")
  } else { # SU
    paste0("20", numbers, "2")
  }
})
courses_to_add$section <- gsub("[^0-9]", "", courses_to_add$section)
courses_to_add$total_enrolled <- 0
courses_to_add$all_semesters <- courses_to_add$semester
courses_to_add$course_desc <- paste(courses_to_add$course_title,
                                    courses_to_add$section_name,
                                    courses_to_add$course_description,
                                    sep = " - ")
courses_new <- rbind(courses, courses_to_add[,names(courses)])

# replace entire row
# courses_to_replace <- courses_to_update %>% filter(Data_Instructions == "Replace")
# for (i in 1:nrow(courses_to_replace)) {
#  j <- which(courses_new$courseID == courses_to_replace$courseID[i] &
#               courses_new$semester == courses_to_replace$semester[i])
#  courses_new[j,] <- courses_to_replace[i,names(courses_new)]
#  courses_new[j,]$department <- strsplit(courses_new[j,]$courseID, "-")[[1]][1]
# }

# update just description
courses_to_update_description <- courses_to_update %>% filter(Data_Instructions == "Update Description")
for (i in 1:nrow(courses_to_update_description)) {
  j <- which(courses_new$courseID == courses_to_update_description$courseID[i] &
               courses_new$semester == courses_to_update_description$semester[i])
  courses_new[j,]$course_description <- courses_to_update_description[i,]$course_description
  courses_new[j,]$course_desc <- paste(courses_new[j,]$course_title,
                                       courses_new[j,]$section_name,
                                       courses_new[j,]$course_desc,
                                       sep = " - ")
}


# arrange semesters in order then create all_semesters column
courses_new$semester <- factor(courses_new$semester,
                               levels = c("SU19","F19",
                                          "SP20","SU20","F20",
                                          "SP21","SU21","F21",
                                          "SP22","SU22","F22",
                                          "SP23","SU23","F23",
                                          "SP24","SU24","F24"))
courses_new <- courses_new %>%
  arrange(courseID, semester) %>%
  group_by(courseID) %>%
  mutate(all_semesters = paste(unique(semester), collapse = ", ")) %>%
  ungroup()

write.csv(courses_new,
          "streamlined_data/04_20251.csv",
          row.names = FALSE)

# remove duplicates
which(duplicated(courses_new))

# # just replacing the title + description
# for (i in 1:nrow(courses_to_update)) {
#   j <- which(courses_to_update$courseID[i] == courses$courseID &
#                courses_to_update$semester[i] == courses$semester)
#   courses[j,]$course_title <- courses_to_update[i,]$course_title
#   courses[j,]$course_desc <- courses_to_update[i,]$course_desc
# }

# ## WRIT-150 sections
# writ150_sample <- courses %>%
#   filter(courseID == "WRIT-150" & semester == "SP24")
# writ <- read_excel("WRIT-150_CORRECTIONS_FOR_SPRING_2024.xlsx")
# writ$school <- writ150_sample$school
# writ$courseID <- writ$CourseID
# writ$course_title <- paste(writ150_sample$course_title, "--", writ$SectionTitle)
# writ$instructor <- writ$Instructor
# writ$section <- writ$Section
# writ$department <- writ150_sample$department
# writ$semester <- writ150_sample$semester
# writ$course_desc <- sapply(writ$course_title, function(x) {
#   gsub(writ150_sample$course_title, x, writ150_sample$course_desc)
# })
# writ$N.Sections <- writ$Session
# writ$year <- writ150_sample$year
# writ$course_level <- writ150_sample$course_level
# writ$total_enrolled <- sapply(writ$Registered, function(x) {
#   as.numeric(strsplit(x, "of")[[1]][1])
# })
# writ$all_semesters <- writ150_sample$all_semesters # just SP24 or all_semesters of original WRIT-150?
# 
# writ %>%
#   select(names(courses)) -> writ_final
# 
# # remove the original writ150
# idx <- which(courses$courseID == "WRIT-150" & courses$semester == "SP24")
# courses <- courses[-idx,]
# # courses[idx,]$total_enrolled <- courses[idx,]$total_enrolled - sum(writ$total_enrolled)
# # courses[idx,]$N.Sections <- courses[idx,]$N.Sections - sum(writ$N.Sections)
# 
# # add all writ 150 into courses
# courses <- rbind(courses, writ_final)


