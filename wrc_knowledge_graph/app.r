# NC Wildlife Diversity Knowledge Graph
# v0.1
# 02/05/2024
# Scott K. Anderson
# NC Wildlife Resources Commission

if(!require(shiny)) install.packages(
  "shiny", repos = "http://cran.us.r-project.org")
if(!require(shinyWidgets)) install.packages(
  "shinyWidgets", repos = "http://cran.us.r-project.org")
if(!require(tidyverse)) install.packages(
  "tidyverse", repos = "http://cran.us.r-project.org")
if(!require(mongolite)) install.packages(
  "mongolite", repos = "http://cran.us.r-project.org")
# if(!require(dplyr)) install.packages(
#   "dplyr", repos = "http://cran.us.r-project.org")
  if(!require(htmltools)) install.packages(
  "htmltools", repos = "http://cran.us.r-project.org")
if(!require(shinythemes)) install.packages(
  "shinythemes", repos = "http://cran.us.r-project.org")
# if(!require(shinytreeview)) install.packages(
if(!require(treemap)) install.packages(
  "treemap", repos = "http://cran.us.r-project.org")
if(!require(d3tree)) install.packages(
  "d3tree", repos = "http://cran.us.r-project.org")
# if(!require(shinytreeview)) install.packages(
#   "shinytreeview", repos = "http://cran.us.r-project.org")
# if(!require(tidyjson)) install.packages(
#   "tidyjson", repos = "http://cran.us.r-project.org")
# if(!require(reactable)) install.packages(
#   "reactable", repos = "http://cran.us.r-project.org")
if(!require(shinydashboard)) install.packages(
  "shinydashboard",
  repos = "http://cran.us.r-project.org"
)
  
if(!require(stringr)) install.packages(
  "stringr", repos = "http://cran.us.r-project.org")

#adds functions for tooltips
if(!require(shinyBS)) install.packages(
  "shinyBS", repos = "http://cran.us.r-project.org"
  )

# load supporting files
source("utils.R")

wrc_green = "#3F7664"

########################################################################
## Begin UI coding

ui <- navbarPage(
  "NC Wildlife Diversity Data Explorer",
  theme = shinytheme("paper"),
  collapsible = TRUE,

  ####################################################################
  ## WILDLIFE ACTION PLAN
  ## see here for data entry form: 
  ## https://shanghai.hosting.nyu.edu/data/r/case-4-database-management-shiny.html
  
  tabPanel(
    "Wildlife Action Plan",
    fluidRow(
      column(
        3,
        treeviewInput(
          inputId = "nodeListTable",
          label = "Select an Item:",
          choices = make_tree(get_all_list(), c("type", "name")),
          multiple = FALSE
        )
      ),
      column(
        6,
        htmlOutput(
          "nodeTitle"
        ),
        htmlOutput(
          "nodeProperties"
        ),
        htmlOutput(
          "nodeDescription"
        )
      ),
      column(
        3,
        tags$h4("Connections"),
        d3treeOutput("treeMap"),
        dataTableOutput(
          "nodeConnections"
        )
      )
    )
  ),
  ####################################################################
  ## NC BIRD ATLAS
  tabPanel(
    "NC Bird Atlas"
  ),
  ####################################################################
  ## NA BAT
  tabPanel(
    "NA Bat"
  )
)

########################################################################
## Begin server code

server <- function(input, output, session) {

###################################################################
## WAP Functions

#get list of entities of type selected in entitySelect
curr_node <- reactive({
  input$nodeListTable
  print(input$nodeListTable)
})

# curr_node_data <- reactive({
#   req(curr_node)
#   get_node_data(curr_node())
# })
# types <- reactive(
#   print(get_types())
# )

output$nodeTitle <- renderUI({
  print(curr_node())
  HTML(paste0(
    "<h3>",
    curr_node(),
    "</h3>"
  ))
})

output$nodeDescription <- renderUI({
  req(curr_node())
  HTML(get_description(curr_node()))
})

output$nodeProperties <- renderPrint({
  print("getting properties")
  req(curr_node())
  print(get_properties(curr_node()))
})

output$nodeConnections <- renderDataTable({
  print("getting connections")
  req(curr_node())
  get_connections(curr_node())
})

output$treeMap <- renderD3tree({
  
})

}

shinyApp(ui, server)
