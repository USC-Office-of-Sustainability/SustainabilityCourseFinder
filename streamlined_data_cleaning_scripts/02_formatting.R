# cleaning 2020-2022 course data
# different format from the 2018/2019 data
library(dplyr)

# data = read.csv("All_SOC_files_2020-2022_fixed.csv")
combined_data <- read.csv("streamlined_data/01_20251.csv")

# filtering out courses with titles containing ..., titles matching ..., and course 
# descriptions containing ...
# also counting number of sections and number of enrolled students
clean_data = function (raw_data){
  # we could split data in to origin < or > 20231
  titles_containing = c("Directed Research",
                        "Individual Instruction",
                        "Graduate Certificate Performance",
                        "Research Materials and Techniques",
                        "Doctoral Dissertation",
                        "Capstone",
                        "Off-Campus Studies",
                        "Overseas Block Enrollment",
                        "Thesis",
                        "Independent Study",
                        "Field Internship Experience",
                        "Individual Production Workshop",
                        "Advanced Production Seminar",
                        "Group Production Workshop",
                        "Independent Studies",
                        "Team Projects",
                        "Independent Research",
                        "Special Laboratory",
                        "Advanced Producing Project",
                        "Research Practicum")
  titles_matching = c("Advanced Research Experience",
                      "Board Development",
                      "Collaborative Communication",
                      "Consortium Enrollment (Financial Aid)",
                      "Creative Problem Solving 2",
                      "Enrollment for Early-Arriving PhD Students",
                      "Fieldwork Section II",
                      "International Academy Holding Course",
                      "International Academy Holding Course (Part II)",
                      "Internship for Curricular Practical Training",
                      "Organizational Development",
                      "Postdoctoral Fellows",
                      "Research",
                      "Studies for Master's Examination",
                      "Studies for the Qualifying Examination",
                      "Summer Enrollment for Continuing PhD Students",
                      "TEMPORARY ENROLLMENT/FILL COURSE",
                      "Test Course",
                      "Dissertation in Practice",
                      "Consulting Project",
                      "Doctoral dissertation",
                      "Dissertation Seminar",
                      "Planning, Design and Development Professional Dissertation")
  descriptions_containing = c("Directed undergraduate research",
                              "Directed graduate research")
  data_clean <- raw_data %>%
    filter(!grepl(paste(titles_containing, collapse = "|"), COURSE_TITLE) & 
             !COURSE_TITLE %in% titles_matching &
             !grepl(paste(descriptions_containing, collapse = "|"), COURSE_DESCRIPTION) &
             !grepl("-[47]90|-594", COURSE_CODE))
  # get total number of enrolled students across all sections for class
  # get number of sections
  data_clean %>%
    group_by(COURSE_CODE, COURSE_TITLE, SECTION_NAME, origin) %>%
    mutate(total_enrolled = sum(TOTAL_ENR),
           N.Sections = n()) %>%
    filter(row_number()==1)
}

cleaned = clean_data(combined_data)

# now need to get the semester format right, need F20, SU20, SP20 etc.
# right now it is in format 20202_SUMMER, 20212_SUMMER
# 3 is fall, 2 is summer, 1 is spring
get_semester <- function(x){
  if (x%%10 == 3) {
    # fall
    res = paste("F", substr(as.character(x), 3, 4), sep = "")
  } else if (x%%10 == 2) {
    # summer
    res = paste("SU", substr(as.character(x), 3, 4), sep = "")
  } else if (x%%10 == 1) {
    # spring
    res = paste("SP", substr(as.character(x), 3, 4), sep = "")
  }
  
#  if (res == "SP24"){
#    res = "SP24FAKE" 
#  }
#  if (res == "SP25"){
#    res = "SP25FAKE"
#  }
  print(res)
  return(res)
}

# helper function to get "year" column in form AY20, AY21 etc.
# parameter is the column of the terms F20, SP21, etc.
# if it is 2020-2 or 2020-3, the AY is 21
# if it is 2021-1, AY is 21
get_year <- function(letters){
  # convert year to a integer
  year = strtoi(substr(letters,3,4))
  term = substr(letters, 5,5)
  # summer and fall terms count as the academic year of spring
  if (term == "2" | term == "3"){
    year = year + 1
  }
  paste0("AY", year)
}


transform_data = function(course_data){
  # now create "semester" column in the classes dataframe
  course_data$semester = sapply(course_data$origin, get_semester)
  #create the "course_num" column from "rcl.class"
  # course_data$section = course_data$SECTION
  #create the "course_desc" column
  course_data$course_desc = paste(course_data$COURSE_TITLE, 
                                  course_data$SECTION_NAME, 
                                  course_data$COURSE_DESCRIPTION, 
                                  sep = " - ")
  #create class_title column
  # course_data$courseID = course_data$COURSE_CODE
  # course_data$section_title = course_data$SECTION_NAME
  # create course column
  # course_data$course_title = course_data$COURSE_TITLE
  # create department column
  # course_data$department = course_data$DEPARTMENT #changed this from departmentowner name
  # course_data$school = course_data$SCHOOL
  # create year column
  course_data$year = sapply(course_data$origin, get_year)
  # select relevant columns for the Shiny App
  # course_data = course_data[, c("courseID", "course_title", "section_title", "semester", "section", "course_desc", "department", "school", "N.Sections", "year", "total_enrolled")]
  
  return (course_data)
}

data_final = transform_data(cleaned)

# rename columns
names(data_final) <- tolower(names(data_final))
data_final <- data_final %>%
  select(-min_units, -max_units, -mode, -link, -publish, -start_time, -end_time, -days, -total_enr, -modality, -assigned_room, -total_enr1) %>%
  rename(courseID = course_code,
         N.Sections = n.sections,
         instructor = instructor_name
         )


# also want to get "all semesters" column in the usc_courses dataframe
get_all_semesters <- function(data) {
  # data$semester <- factor(data$semester, levels = c("SU20", "F20", "SP21", "SU21", "F21", "SP22", "SU22", "F22", "SP23", "SU23", "F23"))
  data %>%
    group_by(courseID, section_name) %>%
    mutate(all_semesters = paste(unique(semester), collapse = ", ")) %>%
    ungroup()
}

data_final = get_all_semesters(data_final)


# last thing!
# helper function to get the grad/undergrad column from courseID column
get_course_level <- function(course) {
  # get just the number after the "-"
  num = strsplit(course, "-")[[1]][2]
  # some course codes have letters at the end, remove them and convert to number
  val = as.numeric(unlist(strsplit(gsub("[^[:digit:]. ]", "", num), " +")))
  if (val >= 500){
    "graduate"
  }
  else if (val < 300){
    "undergrad lower division"
  }
  else {
    "undergrad upper division"
  }
}

# now add the course levels to data
data_final$course_level = sapply(data_final$courseID, get_course_level)

write.csv(data_final, "streamlined_data/02_20251.csv",row.names = F)


