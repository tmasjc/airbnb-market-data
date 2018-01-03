source("header.R")


# Load Data ---------------------------------------------------------------



# Helper Function ---------------------------------------------------------

# create a box functional (function of function) with width default to NULL
nbox <- function(...){shinydashboard::box(width = NULL, ...)}

# UI ----------------------------------------------------------------------

header <- dashboardHeader(
    title = "Airbnb Market Overview"
)

body <- dashboardBody(
    # custom css put here
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")  
    ),
    # 9 - 3 column split
    fluidRow(
        column(width = 9,
               nbox(solidHeader = TRUE),
               nbox(includeMarkdown("about.md"))
        ),
        column(width = 3,
               nbox(tags$h5("Select A City")),
               nbox(tags$h5("Price Density by Room Type")),
               nbox(tags$h5("Top Host by Listings"))
        )
    )
)

# UI Components are here
ui <- dashboardPage(
    header,
    dashboardSidebar(disable = TRUE),
    body
)



# Server ------------------------------------------------------------------


server <- function(input, output, session){
    
    
    
}

# run App
shinyApp(ui = ui, server = server)





