library(dplyr)
library(shiny)
library(miniUI)
library(ggplot2)
library(plotly)

# load data
berlin <- readRDS("Data/berlin.RDS")

# create some options to choose from
nb_list <- berlin$neighbourhood_group %>% unique()

plot_eda <- function(){
    
    ui <- miniPage(
        gadgetTitleBar("Excr: Plotly"),
        miniContentPanel(
            selectInput("select_nb", label = "Select A Neighbourhood : ", choices = c("", nb_list)),
            h5("Price Density by Room Type"),
            plotOutput("price_dst"),
            h5("Host with Multiple Listings"),
            plotOutput("host_vln")
        )
    )
    
    server <- function(input, output, session){
        
        nb <- reactive({
            req(input$select_nb)
            berlin %>% filter(neighbourhood_group == input$select_nb)
        })
        
        # explore price density with respective to room type
        output$price_dst <- renderPlot({
            nb() %>% 
                # filter rightail outlier using Tukey's IQR method
                filter(price < (1.5 * IQR(price) + quantile(price, .75))) %>% 
                ggplot(aes(price, fill = room_type, col = room_type)) + 
                geom_density(alpha = 0.6)
        })
        
        # explore host with multiple listings 
        output$host_vln <- renderPlot({
            nb() %>% 
                ggplot(aes(x = 1, y = calculated_host_listings_count)) + 
                geom_violin(fill = "salmon") + 
                scale_x_continuous(labels = NULL) +
                # log transform scale so that far tail appears narrower
                scale_y_log10(breaks = c(2:10, 20, 30, 50, 100)) + 
                coord_flip()
        })
        
        
    }
    
    runGadget(ui, server)
}
