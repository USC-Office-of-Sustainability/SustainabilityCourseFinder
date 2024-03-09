# summary files

# usc_courses_full1 <- read.csv("usc_courses_full_any_2_keywords2.csv")
# usc_courses_full <- usc_courses_full1 %>%
#   filter((year %in% c("AY20", "AY21", "AY22", "AY23") & total_enrolled > 0) | year %in% c("AY24"))
# write.csv(usc_courses_full,
#           "usc_courses_full_any_2_keywords_enrolled.csv",
#           row.names = FALSE)

usc_courses_full <- read.csv("shiny_app/usc_courses_full.csv")

usc_courses_full_enrolled <- usc_courses_full %>%
  filter((year %in% c("AY20", "AY21", "AY22", "AY23", "AY24") & total_enrolled > 0) | year %in% c("AY25")) %>%
  mutate(grad = ifelse(course_level == "graduate", "graduate", "undergrad")) 

usc_courses_full_enrolled %>%
  group_by(year, sustainability_classification) %>%
  summarize(by_section = sum(N.Sections), 
            by_course = length(unique(courseID)),
            total_enrolled = sum(total_enrolled)) -> courses_summary

courses_summary %>%
  group_by(year) %>%
  mutate(total_section = sum(by_section),
         total_course = sum(by_course),
         total_enrolled = sum(total_enrolled)) -> courses_summary

courses_summary$percent_section <- courses_summary$by_section/courses_summary$total_section*100
courses_summary$percent_course <- courses_summary$by_course/courses_summary$total_course*100

write.csv(courses_summary, 
          "courses_summary_AC1_by_year_20_24.csv",
          row.names = FALSE)

usc_courses_full_enrolled %>%
  group_by(grad,year, sustainability_classification) %>%
  summarize(by_section = sum(N.Sections), 
            by_course = length(unique(courseID)),
            total_enrolled = sum(total_enrolled)) -> courses_summary

courses_summary %>%
  group_by(grad,year) %>%
  mutate(total_section = sum(by_section),
         total_course = sum(by_course),
         total_enrolled = sum(total_enrolled)) -> courses_summary

courses_summary$percent_section <- courses_summary$by_section/courses_summary$total_section*100
courses_summary$percent_course <- courses_summary$by_course/courses_summary$total_course*100

write.csv(courses_summary, 
          "courses_summary_AC1_by_grad_year_20_24.csv",
          row.names = FALSE)

# usc_courses_full %>%
#   filter(year %in% c("AY21", "AY22", "AY23")) %>%
#   filter((year %in% c("AY20", "AY21", "AY22", "AY23", "AY24") & total_enrolled > 0) | year %in% c("AY25")) %>%
#   mutate(grad = ifelse(course_level == "graduate", "graduate", "undergrad")) %>%
#   group_by(grad,year, sustainability_classification) %>%
#   summarize(by_section = sum(N.Sections), by_course = n()) -> courses_summary
# 
# courses_summary %>%
#   group_by(grad,year) %>%
#   mutate(total_section = sum(by_section),
#          total_course = sum(by_course)) -> courses_summary
# 
# courses_summary$percent_section <- courses_summary$by_section/courses_summary$total_section*100
# courses_summary$percent_course <- courses_summary$by_course/courses_summary$total_course*100
# 
# write.csv(courses_summary, 
#           "courses_summary_AC1_corrected_by_grad_year_21_23.csv",
#           row.names = FALSE)
# 
# usc_courses_full %>%
#   filter(year %in% c("AY21", "AY22", "AY23")) %>%
#   filter((year %in% c("AY20", "AY21", "AY22", "AY23", "AY25") & total_enrolled > 0) | year %in% c("AY25")) %>%
#   mutate(grad = ifelse(course_level == "graduate", "graduate", "undergrad")) %>%
#   group_by(year, sustainability_classification) %>%
#   summarize(by_section = sum(N.Sections), by_course = n()) -> courses_summary
# 
# courses_summary %>%
#   group_by(year) %>%
#   mutate(total_section = sum(by_section),
#          total_course = sum(by_course)) -> courses_summary
# 
# courses_summary$percent_section <- courses_summary$by_section/courses_summary$total_section*100
# courses_summary$percent_course <- courses_summary$by_course/courses_summary$total_course*100
# 
# write.csv(courses_summary, 
#           "courses_summary_AC1_corrected_by_year_21_23.csv",
#           row.names = FALSE)
