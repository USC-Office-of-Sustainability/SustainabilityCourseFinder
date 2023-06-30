# cleaning 2020-2022 course data
# different format from the 2018/2019 data

# data = read.csv("All_SOC_files_2020-2022_fixed.csv")
data = read.csv("combined_data.csv")

# filtering out Master's Thesis, Directed Research, and Doctoral Dissertation, all of which have a space at the end
# also counting number of sections and number of enrolled students
clean_data = function (raw_data){
  data_clean = raw_data
  # we could split data in to origin < or > 20231
  # data_clean = raw_data[trimws(raw_data$COURSE_TITLE) !=  "Directed Research"
  #                       & trimws(raw_data$COURSE_TITLE) !=  "Master's Thesis" 
  #                       & trimws(raw_data$COURSE_TITLE) !=  "Doctoral Dissertation"
  #                       & trimws(raw_data$COURSE_TITLE) !=  "Research"
  #                       & trimws(raw_data$COURSE_TITLE) != "Studies for the Qualifying Examination"
  #                       & trimws(raw_data$COURSE_TITLE) != "Enrollment for Early-Arriving PhD Students"
  #                       & trimws(raw_data$COURSE_TITLE) != "Studies for the Qualifying Examination"
  #                       & trimws(raw_data$COURSE_TITLE) != "Studies for Master's Examination"
  #                       & trimws(raw_data$COURSE_TITLE) != "Internship for Curricular Practical Training"
  #                       & trimws(raw_data$COURSE_TITLE) != "Off-Campus Studies"
  #                       & trimws(raw_data$COURSE_TITLE) != "Creative Problem Solving 1"
  #                       & trimws(raw_data$COURSE_TITLE) != "Creative Problem Solving 2"
  #                       & trimws(raw_data$COURSE_TITLE) != "Postdoctoral Fellows"
  #                       & trimws(raw_data$COURSE_TITLE) != "International Academy Holding Course"
  #                       & trimws(raw_data$COURSE_TITLE) != "International Academy Holding Course (Part II)"
  #                       & trimws(raw_data$COURSE_TITLE) != "Test Course"
  #                       & trimws(raw_data$COURSE_TITLE) != "TEMPORARY ENROLLMENT/FILL COURSE"
  #                       & trimws(raw_data$COURSE_TITLE) != "Consortium Enrollment (Financial Aid)"
  #                       & trimws(raw_data$COURSE_TITLE) != "Summer Enrollment for Continuing PhD Students"
  #                       & trimws(raw_data$COURSE_TITLE) != "Capstone"
  #                       & trimws(raw_data$COURSE_TITLE) != "Fieldwork Section II"
  #                       & trimws(raw_data$COURSE_TITLE) != "Organizational Development"
  #                       & trimws(raw_data$COURSE_TITLE) != "Collaborative Communication"
  #                       & trimws(raw_data$COURSE_TITLE) != "Board Development"
  #                       , ]
  # want to get a column for the total number of enrolled students across all sections for class
  # first grab all the unique courses per semester
  data_unique = data_clean[!duplicated(data_clean[ , c("COURSE_CODE", "origin")]), ]
  students = c()
  sections = c()
  for (i in 1:nrow(data_unique)){
    course = data_unique[i, "COURSE_CODE"] 
    term = data_unique[i, "origin"]
    # grab just the data for that course/semester
    mini_df = data_clean[ data_clean$COURSE_CODE == course & data_clean$origin == term , ]
    # sum up the total students across all sections
    total_students = sum(as.numeric(mini_df$TOTAL_ENR))
    students = c(students, total_students)
    # now get number of sections for each class in a semester
    rows = nrow(mini_df)
    sections = c(sections, rows)
  }
  data_unique["total_enrolled"] = students
  data_unique["N.Sections"] = sections
  
  return (data_unique)
}
# still need to cut out 700 level courses

#takes awhile to run this line
cleaned = clean_data(data)

# now need to get the semester format right, need F20, SU20, SP20 etc.
# right now it is in format 20202_SUMMER, 20212_SUMMER
# 3 is fall, 2 is summer, 1 is spring
get_semesters <- function(term_col){
  semesters = c()
  for (i in 1:length(term_col)){
    letters = term_col[i]
    year = substr(letters,3,4)
    term = substr(letters, 5,5)
    if (term == "1"){
      term = "SP"
    }
    else if (term == "2"){
      term = "SU"
    }
    else{
      term = "F"
    }
    result = paste0(term, year)
    semesters = c(semesters, result)
  }
  return(semesters)
}

# helper function to get "year" column in form AY20, AY21 etc.
# parameter is the column of the terms F20, SP21, etc.
# if it is 2020-2 or 2020-3, the AY is 21
# if it is 2021-1, AY is 21
get_year <- function(term_col){
  years = c()
  for (i in 1:length(term_col)){
    letters = term_col[i]
    # convert year to a integer
    year = strtoi(substr(letters,3,4))
    term = substr(letters, 5,5)
    # summer and fall terms count as the academic year of spring
    if (term == "2" | term == "3"){
      year = year + 1
    }
    result = paste0("AY", year)
    years = c(years, result)
  }
  return(years)
}


transform_data = function(course_data){
  # now create "semester" column in the classes dataframe
  course_data$semester = get_semesters(course_data$origin)
  #create the "course_num" column from "rcl.class"
  course_data$section = course_data$SECTION
  #create the "course_desc" column
  course_data$course_desc=paste(course_data$COURSE_TITLE, "-", course_data$COURSE_DESCRIPTION)
  #create class_title column
  course_data$courseID = course_data$COURSE_CODE
  # create course column
  course_data$course_title = course_data$COURSE_TITLE
  # create department column
  course_data$department = course_data$DEPARTMENT #changed this from departmentowner name
  # create year column
  course_data$year = get_year(course_data$origin)
  # select relevant columns for the Shiny App
  course_data = course_data[, c("courseID", "course_title", "semester", "section", "course_desc", "department", "N.Sections", "year", "total_enrolled")]
  
  return (course_data)
}

data_final = transform_data(cleaned)


# also want to get "all semesters" column in the usc_courses dataframe
get_all_semesters <- function(data) {
  data$all_semesters = NA
  for (i in 1:nrow(data)){
    print(i)
    # grab the course ID
    course = data$courseID[i]
    df = data[data$courseID == course, ]
    sems = unique(df$semester)
    result = paste(sems, collapse=", ")
    data$all_semesters[i] = result
  }
  return (data)
}

data_final = get_all_semesters(data_final)


# last thing!
# helper function to get the grad/undergrad column from courseID column
get_class_levels <- function(data) {
  data$course_level = NA
  for (i in 1:nrow(data)){
    print(i)
    # grab the course ID
    course = data$courseID[i]
    # get just the number after the "-"
    num = strsplit(course, "-")[[1]][2]
    # some course codes have letters at the end, remove them and convert to number
    val = as.numeric(unlist(strsplit(gsub("[^[:digit:]. ]", "", num), " +")))
    if (val >= 500){
      data$course_level[i] = "graduate"
    }
    else if (val < 300){
      data$course_level[i] = "undergrad lower division"
    }
    else{
      data$course_level[i] = "undergrad upper division"
    }
  }
  return (data)
}

# now add the course levels to data
data_final = get_class_levels(data_final)

write.csv(data_final, "usc_courses.csv",row.names = F)


