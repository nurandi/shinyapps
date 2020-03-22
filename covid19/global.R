# load libraries

library(shiny)
library(shinydashboard)
library(lubridate)
library(leaflet)
library(dplyr)
library(stringr)
library(DT)
library(plotly)
library(markdown)

# read csv data from Github

read_data <- function(url){
  data <- read.csv(url, stringsAsFactors = F) %>% 
    pivot_longer(cols = starts_with("X"),
                 names_to = "Day",
                 values_to = "Total") %>%
    group_by(Province.State, Country.Region, Long, Lat, Day) %>%
    summarise(Total = sum(Total)) %>%
    ungroup()
  return(data)
}

url_confirmed <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"
url_recovered <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv"
url_death <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"

confirmed <- read_data(url_confirmed)
recovered <- read_data(url_recovered)
death <- read_data(url_death)

all_data <- confirmed %>%
  left_join(recovered, by = c("Country.Region", "Province.State", "Day")) %>%
  left_join(death, by = c("Country.Region", "Province.State", "Day")) %>%
  mutate(Day = mdy(sub("X","", Day)),
         state = if_else(Province.State == "", Country.Region, Province.State, Province.State),
         active = Total.x - (Total.y + Total)) %>%
  group_by(Country.Region) %>%
  mutate(lon_country = mean(Long),
         lat_country = mean(Lat)) %>%
  ungroup() %>%
  select(country = Country.Region, 
         state = state,
         day = Day,
         lon = Long,
         lat = Lat,
         lon_country,
         lat_country,
         confirmed = Total.x,
         recovered = Total.y,
         death = Total,
         active)



# current day

current_day <- max(all_data$day)


# list of affected countries --> for dropdown menu

countryList <-
  all_data %>%
  filter(day == current_day) %>%
  group_by(country) %>%
  summarise(t = sum(confirmed)) %>%
  arrange(desc(t)) %>%
  select(country) %>%
  distinct() %>%
  pull(country)

countryListOption <- c("All Country" = "All", countryList)







  



