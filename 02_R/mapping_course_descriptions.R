

usc_keywords = read.csv("usc_keywords.csv")

# goal of this function is to return a vector of all the keywords 
# in a course description (including duplicates)
find_words = Vectorize(function(text, sdg, keywords="usc_keywords", count_repeats=FALSE){
  if (keywords=="usc_keywords"){
    sdg_keywords = usc_keywords %>% filter (goal==sdg)
  }
  
  patterns <- sdg_keywords$pattern
  keywords <- sdg_keywords$keyword
  
  words <- c()
  
  for (i in 1:nrow(sdg_keywords)){
    if (grepl(tolower(patterns[i]), tolower(text))){
      # count number of times
      sum = str_count(tolower(text), patterns[i])
      for (j in 1:sum){
        words = c(words, keywords[i])
      }
    }
  }
  return(words)
})

# can test function test with this
# find_words("poverty access to clothing access to clothing poverty poor poor poverty", 1)
# data = read.csv("usc_courses_cleaned.csv")
# data = data[data$courseID == "RED-398", ]
# find_words(data$clean_course_desc[1], 11)

# read in the USC course data
classes = read.csv("usc_courses_cleaned.csv")
# usc_keywords = read.csv("USC_PWG-E_2023Keywords.csv") #could filter these if we wanted to
# usc_keywords$weight = 1

all_sdg_keywords <- data.frame()
for (goal_num in 1:17) {
  print(goal_num) #useful for seeing how far you are in the code run
  classes %>%
    mutate(goal = goal_num, #run on clean_course_desc column w no punctuation and accuracy edits made
           keyword = find_words(classes$clean_course_desc, goal_num, keywords = "usc_keywords")) %>%
    unnest(keyword) -> cur_sdg_keywords
  
  all_sdg_keywords <- rbind(all_sdg_keywords, cur_sdg_keywords) 
}

#create a copy because that code took a very long time to run
all_sdg_keywords_copy = all_sdg_keywords


#now join it with usc_keywords to get color and weight
all_sdg_keywords_copy %>%
  left_join(usc_keywords, by = c("goal", "keyword")) %>%
  select(courseID, course_title, section, semester, keyword, goal, weight, color, course_desc, clean_course_desc, department, N.Sections, year, course_level, total_enrolled, all_semesters) %>%
  arrange(courseID) -> all_sdg_keywords_copy

write.csv(all_sdg_keywords_copy, "master_course_sdg_data.csv", row.names = F)

# save this object so we dont have to run code again
save(all_sdg_keywords_copy, file="all_sdg_keywords.Rda")
