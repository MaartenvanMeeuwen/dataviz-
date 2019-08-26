library(tidyverse)  
library(xml2)
library(rvest)
library(stringr)   
library(rebus)     
library(lubridate)
library(magrittr)
library(stringi)
library(furrr)
library(rvest)
library(magrittr)

theme_set(theme_classic()) 
register_google(key = "")

url = 'https://www.zorgkaartnederland.nl/ggz'
urls = c()
for (i in 1:85){
  urls[i] = paste0(url,"/pagina", i)
}

get_locations = function(url) {
  html = read_html(url)
  html %>% 
    html_nodes(".context") %>% 
    html_text() %>% 
    str_trim() %>% 
    unlist()
}

get_org = function(url) {
  html = read_html(url)
  obj = html %>% 
    html_nodes(".media-body") %>% 
    rvest::html_text() %>%
    stringr::str_trim() %>% 
    stringr::word(., sep = "\\\n")
  obj
}


get_rating = function(url){
  html = read_html(url)
  html %>% 
    html_nodes(".fractional_number_holder") %>% 
    html_text() %>% 
    str_trim() %>% 
    str_sub(start  = 1, end = 5) %>% as.numeric()
}

get_nr_reviews = function(url){
  html = read_html(url)
  html %>% 
    html_nodes(".rating_value") %>% 
    rvest::html_text() %>% 
    as.numeric()
}

organisations = urls %>% purrr::map(get_org) %>% purrr::flatten_chr()
locations = urls %>% purrr::map(get_locations) %>% purrr::flatten_chr()
ratings = urls %>% purrr::map(get_rating) %>% purrr::flatten_dbl()
nr_review = urls %>% purrr::map(get_nr_reviews) %>% purrr::flatten_dbl()


df = tibble(locatie = locations, 
            organisatie = organisations,
            rating = ratings,
            nr_reviews = nr_review)
saveRDS(df, "df.Rds")
df = readRDS("df.Rds")


locations_pc <- paste(df$organisatie, df$locatie) %>% geocode(output = "all")
saveRDS(locations_pc, "data/locations_pc.Rds")

coords_lat = c()
coords_lng = c()

for (i in 1:length(locations_pc)){
  full = locations_pc[[i]]$results[[1]]$formatted_address
  if(is.null(full)) next 
  coords_lat[i] = locations_pc[[i]]$results[[1]]$geometry$location$lat
  coords_lng[i] = locations_pc[[i]]$results[[1]]$geometry$location$lng
}

coords = cbind(lat = coords_lat, lng = coords_lng)
  
ad = c()
for (i in 1:length(locations_pc)){
  full = locations_pc[[i]]$results[[1]]$formatted_address
  if(is.null(full)) next 
  ad[i] = full
}



df$pc = stri_extract_last(ad, regex = "\\d{4}") %>% as.numeric() 
df = cbind(df, coords) %>% data.frame() %>% filter(lng > 0 )
df$PC3 = str_sub(df$pc, start = 1, end = 3) %>% as.numeric()

df %>% ggplot(aes(x = lng, y = lat )) + geom_point()

write.csv(df, "data/locations.csv")


#### Numbers per municipality 
url = "https://www.zorgkaartnederland.nl/overzicht/plaatsen/ggz"
html = read_html(url)
institutions = html %>% html_nodes(".list-group-item") %>% html_text()

cities - word(institutions, 1, sep = "\\(")
cities = strsplit(institutions, "[()]") %>% map(1)

aantal = strsplit(institutions, "[()]") %>% map(2)

tibble(
  gemeentes = str_sub(cities, 1, str_length(cities)-1) %>% unlist(),
  aantal = aantal %>% unlist() %>% as.numeric())