# USC SHINY WEB APP
# BRIAN TINSLEY -- btinsley@usc.edu
# EXTENSION FROM PETER WU AT CMU

# require(devtools)
# install_github("lchiffon/wordcloud2")
# library(wordcloud2)

# Run App with the Run App button at the top of the screen

library(tidyverse)
library(shiny)
library(shinydashboard)
# install.packages("plotly")
library(plotly)
# install.packages("wordcloud")
library(wordcloud)
# install.packages("DT")
library(DT)
# install.packages("ggplot2")
library(ggplot2)
# install.packages("ggrepel")
library(ggrepel)
# install.packages("shinyWidgets")
library(shinyWidgets)

classes = read.csv("master_course_sdg_data.csv")
classes$sustainability_classification <- factor(classes$sustainability_classification, levels = c("Sustainability-Focused", "SDG-Related", "Not Related"))

keywords = read.csv("usc_keywords.csv")

sdg_colors <- c('#e5243b', '#DDA63A', '#4C9F38', '#C5192D', '#FF3A21', '#26BDE2', 
                '#FCC30B', '#A21942', '#FD6925', '#DD1367', '#FD9D24', '#BF8B2E',
                '#3F7E44', '#0A97D9', '#56C02B', '#00689D', '#19486A')

goals <- c("1 - No poverty", "2 - Zero hunger", "3 - Good health and well-being", "4 - Quality education", "5 - Gender equality",
           "6 - Clean water and sanitation", "7 - Affordable and clean energy", "8 - Decent work and economic growth", "9 - Industry, innovation, and infrastructure", 
           "10 - Reduced inequalities", "11 - Sustainable cities and communities", "12 - Responsible consumption and production", "13 - Climate action",
           "14 - Life below water", "15 - Life on land", "16 - Peace, justice, and strong institutions", "17 - Partnership for the goals")
# sdg choices with None option
sdg_choices <- c(1:17, NA)
names(sdg_choices) <- c(goals, "None")
num_top_classes <- 10

# data for pie chart
sustainability_related = read.csv("usc_courses_full.csv")

# data for GE's
ge_data = read.csv("ge_data.csv")

# data for find classes by sdgs
recent_courses = read.csv("recent_courses.csv")

# for the ordering of GE's in dropdown
values = c("A", "B", "C",
           "D", "E", "F", "G", "H", "Category I", "Category II", "Category III", "Category IV", "Category V", "Category VI")
names = c("The Arts", "Humanistic Inquiry", "Social Analysis", "Life Sciences", "Physical Sciences",
          "Quantitative Reasoning", "Citizenship in a Diverse World", "Traditions and Historical Foundations", "Western Cultures and Traditions", "Global Cultures and Traditions", "Scientific Inquiry", "Science and Its Significance ",
          "Arts and Letters", "Social Issues")
key = data.frame(value = values, name = names)
key$full_name = paste(key$value, key$name, sep=" - ")
ge_names = key$full_name

feedback_form_link <- "https://forms.gle/keZXBY9uHa9DWsMg6"

# profvis({
# s = shinyApp(
### Begin Shiny App Code ###

