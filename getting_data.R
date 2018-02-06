#!/usr/bin/env Rscript --vanilla

source("helpers.R")

# Convert to Command Line Utility -----------------------------------------

library(magrittr)
library(methods)
library(argparser)
library(knitr)

options(knitr.table.format = "markdown")

p <- arg_parser(description = "Getting Airbnb Market Data")

# Positional argument
p <- add_argument(p, "target", help = "a named city (e.g. vienna) to download or 'list' to get available cities")

# Optional argument
argv <- add_argument(p, "--more", help = "display full info of a city") %>% 
    # p <- add_argument(p, "--short", help = "display short list", flag = TRUE) %>% 
    add_argument("--long", help = "display list in long format (city full name)", flag = TRUE) %>% 
    add_argument("--index", help = "select by date index", default = 1) %>% 
    parse_args()


    
if(as.character(argv$target) == "list"){
    
    load_packages()
    
    if(file.exists("Cache/webpage.xml")){
        e$xml <- read_xml("Cache/webpage.xml", as_html = TRUE)
        get_metadata()    
    }else{
        get_xml()
        get_metadata()
    }
    
    if(!is.na(argv$more)){
        get_available_date(argv$more) %>% knitr::kable(col.names = c("City", "Dates", "Index"))
    }else{
        if(argv$long){
            e$city_full %>% knitr::kable(col.names = c("Cities"))
        }else{
            e$cities$City
        }
    }
    
}else{
    
    load_packages()
    
    if(file.exists("Cache/webpage.xml")){
        e$xml <- read_xml("Cache/webpage.xml", as_html = TRUE)
        get_metadata()    
    }else{
        get_xml()
        get_metadata()
    }
    
    download_data(argv$target, date.index = argv$index)
    
}
