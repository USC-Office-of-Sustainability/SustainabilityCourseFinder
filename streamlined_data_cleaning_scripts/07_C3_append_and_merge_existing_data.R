# read in the AY20-AY23 data
usc_courses_full_checkpoint = read.csv("streamlined_data/checkpoint/usc_courses_full.csv")
usc_courses_full_newrows = read.csv("streamlined_data/06_C2_20251_only_usc_courses_full.csv")
usc_courses_full = rbind(usc_courses_full_checkpoint, usc_courses_full_newrows)
usc_courses_full <- usc_courses_full %>%
  group_by(courseID) %>%
  mutate(all_semesters = paste(unique(semester), collapse = ", ")) %>%
  ungroup()
write.csv(usc_courses_full, "streamlined_data/generated_shiny_app_data/usc_courses_full.csv", row.names = F)


course_sdg_data_checkpoint = read.csv("streamlined_data/checkpoint/course_sdg_data.csv")
course_sdg_data_newrows = read.csv("streamlined_data/06_C2_20251_only_course_sdg_data.csv")
course_sdg_data = rbind(course_sdg_data_checkpoint, course_sdg_data_newrows)
write.csv(course_sdg_data, "streamlined_data/generated_shiny_app_data/course_sdg_data.csv", row.names = F)


master_course_sdg_data_checkpoint = read.csv("streamlined_data/checkpoint/recent_courses.csv")
master_course_sdg_data_newrows = read.csv("streamlined_data/06_C2_20251_only_recent_courses.csv")
master_course_sdg_data = rbind(master_course_sdg_data_checkpoint, master_course_sdg_data_newrows)



master_course_sdg_data <- master_course_sdg_data %>%
  group_by(courseID) %>%
  mutate(all_semesters = paste(unique(all_semesters), collapse = ", ")) %>%
  ungroup()

most_recent_semester <- master_course_sdg_data %>%
  group_by(courseID, section_name, keyword) %>%
  summarize(recentSemester = trimws(tail(strsplit(all_semesters, ",")[[1]], 1))) %>%
  select(courseID, section_name, recentSemester, keyword)

# merge with course data
recent_courses <- merge(most_recent_semester, master_course_sdg_data, by.x = c("courseID", "section_name", "recentSemester", "keyword"), by.y = c("courseID", "section_name", "semester","keyword"))
# rename column
names(recent_courses)[names(recent_courses) == 'recentSemester'] <- "semester"
# save most recent course data for shiny app
write.csv(recent_courses, "streamlined_data/generated_shiny_app_data/recent_courses.csv", row.names = F)

