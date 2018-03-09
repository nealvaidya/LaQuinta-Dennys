if (!"fs" %in% row.names(installed.packages()))
  install.packages("fs", repos = "https://cran.rstudio.com/")

library(rvest)
library(magrittr)
library(purrr)
library(fs)
library(stringr)
library(dplyr)

files = fs::dir_ls("data/dennys")

#Special functions

fix_address = function(address){ #This function trims off the "US " that appears at the start of addresses when we scrape them
  substr(address, 3, nchar(address))
}

#Building the data frame
index = 0

dennys = map_dfr(
  files,
  function(file){
    
    cat(".")
    page = read_html(file)
    
    googleMapsURL = page %>%
      html_nodes("div>link") %>%
      html_attr("href")
    
    coords = googleMapsURL %>%
      str_extract("(?<=center=).*(?=&channel)") %>% #extracts the part of the url that gives the coordinates
      str_split("%2C", simplify = TRUE) #removes the part in the middle separating the coordinates, and splits it into a vector of two characters values
    
    data_frame(
      URL = file,
      
      'Location Name' = page %>%
        html_nodes("#location-name") %>%
        html_text() %>%
        tools::toTitleCase(),
      
      Address = page %>%
        html_nodes("#address") %>%
        html_text() %>%
        fix_address(),
      
      'Phone Number' = page %>%
        html_nodes("#telephone") %>%
        html_text(),
      
      Latitude = coords[1] %>% as.double(),
      
      Longitude = coords[2] %>% as.double()
    )
  }
)

save(dennys, file = "data/dennys.Rdata")