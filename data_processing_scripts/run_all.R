# Master Script to Run All Data Processing Scripts in Sequence

# Define the folder containing the scripts
script_folder <- "data_processing_scripts/"

# List of scripts to run in the desired sequence
scripts <- c(
  "00_parse_SOC.R",
  "01_combine_SOC.R",
  "02_formatting.R",
  "03_fix_school.R",
  "04_update_course.R",
  "05_cleaning_course_descriptions.R",
  "06_cleaning_keywords.R",
  "07_using_text2sdg.R",
  "08_general_education.R",
  "09_generate_total_semesters.R"
)

# Function to source each script
run_scripts <- function(folder, script_list) {
  for (script in script_list) {
    script_path <- file.path(folder, script)
    message("Running: ", script_path)

    # Check if the file exists before running
    if (file.exists(script_path)) {
      tryCatch(
        {
          source(script_path, echo = TRUE)
        },
        error = function(e) {
          message("Error in ", script, ": ", e$message)
        }
      )
    } else {
      message("Script not found: ", script_path)
    }
  }
}

# Run all scripts in sequence
run_scripts(script_folder, scripts)
