# add school column
library(dplyr)
usc_courses_cleaned <- read.csv("usc_courses_updated.csv")
fulldata <- read.csv("01_cleaning_raw_data/00_raw_usc_data/combined_data.csv")
fulldata_select <- fulldata %>%
  select("COURSE_CODE", "COURSE_TITLE", "SECTION", "DEPARTMENT", "SCHOOL", 
         "DEPTOWNERNAME", "origin", "INSTRUCTOR_NAME")
# create semester column based on origin column
# ends in 3 -> fall, 2 -> summer, 1 -> spring
fulldata_select$semester <- sapply(fulldata_select$origin, function(x) {
  if (x%%10 == 3) {
    # fall
    paste("F", substr(as.character(x), 3, 4), sep = "")
  } else if (x%%10 == 2) {
    # summer
    paste("SU", substr(as.character(x), 3, 4), sep = "")
  } else if (x%%10 == 1) {
    # spring
    paste("SP", substr(as.character(x), 3, 4), sep = "")
  }
})

usc_courses_with_school <- merge(
  usc_courses_cleaned, 
  fulldata_select, 
  by.x=c("courseID", "course_title", "section", "department" , "semester"),
  by.y=c("COURSE_CODE", "COURSE_TITLE", "SECTION", "DEPARTMENT", "semester"),
  all.x = TRUE)

# fix DEPTOWNERNAME
Dornsife = c("LAS - Natural Sciences & Mathematics", 
             "LAS - Natural Sciences & Mathematics Keck School of Medicine", 
             "LAS - Other Programs", 
             "LAS- Humanities",
             "LAS- Social Science & Communications", 
             "LAS- Social Science & Communications Animation",
             "Dana and David Dornsife College of Letters, Arts and Sciences" ,
             "Dana and David Dornsife College of Letters, Arts and Sciences Registrar's Office",  
             " Humanities",
             "Hebrew Union College")
Annenberg = c("nenberg School for Communication and Journalism",
              "nnenberg School for Communication and Journalism",
              "Annenberg School for Communication and Journalism", 
              "School of Journalism")
Viterbi = c("Andrew and Erna Viterbi School of Engineering",
            "drew and Erna Viterbi School of Engineering")
Marshall = c("Business",
             "Gordon S. Marshall School of Business",
             "Gordon S. Marshall School of Business Gordon S. Marshall School of Business")
Pharmacy = c("School of Pharmacy", 
             "Pharmacy")
Policy = c("Sol Price School of Public Policy", 
           "Policy, Planning and Development Sol Price School of Public Policy")
Music = c("Flora L. Thornton School of Music",
          "School of Music")
RegistrarOffice_GradSchool = c("Registrar's Office",
                               "Registrar's Office Graduate School" ,
                               "Registration Department",
                               "Graduate School",
                               "Graduate School Registrar's Office",
                               "Graduate Studies")
Ostrow = c("Ostrow School of Dentistry",
           "Independent Health Professions")
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(DEPTOWNERNAME = 
           ifelse(DEPTOWNERNAME %in% Dornsife, 
                  "Dana and David Dornsife College of Letters, Arts and Sciences",
                  ifelse(DEPTOWNERNAME %in% Annenberg,
                         "Annenberg School for Communication and Journalism",
                         ifelse(DEPTOWNERNAME %in% Viterbi,
                                "Andrew and Erna Viterbi School of Engineering",
                                ifelse(DEPTOWNERNAME %in% Marshall,
                                       "Gordon S. Marshall School of Business",
                                       ifelse(DEPTOWNERNAME %in% Pharmacy,
                                              "School of Pharmacy",
                                              ifelse(DEPTOWNERNAME %in% Policy,
                                                     "Sol Price School of Public Policy",
                                                     ifelse(DEPTOWNERNAME %in% Music,
                                                            "Thornton School of Music",
                                                            ifelse(DEPTOWNERNAME %in% RegistrarOffice_GradSchool,
                                                                   "Registrar's Office and Graduate School",
                                                                   ifelse(DEPTOWNERNAME %in% Ostrow,
                                                                          "Ostrow School of Dentistry",
                                                                          DEPTOWNERNAME))))))))))
# check current DEPTOWNERNAME
levels(as.factor(usc_courses_with_school$DEPTOWNERNAME))

# replace empty SCHOOL with NA
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(SCHOOL = na_if(SCHOOL, ""))

# remove extra space around SCHOOL
usc_courses_with_school$SCHOOL <- trimws(usc_courses_with_school$SCHOOL)

# replace empty DEPTOWNERNAME with NA
usc_courses_with_school <- usc_courses_with_school %>% 
  mutate(DEPTOWNERNAME = na_if(DEPTOWNERNAME, ""))

# fill in NA DEPTOWNERNAME based on school to owner
school_to_owner <- usc_courses_with_school %>% 
  filter(!is.na(DEPTOWNERNAME)) %>%
  select(SCHOOL, DEPTOWNERNAME) %>%
  distinct()
school_owner_map <- school_to_owner$DEPTOWNERNAME
school_owner_map <- setNames(school_owner_map, school_to_owner$SCHOOL)
# school_owner_map <- append(school_owner_map, "Dana and David Dornsife College of Letters, Arts and Sciences")
# names(school_owner_map)[length(school_owner_map)] <- "NGP"
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(DEPTOWNERNAME = ifelse(is.na(DEPTOWNERNAME), 
                                school_owner_map[SCHOOL], 
                                DEPTOWNERNAME))

# fill in NA DEPTOWNERNAME based on department to DEPTOWNERNAME
department_to_DEPTOWNERNAME <- usc_courses_with_school %>%
  filter(!is.na(DEPTOWNERNAME)) %>%
  select(department, DEPTOWNERNAME) %>%
  distinct()
department_DEPTOWNERNAME_map <- department_to_DEPTOWNERNAME$DEPTOWNERNAME
department_DEPTOWNERNAME_map <- setNames(department_DEPTOWNERNAME_map, department_to_DEPTOWNERNAME$department)
# NSCI courses belong in Dornsife
department_DEPTOWNERNAME_map <- append(department_DEPTOWNERNAME_map, "Dana and David Dornsife College of Letters, Arts and Sciences")
names(department_DEPTOWNERNAME_map)[length(department_DEPTOWNERNAME_map)] <- "NSCI"
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(school = ifelse(is.na(DEPTOWNERNAME),
                         department_DEPTOWNERNAME_map[department],
                         DEPTOWNERNAME))

# Registrar's Office and Graduate School's HUC- and LING- to Dornsife
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(school = 
           ifelse(school == "Registrar's Office and Graduate School" & 
                    grepl("HUC|LING", courseID),
                  "Dana and David Dornsife College of Letters, Arts and Sciences", 
                  school))

# remove Registrar's Office and Graduate School courses
usc_courses_with_school <- usc_courses_with_school %>%
  filter(school != "Registrar's Office and Graduate School")

usc_courses_school <- usc_courses_with_school %>%
  rename(instructor = INSTRUCTOR_NAME) %>%
  select(school, courseID, course_title, instructor, section, department, semester, course_desc, N.Sections, year, course_level, total_enrolled, all_semesters)

write.csv(usc_courses_school,
          "usc_courses_updated_with_school.csv",
          row.names = FALSE)
