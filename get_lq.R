if (!"fs" %in% row.names(installed.packages()))
  install.packages("fs", repos = "https://cran.rstudio.com/")

library(rvest)
library(purrr)
library(magrittr)
library(dplyr)
library(fs)



base_url = "http://www2.stat.duke.edu/~cr173/lq/www.lq.com/en/findandbook/"

page = read_html(paste0(base_url,"hotel-listings.html"))

urls = page %>% 
  html_nodes("#hotelListing .col-sm-12 a") %>% 
  html_attr("href") %>% 
  discard(is.na) %>%
  paste0(base_url, .)


output_dir = "data/lq"
fs::dir_create(output_dir, recursive=TRUE)


p = dplyr::progress_estimated(length(urls))


purrr::walk(
  urls,
  function(url) {
    download.file(url, destfile = fs::path(output_dir, fs::path_file(url)), quiet = TRUE)
    
    p$tick()$print()
  }
)
