source("data_processing_scripts/config.R")
# parse SOC files
# library(readxl)
library(tidyr)
# library(chron)
library(dplyr)
library(stringr)

## ............................................................................
## clean SOC plain text files
## ............................................................................
# list of plain text files
ff <- list.files(S_00_parse_SOC_INPUT_FILE_PATH, 
                 full.names = TRUE)
# check column names -> no deptownername column
lapply(ff, function(x) {
  readLines(x, n = 1)
})
readOneFile <- function(filename) {
  # get header
  header <- readLines(filename, n = 1)
  # split by 4 spaces
  headerNames <- strsplit(header, "    ")[[1]]
  
  widths <- sapply(headerNames, function(x) {
    nchar(x)+4 # 4 spaces
  })
  
  # clean ......
  headerNames <- gsub("\\.", "", headerNames)
  
  d <- read.fwf(filename, widths = widths, skip = 1, 
                col.names = headerNames, strip.white = TRUE,
                colClasses = "character")
  # replace "" with NA
  d <- d %>% mutate(across(everything(), ~na_if(.,"")))
  # remove rows that are all NA
  df <- d[rowSums(!is.na(d)) != 0, ]
  # remove last row
  if (grepl("listed", df$SCHOOL[nrow(df)])) {
    df <- head(df, - 1)
  }
  
  # fill empty columns based on above column
  df2 <- df %>%
    tidyr::fill(SECTION, COURSE_CODE, .direction = "down")
  
  # uppercase to make them consistent
  names(df2) <- toupper(names(df2))
  
  df3 <- df2 %>%
    group_by(SECTION, COURSE_CODE) %>%
    summarize(SCHOOL = paste(SCHOOL[!is.na(SCHOOL)], collapse = " "),
              SESSION = first(SESSION),
              MIN_UNITS = first(MIN_UNITS),
              MAX_UNITS = first(MAX_UNITS),
              COURSE_TITLE = paste(COURSE_TITLE[!is.na(COURSE_TITLE)], collapse = " "),
              MODE = first(MODE),
              LINK = first(LINK),
              PUBLISH = first(PUBLISH.),
              START_TIME = paste(START_TIME[!is.na(START_TIME)], collapse = " "),
              END_TIME = paste(END_TIME[!is.na(END_TIME)], collapse = " "),
              DAYS = paste(DAYS[!is.na(DAYS)], collapse = " "),
              TOTAL_ENR = first(TOTAL_ENR),
              MODALITY = first(MODALITY),
              INSTRUCTOR_NAME = paste(INSTRUCTOR_NAME[!is.na(INSTRUCTOR_NAME)], collapse = ";"),
              ASSIGNED_ROOM = paste(ASSIGNED_ROOM[!is.na(ASSIGNED_ROOM)], collapse = " "),
              # Only summarize TOTAL_ENR1 if it exists
              TOTAL_ENR1 = if ("TOTAL_ENR.1" %in% colnames(df2)) first(TOTAL_ENR.1) else NA,
              COURSE_DESCRIPTION = paste(COURSE_DESCRIPTION[!is.na(COURSE_DESCRIPTION)], collapse = " "),
              SECTION_NAME = paste(SECTION.NAME[!is.na(SECTION.NAME)], collapse = " "))

  # department is first part of course code
  # CHE in CHE-490
  df3$DEPARTMENT <- sapply(df3$COURSE_CODE, function(x) {
    strsplit(x, "-")[[1]][1]
  })
  # origin comes from filename
  # 20193 in 20193_SOC.txt
  df3$origin <- strsplit(basename(filename), "_")[[1]][1]
  # replace NA with ""
  # apply(df3, 2, anyNA) # which columns have NA
  df3$MODALITY <- df3$MODALITY %>% replace_na("")
  df3$LINK <- df3$LINK %>% replace_na("")
  # cleaned file location + name
  cleanfile <- paste0(S_00_parse_SOC_OUTPUT_FILE_PATH, strsplit(basename(filename), "_")[[1]][1], ".csv")
  write.csv(df3, cleanfile, row.names = FALSE)
  return(cleanfile)
}

# clean all plain txt files
lapply(ff, readOneFile)

## ............................................................................
## clean SOC excel files
## ............................................................................
# list of xlsx files
ff <- list.files(S_00_parse_SOC_INPUT_FILE_PATH,
                 pattern = "xlsx", full.names = TRUE)
