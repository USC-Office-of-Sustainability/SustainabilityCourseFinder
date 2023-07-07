# general education requirements
# ge class based on most recent class info
library(tidyverse)
library(readxl)
data = read_excel("Data/CATALOG_CLASS_GECAT_20231.xlsx")

data = data %>% select(RCA_COURSE, RCA_TITLE, RCA_GECAT_C)
data = data %>% rename(courseID = RCA_COURSE, course_title = RCA_TITLE, geID = RCA_GECAT_C)

# fix PHIL-288 course title
grep(";", data$course_title)
data$course_title <- gsub(";", " ", data$course_title)
# clean course title extra spaces
data$course_title <- trimws(data$course_title)

# want to go through and split off the categories for a class into new rows
data = data %>% 
  mutate(id = strsplit(as.character(geID), ";")) %>% 
  unnest(id) %>% 
  select(-geID)

# 20 - Category I: Western Cultures and Traditions 
# 21 - Category II: Global Cultures and Traditions 
# 22 - Category III: Scientific Inquiry
# 23 - Category IV: Science and Its Significance 
# 24 - Category V: Arts and Letters
# 25 - Category VI: Social Issues
# 30 - A The Arts
# 31 - B Humanistic Inquiry 
# 32 - C Social Analysis 
# 33 - D Life Sciences
# 34 - E Physical Sciences
# 35 - F Quantitative Reasoning 
# 36 - G Citizenship in a Diverse World
# 37 - H Traditions and Historical Foundations

# new column "category" and "category name"

ids = c(20, 21, 22, 23, 24, 25, 30, 31, 32, 33, 34, 35, 36, 37)
values = c("Category I", "Category II", "Category III", "Category IV", "Category V", 
           "Category VI", "A", "B", "C", "D", "E", "F", "G", "H")
names = c("Western Cultures and Traditions", "Global Cultures and Traditions", 
          "Scientific Inquiry", "Science and Its Significance ",
          "Arts and Letters", "Social Issues", "The Arts", "Humanistic Inquiry", 
          "Social Analysis", "Life Sciences", "Physical Sciences",
          "Quantitative Reasoning", "Citizenship in a Diverse World", 
          "Traditions and Historical Foundations")

key = data.frame(id = ids, value = values, name = names)
key$full_name = paste(key$value, key$name, sep=" - ")

# need to convert id's to numbers
key$id = as.numeric(key$id)
data$id = as.numeric(data$id)
# join them together
df = left_join(data, key, by="id")
# nice.

# sustainability_related <- read.csv("shiny_app/usc_courses_full.csv")
# sustainability_related$course_title <- trimws(sustainability_related$course_title)
# result <- left_join(df, sustainability_related, by = "courseID")
# ge_multi <- merge(df, master, by = c("courseID", "course_title"), all.x = TRUE)
# ge_single <- merge(df, sustainability_related, by = c("courseID", "course_title"), all.x = TRUE)

recent_courses <- read.csv("shiny_app/recent_courses.csv")
# course title's have extra spaces at the beginning/end
recent_courses$course_title <- trimws(recent_courses$course_title)
# merge ge data with recent course data
ge_recent <- merge(df, recent_courses, by = c("courseID", "course_title"), all.x = TRUE)

# 3 ge courses are not in recent_courses
# set sustainability_classification as not related
ge_recent$sustainability_classification <- 
  ifelse(is.na(ge_recent$sustainability_classification),
         "Not Related",
         ge_recent$sustainability_classification)

# save ge data for shiny app
write.csv(ge_recent, "shiny_app/ge_data.csv", row.names = FALSE)


