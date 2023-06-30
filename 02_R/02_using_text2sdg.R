# map course description using text2sdg
# add sustainability classification
library(text2sdg)
library(dplyr)

usc_pwg_keywords <- read.csv("shiny_app/usc_keywords.csv")

# create system for text2sdg
usc_pwg_system <- usc_pwg_keywords %>%
  mutate(system = "usc_pwg",
         query = paste0('"', keyword, '"')) %>%
  rename(sdg = goal) %>%
  select(system, sdg, query)


usc_courses <- read.csv("usc_courses_cleaned_with_school.csv")
usc_courses$rowID <- 1:nrow(usc_courses)

# lowercase
usc_courses$text <- tolower(usc_courses$clean_course_desc)

# remove '
usc_courses$text <- gsub("'", " ", usc_courses$text)

# duplicate keywords will only count as 1
hits <- detect_any(usc_courses$text, usc_pwg_system, output = "features")
# remove commas in features
hits$cleanfeatures <- gsub(",", "", hits$features)

hits$sdg_num <- sapply(hits$sdg, function(x) {
  as.numeric(strsplit(x, "-")[[1]][2])
})

hits_color <- merge(hits, usc_pwg_keywords, 
                    by.x = c("cleanfeatures", "sdg_num"), 
                    by.y = c("keyword", "goal")) %>%
  select(document, sdg_num, cleanfeatures, color)

master_course_sdg_data <- merge(hits_color, usc_courses, by.x = "document", by.y = "rowID", all.y = TRUE) %>%
  rename(keyword = cleanfeatures, goal = sdg_num) %>%
  select(document, school, courseID, course_title, instructor, section, semester, keyword, goal, color, course_desc, text, department, N.Sections, year, course_level, total_enrolled, all_semesters) %>%
  arrange(courseID) %>%
  group_by(document) %>%
  mutate(all_keywords = paste(unique(keyword), collapse = ","),
         all_goals = paste(sort(unique(goal)), collapse = ","))

# sustainability classification
social_economic_goals = c(1, 2, 3, 4, 5, 8, 9, 10, 11, 16, 17)
environment_goals = c(6, 7, 12, 13, 14, 15)
determine_classification <- function(x) {
  if (is.na(x) | x == "NA" | x == "") {
    return("Not Related")
  }
  separate_sdgs <- strsplit(x, ",")[[1]]
  if (length(intersect(social_economic_goals, separate_sdgs)) >= 1 & 
      length(intersect(environment_goals, separate_sdgs)) >= 1) {
    return("Sustainability-Focused")
  } else {
    return("SDG-Related")
  }
}
master_course_sdg_data$sustainability_classification <- sapply(master_course_sdg_data$all_goals, determine_classification)
master_course_sdg_data$freq <- str_count(master_course_sdg_data$text, master_course_sdg_data$keyword)
write.csv(master_course_sdg_data, "shiny_app/master_course_sdg_data.csv", row.names = FALSE)

single_rows <- master_course_sdg_data[,!(names(master_course_sdg_data) %in% c("keyword", "goal", "color", "freq"))] %>% distinct()
write.csv(single_rows,
          "shiny_app/usc_courses_full.csv",
          row.names = FALSE)

# all course's most recent semester
most_recent_semester <- single_rows %>%
  group_by(courseID) %>%
  summarize(n = n(),
            recentSemester = trimws(strsplit(all_semesters, ",")[[1]][n])) %>%
  select(courseID, recentSemester)
recent_courses <- merge(most_recent_semester, master_course_sdg_data, by.x = c("courseID", "recentSemester"), by.y = c("courseID", "semester"))
names(recent_courses)[names(recent_courses) == 'recentSemester'] <- "semester"
write.csv(recent_courses, "shiny_app/recent_courses.csv", row.names=FALSE)