# check column names -> no deptownername column
lapply(ff, function(x) {names(read_excel(x))})
# clean 1 excel file
readOneFileExcel <- function(filename) {
  d <- read_excel(filename, col_types = "text")
  # remove . in colname
  names(d) <- gsub("\\.", "", names(d))
  # rename total_enr
  total_enr_i <- grep("TOTAL_ENR", names(d))
  for (i in 1:length(total_enr_i)) {
    names(d)[total_enr_i][i] <- paste0("TOTAL_ENR", i)
  }

  # replace "" with NA
  d <- d %>% mutate(across(everything(), ~na_if(.,"")))
  # remove rows that are all NA
  df <- d[rowSums(!is.na(d)) != 0, ]
  # remove last row
  if (grepl("listed", df$SCHOOL[nrow(df)])) {
    df <- head(df, - 1)
  }

  # convert time
  df$START_TIME <- times(as.numeric(df$START_TIME))
  df$END_TIME <- times(as.numeric(df$END_TIME))
  # split link publish column
  if ("Link    PUBLISH?" %in% names(df)) {
    df$PUBLISH <- substr(df$`Link    PUBLISH?`, nchar(df$`Link    PUBLISH?`), nchar(df$`Link    PUBLISH?`))
    df$Link <- sapply(df$`Link    PUBLISH?`, function(x) {
      c <- trimws(strsplit(x, " ")[[1]])
      if (length(c) > 1) {
        return(c[1])
      } else {
        return("")
      }
    })
  } else {
    # some publish column are PUBLISH?
    names(df)[grep("PUBLISH", names(df))] <- "PUBLISH"
  }

  # fill empty columns based on above column
  df2 <- df %>%
    tidyr::fill(SECTION, COURSE_CODE, .direction = "down")

  # check number of values in each column
  # df4 <- df2 %>%
  #   group_by(SECTION, COURSE_CODE) %>%
  #   summarize(SCHOOL = paste(SCHOOL[!is.na(SCHOOL)], collapse = " "),
  #             SESSION = length(unique(SESSION[!is.na(SESSION)])),
  #             MIN_UNITS = length(unique(MIN_UNITS[!is.na(MIN_UNITS)])),
  #             MAX_UNITS = length(unique(MAX_UNITS[!is.na(MAX_UNITS)])),
  #             MODE = length(unique(MODE[!is.na(MODE)])),
  #             Link = length(unique(Link[!is.na(Link)])),
  #             PUBLISH = length(unique(PUBLISH[!is.na(PUBLISH)])),
  #             START_TIME = length(unique(START_TIME[!is.na(START_TIME)])),
  #             END_TIME = length(unique(END_TIME[!is.na(END_TIME)])),
  #             DAYS = length(unique(DAYS[!is.na(DAYS)])),
  #             TOTAL_ENR = length(unique(TOTAL_ENR1[!is.na(TOTAL_ENR1)])),
  #             MODALITY = length(unique(MODALITY[!is.na(MODALITY)])),
  #             ASSIGNED_ROOM = length(unique(ASSIGNED_ROOM[!is.na(ASSIGNED_ROOM)])),
  #             TOTAL_ENR1 = length(unique(TOTAL_ENR2[!is.na(TOTAL_ENR2)])))
  # apply(df4,2,unique)

  # keep all info in assigned room, days, start + end time columns
  df2$Section.Name <- df2$`Section Name`
  df3 <- df2 %>%
    group_by(SECTION, COURSE_CODE) %>%
    summarize(SCHOOL = paste(SCHOOL[!is.na(SCHOOL)], collapse = " "),
              SESSION = first(SESSION),
              MIN_UNITS = first(MIN_UNITS),
              MAX_UNITS = first(MAX_UNITS),
              COURSE_TITLE = paste(COURSE_TITLE[!is.na(COURSE_TITLE)], collapse = " "),
              MODE = first(MODE),
              Link = first(Link),
              PUBLISH = first(PUBLISH),
              START_TIME = paste(START_TIME[!is.na(START_TIME)], collapse = " "),
              END_TIME = paste(END_TIME[!is.na(END_TIME)], collapse = " "),
              DAYS = paste(DAYS[!is.na(DAYS)], collapse = " "),
              TOTAL_ENR = first(TOTAL_ENR1),
              MODALITY = first(MODALITY),
              INSTRUCTOR_NAME = paste(INSTRUCTOR_NAME[!is.na(INSTRUCTOR_NAME)], collapse = ";"),
              ASSIGNED_ROOM = paste(ASSIGNED_ROOM[!is.na(ASSIGNED_ROOM)], collapse = " "),
              TOTAL_ENR1 = first(TOTAL_ENR2),
              COURSE_DESCRIPTION = paste(COURSE_DESCRIPTION[!is.na(COURSE_DESCRIPTION)], collapse = " "),
              SECTION_NAME = paste(Section.Name[!is.na(Section.Name)], collapse = " "))
  # department is first part of course code
  # CHE in CHE-490
  df3$DEPARTMENT <- sapply(df3$COURSE_CODE, function(x) {
    strsplit(x, "-")[[1]][1]
  })
  # origin comes from filename
  # 20193 in 20193_SOC.xlsx
  df3$origin <- strsplit(basename(filename), "_")[[1]][1]
  # replace NA with ""
  # apply(df3, 2, anyNA) # which columns have NA
  df3$MODALITY <- df3$MODALITY %>% replace_na("")
  df3$Link <- df3$Link %>% replace_na("")
  # cleaned file location + name
  cleanfile <- paste0(S_00_parse_SOC_OUTPUT_FILE_PATH, strsplit(basename(filename), "_")[[1]][1], ".csv")
  write.csv(df3, cleanfile, row.names = FALSE)
  return(cleanfile)
}
# clean all excel files
lapply(ff, readOneFileExcel)

