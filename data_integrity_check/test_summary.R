library(plyr)
library(tidyverse)
library(dplyr)
### new. counts for Evan and everyone else based on the new section names and categorization
AC1courses=read.csv("/Users/fy916/Documents/Projects/Dev_R/SustainabilityCourseFinder/shiny_app/usc_courses_full.csv", header=TRUE)
names(AC1courses)
levels(as.factor(AC1courses$course_level))
##need to filter enrollment to >0!
courses= transform(AC1courses, course_level=revalue(course_level,c("undergrad lower division"="undergraduate","undergrad upper division"="undergraduate")))
#need to filter out AY25
courses_21_25 = courses%>%
  filter(year != "AY20") %>%
  #filter((year %in% c("AY21", "AY22", "AY23", "AY24") & total_enrolled > 0) | year %in% c("AY25"))
  filter((year %in% c("AY21", "AY22", "AY23", "AY24","AY25") & total_enrolled > 0) )
levels(as.factor(courses_21_25$year))
#coursesAY20_AY24=courses %>% filter(year %in% c("AY20","AY21", "AY22", "AY23", "AY24"))
#AC1enrolled=coursesAY20_AY24%>%filter(total_enrolled > 0)
#use AC1enrolled for Provost data
levels(as.factor(courses_21_25$sustainability_classification))
write.csv(courses_21_25, "Classified_Enrolled_Courses_AY20_AY25_updated_10_25_24.csv", row.names=FALSE)
#below summarize for President's Folt Document w/ grad/undergrad just for AY24!
#courses25=courses_21_25 %>% filter(year %in% "AY25" & sustainability_classification %in% "Sustainability-Focused")
# sum21_25=ddply(courses_21_25,.(sustainability_classification, year, course_level), summarise, sections=sum(N.Sections,na.rm=TRUE), courses=length(na.omit(courseID)), enrollment=sum(total_enrolled))

sum21_25 <- ddply(courses_21_25, 
                  .(sustainability_classification, year, course_level), 
                  summarise, 
                  sections = sum(N.Sections, na.rm = TRUE), 
                  courses = length(na.omit(courseID)), 
                  enrollment = sum(total_enrolled))

# Summarize across course levels
sum_combined <- ddply(sum21_25, 
                      .(sustainability_classification, year), 
                      summarise, 
                      course_level = "combined",
                      sections = sum(sections, na.rm = TRUE), 
                      courses = sum(courses, na.rm = TRUE), 
                      enrollment = sum(enrollment, na.rm = TRUE))

# Bind the two datasets together
final_result <- rbind(sum21_25, sum_combined)
final_result <- arrange(final_result, sustainability_classification, year)

write.csv(final_result, "sustainability_focused_courses_summary_AY21_AY25.csv", row.names=FALSE)
names(courses_21_25)
powerBIcourses=courses_21_25%>%
  filter(course_level== "undergraduate") %>%
  filter((sustainability_classification %in% c("Sustainability-Focused", "Sustainability-Inclusive")))
powerbisum=ddply(powerBIcourses,.(sustainability_classification, year, course_level), summarise, sections=sum(N.Sections,na.rm=TRUE), courses=length(na.omit(courseID)), enrollment=sum(total_enrolled))
powerbisum
write.csv(powerbisum, "AE_2.1_sustainability_focused_inclusive_courses_AY25.csv", row.names=FALSE)