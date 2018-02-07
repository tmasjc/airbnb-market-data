Airbnb Market Data
================

    ## This README is generated from README.Rmd

This is a simple visualization inspired by [InsideAirbnb](http://insideairbnb.com/). Written in R, built on Shiny framework.

Demo can be found at - <https://tmasjc.shinyapps.io/airbnb_market_data/>

![Demo.gif](demo.gif)

------------------------------------------------------------------------

##### Motivation

This project aims to exercise

-   utilizing various `reactivity` features by `Shiny`
-   converting `Rscript` to a command line utility
-   shipping an `R`/`Shiny` data product in a `docker` container (TODO)

*Any constructive feedback, especially on how to do things in a more efficient manner is greatly appreciated.*

------------------------------------------------------------------------

##### How to Import Data?

You can use either 2 ways to import data.

-   Use the command line tool, **"getting\_data.R"** on terminal

        # Run on terminal using bash
        ./getting_data.R

-   OR directly from [InsideAirbnb](http://insideairbnb.com/get-the-data.html)

    Navigate to your desire city section and download files "**listings.csv**" (the summary version). Put your download into the *Data* folder.

------------------------------------------------------------------------

##### Usage of Command Line Utility

Execute `./getting_data.R <city>` to download desire <city> market data.

``` bash
# Cause Vienna waits for you - Billy Joel
./getting_data.R vienna

[1] "Downloading data..."
trying URL 'http://data.insideairbnb.com/austria/vienna/vienna/2017-09-15/visualisations/listings.csv'
Content type 'application/csv' length 1389561 bytes (1.3 MB)
==================================================
downloaded 1.3 MB
```

Use `list` instead of city name to view available cities.

``` bash
# View all cities
./getting_data.R list

 [1] amsterdam         antwerp           asheville         athens           
 [5] austin            barcelona         berlin            boston           
 [9] brussels          chicago           copenhagen        denver           
[13] dublin            edinburgh         geneva            hong-kong        
[17] london            los-angeles       madrid            malaga           
[21] mallorca          manchester        melbourne         montreal         
[25] nashville         new-orleans       new-york-city     northern-rivers  
[29] oakland           paris             portland          quebec-city      
[33] rome              san-diego         san-francisco     santa-cruz-county
[37] seattle           sydney            toronto           trentino         
[41] vancouver         venice            victoria          vienna           
[45] washington-dc  
```

The utility automatially fetches the latest data available (of a city). If you prefer a particular time snapshot, you may use `-m <city>` to list date indexes and specify particular `-i <index>` to download.

``` bash
# First, see what's available for Vienna
./getting_data.R list -m vienna

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
./getting_data.R vienna -i 7

[1] "Downloading data..."
trying URL 'http://data.insideairbnb.com/austria/vienna/vienna/2017-03-08/visualisations/listings.csv'
Content type 'application/csv' length 1140895 bytes (1.1 MB)
==================================================
downloaded 1.1 MB
```

##### Acknowledgments

[Murray Cox](http://www.murraycox.com/) for the amazing work @[InsideAirbnb.com](http://insideairbnb.com/index.html) and his generosity in sharing its data.
