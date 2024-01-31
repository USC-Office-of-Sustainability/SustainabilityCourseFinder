USC Sustainability Course Finder
================

- [Introduction](#introduction)
- [Installation](#installation)
- [Keyword List](#keyword-list)
- [Cleaning Course Data](#cleaning-course-data)
- [Cleaning Course Descriptions](#cleaning-course-descriptions)
- [Mapping Course Descriptions with
  text2sdg](#mapping-course-descriptions-with-text2sdg)
- [Sustainability Related Courses](#sustainability-related-courses)
- [General Education](#general-education)
- [Creating Shiny App](#creating-shiny-app)
- [Creating a Github Repo](#creating-a-github-repo)
- [Creating a Readme](#creating-a-readme)
- [Updating Data and Shiny App](#updating-data-and-shiny-app)
- [Questions?](#questions)

<!-- # USC Sustainability Course Finder -->

## Introduction

Peter Wu at Carnegie Mellon wrote the initial code that inspired this
project, and his original R package can be found on
<a href="https://github.com/pwu97/SDGmapR" target="_blank">Github</a>.
At USC, Brian Tinsley, Alison Chen and Dr. Julie Hopper in the Office of
Sustainability switched to using the new
<a href="https://www.text2sdg.io/" target="_blank">text2sdg</a> package
to raise sustainability awareness in higher education by mapping USC
course descriptions to the
<a href="https://sdgs.un.org/goals" target="_blank">United Nations
Sustainability Development Goals</a>.

Check out the <a
href="https://usc-sustainability.shinyapps.io/Sustainability-Course-Finder/"
target="_blank">Sustainability Course Finder</a> to see the the product
of our work! Also find an article about our web app <a
href="https://news.usc.edu/207748/new-usc-sustainability-course-finder/"
target="_blank">here</a>!

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
about Projects <a
href="https://support.posit.co/hc/en-us/articles/200526207-Using-RStudio-Projects#:~:text=Opening%20Projects,Rproj"
target="_blank">here</a>.

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
these keyword lists do not have keywords for SDG 17.

| Source                                                                                                                                                        | Dataset                | CSV                                                                                                                                                |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| USC Keywords (Work in Progress)                                                                                                                               | `usc_keywords`         | <a href="https://github.com/USC-Office-of-Sustainability/SustainabilityCourseFinder/blob/main/shiny_app/usc_keywords.csv" target="_blank">Link</a> |
| <a href="https://data.mendeley.com/datasets/87txkw7khs/1" target="_blank">Core Elsevier (Work in Progress)</a>                                                | `elsevier_keywords`    | <a href="https://github.com/pwu97/SDGmapR/blob/main/datasets/elsevier_keywords_cleaned.csv" target="_blank">Link</a>                               |
| <a href="https://data.mendeley.com/datasets/9sxdykm8s4/2" target="_blank">Improved Elsevier Top 100</a>                                                       | `elsevier100_keywords` | <a href="https://github.com/pwu97/SDGmapR/blob/main/datasets/elsevier100_keywords_cleaned.csv" target="_blank">Link</a>                            |
| <a href="https://ap-unsdsn.org/regional-initiatives/universities-sdgs/" target="_blank">SDSN</a>                                                              | `sdsn_keywords`        | <a href="https://github.com/pwu97/SDGmapR/blob/main/datasets/sdsn_keywords_cleaned.csv" target="_blank">Link</a>                                   |
| <a href="https://www.cmu.edu/leadership/the-provost/provost-priorities/sustainability-initiative/sdg-definitions.html" target="_blank">CMU Top 250 Words</a>  | `cmu250_keywords`      | <a href="https://github.com/pwu97/SDGmapR/blob/main/datasets/cmu250_keywords_cleaned.csv" target="_blank">Link</a>                                 |
| <a href="https://www.sdgmapping.auckland.ac.nz/" target="_blank">University of Auckland (Work in Progress)</a>                                                | `auckland_keywords`    |                                                                                                                                                    |
| <a href="https://data.utoronto.ca/sustainable-development-goals-sdg-report/sdg-report-appendix/" target="_blank">University of Toronto (Work in Progress)</a> | `toronto_keywords`     |                                                                                                                                                    |

Additional keywords can be accessed via
<a href="https://www.text2sdg.io/reference/detect_sdg_systems.html"
target="_blank">text2sdg</a>.

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

The USC keyword list has been modified many times from feedback provided
by students, staff and faculty, including those in the USC Presidential
Working Group (PWG) Education Committee. This list is continually being
improved to increase accuracy.

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
usc_pwg_keywords <- read.csv("USC_PWG-E_Keywords_1_24_24.csv")

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

While we do not expect another school’s data to be of the same format as
the raw files at USC, we are still including some details on how we
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
`01_combine_SOC.R`.

The main problem was that one course’s description was sometimes spread
over two cells instead of one row per course. This occurred in multiple
columns. For instance, the data looked like this:

| SECTION | SCHOOL | COURSE_CODE | SESSION | MIN_UNITS | MAX_UNITS | COURSE_TITLE | MODE | Link | PUBLISH | START_TIME          | END_TIME            | DAYS | TOTAL_ENR1 | MODALITY | INSTRUCTOR_NAME      | ASSIGNED_ROOM | TOTAL_ENR2 | COURSE_DESCRIPTION                                              |
|:--------|:-------|:------------|:--------|:----------|:----------|:-------------|:-----|:-----|:--------|:--------------------|:--------------------|:-----|:-----------|:---------|:---------------------|:--------------|:-----------|:----------------------------------------------------------------|
| 34170   | ACAD   | IDSN-585    | 68      | 3         | 3         | Capstone     | C    | NA   | Y       | 0.72916666666666663 | 0.79513888888888884 | T    | 13         | NA       | Clewis, Jay          | ONLINE        | 13         | Faculty-mentored, applied project with individual and team      |
| NA      | NA     | NA          | NA      | NA        | NA        | NA           | NA   | NA   | NA      | NA                  | NA                  | NA   | NA         | NA       | NA                   | NA            | NA         | components. Implement a prototype solution to a problem. Deploy |
| NA      | NA     | NA          | NA      | NA        | NA        | NA           | NA   | NA   | NA      | NA                  | NA                  | NA   | NA         | NA       | NA                   | NA            | NA         | relevant tools, methods and processes learned throughout the    |
| NA      | NA     | NA          | NA      | NA        | NA        | NA           | NA   | NA   | NA      | NA                  | NA                  | NA   | NA         | NA       | NA                   | NA            | NA         | program. Recommended preparation: all other required courses    |
| NA      | NA     | NA          | NA      | NA        | NA        | NA           | NA   | NA   | NA      | NA                  | NA                  | NA   | NA         | NA       | NA                   | NA            | NA         | (excluding concurrent courses).                                 |
| NA      | NA     | NA          | NA      | NA        | NA        | NA           | NA   | NA   | NA      | NA                  | NA                  | NA   | NA         | NA       | Arnoult, Jean-Michel | NA            | NA         | NA                                                              |

An example of raw data for course IDSN-585 spread over multiple rows.

The key to combining multiple rows as one row was tidyr’s fill function
shown below.

``` r
# fill empty columns based on above column
df2 <- df %>%
  tidyr::fill(SECTION, COURSE_CODE, .direction = "down")
```

By filling in the SECTION and COURSE_CODE columns with the previous row,
the dataframe looks like this:

| SECTION | SCHOOL | COURSE_CODE | SESSION | MIN_UNITS | MAX_UNITS | COURSE_TITLE | MODE | Link | PUBLISH | START_TIME          | END_TIME            | DAYS | TOTAL_ENR1 | MODALITY | INSTRUCTOR_NAME      | ASSIGNED_ROOM | TOTAL_ENR2 | COURSE_DESCRIPTION                                              |
|:--------|:-------|:------------|:--------|:----------|:----------|:-------------|:-----|:-----|:--------|:--------------------|:--------------------|:-----|:-----------|:---------|:---------------------|:--------------|:-----------|:----------------------------------------------------------------|
| 34170   | ACAD   | IDSN-585    | 68      | 3         | 3         | Capstone     | C    | NA   | Y       | 0.72916666666666663 | 0.79513888888888884 | T    | 13         | NA       | Clewis, Jay          | ONLINE        | 13         | Faculty-mentored, applied project with individual and team      |
| 34170   | NA     | IDSN-585    | NA      | NA        | NA        | NA           | NA   | NA   | NA      | NA                  | NA                  | NA   | NA         | NA       | NA                   | NA            | NA         | components. Implement a prototype solution to a problem. Deploy |
| 34170   | NA     | IDSN-585    | NA      | NA        | NA        | NA           | NA   | NA   | NA      | NA                  | NA                  | NA   | NA         | NA       | NA                   | NA            | NA         | relevant tools, methods and processes learned throughout the    |
| 34170   | NA     | IDSN-585    | NA      | NA        | NA        | NA           | NA   | NA   | NA      | NA                  | NA                  | NA   | NA         | NA       | NA                   | NA            | NA         | program. Recommended preparation: all other required courses    |
| 34170   | NA     | IDSN-585    | NA      | NA        | NA        | NA           | NA   | NA   | NA      | NA                  | NA                  | NA   | NA         | NA       | NA                   | NA            | NA         | (excluding concurrent courses).                                 |
| 34170   | NA     | IDSN-585    | NA      | NA        | NA        | NA           | NA   | NA   | NA      | NA                  | NA                  | NA   | NA         | NA       | Arnoult, Jean-Michel | NA            | NA         | NA                                                              |

SECTION and COURSE_CODE columns are filled in based on the first row.

Now, we simply group by SECTION and COURSE_CODE and combine all the text
in each column to end up with one row for one course:

| SECTION | COURSE_CODE | SCHOOL | SESSION | MIN_UNITS | MAX_UNITS | COURSE_TITLE | MODE | Link | PUBLISH | START_TIME          | END_TIME            | DAYS | TOTAL_ENR | MODALITY | INSTRUCTOR_NAME                  | ASSIGNED_ROOM | TOTAL_ENR1 | COURSE_DESCRIPTION                                                                                                                                                                                                                                                                   |
|:--------|:------------|:-------|:--------|:----------|:----------|:-------------|:-----|:-----|:--------|:--------------------|:--------------------|:-----|:----------|:---------|:---------------------------------|:--------------|:-----------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 34170   | IDSN-585    | ACAD   | 68      | 3         | 3         | Capstone     | C    | NA   | Y       | 0.72916666666666663 | 0.79513888888888884 | T    | 13        | NA       | Clewis, Jay;Arnoult, Jean-Michel | ONLINE        | 13         | Faculty-mentored, applied project with individual and team components. Implement a prototype solution to a problem. Deploy relevant tools, methods and processes learned throughout the program. Recommended preparation: all other required courses (excluding concurrent courses). |

Final row for course IDSN-585.

The process is the same for both CSV and Excel files. The only
difference is that CSV files have an extra DEPTOWNERNAME column. While
cleaning the SOC files, we also added an “origin” column which indicates
which year and term the data is from.

Once all the files have been cleaned and saved in a new folder
clean_data, we can combine them all into one dataframe with the
following code:

``` r
ff <- list.files("01_cleaning_raw_data/00_raw_usc_data/clean_data", 
                 pattern = "csv", full.names = TRUE)
# read data
tmp <- lapply(ff, read.csv)

# combine
combined_data <- data.table::rbindlist(tmp, fill = TRUE)

write.csv(combined_data,
          "combined_data.csv",
          row.names = FALSE)
```

In the next R file, `02_formatting.R`, we read in the combined clean CSV
and reformat it. In this file, we change column names, count the number
of students and sections for each section, cut out courses listed purely
for enrollment credit, and we create the “semester,” “all_semesters,”
and “course_level” columns. To see this code please see the R script <a
href="https://github.com/USC-Office-of-Sustainability/SustainabilityCourseFinder/tree/main/01_cleaning_raw_data/00_raw_usc_data/02_formatting.R"
target="_blank">here</a>. In this script, some of the cleaning is done
in one function, `clean_data`, and some cleaning processes are done with
helper functions like `get_semester` and `get_course_level`.

One important piece of this file is excluding certain courses. For
example, courses with titles containing “Directed Research” and
Individual Instruction”, courses with exact titles “Advanced Research
Experience” and Board Development”, courses with descriptions containing
“Directed undergraduate research” and “Directed graduate research”, and
courses with course IDs ending in 490, 790, and 594 are all removed. You
can add additional rules to the clean_data function:

``` r
# a snippet of code from 02_cleaning_2020-2023.R
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

After mapping, we analyze the goals that a course maps to and classify
it as `Sustainability-Focused`,`Sustainability-Inclusive`,
`SDG-Related`, or `Not Related`.

Our current method for classifying courses is as follows:

- Sustainability-Focused: a course (title/description) maps to one or
  more social/economic SDG (1-5, 8-11, 16, 17) AND one or more
  environmental SDG (6, 7, 12, 13, 14, 15)

- Sustainability-Inclusive: a course (title/description) maps to at
  least 2 keywords across 2 SDGs (within either a social/economic OR an
  environmental category)

- SDG-Related: a course (title/description) maps to at 1 keyword for at
  least 1 SDG

- Not-Related: a course (title/description) does not map to any SDG
  keywords

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

We can assure that anyone using this github repository can replicate the
shiny app with little to no coding experience. To learn the basics,
refer to
<a href="https://rstudio.github.io/shinydashboard/" target="_blank">this
tutorial</a>.

If you follow along with the code in the `app.R` file in the “shiny_app”
directory, you will understand the structure and functionality of a
shiny app.

One important tip for making various plots in the dashboard is that it
is often helpful to create a new R script to generate a dataframe that
is easier to work with for the purposes of that plot / function. In the
`02_R` directory, the file `sustainability_related_classes.R` containts
code to generate `classes_by_sdgs.csv` which is used for one of the
barcharts in the dashboard. We found it incredibly helpful to write code
to generate plots in another file so you can quickly go through trial
and error instead of opening the dashboard every time. Lastly, **Google,
ChatGPT and stackOverflow are your coding friends**… Plenty of people
out there are struggling with the same things you struggle with in R and
Rshiny.

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
page! You can find more information
[here](https://rmarkdown.rstudio.com/github_document_format.html). You
can also refer to the README.Rmd file to see how Brian Tinsley created
this original readme file.

## Updating Data and Shiny App

When the keywords or course data are updated, the way we have been
updating the shiny app is by rerunning all of the files in order with
the new data. When doing so, we remove the old files from the `Data`
folder and the `shiny_app` folder, but we recommend storing them in a
backup folder elsewhere in the case that the new run of code doesn’t
work.

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

We are very grateful to the developers that responded to our emails and
helped us along the way. If you have any questions, comments, or
concerns, please reach out to Brian Tinsley: <btinsley@usc.edu> or Julie
Hopper <juliehop@usc.edu>
