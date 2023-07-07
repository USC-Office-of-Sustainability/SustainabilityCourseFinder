
# USC Sustainability Course Finder

Peter Wu at Carnegie Mellon wrote the initial code that inspired this
project, and his original R package can be found on
<a href="https://github.com/pwu97/SDGmapR" target="_blank">Github</a>.
At USC, myself (Brian Tinsley) and Dr. Julie Hopper in the Office of
Sustainability have been working to develop this package further and
raise sustainability awareness in higher education by mapping USC course
descriptions to the
<a href="https://sdgs.un.org/goals" target="_blank">United Nations
Sustainability Development Goals</a>.

Check out the <a
href="https://usc-sustainability.shinyapps.io/Sustainability-Course-Finder/"
target="_blank">Sustainability Course Finder</a> to see the the product
of our work! Also find an article about our web app <a
href="https://news.usc.edu/207748/new-usc-sustainability-course-finder/"
target="_blank">here</a>!

## Table of Contents

- [Installation](#installation)
- [Keyword List](#keyword-list)
- [Cleaning Course Data](#cleaning-course-data)
- [Mapping Course Descriptions with
  text2sdg](#mapping-course-descriptions-with-text2sdg)
- [Sustainability Related Courses](#sustainability-related-courses)
- [General Education](#general-education)
- [Creating Shiny App](#creating-shiny-app)
- [Creating a Github Repo](#creating-a-github-repo)
- [Creating a Readme](#creating-a-readme)
- [Updating Data and Shiny App](#updating-data-and-shiny-app)
- [Questions?](#questions)

## Installation

Prerequisites: R and RStudio

If you wish to install this package on your computer, clone this
repository by following <a
href="https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository"
target="_blank">these instructions</a>. Once downloaded, you can open,
view, and edit all files in this repository.

Open RStudio and click on the button in the top right to open the
project file `SustainabilityCourseFinder.Rproj`. This will automatically
set the working directory as the project directory. For more information
about Projects
[here](https://support.posit.co/hc/en-us/articles/200526207-Using-RStudio-Projects#:~:text=Opening%20Projects,Rproj).){target=“\_blank”}.

``` r
# check current directory
getwd()
```

For those who are new to R, we often install and load external packages
at the top of our R scripts like this:

``` r
# install the tidyverse package
install.packages("tidyverse")
# load the package into our library so we can access its functions
library(tidyverse)
```

The <a href="https://github.com/tidyverse/tidyverse"
target="_blank">tidyverse package</a> is an incredibly powerful R
package which helps transform and present data; it has been used
extensively in this project.

## Keyword List

The way in which we map course descriptions to the SDGs is through
keyword lists containing words relevant to each SDG. The table below
lists publicly available SDG keywords that have been published online.

Some of the lists have weights associated with every keyword based on
their relevance to the SDG, while some do not. Also note that some of
these keyword lists do not have keywords for SDG 17. In prior versions
of this project, we attempted to mimic CMU’s method and use various
Python and R packages to assign weights but in our current version we do
not use weights.

| Source                                                                                                              | Dataset                | CSV                                                                                                                    |
|:--------------------------------------------------------------------------------------------------------------------|:-----------------------|:-----------------------------------------------------------------------------------------------------------------------|
| <a href="https://www.president.usc.edu/sustainability-pwg/"                                                         
 target="_blank">USC Keywords (Work in Progress)</a>                                                                  | `usc_keywords`         | <a                                                                                                                     
                                                                                                                                                href="https://github.com/USC-Office-of-Sustainability/SustainabilityCourseFinder/blob/main/shiny_app/usc_keywords.csv"  
                                                                                                                                                target="_blank">Link</a>                                                                                                |
| <a href="https://data.mendeley.com/datasets/87txkw7khs/1"                                                           
 target="_blank">Core Elsevier (Work in Progress)</a>                                                                 | `elsevier_keywords`    | <a                                                                                                                     
                                                                                                                                                href="https://github.com/pwu97/SDGmapR/blob/main/datasets/elsevier_keywords_cleaned.csv"                                
                                                                                                                                                target="_blank">Link</a>                                                                                                |
| <a href="https://data.mendeley.com/datasets/9sxdykm8s4/2"                                                           
 target="_blank">Improved Elsevier Top 100</a>                                                                        | `elsevier100_keywords` | <a                                                                                                                     
                                                                                                                                                href="https://github.com/pwu97/SDGmapR/blob/main/datasets/elsevier100_keywords_cleaned.csv"                             
                                                                                                                                                target="_blank">Link</a>                                                                                                |
| <a href="https://ap-unsdsn.org/regional-initiatives/universities-sdgs/"                                             
 target="_blank">SDSN</a>                                                                                             | `sdsn_keywords`        | <a                                                                                                                     
                                                                                                                                                href="https://github.com/pwu97/SDGmapR/blob/main/datasets/sdsn_keywords_cleaned.csv"                                    
                                                                                                                                                target="_blank">Link</a>                                                                                                |
| <a                                                                                                                  
 href="https://www.cmu.edu/leadership/the-provost/provost-priorities/sustainability-initiative/sdg-definitions.html"  
 target="_blank">CMU Top 250 Words</a>                                                                                | `cmu250_keywords`      | <a                                                                                                                     
                                                                                                                                                href="https://github.com/pwu97/SDGmapR/blob/main/datasets/cmu250_keywords_cleaned.csv"                                  
                                                                                                                                                target="_blank">Link</a>                                                                                                |
| <a                                                                                                                  
 href="https://www.cmu.edu/leadership/the-provost/provost-priorities/sustainability-initiative/sdg-definitions.html"  
 target="_blank">CMU Top 500 Words</a>                                                                                | `cmu500_keywords`      | <a                                                                                                                     
                                                                                                                                                href="https://github.com/pwu97/SDGmapR/blob/main/datasets/cmu500_keywords_cleaned.csv"                                  
                                                                                                                                                target="_blank">Link</a>                                                                                                |
| <a                                                                                                                  
 href="https://www.cmu.edu/leadership/the-provost/provost-priorities/sustainability-initiative/sdg-definitions.html"  
 target="_blank">CMU Top 1000 Words</a>                                                                               | `cmu1000_keywords`     | <a                                                                                                                     
                                                                                                                                                href="https://github.com/pwu97/SDGmapR/blob/main/datasets/cmu1000_keywords_cleaned.csv"                                 
                                                                                                                                                target="_blank">Link</a>                                                                                                |
| <a href="https://www.sdgmapping.auckland.ac.nz/"                                                                    
 target="_blank">University of Auckland (Work in Progress)</a>                                                        | `auckland_keywords`    |                                                                                                                        |
| <a                                                                                                                  
 href="https://data.utoronto.ca/sustainable-development-goals-sdg-report/sdg-report-appendix/"                        
 target="_blank">University of Toronto (Work in Progress)</a>                                                         | `toronto_keywords`     |                                                                                                                        |

The first few rows of the USC keyword table, which has over 4250
keywords, are shown below.

| goal | keyword             | color    |
|-----:|:--------------------|:---------|
|    1 | access to clothing  | \#E5243B |
|    1 | access to housing   | \#E5243B |
|    1 | access to resources | \#E5243B |
|    1 | access to shelter   | \#E5243B |
|    1 | affluence           | \#E5243B |
|    1 | affluent            | \#E5243B |

The USC keyword list has been modified many times with the help of the
Presidential Working Group (PWG) and is continually being improved to
increase accuracy.

In the 02_R directory’s file `01_cleaning_keywords.R`, notice that the
keywords are converted to lowercase, punctuation is removed, and that
duplicates are removed. Removing duplicates is very important for
ensuring some courses do not get mapped twice. Furthermore, the pound
symbol causes problems when using
<a href="https://www.text2sdg.io/" target="_blank">text2sdg</a>’s
`detect_any()` so keywords with `#` are removed.

``` r
library(dplyr)

# cleaning keywords
usc_pwg_keywords <- read.csv("USC_PWG-E_2023Keywords_06_30_23.csv")

# check color
usc_pwg_keywords %>% select(goal, color) %>% distinct()

# # causes errors
usc_pwg_keywords <- usc_pwg_keywords[-grep("#", usc_pwg_keywords$keyword),]
# remove punctuation
usc_pwg_keywords$keyword <- gsub("[^[:alnum:][:space:]]", " ", usc_pwg_keywords$keyword)
# lowercase
usc_pwg_keywords$keyword <- tolower(usc_pwg_keywords$keyword)
# remove duplicates bc otherwise text2sdg will count the word twice
usc_pwg_keywords <- usc_pwg_keywords[!duplicated(usc_pwg_keywords),]

# save
write.csv(usc_pwg_keywords,
          "shiny_app/usc_keywords.csv",
          row.names = FALSE)
```

## Cleaning Course Data

While I do not expect another school’s data to be of the same format as
the raw files at USC, I am still including some details on how we
cleaned the files in hopes that it may address some common problems
others might have with their data.

<!-- add link to a file? -->

Course data was retrieved from the USC’s Office of Academic Records and
Registrar, and the raw data files, as well as the R scripts to clean
them, can be found in the `01_cleaning_raw_data/00_raw_usc_data` folder
<a
href="https://github.com/USC-Office-of-Sustainability/SustainabilityCourseFinder/tree/main/01_cleaning_raw_data/00_raw_usc_data"
target="_blank">here</a>. The raw data files had lots of problems with
spacing and column names, and we addressed these issues in
`01_cleaning_scattered_files.R`.

<!-- show the dataframe -->
<!-- show the code to clean it -->

In the `clean_file` function, we loop from the bottom of the raw
dataframe and combine empty rows with the row above to fix the empty
line issue. We also trim spaces before and after to account for random
spaces added at the end of some data entries. One problem to look out
for when cleaning a dataframe is accounting for empty values (““) vs NA
vs”NA” in data entries.

Note that this function (and script) contain various other adjustments
to the data which you can find in the file.

``` r
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
    }
}
```

Once the files are cleaned, we run a function (in the same R script) to
clean each individual file and write it as CSV into a new folder, as
well as obtain the “origin” column which is the year and term of the
data. Once again, I do not expect anyone’s data to be in the same
format, but this might help someone clean scattered CSV files.

``` r
# make sure folder only contains CSVs you want to run the code on
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
```

Once all the files have been cleaned and put into a new folder, we can
combine them all into one dataframe with the following code:

``` r
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

write.csv(master_df, "combined_data.csv", row.names=FALSE)
```

In the next R file, `02_cleaning_2020-2023.R`, we read in the combined
clean CSV and reformat it. In this file, we change column names, count
the number of students and sections for each section, cut out courses
listed purely for enrollment credit, and we create the “semester,”
“all_semesters,” and “course_level” columns. To see this code please see
the R script. In this script, some of the cleaning is done in one
function, `clean_data`, and some cleaning processes are done with helper
functions like `get_semester` and `get_course_level`.

One important piece of this file is excluding certain courses. For
example, courses with titles containing “Directed Research” and
Individual Instruction”, courses with exact titles “Advanced Research
Experience” and Board Development”, courses with descriptions containing
“Directed undergraduate research” and “Directed graduate research”, and
courses with course IDs ending in 490, 790, and 594 are all removed. You
can add additional rules to the clean_data function:

``` r
titles_containing = c("Directed Research",
                        "Individual Instruction")
titles_matching = c("Advanced Research Experience",
                      "Board Development")
descriptions_containing = c("Directed undergraduate research",
                              "Directed graduate research")
data_clean <- raw_data %>%
    filter(!grepl(paste(titles_containing, collapse = "|"), COURSE_TITLE) & 
             !COURSE_TITLE %in% titles_matching &
             !grepl(paste(descriptions_containing, collapse = "|"), COURSE_DESCRIPTION) &
             !grepl("-[47]90|-594", COURSE_CODE))
```

Note that when you make an update to data like such, you must go and
rerun the next R scripts with the new data to update all of the data
frames for the shiny app. Once we create the cleaned `usc_courses.csv`,
we duplicate it and move it up one directory so that we can run more
code on it.

In the above directory, `01_cleaning_raw_data`, there is an R script
that shows you how to add a course to the dataframe
`01_adding_course.R`. It is important that you include ALL COLUMNS when
adding new entries – otherwise the data will get messy.

## Cleaning Course Descriptions

Once we have the cleaned dataframe with correct column names, we now
clean the course descriptions in
`01_cleaning_raw_data/03_cleaning_course_descriptions.R` to increase the
accuracy of the mapping we will perform to the keyword list.

This file corrects context-dependency issues that lead to inaccurate
mappings of courses to SDGs. For example, courses with the phrases
“business environment” or “learning environment” should not be mapped to
the word “environment” and its related SDGs.

First some typos in the course descriptions are corrected using
`stri_replace_all_regex` from the
<a href="https://stringi.gagolewski.com/" target="_blank">stringi
package</a>.

Next we want to create a new column “clean_course_desc” which holds the
course description of the course without punctuation except apostrophes
and corrected context dependencies.

``` r
usc_courses$clean_course_desc <- 
  apply_context_dependency(remove_punctuation(usc_courses$course_desc))
```

The `remove_punctuation` function simply replaces all punctuation in the
text with a space using gsub. Learn more about regular expressions in R
by typing `?base::regex` into the console.

``` r
remove_punctuation <- function(tt) {
  gsub("[^[:alnum:][:space:]']", " ", tt)
}
```

The `apply_context_dependency` function uses `stri_replace_all_regex` to
replace advertising ecosystem with advertising domain in all course
descriptions. There is a file called `context_dependencies.csv` which
lists all the replacements to be made as two columns: before and after.
You can use regex capture groups for more generic matches. Warning: the
more context dependencies in the csv file, the slower this function will
run.

Once we have the output from this cleaning, `usc_courses_cleaned.csv`,
we duplicate it and move it to the `data` directory where we will be
working from now on. Now, all of our R scripts will be from the `02_R`
directory and our data will be in this data directory.

## Mapping Course Descriptions with text2sdg

Our previous strategy to map course descriptions took over 6 hours to
run. We now use
<a href="https://www.text2sdg.io/" target="_blank">text2sdg</a>’s
`detect_any` function to map course descriptions in less than 5 minutes.

Now, we are ready to map the clean course descriptions void of
punctuation errors and major context dependencies to our keyword list
and the 17 SDGs. In the `02_R` directory, find the code to map course
descriptions in `02_using_text2sdg.R`.  
First we need to create a system to use the USC keywords. The system
needs to have 3 columns: system name, SDG, and query.

``` r
# create system for text2sdg
usc_pwg_system <- usc_pwg_keywords %>%
  mutate(system = "usc_pwg",
         query = paste0('"', keyword, '"')) %>%
  rename(sdg = goal) %>%
  select(system, sdg, query)
```

Make sure the keywords and the text (course description) have no
punctuation and are lowercase, so that detect_any can find the keywords
in the text.

Next we run detect_any using our keyword system. This function will only
count a keyword once. The output from this function is a dataframe with
columns: document, sdg, system, query_id, features, hit. The important
columns are document, sdg, and features. The document number corresponds
to the row number of usc_courses dataframe. SDG got changed into
‘SDG-01’ not 1. Features that are made up of multiple words get split by
commas in this column, so I glued them back together. If a course gets
mapped to multiple SDGs it will show up multiple rows in the dataframe.

``` r
# duplicate keywords will only count as 1
hits <- detect_any(usc_courses$text, usc_pwg_system, output = "features")
# remove commas in features
hits$cleanfeatures <- gsub(",", "", hits$features)
# get sdg number
hits$sdg_num <- sapply(hits$sdg, function(x) {
  as.numeric(strsplit(x, "-")[[1]][2])
})
```

Then we want the color for the corresponding sdg (and keyword) by
merging the dataframe with the original keywords.

``` r
hits_color <- merge(hits, usc_pwg_keywords, 
                    by.x = c("cleanfeatures", "sdg_num"), 
                    by.y = c("keyword", "goal")) %>%
  select(document, sdg_num, cleanfeatures, color)
```

Next, we want to combine the dataframe with our original course info
dataframe. In addition we want two columns that summarize a course’s
keywords and goals.

``` r
master_course_sdg_data <- merge(hits_color, usc_courses, by.x = "document", by.y = "rowID", all.y = TRUE) %>%
  rename(keyword = cleanfeatures, goal = sdg_num) %>%
  select(document, school, courseID, course_title, instructor, section, semester, keyword, goal, color, course_desc, text, department, N.Sections, year, course_level, total_enrolled, all_semesters) %>%
  arrange(courseID) %>%
  group_by(document) %>%
  mutate(all_keywords = paste(unique(keyword), collapse = ","),
         all_goals = paste(sort(unique(goal)), collapse = ","))
```

## Sustainability Related Courses

After mapping, we analyze the goals a course is mapped to and labels it
as `SDG-Related`, `Sustainability-Focused`, or `Not Related`.

We have tried multiple methods to determine sustainability
classifications, and our current method is as follows:

- If a course description does not map to any SDGs, it is “Not
  Related”.  
- If a course description maps to at least 1 SDG, we categorize it as
  “SDG-Related”.  
- If a course maps to one or more social/economic SDG (1-5, 8-11,
  16, 17) AND one or more environmental SDG (6, 7, 12, 13, 14, 15), then
  it is labeled “Sustainability Focused”.

Code for achieving these labels are found in the R script
`02_using_text2sdg.R`.

Lastly, we also want a count of the number of occurrences of each
keyword in the course description using `str_count`.

## General Education

We were given completely a different set of data for USC’s general
education requirements. Code for obtaining the GE categories and course
titles is found in `03_general_education.R`. In this script, we join the
GE data with the course and sustainability data and then go through and
ensure that unmapped courses have “Not Related” as the sustainability
classification. The resulting dataframe is used in the Shiny App for the
general education page.

## Creating Shiny App

When I was tasked with creating a shiny app, I was daunted but
eventually learned through trial and error. Despite the scary sight of
1400 lines of code, I can assure that anyone using this github
repository can replicate the shiny app with little to no coding
experience. To learn the basics, refer to
<a href="https://rstudio.github.io/shinydashboard/" target="_blank">this
tutorial</a>.

If you follow along with the code in the `app.R` file in the “shiny_app”
directory, you will understand the structure and functionality of a
shiny app.

One important lesson I learned when making various plots for the
dashboard is that it is often helpful to create a new R script to
generate a dataframe that is easier to work with for the purposes of
that plot / function. In the `02_R` directory, the file
`sustainability_related_classes.R` containts code to generate
`classes_by_sdgs.csv` which is used for one of the barcharts in the
dashboard. I also found it incredibly helpful to write code to generate
plots in another file so you can quickly go through trial and error
instead of opening the dashboard every time. Lastly, **Google and
stackOverflow are your friends**… Plenty of people out there are
struggling with the same things you struggle with in R and Rshiny.

## Creating a Github Repo

To make a github repository, follow <a
href="https://docs.github.com/en/get-started/quickstart/create-a-repo"
target="_blank">this tutorial</a> and consider downloading the
<a href="https://desktop.github.com/" target="_blank">GitHub Desktop
App</a>. You can also make commits and pushes using the Git button on
the top bar of RStudio.

## Creating a Readme

To create a Readme, familiarize yourself with
<a href="https://www.markdownguide.org/getting-started"
target="_blank">Markdown</a> and
<a href="https://rmarkdown.rstudio.com/articles_intro.html"
target="_blank">R Markdown</a>. In `.Rmd` (R Markdown) files, you can
specify the `output` of the document to be a `github_document` and when
you “knit” the `.Rmd` file, it will automatically generate a `.md`
(markdown) file in the directory which will be displayed on your github
page! You can also refer to my README.Rmd file to see how I created this
readme file.

## Updating Data and Shiny App

When the keywords or course data is updated, the way I have been
updating the shiny app is by rerunning all of the files in order with
the new data. When doing so, remove the old files from the `Data` folder
and the `shiny_app` folder, but I recommend storing them in a backup
folder elsewhere in the case that the new run of code doesn’t work.

Which files you will have to rerun is determined by what data you are
updating. If the raw course data is updated, you will need to start from
the beginning (at
`01_cleaning_raw_data/00_raw_usc_data/01_cleaning_scattered_files.R`)
and clean and combine all of the school data again. Similarly, if you
are adding / fixing keyword mapping issues with context dependencies,
you will need to clean the course data again (starting at
`01_cleaning_raw_data/03_cleaning_course_descriptions.R`). If you are
only updating the keywords list, then you only need to rerun code
starting at the mapping of course descriptions (starting at
`02_R/01_cleaning_keywords.R`).

## Questions?

There have been many packages in R that have confused me, and I am very
grateful for some developers that responded to my emails and helped me
along the way.

If you have any questions, comments, or concerns, please reach out to me
via email: <btinsley@usc.edu>
