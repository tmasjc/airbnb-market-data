source("header.R")


# Load Data ---------------------------------------------------------------
vienna <- readRDS("Data/vienna_summary.RDS")

# For dropdown choices
area <- unique(vienna$neighbourhood)

# Helper Function ---------------------------------------------------------

# For Leaflet's markers color
pal <- colorFactor(brewer.pal(3, "Set1"), domain = vienna$room_type)

# Modify ggplot theme
old <- theme_set(theme_light() + 
                     theme(legend.position = "none", axis.title = element_text(family = "mono")))

# UI ----------------------------------------------------------------------

ui <- fillPage(
    
    # Custom CSS goes here
    tags$head(
        tags$style(HTML("
                .leaflet-control.legend {
                    font-family: 'Futura', mono, sans;
                    width: 12em;
                    margin-right: 20px;
                }
            "))
    ),
    
    # Theme selection
    theme = shinythemes::shinytheme("yeti"),
    
        # Upper half
        leafletOutput("map", height = '50%'),
        hr(),
    
        # Lower half
        fluidPage(
            h4("Hello World", style = "text-align: center;"),
            sidebarLayout(
                sidebarPanel(width = 2, 
                       selectInput("area", label = "Choose A Neighbourhood", choices = c("", area)),
                       verbatimTextOutput("roomInBounds")),
                mainPanel(width = 10,
                    column(6, plotlyOutput("price")),
                    column (6, plotlyOutput("host"))
                )
            )
        )
)


# Server ------------------------------------------------------------------

server <- function(input, output, session){
    
    # Geography concentration goes here
    output$map <- renderLeaflet({
        
        # Create a base map
        leaflet(vienna) %>% 
            addProviderTiles(providers$CartoDB.Positron) %>% 
            fitBounds(lng1 = ~min(longitude), lat1 = ~min(latitude), lng2 = ~max(longitude), lat2 = ~max(latitude)) %>% 
            addLegend("bottomleft", pal = pal, values = ~room_type, title = "Room Type") %>% 
            # For resetting zoom
            addEasyButton(
                easyButton("fa-arrows-alt", title = "Reset Zoom", 
                           onClick = JS("function(btn, map){ map.setZoom(14); }"))
            )
    })
    
    # Subset neighbourhood, update when selection changes
    df <- reactive({
        req(input$area)
        subset(vienna, neighbourhood == input$area)
    })
    
    # Prepare neighbourhood bounding lng and lat for Leaflet proxy
    bounds <- reactive({
        list(
            lng = range(df()$longitude),
            lat = range(df()$latitude)
        )
    })
    
    # Update data points within current bounding box
    bounded_area <- reactive({
        
        req(input$map_bounds, cancelOutput = TRUE)
        
        # Get map boundary from Leaflet
        bounds <- input$map_bounds
        latRng <- range(bounds$north, bounds$south)
        lngRng <- range(bounds$east, bounds$west)
        
        # Filter area given boundary
        subset(df(), latitude >= latRng[1] & latitude <= latRng[2] & longitude >= lngRng[1] & longitude <= lngRng[2])
        
    })
    
    # Leaflet proxy to modify map aspect (add markers here)
    observeEvent(input$area, {
        leafletProxy("map", data = df()) %>% 
            clearMarkers() %>% 
            addCircleMarkers(lng = ~longitude, lat = ~latitude, color = ~pal(room_type), radius = 5, stroke = FALSE, fillOpacity = 0.5) %>% 
            # Fit bounding box based on neighbourhood
            fitBounds(lng1 = bounds()$lng[1], lng2 = bounds()$lng[2], lat1 = bounds()$lat[1], lat2 = bounds()$lat[2])
    })
    
    # Calculate total of respective room type (within bounding box)
    output$roomInBounds <- renderPrint({
        
        # Total count by room type
        #with(bounded_area(), ftable("Room Type" = room_type))
        nrow(bounded_area())
        
    })
    
    ## Preventing frequent invalidation signals 
    bounded_area_d <- bounded_area %>% debounce(500)
    
    # Price distribution goes here
    output$price <- renderPlotly({
        
        p <- bounded_area_d() %>% 
            # filter right tail outlier using Tukey's IQR method
            filter(price < (1.5 * IQR(price) + quantile(price, .75))) %>% 
            ggplot(aes(price, fill = room_type, col = room_type, text = "")) +
            geom_density(alpha = 0.6) + 
            labs(x = "Price", y = "Kernel Density Estimation")
        
        ggplotly(p, tooltip = c("text"))
    })
    
    # Listings per host goes here
    output$host <- renderPlotly({
        
        p <- bounded_area_d() %>% 
            group_by(host_id, host_name) %>% 
            summarise(n = n_distinct(id)) %>% 
            # Do a count on n (how many hosts own 3, 4..n houses?)
            ungroup() %>% count(n) %>% 
            filter(n > 1) %>% 
            ggplot(aes(n, nn, text = paste("# Listings:", n, "\n# Hosts:", nn))) + 
            # geom_hline(aes(yintercept = 0), lty = 3) +
            geom_bar(stat = 'identity', width = 0.1, fill = "skyblue", alpha = 0.6) + 
            geom_point(size = 3, col = "royalblue") +
            scale_x_continuous(breaks = scales::pretty_breaks(n = 5)) +
            scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
            coord_flip() + 
            labs(x = "# Listings", y = "# Hosts with y listings")
        
        ggplotly(p, tooltip = c("text"))

    })
    
}

# run App
shinyApp(ui = ui, server = server)





