# this script categorizes each course as sustainability, 
# focused, inclusive, or not related

library(tidyverse)

# data containing all course titles
usc_courses = read.csv("usc_courses_cleaned.csv")
# data containing what courses map to which goals
master_data = read.csv("master_course_sdg_data.csv")


# grab the unique class titles
courseID = unique(usc_courses$courseID)
sustainability = data.frame(courseID)
# create column to store goals that class maps to 
sustainability = sustainability %>% add_column(goals = NA)
# create column to store sustainability-relatedness
sustainability = sustainability %>% add_column(related = NA)
# create column to store keywords
sustainability = sustainability %>% add_column(keywords = NA)
# criteria lists
social_economic_goals = c(1, 2, 3, 4, 5, 8, 9, 10, 11, 16, 17)
environment_goals = c(6, 7, 12, 13, 14, 15)


# go through and get all the related goals for each class
index = 1
for (course in sustainability$courseID){
  # subset master data to just the rows for that class and grab the unique goals
  mini_df = unique(master_data[master_data$courseID == course, "goal"])
  # combine all the goals into a string to be added to the goals column in df
  goals = paste(mini_df, collapse=",")
  #update the goals column of df to be this string "goals"
  sustainability$goals[index] = goals
  
  # subset master data to just the rows for that class and grab the unique keywords
  mini_df = unique(master_data[master_data$courseID == course, "keyword"])
  # combine all keywords into a string to be added to the keywords column in df
  keywords = paste(mini_df, collapse = ",")
  # update the keywords colun of df to be this string "keywords"
  sustainability$keywords[index] = keywords
  
  index = index + 1
}




# now need to go through and check criteria and update the related column accordingly
for (i in 1:nrow(sustainability)){
  # first check if it is null
  if (sustainability$goals[i] == ""){
    sustainability$related[i] = "Not Related"
    next
  }
  # check if it has at least two keywords
  course = sustainability$courseID[i]
  num_keywords = 0
  mini_df = master_data[master_data$courseID == course, "keyword"]
  if (length(mini_df) > 1){
    sustainability$related[i] = "SDG-Related"
  }
  if (length(mini_df) == 1){
    sustainability$related[i] = "Not Related"
  }
  # now checking if sustainability-focused
  # grab the goals in each row
  goals = as.list(strsplit(sustainability$goals[i], ",")[[1]])
  # set these booleans to false for each row to start
  is_social_economic = FALSE
  is_environment = FALSE
  for (j in 1:length(goals)){
    if (goals[j] %in% social_economic_goals){
      is_social_economic = TRUE
    }
    if (goals[j] %in% environment_goals){
      is_environment = TRUE
    }
  }
  # now we should know if there was at least one of the criteria present
  if (is_social_economic & is_environment){
    sustainability$related[i] = "Sustainability-Focused"
  }
  # if (is_social_economic & !is_environment){
  #   sustainability$related[i] = "SDG-Related"
  # }
  # if (!is_social_economic & is_environment){
  #   sustainability$related[i] = "SDG-Related"
  # }
}

# need to rename the columns
# names(sustainability)[names(sustainability) == 'courseID'] <- "course_title"
names(sustainability)[names(sustainability) == 'related'] <- "sustainability_classification"
names(sustainability)[names(sustainability) == 'goals'] <- "all_goals"
names(sustainability)[names(sustainability) == 'keywords'] <- "all_keywords"

# check the counts of how many there are of each
# sum(sustainability$sustainability_classification == "Focused")
# sum(sustainability$sustainability_classification == "Inclusive")
# sum(sustainability$sustainability_classification == "Not Related")

write.csv(sustainability, "sustainability_related_courses.csv", row.names = F)


# want to create a dataframe with more information for pie charts using joins
sustainability = read.csv("sustainability_related_courses.csv")
# course_data = usc_courses %>% left_join(sustainability, by="courseID", all.x = T)
course_data = usc_courses %>% left_join(sustainability, by="courseID")
write.csv(course_data, "usc_courses_full.csv", row.names = F)
