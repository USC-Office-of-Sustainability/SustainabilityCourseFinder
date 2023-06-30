# adding PM-599 and GEOL-599

# read in the AY20-AY23 data
data = read.csv("usc_courses.csv")

# make sure you check all the semesters or you will run into problems later
# i could probably write a function one day where you enter a class and duplicate it and
# manually change just one or two things
geol = c("GEOL-599", "Data Science Methods for Climate Change Health Research", "SP23", 25001,
         "Data Science Methods for Climate Change Health Research - Introduces fundamental concepts on climate, epidemiology, and biostatistics and follows with data science methods to study impacts of climate-related events on human health.", "GEOL", 1, "AY23", 3, 
         "F20, SP21, F21, SP22, F22", "graduate")

pm = c("PM-599", "Data Science Methods for Climate Change Health Research", "SP23", 41249,
         "Data Science Methods for Climate Change Health Research - Introduces fundamental concepts on climate, epidemiology, and biostatistics and follows with data science methods to study impacts of climate-related events on human health.", "PM", 1, "AY23", 3, 
       "F21, SP22", "graduate")

data_new = rbind(data, geol)
data_new = rbind(data_new, pm)

write.csv(data_new, "usc_courses_updated.csv", row.names=F)
