source("data_processing_scripts/config.R")
# combine SOC files
# library(readxl)
library(tidyr)
# library(chron)
library(dplyr)
library(stringr)


## ............................................................................
## combine cleaned files
## ............................................................................
# list of cleaned csv files
# 20242 needs section name!!
ff <- list.files(S_00_parse_SOC_OUTPUT_FILE_PATH, 
                 pattern = "csv", full.names = TRUE)
# read data
tmp <- lapply(ff, read.csv, colClasses = "character")

# combine
combined_data <- data.table::rbindlist(tmp, fill = TRUE)

# filter out the columns with COURSE_CODE == "BISC-369"
combined_data <- combined_data %>%
  filter(COURSE_CODE != "BISC-369") %>%
  filter(!(origin %in% c("20251", "20243") == FALSE & TOTAL_ENR == 0))



write.csv(combined_data,
          S_01_combine_SOC_OUTPUT_FILE_PATH,
          row.names = FALSE)