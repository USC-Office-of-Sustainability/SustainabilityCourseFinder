# fix school column
usc_courses_cleaned <- read.csv("streamlined_data/02_A2_20251.csv")

# there's one school that is "" -> HUC -> Dornsife
Dornsife = c("LASN", "LAS", "LASO", "LASH", "LASS", "LASO",
             "PROV", # for ALI- courses
             "LAS RNR",  
             "HUC", # Hebrew Union College
             "NGP", # neurosci
             "LASS CTAN"
             )
Annenberg = c("ANSC", "ASC", "JOUR")
Viterbi = c("ENGR")
Marshall = c("BUAD", "GSBA", "BUS", "BUSD", "GSBA BUAD", "BUAD GSBA")
Pharmacy = c("PHAR", "PHRD")
Policy = c("PPD", "XPPD", "XPPD PPD", "PUAD")
Music = c("MUS", "MUSC")
RegistrarOffice_GradSchool = c("RNR", "REG")
Ostrow = c("DHRP", "DENT")
Keck = c("MED")
Law = c("LAW")
Iovine = c("ACAD")
Architecture = c("ARCH")
Bovard = c("BVC")
Leventhal = c("ACCT")
Cinematic = c("CNTV")
Kaufman = c("DANC")
Rossier = c("EDUC")
Roski = c("FA")
Gerontology = c("GERO")
Dworak = c("SOWK")
Dramatic = c("THTR")

usc_courses_with_school <- usc_courses_cleaned %>%
  mutate(school = case_when(
    school %in% Dornsife ~ "Dana and David Dornsife College of Letters, Arts and Sciences",
    school %in% Annenberg ~ "Annenberg School for Communication and Journalism",
    school %in% Viterbi ~ "Andrew and Erna Viterbi School of Engineering",
    school %in% Marshall ~ "Gordon S. Marshall School of Business",
    school %in% Pharmacy ~ "School of Pharmacy",
    school %in% Policy ~ "Sol Price School of Public Policy",
    school %in% Music ~ "Thornton School of Music",
    school %in% RegistrarOffice_GradSchool ~ "Registrar's Office and Graduate School",
    school %in% Ostrow ~ "Ostrow School of Dentistry",
    school %in% Keck ~ "Keck School of Medicine",
    school %in% Law ~ "Gould School of Law",
    school %in% Iovine ~ "Jimmy Iovine and Andre Young Academy",
    school %in% Architecture ~ "School of Architecture",
    school %in% Bovard ~ "Bovard College",
    school %in% Leventhal ~ "Elaine and Kenneth Leventhal School of Accounting",
    school %in% Cinematic ~ "School of Cinematic Arts",
    school %in% Kaufman ~ "Glorya Kaufman School of Dance",
    school %in% Rossier ~ "Barbara J. and Roger W. Rossier School of Education",
    school %in% Roski ~ "Roski School of Art and Design",
    school %in% Gerontology ~ "Leonard Davis School of Gerontology",
    school %in% Dworak ~ "Suzanne Dworak-Peck School of Social Work",
    school %in% Dramatic ~ "School of Dramatic Arts",
    .default = school
  ))
# Registrar's Office and Graduate School's HUC- and LING- to Dornsife
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(school = 
           ifelse(school == "Registrar's Office and Graduate School" & 
                    grepl("HUC|LING", courseID),
                  "Dana and David Dornsife College of Letters, Arts and Sciences", 
                  school))

# one HUC has no school
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(school =
           ifelse(grepl("HUC-", courseID),
                  "Dana and David Dornsife College of Letters, Arts and Sciences",
                  school))

# fix specific classes
# BUAD-280 BUAD-281 to Leventhal
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(school = ifelse(courseID == "BUAD-280" | courseID == "BUAD-281", 
                         "Elaine and Kenneth Leventhal School of Accounting", 
                         school))

# fix some department's school
# ACCT to Leventhal
usc_courses_with_school[grep("ACCT",usc_courses_with_school$courseID),]$department %>% length()
usc_courses_with_school %>% filter(department == "ACCT") %>% nrow()
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(school = ifelse(department == "ACCT", 
                         "Elaine and Kenneth Leventhal School of Accounting", 
                         school))
# ACAD and ISDN to Iovine/Young
usc_courses_with_school[grep("ACAD",usc_courses_with_school$courseID),]$department %>% length()
usc_courses_with_school %>% filter(department == "ACAD") %>% nrow()
usc_courses_with_school[grep("IDSN",usc_courses_with_school$courseID),]$department %>% length()
usc_courses_with_school %>% filter(department == "IDSN") %>% nrow()
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(school = ifelse(department == "ACAD" | department == "IDSN", 
                         "Jimmy Iovine and Andre Young Academy", 
                         school))
# PUBD to Annenberg
usc_courses_with_school[grep("PUBD",usc_courses_with_school$courseID),]$department %>% length()
usc_courses_with_school %>% filter(department == "PUBD") %>% nrow()
usc_courses_with_school <- usc_courses_with_school %>%
  mutate(school = ifelse(department == "PUBD", 
                         "Annenberg School for Communication and Journalism", 
                         school))

# remove Registrar's Office and Graduate School courses
usc_courses_with_school <- usc_courses_with_school %>%
  filter(school != "Registrar's Office and Graduate School")

# usc_courses_with_school_final <- usc_courses_with_school %>%
#   select(school, courseID, course_title, instructor, section, department, semester, course_desc, N.Sections, year, course_level, total_enrolled, all_semesters)

write.csv(usc_courses_with_school,
          "streamlined_data/03_B1_20251.csv",
          row.names = FALSE)
