if (!"fs" %in% row.names(installed.packages()))
  install.packages("fs", repos = "https://cran.rstudio.com/")


library(rvest)
library(magrittr)
library(purrr)
library(fs)
library(stringr)
library(dplyr)

files = fs::dir_ls("data/lq")

lq = map_dfr(files,
             function(target_file) {
               page = read_html(target_file)
               cat(".")
               
               
               info = page %>%
                 html_node(xpath = '//*[@id="main-wrapper"]/div[2]/div[3]/div[4]/div/div[3]/div[1]/div[1]/p') %>%  # used the copy XPath function in chrome
                 html_text() %>%
                 str_split("\n", simplify = TRUE) %>% # split info chunk by line
                 str_trim() %>% # remove padding whitespace
                 .[. != ""] # remove the empty lines from the info chunk
               
               latlong = page %>%
                 html_node(".minimap") %>% # element that contains GoogleMaps API call
                 html_attr("src") %>% # url of API call
                 str_extract("(?<=\\|).*(?=&size)") %>% # lat long is contained between a | and & character
                 str_split(",", simplify = TRUE) # splits lat and long by ,
               
               amenities = page %>% html_nodes(".pptab_contentL li") %>% html_text()
               
               data_frame(
                 file = target_file, # for debugging and exploring the data
                 name = page %>% html_node("h1") %>% html_text(),
                 address = paste(info[1], info[2]),
                 phone = info[3] %>% str_replace("Phone: ", ""), # remove the text, leave the number
                 fax = info[4] %>% str_replace("Fax: ", ""), # remove the text, leave the number
                 lat = latlong[1] %>% as.double(),
                 long = latlong[2] %>% as.double(),
                 pool = any(str_detect(amenities, "p|Pool")), # do any of the amenities mention a pool?
                 breakfast = any(str_detect(
                   amenities, "Free( Bright Side)? Breakfast" # does the hotel ffer free breakfast? Bright Side is La Quinta branding
                 ))
               )
             })

save(lq, file = "data/lq.Rdata")

