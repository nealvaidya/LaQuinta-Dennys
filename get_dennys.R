if (!"fs" %in% row.names(installed.packages()))
  install.packages("fs", repos = "https://cran.rstudio.com/")


library(rvest)
library(fs)

base_url = "http://www2.stat.duke.edu/~cr173/dennys/locations.dennys.com/"

page = read_html(paste0(base_url,"index.html"))

# Basically goes through each of these, and assumes they go three nested links deep. 
# If they don't, each level of the just returns the level that was passed into it. 
# So for example, Aurora Colorado goes CO>Aurora>the individual restaurants, 
# while delware is just DE, since theres only one Denny's Deleware. So every time we try to 
# get the next level underneath DE (first cities, then locations) we just throw back the DE link

states = page %>% html_nodes(".c-directory-list-content-item-link") %>% html_attr("href")

cities = sapply(states,
                function(state){
                  city = read_html(paste0(base_url,state)) %>% 
                    html_nodes(".c-directory-list-content-item-link") %>% 
                    html_attr("href")
                  if(length(city)==0)
                    return(state)
                  return(city)
                }) %>% unlist()

locations = sapply(cities, 
                   function(city){
                     state = substr(city, 1, 2)
                     location = read_html(paste0(base_url,city)) %>% 
                       html_nodes(".c-location-grid-item-title a") %>% 
                       html_attr("href")
                     if(length(location)==0)
                       return(city)
                     location = paste(state, location, sep = "/") #make sure that state is included in the URL
                     return(location)
                   }) %>% unlist()





output_dir = "data/dennys"
fs::dir_create(output_dir, recursive=TRUE)

p = dplyr::progress_estimated(length(locations))

purrr::walk(
  locations,
  function(location) {
    download.file(location, destfile = fs::path(output_dir, fs::path_file(location)), quiet = TRUE)
    
    p$tick()$print()
  }
)


download.file(paste0(base_url,"index.html"), destfile = fs::path(output_dir, "index.html"), quiet=TRUE)

".c-directory-list-content-item"