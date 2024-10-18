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
ff <- list.files("streamlined_data/cleaned_SOC_files/", 
                 pattern = "csv", full.names = TRUE)
# read data
tmp <- lapply(ff, read.csv, colClasses = "character")

# combine
combined_data <- data.table::rbindlist(tmp, fill = TRUE)

write.csv(combined_data,
          "streamlined_data/01_20251.csv",
          row.names = FALSE)