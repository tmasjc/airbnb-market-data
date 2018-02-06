library(dplyr)
library(shiny)
library(leaflet)
library(RColorBrewer)
library(miniUI)

plot_leaflet <- function() {
    
    vienna <- readr::read_csv("Data/vienna.csv") %>% as.tibble()
    
    # For dropdown choices
    nb <- unique(vienna$neighbourhood)
    
    # For Leaflet markers' color
    pal <- colorFactor(brewer.pal(3, "Set1"), domain = vienna$room_type)
    
    ui <- miniPage(
        gadgetTitleBar("Leaflet"),
        miniContentPanel(
            leafletOutput("map"),
            tags$hr(),
            selectInput("nb", label = "Choose A Neighbourhood", choices = c("", nb)),
            verbatimTextOutput("roomInBounds")
            
        )
    )
    
    server <- function(input, output, session){
        
        # Create a map (static aspect of Leaflet)
        output$map <- renderLeaflet({
            leaflet(vienna) %>% 
                addProviderTiles(providers$CartoDB.Positron) %>% 
                fitBounds(lng1 = ~min(longitude), lat1 = ~min(latitude), lng2 = ~max(longitude), lat2 = ~max(latitude)) %>% 
                addLegend("bottomright", pal = pal, values = ~room_type, title = "Room Type") %>% 
                addEasyButton(easyButton(
                    icon="fa-arrows-alt", title="Reset Zoom",
                    onClick=JS("function(btn, map){ map.setZoom(14); }")))
        })
        
        # Subset data based on user selection
        filteredData <- reactive({
            req(input$nb)
            vienna[vienna$neighbourhood == input$nb, ]
        })
        
        # Prepare neighbourhood bounding lng and lat for Leaflet proxy
        bounds <- reactive({
            list(
                lng = range(filteredData()$longitude),
                lat = range(filteredData()$latitude)
            )
        })
        
        # Leaflet proxy
        observe({
            leafletProxy("map", data = filteredData()) %>% 
                clearMarkers() %>% 
                addCircleMarkers(lng = ~longitude, lat = ~latitude, color = ~pal(room_type), radius = 5, stroke = FALSE, fillOpacity = 0.5) %>% 
                # Fit bounding box based on neighbourhood
                fitBounds(lng1 = bounds()$lng[1], lng2 = bounds()$lng[2], lat1 = bounds()$lat[1], lat2 = bounds()$lat[2])
        })
        
        # Calculate total of respective room type (within bounding box)
        output$roomInBounds <- renderPrint({
            
            req(input$map_bounds)
            
            bounds <- input$map_bounds
            latRng <- range(bounds$north, bounds$south)
            lngRng <- range(bounds$east, bounds$west)
            
            df <- subset(filteredData(),
                   latitude >= latRng[1] & latitude <= latRng[2] &
                       longitude >= lngRng[1] & longitude <= lngRng[2])
            
            df %>% group_by("Room Type" = room_type) %>% 
                summarise("Total" = n())
            
        })
    }
    
    runGadget(ui, server)
}