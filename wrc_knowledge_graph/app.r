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
if(!require(dplyr)) install.packages(
  "dplyr", repos = "http://cran.us.r-project.org")
  if(!require(htmltools)) install.packages(
  "htmltools", repos = "http://cran.us.r-project.org")
if(!require(shinythemes)) install.packages(
  "shinythemes", repos = "http://cran.us.r-project.org")
if(!require(reactable)) install.packages(
  "reactable", repos = "http://cran.us.r-project.org")
if(!require(shinydashboard)) install.packages(
  "shinydashboard",
  repos = "http://cran.us.r-project.org"
)

#adds functions for tooltips
if(!require(shinyBS)) install.packages(
  "shinyBS", repos = "http://cran.us.r-project.org")

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
    tabPanel(
        "Wildlife Action Plan",
        fluidRow(
            column(
                3,
                # DT::dataTableOutput("nodeListTable"),
                # verbatimTextOutput("nodeListSelected")
                reactableOutput("nodeListTable")
            ),
            column(
                6,
                # htmlOutput(
                #   "entityTitle"
                #   ),
                # htmlOutput(
                #   "entityDetails"
                # )
            ),
            column(
              3,
              tags$h4("Connections"),
            #   dataTableOutput(
            #     "entityConnections"
            #   )
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
    curr_node <- reactive(getReactableState("nodeListTable", selected))

    output$nodeListTable <- renderReactable({
        reactable(
            get_all_list(),
            groupBy = "type",
            selection = "single",
            searchable = TRUE,
            striped = TRUE,
            highlight = TRUE
        )
    })

    # output$nodeListTable <- DT::renderDataTable(
    #     DT::datatable(
    #         get_all_list(),
    #         selection = "single"
    #     )
    # )

    output$entityTitle <- renderPrint({
        state <- req(getReactableState("nodeListTable"))
        print(state)

    #   HTML(paste0(
    #     "<h3>",
    #     getReactableState("nodeListTable"),
    #     "</h3>"
    #   ))
    })

    output$nodeDetails <- renderUI({
        req(curr_node)
        print(curr_node)
    #   filter <- sprintf(
    #     '{"name": "%s"}',
    #     input$entitySelect
    #     )

    #   r <- nodes$find(
    #     filter,
    #     '{"description":1}'
    #   )
    #   HTML(r$wikitext)

    })

    # output$entityConnections <- renderDataTable({
    #   print("getting connections")
    # #   filter <- sprintf(
    # #     '{ "from" : "%s" }',
    # #     input$entitySelect
    # #   )
    # #   project <- '{ "to" : 1, "type" : 1}'
    # #   rsort <- '{ "type" : 1}'

    #   pipeline <- sprintf(
    #     paste0(
    #         '[',
    #         '{ "$match" : { "name" : "%s"}},',
    #         #start graphLookup
    #         '{"$graphLookup" : {',
    #         '"from" : "nodes",',
    #         '"startWith" : "$edges",',
    #         '"connectFromField" : "edges",',
    #         '"connectToField" : "name",',
    #         '"as" : "connections",',
    #         '"maxDepth" : 1,',
    #         '} }', #end graphLookup
    #         '{ "$project" : { "connections" : 1}} ',
    #         '{ "$unwind" : {"path" : "$connections"}}',
    #         '{ "$project" : { ',
    #         '"node" : "$connections.name"',
    #         '"type" : "$connections.type"',
    #         '}}',
    #         ']'
    #     ),
    #     input$entitySelect
    #   )

    #   r <- nodes$aggregate( pipeline)
      
    #   subset(r, select = c("node", "type"))
    # })

}

shinyApp(ui, server)