## ............................................................................
## clean SOC csv files
## ............................................................................
# list of csv files
ff <- list.files(S_00_parse_SOC_INPUT_FILE_PATH,
                 pattern = "csv", full.names = TRUE)
# check column names
lapply(ff, function(x) {names(read.csv(x))})
# clean 1 csv file
readOneFileCSV <- function(filename) {
  d <- read.csv(filename)
  # remove . in colname
  names(d) <- gsub("\\.", "", names(d))
  # remove weird symbols
  d$COURSE_DESCRIPTION <- gsub("\\?\xc7\xd6", "'", d$COURSE_DESCRIPTION, useBytes = TRUE)
  d$COURSE_DESCRIPTION <- gsub("\\?\xc7\xf4", "-", d$COURSE_DESCRIPTION, useBytes = TRUE)
  # remove whitespace
  d <- d %>%
    mutate_if(is.character, str_trim)
  # replace "" with NA
  d <- d %>% mutate(across(everything() & where(is.character), ~na_if(.,"")))
  # remove rows that are all NA
  df <- d[rowSums(!is.na(d)) != 0, ]
  # remove last row
  if (grepl("listed", df$SCHOOL[nrow(df)])) {
    df <- head(df, - 1)
  }

  # fix some COURSE_CODE (-CHE 490.00)
  for (i in which(startsWith(df$COURSE_CODE, "-"))) {
    cc <- df$COURSE_CODE[i]
    letters <- str_extract(cc, "([A-Z]+)")
    number <- str_extract(cc, "(\\d+)")
    df$COURSE_CODE[i] <- paste(letters, number, sep = "-")
  }

  # fill empty columns based on above column
  df2 <- df %>%
    tidyr::fill(SECTION, COURSE_CODE, .direction = "down")

  # check number of values in each column
  # df4 <- df2 %>%
  #   group_by(SECTION, COURSE_CODE) %>%
  #   summarize(SCHOOL = paste(SCHOOL[!is.na(SCHOOL)], collapse = " "),
  #             SESSION = length(unique(SESSION[!is.na(SESSION)])),
  #             MIN_UNITS = length(unique(MIN_UNITS[!is.na(MIN_UNITS)])),
  #             MAX_UNITS = length(unique(MAX_UNITS[!is.na(MAX_UNITS)])),
  #             MODE = length(unique(MODE[!is.na(MODE)])),
  #             Link = length(unique(Link[!is.na(Link)])),
  #             PUBLISH = length(unique(PUBLISH[!is.na(PUBLISH)])),
  #             START_TIME = length(unique(START_TIME[!is.na(START_TIME)])),
  #             END_TIME = length(unique(END_TIME[!is.na(END_TIME)])),
  #             DAYS = length(unique(DAYS[!is.na(DAYS)])),
  #             TOTAL_ENR = length(unique(TOTAL_ENR[!is.na(TOTAL_ENR)])),
  #             MODALITY = length(unique(MODALITY[!is.na(MODALITY)])),
  #             ASSIGNED_ROOM = length(unique(ASSIGNED_ROOM[!is.na(ASSIGNED_ROOM)])),
  #             TOTAL_ENR1 = length(unique(TOTAL_ENR1[!is.na(TOTAL_ENR1)])),
  #             DEPTOWNERNAME = length(unique(DEPTOWNERNAME[!is.na(DEPTOWNERNAME)])))
  # apply(df4,2,unique)

  # keep all info in assigned room, days, start + end time columns
  if ("DEPTOWNERNAME" %in% names(df2)) {
    df3 <- df2 %>%
      group_by(SECTION, COURSE_CODE) %>%
      summarize(SCHOOL = paste(SCHOOL[!is.na(SCHOOL)], collapse = " "),
                SESSION = first(SESSION),
                MIN_UNITS = first(MIN_UNITS),
                MAX_UNITS = first(MAX_UNITS),
                COURSE_TITLE = paste(COURSE_TITLE[!is.na(COURSE_TITLE)], collapse = " "),
                MODE = first(MODE),
                Link = first(Link),
                PUBLISH = first(PUBLISH),
                START_TIME = paste(START_TIME[!is.na(START_TIME)], collapse = " "),
                END_TIME = paste(END_TIME[!is.na(END_TIME)], collapse = " "),
                DAYS = paste(DAYS[!is.na(DAYS)], collapse = " "),
                TOTAL_ENR = first(TOTAL_ENR),
                MODALITY = first(MODALITY),
                INSTRUCTOR_NAME = paste(INSTRUCTOR_NAME[!is.na(INSTRUCTOR_NAME)], collapse = ";"),
                ASSIGNED_ROOM = paste(ASSIGNED_ROOM[!is.na(ASSIGNED_ROOM)], collapse = " "),
                TOTAL_ENR1 = first(TOTAL_ENR1),
                COURSE_DESCRIPTION = paste(COURSE_DESCRIPTION[!is.na(COURSE_DESCRIPTION)], collapse = " "),
                DEPTOWNERNAME = first(DEPTOWNERNAME))
  } else {
    df3 <- df2 %>%
      group_by(SECTION, COURSE_CODE) %>%
      summarize(SCHOOL = paste(SCHOOL[!is.na(SCHOOL)], collapse = " "),
                SESSION = first(SESSION),
                MIN_UNITS = first(MIN_UNITS),
                MAX_UNITS = first(MAX_UNITS),
                COURSE_TITLE = paste(COURSE_TITLE[!is.na(COURSE_TITLE)], collapse = " "),
                MODE = first(MODE),
                Link = first(Link),
                PUBLISH = first(PUBLISH),
                START_TIME = paste(START_TIME[!is.na(START_TIME)], collapse = " "),
                END_TIME = paste(END_TIME[!is.na(END_TIME)], collapse = " "),
                DAYS = paste(DAYS[!is.na(DAYS)], collapse = " "),
                TOTAL_ENR = first(TOTAL_ENR),
                MODALITY = first(MODALITY),
                INSTRUCTOR_NAME = paste(INSTRUCTOR_NAME[!is.na(INSTRUCTOR_NAME)], collapse = ";"),
                ASSIGNED_ROOM = paste(ASSIGNED_ROOM[!is.na(ASSIGNED_ROOM)], collapse = " "),
                TOTAL_ENR1 = first(TOTAL_ENR1),
                COURSE_DESCRIPTION = paste(COURSE_DESCRIPTION[!is.na(COURSE_DESCRIPTION)], collapse = " "))
  }

  # department is first part of course code
  # CHE in CHE-490
  df3$DEPARTMENT <- sapply(df3$COURSE_CODE, function(x) {
    strsplit(x, "-")[[1]][1]
  })
  # origin comes from filename
  # 20193 in 20193_SOC.csv
  df3$origin <- strsplit(basename(filename), "_")[[1]][1]
  # replace NA with ""
  # apply(df3, 2, anyNA) # which columns have NA
  df3$MODALITY <- df3$MODALITY %>% replace_na("")
  df3$Link <- df3$Link %>% replace_na("")
  # cleaned file location + name
  cleanfile <- paste0(S_00_parse_SOC_OUTPUT_FILE_PATH, strsplit(basename(filename), "_")[[1]][1], ".csv")
  write.csv(df3, cleanfile, row.names = FALSE)
  return(cleanfile)
}
# clean all csv files
lapply(ff, readOneFileCSV)
