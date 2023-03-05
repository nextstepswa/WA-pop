#
# OFM postcensal estimates for WA State
#

library(readxl)
library(tidyverse)

## "Filter" variable identifies level, 1 is county total

url <- "https://ofm.wa.gov/sites/default/files/public/dataresearch/pop/april1/hseries/ofm_april1_postcensal_estimates_pop_1960-present.xlsx"
destfile <-  here::here("data-raw", "ofm_wa_pop_postcensal.xlsx")
curl::curl_download(url, destfile)
wa_pop_raw <- read_excel(destfile, sheet = "Population", skip = 3)

## 2012-2021 for matching to OFM NIBRS data

wa_popcounties_wide <- wa_pop_raw %>%
  filter(Filter == 1 | Jurisdiction == "State Total") %>%
  select(Jurisdiction, matches("2012|2013|2014|2015|2016|2017|2018|2019|2020|2021")) %>%
  rename_at(vars(starts_with("2")), ~sub(" Postcen.*tion.*", "", .)) %>%
  rename_at(vars(contains("2020")), ~sub(".*$", "2020", .)) %>%
  rename_at(vars(starts_with("2")), ~sub("^", "Y", .)) %>%
  mutate(across(starts_with("Y"), ~as.numeric(.)),
         pct.chg = Y2021/Y2012 - 1)

## just the state totals by year
wa_poptotal_long   <- wa_pop_raw %>%
  filter(Jurisdiction == "State Total") %>%
  select(matches("2012|2013|2014|2015|2016|2017|2018|2019|2020|2021")) %>%
  pivot_longer(everything(),
               names_to = "Year",
               values_to = "StatePop") %>%
  mutate(Year = sub("Postcen.*tion.*", "", Year),
         Year = sub("Cen.*tion", "", Year),
         Year = as.numeric(Year),
         StatePop = as.numeric(StatePop))

save.image(here::here("data-outputs", "WA_pop.rda"))

