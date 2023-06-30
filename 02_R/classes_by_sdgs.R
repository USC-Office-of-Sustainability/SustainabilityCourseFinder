# need a new dataframe for find classes by sdgs page that

classes = read.csv("master_course_sdg_data.csv")
# basically just grab the data for most recent semester of each class

result = data.frame()
courses = unique(classes$courseID)


for (i in 1:length(courses)){
  print(i)
  course = courses[i]
  mini_df = classes[classes$courseID == course, ]
  if ("SP23" %in% unique(mini_df$semester))
  {
    sem = "SP23"
  }
  else
  {
    sem = unique(mini_df$semester)[length(unique(mini_df$semester))]
  }
  data = mini_df[mini_df$semester == sem, ]
  result = rbind(result, data)
}


# need to get the sustainability classification too
sustainability = read.csv("sustainability_related_courses.csv")
final = result %>% left_join(sustainability, by="courseID")


write.csv(final, "classes_by_sdgs.csv", row.names=F)