# Define UI for application that draws a histogram
ui <- dashboardPage( skin="black",
                     
                     # Application title
                     dashboardHeader(title = "USC Sustainability Course Finder", titleWidth = 350),
                     
                     
                     dashboardSidebar(
                       width = 350,
                       sidebarMenu(
                         menuItem("About", tabName = "1"),
                         menuItem("FAQ", tabName = "2"),
                         menuItem("Map Your Courses", tabName = "3"),
                         menuItem("Find SDGs by Courses", tabName = "4"),
                         menuItem("Find Courses by SDGs", tabName = "5"),
                         menuItem("Search by GE Requirements", tabName = "6"),
                         menuItem("All Sustainability-Related Courses", tabName = "7"),
                         menuItem("Download Data", tabName = "downloaddata")
                       )
                     ),
                     
                     dashboardBody( 
                       tags$head(
                         tags$link(rel="stylesheet", type="text/css", href="custom.css"), # link css stylesheet
                         tags$link(rel="stylesheet", # link icon library
                           href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css")),
                                    tabItems(
                                      tabItem(tabName = "1",
                                              fluidPage(
                                                h1("About"),
                                                h3("Welcome to the USC Sustainability Course Finder\u2014a collaborative project from the 
                                                staff, faculty, and students of the University of Southern California and Carnegie 
                                                Mellon University. This tool allows users to identify USC courses which relate to the 
                                                17 United Nations Sustainable Development Goals (SDGs). With this information, students 
                                                can focus their studies in particular sustainability goals, and faculty can identify 
                                                ways to incorporate sustainability into their classes."),
                                                h3("This dashboard is a work in progress and will be improved through feedback and 
                                                   collaboration with faculty (", 
                                                   a("access the feedback form here", 
                                                     href = feedback_form_link, 
                                                     target="_blank", .noWS = "outside"),
                                                   "). To learn more about this tool visit the FAQ page."),
                                                fluidRow(id = "asgmtearth",
                                                  column(6,
                                                         fluidRow(a(img(src="Education.png", width = "100%"), 
                                                                    href="https://sustainability.usc.edu/assignment-earth/", target="_blank"))
                                                  ),
                                                  column(6,
                                                         h3(strong("Assignment: Earth"), "is USC’s Sustainability Framework for a greener campus and planet. It articulates our 
                                                         commitment to addressing the impacts of climate change and creating a more just, equitable, and 
                                                         sustainable future. It’s a big assignment. ", strong("We’re all in!"))
                                                         )
                                                  
                                                ),
                                                
                                                # br(),
                                                # br(),
                                                
                                                h1("Mapping the 17 SDGs"),
                                                h3("The SDGs were adopted by all United Nations Member States in 2015, providing a shared blueprint for peace and prosperity 
                                                   for people and the planet, now and into the future. The SDGs are an urgent call for action by all countries - developed and 
                                                   developing - in a global partnership. They recognize that ending poverty and other deprivations must go hand-in-hand with 
                                                   strategies that improve health and education, reduce inequality, and spur economic growth – all while tackling climate 
                                                   change and working to preserve our oceans and forests."), 
                                                   h3("Below displays a wordcloud for the keywords for each SDG. The keywords 
                                                   were edited by USC’s Office of Sustainability staff and interns as well as the USC Presidential Working Group. These keywords 
                                                   evolved from lists suggested by Elsevier and Carnegie Mellon University."),
                                
                                                # h3("Below displays a wordcloud for the top keywords for each SDG.
                                                #   The keywords come from the ", a("CMU250 keywords list,", href="https://github.com/CMUSustainability/SDGmapR/tree/main/data", target="_blank"), 
                                                #    "and the weights of the words relative to each SDG 
                                                #       were calculated using ",a("Google's word2vec.", href="https://code.google.com/archive/p/word2vec/", target="_blank"), "These word and weight 
                                                #        combinations are the criteria for the course mappings in the other pages of this website."),
                                                # h3("In the near future, this list will be updated to a USC and CMU combined list with the input of
                                                #              the PWG. To see the words in a CSV file format, please see the ",a("USC-SDGmap package.", href="https://github.com/USC-Office-of-Sustainability/USC-SDG-Curriculum", target="_blank")),
                                                h2("Select an SDG below to see its most relevant keywords."),
                                                uiOutput("disclaimer1"),
                                                selectizeInput(inputId = "sdg_goal3", 
                                                               label = "Choose SDG", 
                                                               choices = goals
                                                               ),
                                                fluidRow(bootstrapPage(
                                                  column(6, plotOutput(outputId = "visualize_sdg"),br()),
                                                  column(6, img(src = "un_17sdgs.png", width = "100%"))
                                                )),
                                                h2(strong("SDG Keywords Table")),
                                                fluidRow(bootstrapPage(
                                                  column(6, DT::dataTableOutput("keywords_table"))
                                                ))
                                              ) #end fluid page
                                      ), # end tabitem 1
                                      
                                      
                                      tabItem(tabName = "2",
                                              fluidPage(
                                                h2(strong("FAQ")),
                                                h3(strong("How do I use this dashboard?"), "You can choose your search function in 
                                 the main menu in the upper-left corner of this dashboard. 
                                 Here you can either find courses by the 17 different SDGs 
                                 (Find Courses by SDGs) or see which SDGs map to a selected course 
                                 (Find SDGs by Courses). To see how many courses at USC are sustainability-focused 
                                 or SDG-related, please click on the bottom menu option 
                                 ‘All Sustainability-Related Courses”."),
                                                
                                                h3(strong("How was this dashboard created?"), "This dashboard was created with R Shiny, based on source code in R through a 
                                              collaboration of USC’s Office of Sustainability (Source Code Developers: PSIP Intern- Brian Tinsley and Data Analyst- Dr. 
                                              Julie Hopper) with Carnegie Mellon University (Source Code Developers: Director of Sustainability Initiatives - Alex Hinicker 
                                              and Undergraduate Alumni - Peter Wu). Following the initial development of this dashboard, USC staff in the Office of 
                                              Sustainability and faculty in the Presidential Working Group (PWG) on Sustainability in Education reviewed the dashboard and 
                                              keywords. All of the datasets and source code used in this dashboard are open-source and can be found through", a("our
                                              Github page.", href="https://github.com/USC-Office-of-Sustainability/USC-SDGmap", target="_blank")),
                                                h3(strong("What are the UN’s 17 Sustainability Development Goals (SDGs)?"),
                                                   "The 2030 Agenda for Sustainable Development was adopted in 2015 by all UN member 
                                    states and provides a ‘blueprint for peace and prosperity for people and the planet, 
                                    now and into the future’. At the center of this are the 17 Sustainable Development
                                    Goals (SDGs). These goals acknowledge that ending poverty and other deprivations must
                                    accompany strategies that reduce inequality,  improve education and health, and 
                                    spur economic growth – all while working to preserve our natural ecosystems and 
                                    tackling climate change. To explore the 17 SDGs, 
                                    please visit ", a("their website.", href= "https://sdgs.un.org/goals#icons", target="_blank")),
                                                
                                                h3(strong("Which USC courses are included in this dashboard?"), "All USC courses except for \"Directed Research,\"
                                                   Master's Thesis,\" and \"Doctoral Dissertation\" courses. Although some courses do not map to the SDGs, they are still included
                                                   in data analysis. "),
                                                
                                                h3(strong("How often is this dashboard updated?"), "Data is updated at least once a semester after registration 
                                                is complete for the following semester, and more frequently upon feedback."),
                                                
                                                h3(strong("How are USC's courses mapped to the 17 SDGs?"), "Please visit our 
                                                   “Home” page to learn more."),
                                                
                                                h3(strong("I’m a faculty member, how can I use or provide feedback on this dashboard?"),
                                                   "It is our hope that this dashboard will be a useful tool for faculty who are looking 
                                                   for ways to incorporate sustainability into their courses by identifying potential 
                                                   connections between course topics and the UN SDGs. The dashboard is a work in progress 
                                                   and faculty feedback is critical in refining its accuracy and utility. If you have 
                                                   feedback or suggestions, please fill out", 
                                                   a("this form", href = feedback_form_link, target="_blank"), 
                                                   "or email us at oosdata@usc.edu."),
                                                
                                                h3(strong("I’d like to integrate sustainability into my courses. Where can I get help 
                                                          with this?"),
                                                   "If you’re interested in integrating sustainability into an existing course, contact 
                                                   the Office of Sustainability’s Experiential Learning Manager, Dr. Chelsea Graham at 
                                                   cmgraham@usc.edu."),
                                                
                                                h3(strong("What if I have more Questions/Comments or Suggestions?"), "Please fill out our ", a("feedback form.", 
                                                          href=feedback_form_link, target="_blank"))
                                              ) #end fluidpage
                                      ), #end tabitem 2
                                      
                                      
                                      tabItem(tabName = "3",
                                              fluidPage(
                                                h1("Map Your Courses"),
                                                h3("Select your courses below and see how your curriculum relates to the 17 SDGs. Some courses
                                                   do not map to the SDGs via our keywords so those courses' mapping will be blank."), 
                                                uiOutput("disclaimer2"),
                                                # h3("Enter Your USC Courses"),
                                                h4("Type in the course ID using the same format as this example: “ENST-150”"),
                                                selectizeInput(
                                                  inputId = "user_classes",
                                                  label = "Enter Your USC Courses by Course ID",
                                                  choices = "",
                                                  # choices = unique(sustainability_related$courseID), #changed this from master data
                                                  selected = NULL,
                                                  multiple = TRUE,
                                                  # width = "100%",
                                                  options = list(
                                                    'plugins' = list('remove_button'), # add remove button to each item
                                                    'create' = TRUE,
                                                    'persist' = TRUE # keep created choices
                                                  )
                                                ),
                                                h3("SDG Mapping Data for:"),
                                                h4(textOutput("personal_classes")),
                                                br(),
                                                fluidRow(
                                                  column(6, plotOutput(outputId = "users_wordcloud"), br(),
                                                         plotOutput(outputId = "user_to_goals"), br()),
                                                  column(6, plotOutput(outputId = "user_classes_barplot"), img(src = "un_17sdgs.png", width="100%"), br())
                                                ),
                                                h2(strong("Your Courses")),
                                                fluidRow(bootstrapPage(
                                                  column(12, DT::dataTableOutput("user_table"))
                                                ))
                                              )#end fluid page
                                      ),# end tabitem 3
                                      
                                      
                                      tabItem(tabName = "4",
                                              # tabPanel("All", fluidPage(
                                              fluidPage(
                                                h1("Find SDGs by Courses"),
                                                h4(""),
                                                h3("Select a USC course ID below to view the SDG mapping for 
                          that particular course. If you cannot find a course you are looking for, then it did not map to any of the SDGs via our keyword list.
                                                   To check out the USC course catalogue, click ", a("here.", href="https://catalogue.usc.edu/", target="_blank")),
                                                uiOutput("disclaimer3"),
                                                h4("Type in the course ID using the same format as this example: “ENST-150”"),
                                                selectizeInput(inputId = "usc_classes", 
                                                               label = "Choose USC Course by Course ID", 
                                                               choices = "",
                                                               # width = "100%",
                                                               # choices = unique(classes$courseID),
                                                               options = list(maxOptions = 10000)),
                                                h3(textOutput("semesters_offered")),
                                                
                                                h5("*special topics courses (course levels 499 and 599) often change, but the course data comes from the
                                                   current semester for all courses."),
                                                
                                                br(),
                                                h3(strong("Course Title and Description:")),
                                                h3(textOutput("course_desc")),
                                                fluidRow(bootstrapPage(
                                                  column(6, plotOutput(outputId = "classes_to_wordcloud"), br()),
                                                  column(6, plotOutput(outputId = "classes_to_keywords"), br())
                                                  # column(6, plotOutput(outputId = "test_run"), br())
                                                )),
                                                fluidRow(bootstrapPage(
                                                  column(6, plotOutput(outputId = "classes_to_goals"), br()),
                                                  column(6, img(src = "un_17sdgs.png", width = "100%"))
                                                )),
                                                h2(strong("Keyword Table")),
                                                fluidRow(bootstrapPage(
                                                  column(6, DT::dataTableOutput("classes_table"))
                                                ))
                                                ) # end fluidpage
                                      ),#end tabitem 4
                                      
                                      
                                      tabItem(tabName = "5",
                                              fluidPage(
                                                h1("Find Courses by SDGs"),
                                                h3("Select USC departments and course levels, and then choose an SDG to display the 10 most relevant USC courses that map to
                                                  that goal. To check out the USC course catalogue, click ", a("here.", href="https://catalogue.usc.edu/", target="_blank")),
                                                uiOutput("disclaimer4"),
                                                # div(style="font-size:24px;", selectInput(inputId = "usc_semester3",
                                                #                                          label = "Choose USC Semester",
                                                #                                          selected = "SP23",
                                                #                                          choices = unique(classes$semester))),
                                                # tags$style("course_level_input {background-color:grey; color:red;}"),
                                                pickerInput(inputId = "department_input", 
                                                            label = "Choose Departments", 
                                                            choices = unique(recent_courses$department) %>% sort(),
                                                            # choices = NULL,
                                                            selected = unique(recent_courses$department) %>% sort(),
                                                            options = list(maxOptions = 10000, `actions-box` = TRUE), multiple = T),
                                                pickerInput(inputId = "course_level_input",
                                                            label = "Restrict course level?",
                                                            choices = c("All", "Undergrad lower division", "Undergrad upper division", "Graduate"),
                                                            options = list(height = 20)),
                                                                                        # choicesOpt = list(
                                                                                        # style = rep(("font-size:24px; line-height: 1.5;"),2)))),
                                                selectizeInput(inputId = "sdg_goal1", 
                                                               label = "Choose SDG", 
                                                               choices = goals
                                                               ),
                                                br(),
                                                h2(strong(textOutput("top_classes"))),
                                                fluidRow(bootstrapPage(
                                                  column(6, plotOutput(outputId = "goals_to_classes"), br()),
                                                  column(6, img(src = "un_17sdgs.png", width = "100%"))
                                                )),
                                                h2(strong(textOutput("sdg_name"))),
                                                fluidRow(bootstrapPage(
                                                  column(12, DT::dataTableOutput("top_classes_sdg_table"))
                                                ))
                                              ) #end fluidpage
                                      ), #end tabitem5
                                      
                                      tabItem(tabName="6",
                                              fluidPage(
                                                h1("Search by GE Requirements"),
                                                
                                                # h3("All students at USC are required to fulfill their general education (GE) requirements."),
                                                h3("Select a GE category below to see the sustainability related courses which satisfy that requirement. GE courses that
                                                   did not map to the SDGs via our keywords are not shown, but you can find them in the course catalogue ", a("here.", href="https://dornsife.usc.edu/2015ge/2015ge-requirements/")),
                                                
                                                uiOutput("disclaimer5"),
                                                selectInput(inputId = "ge_category",
                                                            label = "Choose GE Category",
                                                            selected = "A - The Arts",
                                                            choices = ge_names),
                                                pickerInput(inputId = "ge_sdgs", 
                                                            label = "Choose SDGs", 
                                                            choices = seq(17),
                                                            selected = seq(17),
                                                            options = list(maxOptions = 10000, `actions-box` = TRUE), multiple = T),
                                                
                                                br(), br(),
                                                h3(strong(textOutput("top_ge_chart"))),
                                                fluidRow(bootstrapPage(
                                                  column(6, plotOutput(outputId = "ge_bar"), br()),
                                                  column(6, img(src = "un_17sdgs.png", width = "100%")))),
                                                h1(strong(textOutput("ge_name"))),
                                                fluidRow(bootstrapPage(
                                                  column(12, DT::dataTableOutput("ge_table"))
                                                ))
                                              ) #end fluid page
                                      ), #end tabitem 6
                                      
                                      
                                      tabItem(tabName = "7",
                                              fluidPage(
                                                h1("All Sustainability-Related Courses"),
                                                h3("The below charts show the percent and number of USC courses that are ‘sustainability-focused’, ‘SDG-related’ or ‘not related’ to 
                                                sustainability, as well as the number and percent of departments that offer sustainability-focused or SDG-related courses. Note that there are often many sections
                                                   for an offered course."),
                                                h3("For a course to count as SDG-related, it has to include at least two SDG keywords. For a course to count as sustainability-focused, 
                                                   it has to map to a combination of SDGs that includes at least one environmental focused SDG (6, 7, 12, 13, 14, 15) and at least one economic or social 
                                                   focused SDG (1, 2, 3, 4, 5, 8, 9, 10, 11, 16, 17)."),
                                                uiOutput("disclaimer6"),
                                                h4("Academic year determined by the year of the Spring semester and includes Summer and Fall terms of the previous calendar year. (AY23 = SU22, F22, SP23)"),
                                                selectInput(inputId = "usc_year",
                                                            label = "Choose USC Academic Year",
                                                            selected = "AY23",
                                                            choices = unique(sustainability_related$year)),
                                                pickerInput(inputId = "course_level_pie",
                                                            label = "Restrict course level?",
                                                            choices = c("All", "Undergraduate", "Graduate"),
                                                            options = list(height = 20)), br(),
                                                # choicesOpt = list(
                                                # style = rep(("font-size:24px; line-height: 1.5;"),2)))),
                                                
                                                fluidRow(column(6, 
                                                                h2("Sustainability Related Courses Offered"),
                                                                plotOutput("pie4")),
                                                         column(6,
                                                                h2("Sustainability Focused Courses"),
                                                                DT::dataTableOutput("courses_sustainability_table"))),
                                                fluidRow(
                                                  column(6, 
                                                         h2("Sustainability Related Departments"),
                                                         plotOutput("pie3")),
                                                  column(6,
                                                         h2("Department Wordcloud"),
                                                         h3("Based on the number of sustainability focused courses offered by each department"),
                                                         plotOutput("department_wordcloud"))),
                                                  # column(6,
                                                  #        h2("Department Sustainability Classification Table"),
                                                  #        DT::dataTableOutput("department_sustainability_table"))),
                                                # textOutput("pie4_numbers")
                                                # h2(strong("Department Sustainability Classification Table")),
                                                # fluidRow(column(12, DT::dataTableOutput("sustainability_table")))
                                                # pickerInput("usc_school", "Choose School",  
                                                #             choices = sort(unique(sustainability_related$school)), 
                                                #             selected = sort(unique(sustainability_related$school))[1]),
                                                # h2(textOutput("department_barchart_title")),
                                                # fluidRow(column(12, plotOutput("department_barchart")))
                                                h2(textOutput("school_barchart_title")),
                                                fluidRow(column(12, plotOutput("school_barchart")))
                                              ), # end fluid page
                                      ), # end tabitem 7
                                      tabItem(tabName="downloaddata",
                                              fluidPage(
                                                h1("Download Data"),
                                                h3("Select schools, departments, SDGs, and sustainability classifications to view and
                                                   download USC course data displayed in the table at the bottom."),
                                                uiOutput("disclaimer7"),
                                                pickerInput("school_dl", "Choose Schools",  
                                                            choices = sort(unique(sustainability_related$school)), 
                                                            selected = sort(unique(sustainability_related$school))[1],
                                                            multiple = TRUE,
                                                            options = list(`actions-box` = TRUE)),
                                                pickerInput("dept_dl", "Choose Departments",  
                                                            choices = NULL,
                                                            selected = NULL,
                                                            multiple = TRUE, 
                                                            options = list(`actions-box` = TRUE)),
                                                pickerInput("sdg_dl", "Choose SDGs",  choices = sdg_choices, selected = sdg_choices,
                                                            multiple = TRUE, 
                                                            options = list(`actions-box` = TRUE)),
                                                # pickerInput("sustainability_dl", "Choose Sustainability Category",  
                                                #             choices = sort(unique(sustainability_related$sustainability_classification)),
                                                #             selected = sort(unique(sustainability_related$sustainability_classification)),
                                                #             multiple = TRUE, 
                                                #             options = list(`actions-box` = TRUE)),
                                                checkboxGroupInput("sustainability_dl", "Choose Sustainability Categories",  
                                                                   choices = sort(unique(sustainability_related$sustainability_classification)),
                                                                   selected = sort(unique(sustainability_related$sustainability_classification))),
                                                downloadButton("download_data_table", "Download"),
                                                fluidRow(column(12, DT::dataTableOutput("view_data_table")))
                                              )
                                              ) # end tabitem
                                ),#end tabitems
                                tags$footer(
                                  fluidPage(
                                    h3("Stay connected by visiting our", 
                                       a("home page", href="https://sustainability.usc.edu",
                                         target = "_blank"), 
                                       "or by following the Office of Sustainability on social media via", 
                                       a("", href="https://www.instagram.com/green.usc/", class="fa fa-instagram",
                                         target = "_blank"),
                                       a("Instagram", href="https://www.instagram.com/green.usc/",
                                         target = "_blank"), "or", 
                                       a("", href="https://twitter.com/GreenUSC", class="fa fa-twitter",
                                         target = "_blank"),
                                       a("Twitter", href="https://twitter.com/GreenUSC", .noWS = "after",
                                         target = "_blank"), 
                                       ". You can also support the Office of Sustainability by donating", 
                                       a("here", 
                                         href="https://green.usc.edu/get-involved/give-to-the-office-of-sustainability/",
                                         .noWS = "after",
                                         target = "_blank"), 
                                       ". More questions or suggestions in regard to this tool? Please fill out our",
                                       a("feedback form",
                                         href=feedback_form_link, .noWS = "after",
                                         target = "_blank"),
                                       "."
                                    ),
                                  ))
                     )#end dashboard body
) #end UI
############ EDIT COMMA OUT HERE #####


# Define server logic
server <- function(input, output, session) {
  
  ## updating inputs to speed up program
  updateSelectizeInput(session, 'usc_classes', choices = recent_courses %>% filter(all_goals != "") %>% select(courseID) %>% distinct() %>% pull(), selected = "ENST-150", server = TRUE)
  # map classes in ascending order
  updateSelectizeInput(session, 'user_classes', choices = unique(sustainability_related$courseID) %>% sort(), server = TRUE)
  
  
  # disclaimer
  output$disclaimer1 <- output$disclaimer2 <- output$disclaimer3 <- output$disclaimer4 <- output$disclaimer5 <- output$disclaimer6 <- output$disclaimer7 <- renderUI({
    tagList(
      h5("*This app is a work in progress, and we are continually improving accuracy.
         If you have feedback, please fill out our ", 
         a("feedback form", 
           href=feedback_form_link, .noWS = "after",
           target="_blank"),
         ".")
    )
  })
  
  
  #####
  ##
  ##### tabitem1 -- home(about) and MAPPING THE 17 SDGS ###
  ##
  #####
  
  
  output$visualize_sdg <- renderImage({
    sdg_goal_keyword_df <- classes %>%
      filter(goal %in% as.numeric(substr(input$sdg_goal3, 1, 2))) %>%
      group_by(keyword) %>%
      summarize(count = sum(freq))
    png("wordcloud.png")
    wordcloud(words = sdg_goal_keyword_df$keyword, 
              freq = sdg_goal_keyword_df$count,
              min.freq = 1, max.words = 50, random.order = FALSE, rot.per = 0, 
              scale = c(8,1),
              colors = sdg_colors[as.numeric(substr(input$sdg_goal3, 1, 2))])
    dev.off()
    filename <- normalizePath(file.path("wordcloud.png"))
    list(src = filename, height = "100%")
  }, deleteFile = TRUE)
  
  #sdg keywords table
  output$keywords_table <- DT::renderDataTable({
    keywords %>%
      # filter(!(keyword %in% exclude_words)) %>%
      filter(goal == as.numeric(substr(input$sdg_goal3, 1, 2))) %>%
      rename(Keyword = keyword,
             SDG = goal) %>%
      select(Keyword) %>%
      distinct()
  }, rownames=FALSE)
  
  
  
  
  
  
  #####
  ##
  ##### tabitem3 -- MAP YOUR CLASSES ###
  ##
  ##### 
  
  
  # get the courses
  output$personal_classes <- renderText({
    if (length(input$user_classes) > 0){ #first make sure they typed something in
      
      class_list <- sustainability_related %>% #changed this from master
        filter(courseID %in% input$user_classes) %>% #changed from section
        distinct(courseID, .keep_all = TRUE) %>%
        select(courseID) %>%
        unique() %>%
        pull()
      return(paste(class_list, collapse = ", "))
    }
  })
  
  # wordcloud for users classes
  output$users_wordcloud <- renderImage({
    df = recent_courses %>%
      filter(courseID %in% input$user_classes) %>%
      filter(!is.na(keyword)) %>%
      select(keyword, color, freq) %>%
      arrange(desc(freq)) %>%
      distinct(keyword, .keep_all = TRUE)
    png("wordcloud.png")
    if (nrow(df) == 0) {
      ggplot()
    } else {
      wordcloud(words = df$keyword, 
                freq = df$freq,
                min.freq = 1, max.words = 50, random.order = FALSE, rot.per = 0, 
                scale = c(3,1),
                colors = df$color,
                ordered.colors = TRUE)
    }
    dev.off()
    filename <- normalizePath(file.path("wordcloud.png"))
    list(src = filename, height = "100%")
  }, deleteFile = TRUE)
  
  # output for users classes
  output$user_classes_barplot <- renderPlot({
    df <- recent_courses %>%
      filter(courseID %in% input$user_classes) %>%
      filter(!is.na(keyword)) %>%
      select(keyword, goal, color, freq)
    plot_colors <- df %>%
      arrange(goal) %>%
      select(color) %>%
      distinct() %>%
      pull()
    df %>%
      ggplot(aes(x = keyword, y = freq, fill = factor(as.numeric(goal)))) +
      geom_col() +
      coord_flip() +
      labs(title = paste0("All SDG Keywords"),
           fill = "SDG",
           x = "SDG Keyword",
           y = "Total SDG Keyword Frequency") +
      theme(text = element_text(size = 20, face="bold"),
            axis.text = element_text(color = "black")) +
      scale_fill_manual(values = plot_colors) + 
      scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1))))) # integer breaks
      
  })
  
  
  # user to goals barplot
  output$user_to_goals <- renderPlot({
    df <- recent_courses %>%
      filter(courseID %in% input$user_classes) %>%
      filter(!is.na(keyword)) %>%
      select(keyword, goal, color, freq)
    plot_colors <- df %>%
      arrange(goal) %>%
      select(color) %>%
      distinct() %>%
      pull()
    df %>%
      ggplot(aes(x = factor(as.numeric(goal)), y = freq, fill = factor(as.numeric(goal)))) +
      geom_col() +
      coord_flip() +
      labs(title = paste0("All SDGs Mapped to your Courses"),
           fill = "SDG",
           x = "SDG",
           y = "Total SDG Keyword Frequency") +
      theme(text = element_text(size = 20, face="bold"),
            axis.text = element_text(color = "black")) +
      scale_fill_manual(values = plot_colors) +
      scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1))))) # integer breaks
  })
  
  
  output$user_table <- DT::renderDataTable({
    # use this dataframe so the course descriptions still show for unmapped classes
    # df = sustainability_related[sustainability_related$courseID %in% input$user_classes, ]
    # need to only grab one instance

    recent_courses %>% 
      filter(courseID %in% input$user_classes) %>%
      # distinct(courseID, .keep_all = TRUE) %>%
      rename("Course ID" = courseID, "Course Description" = course_desc, "All Goals" = all_goals, "Sustainability Classification" = sustainability_classification) %>%
      select("Course ID", "All Goals", "Sustainability Classification","Course Description") %>%
      distinct()
  }, rownames=FALSE)
  
  
  
  
  
  
  #####
  ##### tabitem4 -- FIND SDGS BY CLASSES ###
  #####
  
  
  
  #this returns a dataframe with the descriptions of all the classes the user selected
  output$course_desc <- renderText({
    recent_courses %>%
      filter(courseID == input$usc_classes) %>% #changed from section
      select(course_desc) %>%
      distinct() %>%
      pull()
    
  })
  
  # writes out the semesters offered
  output$semesters_offered <- renderText({
    sems <- recent_courses %>%
      filter(courseID == input$usc_classes) %>%
      select(all_semesters) %>% 
      distinct() %>% 
      pull()
    paste("Semesters offered: ", sems)
  })
  
  #this part filters the classes by the semester chosen in input field
  # observeEvent(input$usc_semester1,
  #              {
  #                updateSelectizeInput(session, "usc_classes",
  #                                     server = TRUE,
  #                                     choices = sort(classes %>% filter(semester == input$usc_semester1) %>% select(courseID) %>% pull()), #change this section to course_
  #                                     # selected = unique(classes %>% filter(semester == input$usc_semester1) %>% select(courseID) %>% pull())[1])
  #                                     selected = "ENST-100")
  #                
  #              })
  
  # barplot for sdgs
  output$classes_to_goals <- renderPlot({
    df <- recent_courses %>%
      filter(courseID == input$usc_classes)
    plot_colors <- df %>%
      arrange(goal) %>%
      select(color) %>%
      filter(!is.na(color)) %>%
      distinct() %>%
      pull()
    if (length(plot_colors) == 0) {
      return(ggplot())
    }
    df %>%
      group_by(goal) %>%
      mutate(sum_freq = sum(freq)) %>%
      ungroup() %>%
      distinct() %>%
      ggplot(aes(x = factor(goal), y = sum_freq, fill = factor(as.numeric(goal)))) +
      geom_col() +
      coord_flip() +
      labs(title = paste0("All SDGs Mapped to ", input$usc_classes),
           fill = "SDG",
           x = "SDG",
           y = "Total SDG Keyword Frequency") +
      theme(text = element_text(size = 18, face= "bold"),
            axis.text = element_text(color = "black")) +
      scale_fill_manual(values = plot_colors) +
      scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))
  })
  
  
  # keyword to sdg barplot
  output$classes_to_keywords <- renderPlot({
    df <- recent_courses %>%
      filter(courseID == input$usc_classes)
    plot_colors <- df %>%
      arrange(goal) %>%
      select(color) %>%
      filter(!is.na(color)) %>%
      distinct() %>%
      pull()
    if (length(plot_colors) == 0) {
      return(ggplot())
    }
    df %>%
      ggplot(aes(x = keyword, y = freq, fill = factor(as.numeric(goal)))) +
      geom_col() +
      coord_flip() +
      labs(title = paste0(input$usc_classes, " SDG Keywords"),
           fill = "SDG",
           x = "SDG Keyword",
           y = "Total SDG Keyword Frequency") +
      scale_fill_manual(values = plot_colors) +
      theme(text = element_text(size = 18, face= "bold"),
            axis.text = element_text(color = "black")) +
      scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))
  })

  
  # class to wordcloud
  output$classes_to_wordcloud <- renderImage({
    df = recent_courses %>%
      filter(courseID == input$usc_classes) %>%
      filter(!is.na(keyword)) %>%
      select(keyword, color, freq) %>%
      arrange(desc(freq)) %>%
      distinct(keyword, .keep_all = TRUE)
    png("wordcloud.png")
    if (nrow(df) == 0) {
      ggplot()
    } else {
      wordcloud(words = df$keyword, 
                freq = df$freq,
                min.freq = 1, max.words = 50, random.order = FALSE, rot.per = 0, 
                scale = c(3,1),
                colors = df$color,
                ordered.colors = TRUE)
    }
    dev.off()
    filename <- normalizePath(file.path("wordcloud.png"))
    list(src = filename, height = "100%")
  }, deleteFile = TRUE)
  
  
  # data table at bottom
  output$classes_table = DT::renderDataTable({
    recent_courses %>%
      filter(courseID == input$usc_classes) %>%
      filter(!is.na(keyword)) %>%
      group_by(keyword) %>%
      summarize(SDGs = paste(sort(unique(goal)), collapse = ", ")) %>%
      rename(Keyword = keyword) %>%
      select(Keyword, SDGs) %>%
      arrange(Keyword)
  }, 
  rownames=FALSE,
  options = list(
    language = list(
      zeroRecords = "Not Related"
    )
  ))
  
  
  
  
  
  
  #####
  ##### tabitem5 -- FIND CLASSES BY SDGS
  #####
  
  
  
  # trying to get Classes by SDGs table name
  output$sdg_name = renderText({
    paste("All Courses Mapped to SDG", input$sdg_goal1, sep="")
  })
  
  # title of graph
  output$top_classes = renderText({
    paste0("Top 10 Courses that Map to SDG", input$sdg_goal1)
  })
  
  #this part filters the departments by the semester chosen in input field
  # observeEvent(input$usc_semester3,
  #              {
  #                updatePickerInput(session=session,
  #                                  inputId = "department_input",
  #                                     # server = TRUE,
  #                                     
  #                                     choices = unique(sort(classes %>% filter(semester == input$usc_semester3) %>% select(department) %>% pull())),#change this section to course_
  #                                     selected = unique(classes %>% filter(semester == input$usc_semester3) %>% select(department) %>% pull()))
  #                                     # selected = "All")
  #                
  #              })
  
  # need to filter for these options based on input from input$course_level
  # "All", "Graduate", "Undergrad lower divison", "Undergrad upper division"
  # undergrad lower division
  # undergrad upper division
  # graduate
  
  output$goals_to_classes <- renderPlot({
    df <- recent_courses %>%
      filter(department %in% input$department_input,
             goal %in% as.numeric(substr(input$sdg_goal1, 1, 2)))
    if (input$course_level_input != "All") {
      df <- df %>%
        filter(course_level == tolower(input$course_level_input))
    }
    if (nrow(df) == 0) {
      return (ggplot() + 
                annotate("text", x = 1, y = 1, size = 8, label = "No Courses") + 
                theme(panel.border = element_blank(),
                      panel.grid.major = element_blank(),
                      panel.grid.minor = element_blank(),
                      axis.title = element_blank(),
                      axis.ticks = element_blank(),
                      axis.text = element_blank()))
    }
    df %>%
      group_by(courseID) %>%
      mutate(total_freq = sum(freq)) %>%
      ungroup() %>%
      select(courseID, total_freq) %>%
      distinct() %>%
      arrange(desc(total_freq)) %>%
      head(num_top_classes) %>%
      ggplot(aes(x = reorder(courseID, total_freq), y = total_freq)) +
      geom_col(fill = sdg_colors[as.numeric(substr(input$sdg_goal1, 1, 2))], alpha = 1) +
      coord_flip() +
      scale_x_discrete(labels = function(x) str_wrap(x, width = 30)) +
      labs(
        x = "Course",
        y = "Total SDG Keyword Frequency") +
      theme(text = element_text(size = 20, face="bold"),
            axis.text = element_text(color = "black")) +
      scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))
  })
  
  # table for sdgs to classes
  output$top_classes_sdg_table <- DT::renderDataTable({
    df <- recent_courses %>%
      filter(department %in% input$department_input,
             goal %in% as.numeric(substr(input$sdg_goal1, 1, 2)))
    if (input$course_level_input != "All") {
      df <- df %>%
        filter(course_level == tolower(input$course_level_input))
    }
    df %>%
      group_by(courseID) %>%
      mutate(total_freq = sum(freq)) %>%
      ungroup() %>%
      distinct(courseID, .keep_all = TRUE) %>%
      arrange(desc(total_freq)) %>%
      rename('Course ID' = courseID,"Sustainability Classification" = sustainability_classification, Semester = semester, "Course Title" = course_title, 'Total SDG Keyword Frequency'= total_freq, "Course Description" = course_desc, "Semesters Offered" = all_semesters) %>%
      select('Course ID', "Total SDG Keyword Frequency", "Sustainability Classification", "Course Description", "Semesters Offered")
  }, 
  rownames=FALSE,
  options = list(
    language = list(
      zeroRecords = "No Courses"
    )
  ))
  # options = list(
  #     autoWidth = TRUE)
  #     # columnDefs = list(list(width = '200px', targets = "_all"))
  # )
  
  
  
  
  
  
  
  
  
  
  #####
  ##### tabitem6 -- GE requirements
  #####
  
  
  
  # stacked bar chart for GEs
  output$ge_bar <- renderPlot({
    # get the top 10 classes and total weights
    df <- ge_data %>%
      filter(full_name == input$ge_category) %>%
      filter(goal %in% input$ge_sdgs) %>%
      group_by(courseID, course_title) %>%
      mutate(total_freq = sum(freq)) %>%
      ungroup()
    top_10_courses <- df %>%
      select(courseID, total_freq) %>%
      distinct() %>%
      arrange(desc(total_freq)) %>%
      head(num_top_classes) %>%
      select(courseID) %>%
      pull()
    if (length(top_10_courses) == 0) {
      return (ggplot() + 
                annotate("text", x = 1, y = 1, size = 8, label = "No Courses") + 
                theme(panel.border = element_blank(),
                      panel.grid.major = element_blank(),
                      panel.grid.minor = element_blank(),
                      axis.title = element_blank(),
                      axis.ticks = element_blank(),
                      axis.text = element_blank()))
    }
    plot_colors <- df %>%
      filter(courseID %in% top_10_courses) %>%
      arrange(goal) %>%
      select(color) %>%
      distinct() %>%
      pull()
    df %>%
      filter(courseID %in% top_10_courses) %>%
      ggplot(aes(x = reorder(courseID, total_freq), y = freq, fill = factor(as.numeric(goal)))) +
      geom_col() +
      coord_flip() + 
      scale_fill_manual(values = plot_colors) + 
      scale_x_discrete(labels = function(x) str_wrap(x, width = 30)) +
      labs(
        fill="SDG",
        x = "Course",
        y = "Total SDG Keyword Frequency") +
      theme(text = element_text(size = 20, face="bold"),
            axis.text = element_text(color = "black")) +
      scale_y_continuous(breaks = function(x) unique(floor(pretty(seq(0, (max(x) + 1) * 1.1)))))
    
  })
  
  # title above the chart
  output$top_ge_chart = renderText({
    paste("Top 10 Courses that Map to ", input$ge_category)
  })
  
  # trying to get Classes by SDGs table name
  output$ge_name = renderText({
    paste("All GE Courses Mapped to ", input$ge_category, sep="")
  })
  
  output$ge_table <- DT::renderDataTable({
    ge_data %>%
      filter(full_name == input$ge_category) %>%
      filter(goal %in% input$ge_sdgs) %>%
      group_by(courseID, course_title) %>%
      mutate(total_freq = sum(freq)) %>%
      arrange(desc(total_freq)) %>%
      ungroup() %>%
      rename('Course ID' = courseID, Semester = semester, "All Goals" = all_goals, 'Total SDG Keyword Frequency'= total_freq, "Sustainability Classification" = sustainability_classification, "Course Description" = course_desc) %>%
      select('Course ID', "Total SDG Keyword Frequency", "All Goals", "Sustainability Classification", "Course Description") %>%
      distinct()
  }, 
  rownames=FALSE,
  options = list(
    language = list(
      zeroRecords = "No Courses"
    )
  ))
  
  
  
  
  
  
  #####
  ##### tabitem7 -- ALL SUSTAINABILITY RELATED CLASSES ###
  #####
  
  
  # sustainability related departments pie chart
  output$pie3 <- renderPlot({
    df <- sustainability_related %>% 
      filter(year == input$usc_year) 
    if (input$course_level_pie == "Undergraduate"){
      df <- df %>% 
        filter(course_level == "undergrad upper division" | course_level == "undergrad lower division")
    }
    else if(input$course_level_pie == "Graduate") {
      df <- df %>% 
        filter(course_level == "graduate")
    }
    df <- df %>%
      group_by(department) %>%
      summarize(all_sustainability_classifications = paste(unique(sustainability_classification), collapse = ";")) %>%
      mutate(one_sustainability_classification = case_when(grepl("Focused", all_sustainability_classifications)~"Sustainability Focused",
                                                           grepl("SDG", all_sustainability_classifications)~"SDG Related",
                                                           grepl("Not", all_sustainability_classifications)~"Not Related")) %>%
      group_by(one_sustainability_classification) %>%
      count()
    total_num = sum(df$n)
    pie_data <- data.frame(group = df$one_sustainability_classification,
                           value = df$n,
                           proportion = round(df$n/total_num*100,1))
    
    # compute positions of labels
    pie_data <- pie_data %>%
      arrange(desc(group)) %>%
      mutate(prop = value / sum(pie_data$value) * 100) %>%
      mutate(ypos = cumsum(prop) - 0.5 * prop )
    
    pie(pie_data$value,
        labels = paste0(str_wrap(pie_data$group, 20),"\n (", pie_data$value, ", " , pie_data$proportion,"%)"),
        col = c("#990000", "#FFC72C", "#767676"),
        cex = 1.5, cex.main = 2, family = "sans")
  })
  
  # sustainability courses offered pie chart
  output$pie4 <- renderPlot({
    df <- sustainability_related %>% 
      filter(year == input$usc_year)
    if (input$course_level_pie == "Undergraduate"){
      df <- df %>% 
        filter(course_level == "undergrad upper division" | course_level == "undergrad lower division")
    }
    else if (input$course_level_pie == "Graduate") {
      df <- df %>% 
        filter(course_level == "graduate")
    }
    df <- df %>%
      group_by(sustainability_classification) %>%
      summarize(by_section = sum(N.Sections), by_course = n())
    df$sustainability_classification <- gsub("-", " ", df$sustainability_classification)
    total_num <- sum(df$by_section)
    pie_data <- data.frame(group = df$sustainability_classification,
                           value = df$by_section,
                           proportion = round(df$by_section/total_num*100, 1))
    
    # compute positions of labels
    pie_data <- pie_data %>%
      arrange(desc(group)) %>%
      mutate(prop = value / sum(pie_data$value) * 100) %>%
      mutate(ypos = cumsum(prop) - 0.5 * prop )
    
    pie(pie_data$value,
        labels = paste0(str_wrap(pie_data$group, 20),"\n (", pie_data$value, ", " , pie_data$proportion,"%)"),
        col = c("#990000", "#FFC72C", "#767676"),
        cex = 1.5, cex.main = 2, family = "sans")
  })
  
  # sustainability departments table
  output$department_sustainability_table <- DT::renderDataTable({
    df <- sustainability_related %>% 
      filter(year == input$usc_year) 
    if (input$course_level_pie == "Undergraduate"){
      df <- df %>% 
        filter(course_level == "undergrad upper division" | course_level == "undergrad lower division")
    }
    else if(input$course_level_pie == "Graduate") {
      df <- df %>% 
        filter(course_level == "graduate")
    }
    course_sustainability_classification <- df %>%
      group_by(department) %>%
      summarize(all_sustainability_classifications = paste(unique(sustainability_classification), collapse = ";")) %>%
      mutate(one_sustainability_classification = case_when(grepl("Focused", all_sustainability_classifications)~"Sustainability Focused",
                                                           grepl("SDG", all_sustainability_classifications)~"SDG Related",
                                                           grepl("Not", all_sustainability_classifications)~"Not Related"))
    sustainability_focused_courses <- df %>%
      filter(sustainability_classification == "Sustainability-Focused") %>%
      group_by(department) %>%
      summarize(courses = paste(courseID, collapse = ", "))
    department_output <- merge(course_sustainability_classification, 
                               sustainability_focused_courses, all.x = TRUE) %>%
      arrange(department) %>%
      select(department, one_sustainability_classification, courses) %>%
      rename(Department = department, "Sustainability Classification" = one_sustainability_classification, "Sustainability-Focused Courses" = courses)
  }, rownames=FALSE)
  
  output$courses_sustainability_table <- DT::renderDataTable({
    df <- sustainability_related %>% 
      filter(year == input$usc_year) 
    if (input$course_level_pie == "Undergraduate"){
      df <- df %>% 
        filter(course_level == "undergrad upper division" | course_level == "undergrad lower division")
    }
    else if(input$course_level_pie == "Graduate") {
      df <- df %>% 
        filter(course_level == "graduate")
    }
    df %>%
      filter(sustainability_classification == "Sustainability-Focused") %>%
      select(courseID, sustainability_classification) %>%
      rename("Course ID" = courseID, "Sustainability Classification" = sustainability_classification) %>%
      distinct()
  }, rownames=FALSE)
  
  output$department_wordcloud <- renderImage({
    df <- sustainability_related %>% 
      filter(year == input$usc_year) 
    if (input$course_level_pie == "Undergraduate"){
      df <- df %>% 
        filter(course_level == "undergrad upper division" | course_level == "undergrad lower division")
    }
    else if(input$course_level_pie == "Graduate") {
      df <- df %>% 
        filter(course_level == "graduate")
    }
    Mode <- function(x) {
      ux <- unique(x)
      ux[which.max(tabulate(match(x, ux)))]
    }
    wordcloud_data <- df %>%
      group_by(department, sustainability_classification) %>%
      summarize(n = n(),
                goals = paste(all_goals, collapse = ",")) %>%
      filter(sustainability_classification == "Sustainability-Focused")
    wordcloud_data$goal = sapply(wordcloud_data$goals, function(x) {
      Mode(strsplit(x, ",")[[1]])
    })
    wordcloud_data$color <- sdg_colors[as.numeric(wordcloud_data$goal)]
    png("wordcloud.png")
    wordcloud(words = wordcloud_data$department, 
              freq = wordcloud_data$n,
              min.freq = 1, max.words = 50, random.order = FALSE, rot.per = 0, 
              scale = c(8,1),
              colors = wordcloud_data$color,
              ordered.colors = TRUE)
    dev.off()
    filename <- normalizePath(file.path("wordcloud.png"))
    list(src = filename, height = "100%")
  }, deleteFile = TRUE)
  
  # title above the chart
  output$department_barchart_title = renderText({
    paste(input$course_level_pie, "courses in", input$usc_school, "by Department in", input$usc_year)
  })
  
  output$department_barchart <- renderPlot({
    df <- sustainability_related %>% 
      filter(year == input$usc_year) %>%
      filter(school == input$usc_school)
    if (input$course_level_pie == "Undergraduate"){
      df <- df %>% 
        filter(course_level == "undergrad upper division" | course_level == "undergrad lower division")
    }
    else if(input$course_level_pie == "Graduate") {
      df <- df %>% 
        filter(course_level == "graduate")
    }
    plot_colors <- c("Sustainability-Focused" = "#990000", 
                     "SDG-Related" = "#FFC72C", 
                     "Not Related" = "#767676")
    plot_data <- df %>%
      group_by(department, sustainability_classification) %>%
      count() 
    
    middle_department <- unique(plot_data$department)[length(unique(plot_data$department))/2]
    
    plot_data$group <- 1
    if (length(unique(plot_data$department)) > 40) {
      bottom_third <- unique(plot_data$department)[length(unique(plot_data$department))/3]
      top_third <- unique(plot_data$department)[length(unique(plot_data$department))/3*2]
      plot_data <- plot_data %>%
        group_by(department) %>%
        mutate(group = ifelse(department <= bottom_third,
                              1,
                              ifelse(department <= top_third,
                                     2,
                                     3))) %>%
        ungroup()
    } else if (length(unique(plot_data$department)) > 20) {
      plot_data <- plot_data %>%
        group_by(department) %>%
        mutate(group = ifelse(department <= middle_department,
                              1,
                              2)) %>%
        ungroup()
    }
    plot_data %>%
      ggplot(aes(x = department, y = n, fill = sustainability_classification)) +
      geom_bar(position = "fill", stat = "identity") +
      facet_wrap(~ group, scales = "free", nrow = length(unique(plot_data$group))) +
      scale_fill_manual(values=plot_colors) +
      scale_y_continuous(labels = scales::percent) +
      labs(
        fill=str_wrap("Sustainability Classification", 20),
        x = "Department",
        y = "Percent") +
      theme(text = element_text(size = 18, face="bold"),
            axis.text = element_text(color = "black"),
            legend.position="bottom",
            strip.background = element_blank(),
            strip.text.x = element_blank()) +
      guides(fill = guide_legend(nrow = 2, byrow = TRUE)) -> actual_plot
    if (length(unique(plot_data$department)) > 10 & length(unique(plot_data$group)) == 1) {
      actual_plot +
        scale_x_discrete(guide = guide_axis(n.dodge = 2))
    } else if (length(unique(plot_data$group)) > 1 & sum(plot_data$group == 1) > 10) {
      actual_plot +
        scale_x_discrete(guide = guide_axis(n.dodge = 2))
    } else {
      actual_plot
    }
    
  })
  
  # title above the chart
  output$school_barchart_title = renderText({
    paste(input$course_level_pie, "courses by School in", input$usc_year)
  })
  
  output$school_barchart <- renderPlot({
    df <- sustainability_related %>% 
      filter(year == input$usc_year)
    if (input$course_level_pie == "Undergraduate"){
      df <- df %>% 
        filter(course_level == "undergrad upper division" | course_level == "undergrad lower division")
    }
    else if(input$course_level_pie == "Graduate") {
      df <- df %>% 
        filter(course_level == "graduate")
    }
    plot_colors <- c("Sustainability-Focused" = "#990000", 
                     "SDG-Related" = "#FFC72C", 
                     "Not Related" = "#767676")
    plot_data <- df %>%
      group_by(school, sustainability_classification) %>%
      count() 
    
    middle_school <- unique(plot_data$school)[length(unique(plot_data$school))/2]
    
    plot_data$group <- 1
    if (length(unique(plot_data$school)) > 20) {
      plot_data <- plot_data %>%
        group_by(school) %>%
        mutate(group = ifelse(school <= middle_school,
                              1,
                              2)) %>%
        ungroup()
    }
    plot_data <- plot_data %>%
      mutate(SCHOOL = recode(school,
                             "Andrew and Erna Viterbi School of Engineering" = "Viterbi School of Engineering",
                             "Annenberg School for Communication and Journalism" = "Annenberg School for Communication & Journalism",
                             "Barbara J. and Roger W. Rossier School of Education" = "Rossier School of Education",
                             "Bovard College" = "Bovard College",
                             "Dana and David Dornsife College of Letters, Arts and Sciences" = "Dornsife College of Letters, Arts & Sciences",
                             "Elaine and Kenneth Leventhal School of Accounting" = "Leventhal School of Accounting",
                             "Glorya Kaufman School of Dance" = "Kaufman School of Dance",
                             "Gordon S. Marshall School of Business" = "Marshall School of Business",
                             "Gould School of Law" = "Gould School of Law",
                             "Hebrew Union College" = "Hebrew Union College",
                             "Independent Health Professions" = "Independent Health Professions",
                             "Jimmy Iovine and Andre Young Academy" = "Iovine & Young Academy",
                             "Keck School of Medicine" = "Keck School of Medicine",
                             "Leonard Davis School of Gerontology" = "Davis School of Gerontology",
                             "Ostrow School of Dentistry" = "Ostrow School of Dentistry",
                             "Registrar's Office and Graduate School" = "Registrar's Office & Graduate School",
                             "Roski School of Art and Design" = "Roski School of Art & Design",
                             "School of Architecture" = "School of Architecture",
                             "School of Cinematic Arts" = "School of Cinematic Arts",
                             "School of Dramatic Arts" = "School of Dramatic Arts",
                             "School of Pharmacy" = "School of Pharmacy",
                             "Sol Price School of Public Policy" = "Price School of Public Policy",
                             "Suzanne Dworak-Peck School of Social Work" = "Dworak-Peck School of Social Work",
                             "Thornton School of Music" = "Thornton School of Music")) %>%
      arrange(SCHOOL)
    plot_data %>%
      ggplot(aes(x = SCHOOL, y = n, fill = sustainability_classification)) +
      geom_bar(position = "fill", stat = "identity") +
      # facet_wrap(~ group, scales = "free", nrow = length(unique(plot_data$group))) +
      scale_fill_manual(values=plot_colors) +
      scale_y_continuous(labels = scales::percent) +
      labs(
        fill="Sustainability Classification",
        x = "School",
        y = "Percent") +
      theme(text = element_text(size = 18, face="bold"),
            legend.position="bottom",
            axis.text = element_text(face = "plain", color = 'black')) +
      # guides(fill = guide_legend(nrow = 2, byrow = TRUE)) +
      coord_flip() +
      scale_x_discrete(labels = scales::label_wrap(50))
    
  })
  
  
  ###
  ### tabitem8 - DOWNLOAD DATA
  ###
  
  # download data page
  observeEvent(input$school_dl,
               {
                 depts <- sustainability_related %>%
                   filter(school %in% input$school_dl) %>%
                   select(department) %>%
                   distinct() %>%
                   arrange(department)
                 depts_selected <- depts %>%
                   filter(department %in% input$dept_dl)
                 updatePickerInput(session,
                                   "dept_dl",
                                   choices = depts$department,
                                   selected = depts_selected
                                   )
               })
  output$download_data_table <- downloadHandler(
    filename = function() {"usc_sustainability_course_data.csv"},
    content = function(fname) {
      classes %>%
        filter(school %in% input$school_dl,
               department %in% input$dept_dl,
               sustainability_classification %in% input$sustainability_dl,
               goal %in% as.numeric(input$sdg_dl)) %>%
        ungroup() %>%
        select(school, department, courseID, course_title, course_desc, semester, all_goals, sustainability_classification, N.Sections, total_enrolled, all_semesters, course_level, year) %>%
        rename(School = school, Department = department, "Course ID" = courseID, "Course Title" = course_title, "Course Description" = course_desc, Semester = semester, "All Goals" = all_goals, "Sustainability Classification" = sustainability_classification, "Number of Sections" = N.Sections, "Total Enrolled" = total_enrolled, "All Semesters" = all_semesters, "Course Level" = course_level, Year = year) %>%
        distinct() -> download_data_output
      write.csv(download_data_output, fname, row.names = FALSE)
    }
  )
  output$view_data_table <- DT::renderDataTable({
    classes %>%
      filter(school %in% input$school_dl,
             department %in% input$dept_dl,
             sustainability_classification %in% input$sustainability_dl,
             goal %in% as.numeric(input$sdg_dl)) %>%
      ungroup() %>%
      arrange(sustainability_classification) %>%
      select(school, department, courseID, course_title, course_desc, semester, all_goals, sustainability_classification, N.Sections, total_enrolled, all_semesters, course_level, year) %>%
      rename(School = school, Department = department, "Course ID" = courseID, "Course Title" = course_title, "Course Description" = course_desc, Semester = semester, "All Goals" = all_goals, "Sustainability Classification" = sustainability_classification, "Number of Sections" = N.Sections, "Total Enrolled" = total_enrolled, "All Semesters" = all_semesters, "Course Level" = course_level, Year = year) %>%
      distinct()
  }, rownames=FALSE,
  options = list(
    scrollX = TRUE,
    autoWidth = TRUE,
    columnDefs = list(list(width = '100px', targets = c(0,3)),
                      list(width = '250px', targets = c(4))),
    language = list(
      zeroRecords = "No Courses"
    )
  ))
}

# Run the application 
shinyApp(ui = ui, server = server)

# ) # end shinyApp(
# runApp(s)
# }) ## end profvis(



