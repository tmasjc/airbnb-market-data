library(shiny)
library(miniUI)
library(ggplot2)

airbnb_city <- function() {
    
    # get what is in the data directory
    city_list <- dir(path = "data/") %>% gsub(pattern = "_summary\\.RDS$", replacement = "")
    
    # make path list of respective city RDS, and then read data
    cities <- sapply(X = city_list, FUN = sprintf, fmt = "data/%s_summary.RDS") %>% 
        lapply(FUN = readRDS) 
    
    # assign names to be aligned with input selector
    names(cities) <- toupper(city_list)
    
    ui <- miniPage(
        gadgetTitleBar("Airbnb Rental Market"),
        miniContentPanel(
            selectInput("city", label = "Select A City : ", choices = toupper(city_list), selected = "BERLIN"),
            uiOutput("subcity"),
            tableOutput("head")
        )
    )
    
    server <- function(input, output, session) {
        
        # select from a list of data frames
        selectCity <- reactive({ 
            cities[[input$city]] 
        })
        
        # neighbourhood (subcity) selection
        subcity <- reactive({ 
            unique(selectCity()[["neighbourhood"]]) 
        })
        
        # generate subcity selection based on selected city (dynamic UI)
        output$subcity <- renderUI({
            tagList(
                selectInput("neighbourhood", label = "Select A Neighbourhood : ", choices = list("All" = c("--", subcity())))
            )
        })
        
        # produce head of selected area
        output$head <- renderTable({
            if(input$neighbourhood == "--"){
                head(selectCity())[1:3]
            }else{
                (selectCity() %>% filter(neighbourhood == input$neighbourhood) %>% head())[1:3]
            }
        })
    
    }
    
    runGadget(ui, server)
}