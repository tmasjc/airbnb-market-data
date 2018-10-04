Airbnb Market Data
================

    ## This README is generated from README.Rmd

This is a simple visualization inspired by [InsideAirbnb](http://insideairbnb.com/). Written in R, built on [Shiny](https://shiny.rstudio.com/) framework.

Demo can be found at - <https://tmasjc.shinyapps.io/airbnb_market_data/>

![Demo.gif](demo.gif)

Motivation
----------

This project aims to demonstrate

-   reactivity of Shiny framework
-   converting Rscript to a command line utility
-   shipping Shiny data product with Docker

Any constructive feedback is greatly appreciated.

Download Data
-------------

This project ships with 2 cities data (Berlin and Vienna). You may use the command line tool, `download_csv.R` to import more data.

``` bash
# Make sure it is executable
chmod +x download_csv.R
# Download data for Rome
./download_csv.R Rome
```

Of course, you can also download the data manually from **[InsideAirbnb](http://insideairbnb.com/get-the-data.html)**. Navigate to your desire city section and download file named "listings.csv" (the summary version). Put your download into the *Data/* folder.

Usage of Command Line Tool
--------------------------

Execute `./download_csv.R {city}` to download desire {city} market data.

``` bash
# Cause Vienna waits for you - Billy Joel
./download_csv.R vienna

[1] "Downloading data..."
trying URL 'http://data.insideairbnb.com/austria/vienna/vienna/2017-09-15/visualisations/listings.csv'
Content type 'application/csv' length 1389561 bytes (1.3 MB)
==================================================
downloaded 1.3 MB
```

Use `list` instead of a city name to view all available cities.

``` bash
# View all available cities
./download_csv.R list

 [1] amsterdam         antwerp           asheville         athens           
 [5] austin            barcelona         berlin            boston           
 [9] brussels          chicago           copenhagen        denver           
 ...
```

The utility automatically fetches the latest data available. If you prefer a particular snapshot, you may use `-s {city}` to list date indexes and specify particular `-i <index>` to download.

``` bash
# First, see what's available for Vienna
./download_csv.R list -s vienna

|City   |Dates      |Index |
|:------|:----------|:-----|
|vienna |2017-09-15 |1     |
|vienna |2017-08-11 |2     |
|vienna |2017-07-10 |3     |
|vienna |2017-06-07 |4     |
|vienna |2017-05-09 |5     |
|vienna |2017-04-09 |6     |
|vienna |2017-03-08 |7     |
...

# Then, you may specify index to download
# i.e if you desire snapshot on 2017-03-08, choose 7
./download_csv.R vienna -i 7

[1] "Downloading data..."
trying URL 'http://data.insideairbnb.com/austria/vienna/vienna/2017-03-08/visualisations/listings.csv'
Content type 'application/csv' length 1140895 bytes (1.1 MB)
==================================================
downloaded 1.1 MB
```

Deployment
----------

This Shiny app is shipped with Docker, built on [rocker/tidyverse](https://hub.docker.com/r/rocker/tidyverse/) image.

``` bash
# from this repo
git clone git@github.com:tmasjc/Airbnb_Market_Data.git

# move inside directory
cd Airbnb_Market_Data

# name your image
# it may take a while to build
docker build -t airbnb_market_data .

# start container
docker run -dp 3838:3838 airbnb_market_data

## You are set. Go to localhost:3838/airbnb_market_data to view application. 
```

Or you can simply deploy it to Shiny server as per usual.

Acknowledgments
---------------

[Murray Cox](http://www.murraycox.com/) for the amazing work at [InsideAirbnb.com](http://insideairbnb.com/index.html) and his generosity in sharing these data.
