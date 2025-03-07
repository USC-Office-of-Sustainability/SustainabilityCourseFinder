# adding PM-599 and GEOL-599 - both of these are already in the SOC files 2/28/24!
# skip this file

# read in the AY20-AY23 data
data = read.csv("usc_courses.csv")

# make sure you check all the semesters or you will run into problems later
# i could probably write a function one day where you enter a class and duplicate it and
# manually change just one or two things
geol = c("GEOL-599", "Special Topics", "Data Science Methods for Climate Change Health Research", "SP23", 25001,
         "Data Science Methods for Climate Change Health Research - Introduces fundamental concepts on climate, epidemiology, and biostatistics and follows with data science methods to study impacts of climate-related events on human health.", "GEOL", "LASN", 1, "AY23", 3, 
         "F20, SP21, F21, SP22, F22", "graduate")

pm = c("PM-599", "Special Topics", "Data Science Methods for Climate Change Health Research", "SP23", 41249,
         "Data Science Methods for Climate Change Health Research - Introduces fundamental concepts on climate, epidemiology, and biostatistics and follows with data science methods to study impacts of climate-related events on human health.", "PM", "MED", 1, "AY23", 3, 
       "F21, SP22", "graduate")

data_new = rbind(data, geol)
data_new = rbind(data_new, pm)

# update all_semesters
data_new <- data_new %>%
  group_by(courseID) %>%
  mutate(all_semesters = paste(unique(semester), collapse = ", ")) %>%
  ungroup()

write.csv(data_new, "usc_courses_updated.csv", row.names=F)
