#!/usr/local/bin/Rscript --vanilla

source("helpers.R")

# Convert to Command Line Utility -----------------------------------------

library(methods)
library(argparser)

p <- arg_parser(description = "Getting Airbnb Market Data")

# Positional argument
p <- add_argument(p, "download", help = "a named city to download or 'list' to show available cities")

# Optional argument
p <- add_argument(p, "--index", help = "select by date index", flag = TRUE)

# Parse argument
argv <- parse_args(p)
    
if(as.character(argv$download) == "list"){
    
    load_packages()
    
    if(file.exists("Cache/webpage.xml")){
        e$xml <- read_xml("Cache/webpage.xml", as_html = TRUE)
        get_metadata()    
    }else{
        get_xml()
        get_metadata()
    }
    
    get_city_list()
    
}else{
    
    load_packages()
    
    if(file.exists("Cache/webpage.xml")){
        e$xml <- read_xml("Cache/webpage.xml", as_html = TRUE)
        get_metadata()    
    }else{
        get_xml()
        get_metadata()
    }
    
    is_valid(argv$download)
    
    download_data(argv$download)
    
}