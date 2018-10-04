#!/usr/bin/env Rscript --vanilla
library(magrittr)
library(methods)
library(argparser)
library(knitr)

# Set up new environment
e <- new.env()

# Load Packages ----------------------------------------------------------

load_packages <- function(){
    
    pkgs <- c("dplyr", "rvest", "stringr")
    libs <- lapply(pkgs, library, character.only = TRUE, quietly = TRUE, warn.conflicts = FALSE)
    
}


# Extract XML -------------------------------------------------------------


get_xml <- function(){
    
    # Data source URL
    url <- "http://insideairbnb.com/get-the-data.html"
    
    # Test internet connection is available by extracting xml
    print("Extracting webpage... Please hold on...")
    
    e$xml <- tryCatch(
        read_html(url),
        error = function(e) {
            write(paste(Sys.time(), as.character(e)), "error_log.txt", append = TRUE)
            print("Could not establish link with source. See error log.")
            return(NULL)
        }
    )
    
    if(!is.null(e$xml)){
        print("Obtained source successfully.")
        write_xml(e$xml, "Cache/webpage.xml")
    }
    
}


# Getting Metadata ------------------------------------------------------------


get_metadata <- function(){
    
    # City in full name
    e$city_full <- e$xml %>% html_nodes(css = "h2") %>% html_text()    
    
    # Table CSS
    e$table_css <- e$xml %>% html_nodes("table") %>% html_attrs()
    
    # Available cities
    e$cities <- lapply(e$table_css, FUN = str_extract, pattern = "\\s{1}([a-z]|-)*$") %>% str_trim() %>% as.data.frame()
    names(e$cities) <- "City"
    e$cities <- e$cities %>% cbind(Index = 1:nrow(.))
    
}


# Helper Functions ---------------------------------------------------------------


# Check if given city can be found
is_valid <- function(city = NULL){
    
    if(is.null(c(city))){
        return("Require at least city name or index to be specified.")
    }
    
    if(is.character(city)){
        
        city <- tolower(city)
        
        if(city %in% e$cities$City){
            ct <- city
        }else{
            stop(sprintf("City ‘%s’ not found.", city))
        }
    }
    
    if(is.numeric(city)){
        
        if(city %in% e$cities$Index){
            ct <- e$cities$City[city]
        }else{
            stop(sprintf("Index %s is out of bound.", as.character(city)))
        }
    }
    
    if(!is.null(ct)){ return(ct) }
    
}

# Get data download urls
get_download_urls <- function(city){
    
    e$xml %>% html_nodes(paste0(".", is_valid(city), " a")) %>% html_attr("href")
    
}

# List available dates from data source
get_available_date <- function(city){
    
    ymd <- is_valid(city) %>% get_full_info() %>% pull(ymd) %>% unique() %>% sort(decreasing = TRUE) 
    
    df <- cbind(rep(city, length(ymd)), as.character(ymd), 1:length(ymd)) %>% as.data.frame()
    
    # print.data.frame(df, row.names = FALSE)
    df
    
}

# Get description of a particular city data
get_full_info <- function(city){
    
    ref <- which(e$cities$City == is_valid(city)) %>% e$table_css[[.]]
    
    df <- e$xml %>% html_nodes(css = gsub(ref, pattern = '\\s+', replacement = ".")) %>% html_table() %>% bind_rows()
    
    df <- df %>% select(-Description) %>% mutate(ymd = as.Date(`Date Compiled`, format = "%d %b, %Y"))
    
    df %>% cbind(url = get_download_urls(city))
    
}

# Download data
download_data <- function(city, date.index = 1, method = "auto"){
    
    # retrieve url
    url <- city %>% get_full_info() %>% 
        filter(`File Name` == "listings.csv") %>% 
        arrange(-as.numeric(ymd)) %>% 
        pull(url) %>% 
        as.character()
    
    # start downloading
    print("Downloading data...")
    # print(url[date.index])
    tryCatch(url[date.index] %>% download.file(destfile = paste0("Data/", city, ".csv"), method = method), finally = "Success")
    
}

# Convert to Command Line Utility -----------------------------------------

options(knitr.table.format = "markdown")

p <- arg_parser(description = "Download CSV data")

# Positional argument
p <- add_argument(p, "target", help = "city name (e.g. vienna) or 'list' to get available cities")

# Optional argument
argv <- add_argument(p, "--snapshot", help = "list snapshots in a table format") %>% 
    # p <- add_argument(p, "--short", help = "display short list", flag = TRUE) %>% 
    add_argument("--long", help = "display list in long format (city full name)", flag = TRUE) %>% 
    add_argument("--index", help = "select by specifying date index", default = 1) %>% 
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
    
    if(!is.na(argv$snapshot)){
        get_available_date(argv$snapshot) %>% knitr::kable(col.names = c("City", "Dates", "Index"))
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
