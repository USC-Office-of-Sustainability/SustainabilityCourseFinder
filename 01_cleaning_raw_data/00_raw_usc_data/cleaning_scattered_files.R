# going to try running Dr. Hopper's code for the old data on the new data for 
# 2020-2023, the files have weird bugs we need to fix

library(tidyverse)
library(gdata)

# function to clean a file
clean_file = function(table) {
  x = table
  # get rid of weird spacing issue with empty section column "      " -> ""
  x$SECTION = as.numeric(trimws(x$SECTION, which=c("both")))
  
  # go through backwords and combine error rows with row above it
  for(i in seq(nrow(x), 2, -1)) { # Work on the table in bottom to top so we can merge the values
    if(is.na(x[i, "SECTION"]) | x[i, "SECTION"] == "NA" | x[i, "SECTION"] == "") { #always note if values are NA or "NA" or ""
        x[i, "SECTION"] = NA # fix the issue of combining character "NA" 
        print(i)
        # Work on the current row and the previous row.
        # Don't modify numeric columns (don't want to merge NA values).
        # Use lead() to check across rows, and turn NA values into an empty string.
        # Use paste() to combine the row values.
        # use trim() to get rid of any excess white space produced.
        x[i-1,] <- (x[c(i-1,i),] %>% mutate(across(.fns = ~ ifelse(is.numeric(.x), .x, trim(paste(.x, ifelse(is.na(lead(.x)), "", lead(.x))))))))[1, ]
        # x[i-1,] <- gsub("  ", "", x[i-1,]) # remove anything more than 1 space
      }
  }
  # remove the empty rows
  x <- x[!is.na(x$SECTION),]
  # create department column
  x$DEPARTMENT = NA
  # remove the periods at end of column names
  for (i in 1:length(names(x))){
    # newname = sub("[.]$", "", names(x)[i]) # removes a dot at the end
    newname = gsub("[.]", "", names(x)[i]) # removes all dots
    names(x)[i] = newname
  }
  
  for (i in 1:nrow(x)){
    # going to get rid of whitespace
    x[i, ] = gsub("  ", "", x[i,])
    
    # going to fix the classes that start with - like "-CHE 490.00"
    if (startsWith(x$COURSE_CODE[i],"-")){
      print(i)
      # get rid of the .00 first
      if (grepl(".", x$COURSE_CODE[i])){
        print(i)
        x$COURSE_CODE[i] = gsub("\\..*", "", x$COURSE_CODE[i])
      }
      # replace the starting - with a nothing
      x$COURSE_CODE[i] = gsub("-", "", x$COURSE_CODE[i])
      # replace the space with a dash, doesnt work with normal gsub
      y = substr(x$COURSE_CODE[i], 4, 4) # super strange.... y is not a space or a tab its an unidentifiable alien coming for us all
      x$COURSE_CODE[i] = gsub(y, "-", x$COURSE_CODE[i])
    }
    
    # get the department
    split = strsplit(x[i, "COURSE_CODE"], split="-")
    term = split[[1]][1]
    x[i, "DEPARTMENT"] = term
    
  }
  # alphabetize the COURSE_CODE
  x = x[order(x$COURSE_CODE),]
  # remove hanging whitespace in course code
  x$COURSE_CODE = trimws(x$COURSE_CODE, which = c("right"))
  return (x)
}


# grab file names in the "old_data" folder 
# make sure they are all CSVs you want to run the code on
files = list.files("SOC_files/")

# going to apply the function to each file and write a new csv in "clean_data" folder
# this loop will also get the "origin" column from the file name
# other users may have different file names and have to figure out how to get the origin
# column in the form "YYYYS" where s is 1, 2, 3 for spring, summer, fall
for (i in 1:length(files)){
  table = read.csv(paste0("SOC_files/", files[i]), header=TRUE) # load file
  out <- clean_file(table) # clean the file
  out$origin = NA #create origin column
  file_name = files[i] #grab the name of the file that starts with YYYYS
  term = substr(file_name, 1, 5) # grab just the first 5 digits to be used in the origin
  out$origin = term
  name = paste0("clean_data/", term, ".csv") # will change this to actually be the year output format
  write.csv(out, file = name, row.names = FALSE)
}



### now lets combine them all ###

dataframes = list.files("clean_data")
master_df = data.frame()
for (i in 1:length(dataframes)){
  table = read.csv(paste0("clean_data/", dataframes[i]), header=TRUE) # load file
  # master_df = rbind(master_df, table)
  # number of columns is different in dataframes so use this function and fill empty with NA
  master_df = data.table::rbindlist(list(master_df, table), fill=TRUE) 
}

# just noticed theres a space at the end of the course_code, lets fix
master_df$COURSE_CODE = trimws(master_df$COURSE_CODE, which = c("right"))

# now write it out
write.csv(master_df, "combined_data.csv", row.names=FALSE)






# crosschecking the data we used to use with the new data we just made

# old = read.csv("All_SOC_files_2020-2022_fixed copy.csv")
# new = read.csv("20202-20231_data.csv")


