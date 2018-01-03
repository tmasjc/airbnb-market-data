library(shiny)
library(miniUI)
library(ggplot2)

airbnb_city <- function() {
    
    # get what is in the data directory
    city_list <- dir(path = "data/") %>% gsub(pattern = "_summary\\.RDS$", replacement = "")
    
    # make path list of respective city RDS 
    dat <- sapply(X = city_list, FUN = sprintf, fmt = "data/%s_summary.RDS") %>% 
        lapply(FUN = readRDS) # read data
    
    # assign names to be aligned with input selector
    names(dat) <- toupper(city_list)
    
    ui <- miniPage(
        gadgetTitleBar("Airbnb Rental Market"),
        miniContentPanel(
            selectInput("city", label = "Choose A City:", choices = toupper(city_list)),
            tableOutput("head")
        )
    )
    
    server <- function(input, output, session) {
        
        # select city from list of data frames
        cityInput <- reactive({ dat[[input$city]][1:3] })
        
        output$head <- renderTable({ head(cityInput()) })
    }
    
    runGadget(ui, server)
}