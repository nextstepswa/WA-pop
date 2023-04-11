################################################################################################

# County and City codes from GSA for matching across WA datasets

################################################################################################

library(readxl)
library(tidyverse)

url <- "https://www.gsa.gov/cdnstatic/FRPP_GLC_-_United_States_fEB_16_20233.xlsx"
destfile <- (here::here("data-raw", "FRPP_GLC_United_States_fEB_16_20233.xlsx"))
curl::curl_download(url, destfile)

geo.codes <- readxl::read_excel(destfile) %>%
  filter(`State Name` == "WASHINGTON") %>%
  select(`City Code`:`County Name`) %>%
  mutate(city.code = as.numeric(`City Code`),
         county.code = as.numeric(`County Code`))

# Consolidate / Remove duplicates
county.codes <- geo.codes %>% select(county.code, county.name = `County Name`) %>%
  group_by(county.code) %>%
  summarise(county.code = first(county.code),
            county.name = first(county.name))

# Some cities have the same codes (like Friday Harbor and Fredrickson)
city.codes <- geo.codes %>% select(city.code, city.name = `City Name`) %>%
  group_by(city.name) %>%
  summarise(city.code = first(city.code),
            city.name = first(city.name))


save.image(here::here("data-outputs", "WA_GSA_geocodes.rda"))