# checking 2020 summer
# oldsummer20 = old[old$origin == "20202_SUMMER", ]
# newsummer20 = new[new$origin == 20202, ]
# dim(oldsummer20)
# dim(newsummer20)
# newsummer20$COURSE_CODE == oldsummer20$COURSE_CODE # could save this in a vector
# courses = unique(oldsummer20[!oldsummer20$COURSE_CODE %in% newsummer20$COURSE_CODE, "COURSE_CODE"])
# other = unique(newsummer20[!newsummer20$COURSE_CODE %in% oldsummer20$COURSE_CODE, "COURSE_CODE"])
# other
# courses
# length(courses)
# write.csv(courses, "missing_20202.csv", row.names = FALSE)
# 
# 
# 
# # 2020 fall
# oldfall20 = old[old$origin == "20203_FALL", ]
# newfall20 = new[new$origin == 20203, ]
# dim(oldfall20)
# dim(newfall20)
# oldfall20$COURSE_CODE == newfall20$COURSE_CODE # could save this in a vector
# courses = unique(oldfall20[!oldfall20$COURSE_CODE %in% newfall20$COURSE_CODE, "COURSE_CODE"])
# other = unique(newfall20[!newfall20$COURSE_CODE %in% oldfall20$COURSE_CODE, "COURSE_CODE"])
# other
# length(courses)
# courses
# write.csv(courses, "missing_20203.csv", row.names = FALSE)
# 
# 
# # 2021 spring
# oldspring21 = old[old$origin == "20211_SPRING", ]
# newspring21 = new[new$origin == 20211, ]
# dim(oldspring21)
# dim(newspring21)
# oldspring21$COURSE_CODE == newspring21$COURSE_CODE # could save this in a vector
# courses = unique(oldspring21[!oldspring21$COURSE_CODE %in% newspring21$COURSE_CODE, "COURSE_CODE"])
# other = unique(newspring21[!newspring21$COURSE_CODE %in% oldspring21$COURSE_CODE, "COURSE_CODE"])
# other
# length(courses)
# courses
# write.csv(courses, "missing_20211.csv", row.names = FALSE)
# 
# 
# # 2021 summer
# oldsummer21 = old[old$origin == "20212_SUMMER", ]
# newsummer21 = new[new$origin == 20212, ]
# dim(oldsummer21)
# dim(newsummer21)
# newsummer21$COURSE_CODE == oldsummer21$COURSE_CODE # could save this in a vector
# courses = unique(oldsummer21[!oldsummer21$COURSE_CODE %in% newsummer21$COURSE_CODE, "COURSE_CODE"])
# other = unique(newsummer21[!newsummer21$COURSE_CODE %in% oldsummer21$COURSE_CODE, "COURSE_CODE"])
# other
# length(courses)
# courses
# # write.csv(courses, "missing_20212.csv", row.names = FALSE)
# 
# 
# # 2021 fall
# oldfall21 = old[old$origin == "20213_FALL", ]
# newfall21 = new[new$origin == 20213, ]
# dim(oldfall21)
# dim(newfall21)
# oldfall21$COURSE_CODE == newfall21$COURSE_CODE # could save this in a vector
# courses = unique(oldfall21[!oldfall21$COURSE_CODE %in% newfall21$COURSE_CODE, "COURSE_CODE"])
# other = unique(newfall21[!newfall21$COURSE_CODE %in% oldfall21$COURSE_CODE, "COURSE_CODE"])
# other
# length(courses)
# courses
# write.csv(courses, "missing_20213.csv", row.names = FALSE)
# 
# 
# # 2022 spring
# oldspring22 = old[old$origin == "20221_SPRING", ]
# newspring22 = new[new$origin == 20221, ]
# dim(oldspring22)
# dim(newspring22)
# oldspring22$COURSE_CODE == newspring22$COURSE_CODE # could save this in a vector
# courses = unique(oldspring22[!oldspring22$COURSE_CODE %in% newspring22$COURSE_CODE, "COURSE_CODE"])
# other = unique(newspring22[!newspring22$COURSE_CODE %in% oldspring22$COURSE_CODE, "COURSE_CODE"])
# other
# length(courses)
# courses
# write.csv(courses, "missing_20221.csv", row.names = FALSE)
# 
# 
# 
# # 2022 summer
# oldsummer22 = old[old$origin == "20222_SUMMER", ]
# newsummer22 = new[new$origin == 20222, ]
# dim(oldsummer22)
# dim(newsummer22)
# newsummer22$COURSE_CODE == oldsummer22$COURSE_CODE # could save this in a vector
# courses = unique(oldsummer22[!oldsummer22$COURSE_CODE %in% newsummer22$COURSE_CODE, "COURSE_CODE"])
# other = unique(newsummer22[!newsummer22$COURSE_CODE %in% oldsummer22$COURSE_CODE, "COURSE_CODE"])
# other
# write.csv(courses, "missing_from_old_20222.csv", row.names = FALSE)
# length(courses)
# courses
# # write.csv(courses, "missing_20222.csv", row.names = FALSE)
# 
# 
# # 2022 fall
# oldfall22 = old[old$origin == "20223_FALL", ]
# newfall22 = new[new$origin == 20223, ]
# dim(oldfall22)
# dim(newfall22)
# oldfall22$COURSE_CODE == newfall22$COURSE_CODE # could save this in a vector
# courses = unique(oldfall22[!oldfall22$COURSE_CODE %in% newfall22$COURSE_CODE, "COURSE_CODE"])
# other = unique(newfall22[!newfall22$COURSE_CODE %in% oldfall22$COURSE_CODE, "COURSE_CODE"])
# other
# write.csv(courses, "missing_from_old_20223.csv", row.names = FALSE)
# length(courses)
# courses
# write.csv(courses, "missing_20223.csv", row.names = FALSE)


