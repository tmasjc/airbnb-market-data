#!/usr/local/bin/Rscript --vanilla

library(dplyr)
library(rvest)
library(stringr)


# Extract XML -------------------------------------------------------------


# Data source URL
url <- "http://insideairbnb.com/get-the-data.html"

# Test internet connection is available by extracting xml
print("Extracting webpage... Please hold on...")

src <- tryCatch(
    read_html(url),
    error = function(e) {
        write(paste(Sys.time(), as.character(e)), "error_log.txt", append = TRUE)
        print("Could not establish link with source. See error log.")
        return(NULL)
    }
)

if(!is.null(src)){
    print("Obtained source successfully.")
}


# Getting Metadata ------------------------------------------------------------


# Initiate an empty vector to store city list if necessary
e <- new.env()

# City in full name
e$city_full <- src %>% html_nodes(css = "h2") %>% html_text()    

# Table CSS
e$table_css <- src %>% html_nodes("table") %>% html_attrs()

# Available cities
e$cities <- lapply(e$table_css, FUN = str_extract, pattern = "\\s{1}([a-z]|-)*$") %>% str_trim() %>% as.data.frame()
names(e$cities) <- "City"
e$cities <- e$cities %>% cbind(Index = 1:nrow(.))



# Helper Functions ---------------------------------------------------------------

# Check if given city can be found
is_valid <- function(city = NULL){
    
    if(is.null(c(city))){
        return("Require at least city name or index to be specified.")
    }
    
    if(is.character(city)){
        if(tolower(city) %in% e$cities$City){
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

# Return all available cities
get_city_list <- function(){
    
    e$city_full
    
}

# Get data download urls
get_download_urls <- function(city){
    
    src %>% html_nodes(paste0(".", city, " a")) %>% html_attr("href")
    
}

# List available dates from data source
list_date <- function(city){
    
    df <- is_valid(city) %>% get_full_info() %>% pull(dmy) %>% unique() %>% sort(decreasing = TRUE) %>% as.data.frame()
    
    df <- df %>% cbind(i = 1:nrow(df))
    
    print.data.frame(df, row.names = FALSE)
    
}

# Get description of a particular city data
get_full_info <- function(city){
    
    ref <- which(e$cities$City == is_valid(city)) %>% e$table_css[[.]]
    
    df <- src %>% html_nodes(css = gsub(ref, pattern = '\\s+', replacement = ".")) %>% html_table() %>% bind_rows()
    
    df <- df %>% select(-Description) %>% mutate(dmy = as.Date(`Date Compiled`, format = "%d %b, %Y"))
    
    df %>% cbind(url = get_download_urls(city))
    
}

# Download data
download_data <- function(city, date.index = 1, format = "listings.csv", file.name = "", file.ext = ".csv", method = "auto"){
    
    # retrieve url
    url <- city %>% get_full_info() %>% 
                filter(`File Name` == format) %>% 
                arrange(-as.numeric(dmy)) %>% 
                pull(url) %>% 
                as.character()
    
    # start downloading
    print("Downloading data...")
    url[date.index] %>% download.file(destfile = paste0("Data/", file.name, file.ext), method = method)
    
}






