if (!"fs" %in% row.names(installed.packages()))
  install.packages("fs", repos = "https://cran.rstudio.com/")


library(rvest)
library(magrittr)
library(purrr)
library(fs)
library(stringr)
library(dplyr)

files = fs::dir_ls("data/lq")
p = dplyr::progress_estimated(length(files))
index = 0

lq = map_dfr(
  files,
  function(target_file) {
    page = read_html(target_file)
    cat(".")

    
    info = page %>% 
      html_node(xpath = '//*[@id="main-wrapper"]/div[2]/div[3]/div[4]/div/div[3]/div[1]/div[1]/p') %>% 
      html_text() %>% 
      str_split("\n",simplify = TRUE) %>%
      str_split("\n", simplify = T) %>% 
      str_trim() %>% 
      .[. != ""]
    
    latlong = page %>% 
      html_node(".minimap") %>% 
      html_attr("src") %>%
      str_extract("(?<=\\|).*(?=&size)") %>%
      str_split(",", simplify = TRUE)
    
    data_frame(
      file = target_file,
      name = page %>% html_node("h1") %>% html_text(),
      address = paste(info[1],info[2]),
      phone = info[3] %>% str_replace("Phone: ",""),
      fax = info[4] %>% str_replace("Fax: ",""),
      lat = latlong[1] %>% as.double(),
      long = latlong[2] %>% as.double()
    )
  }
)

save(lq, file = "data/lq.Rdata")