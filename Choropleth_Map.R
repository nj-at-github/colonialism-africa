library(ggplot2)
library(sf)
library(dplyr)
library(viridis)
library(rnaturalearth)
library(rnaturalearthdata)
library(rnaturalearthhires)


world_map <- ne_countries(scale = "large", returnclass = "sf")


africa_map_sf <- world_map %>% filter(continent == "Africa")

library(devtools)
devtools::install_github("ropensci/rnaturalearthhires")

library(readxl)
dataset <- read_excel("C:\\Users\\Anand Gurazada\\Desktop\\journal article work\\choropleth_difference.xlsx")
View(dataset)


dataset <- dataset %>%
  mutate(name = case_when(
    name == "Ivory Coast" ~ "Côte d'Ivoire",
    name == "Tanzania" ~ "United Republic of Tanzania",
    name == "Swaziland" ~ "Eswatini",
    name == "Congo (Kinshasa)" ~ "Democratic Republic of the Congo",
    name == "Congo (Brazzaville)" ~ "Republic of the Congo",
    name == "Gambia" ~ "The Gambia",
    name == "Cape Verde" ~ "Cabo Verde",
    name == "Libya" ~ "Libyan Arab Jamahiriya",
    name == "South Sudan" ~ "S. Sudan",
    TRUE ~ name
  ))


africa_map_sf <- merge(africa_map_sf, dataset, by.x = "name", by.y = "name", all.x = TRUE)


africa_map_sf$value <- as.numeric(africa_map_sf$value)


head(africa_map_sf)


unique(africa_map_sf$name)


countries_to_remove <- c("W. Sahara", "Somaliland", "S. Sudan", "Bir Tawil", "São Tomé and Principe", "Cabo Verde")

africa_map_sf <- africa_map_sf %>%
  filter(!name %in% countries_to_remove)


unique(africa_map_sf$name)


"Mauritius" %in% africa_map_sf$name

mauritius <- data.frame(
  name = "Mauritius",
  geometry = st_sfc(st_point(c(57.5522, -20.3484)), crs = 4326)  
)


africa_map_sf <- rbind(africa_map_sf, st_as_sf(mauritius))

africa_map_sf <- merge(africa_map_sf, dataset, by.x = "name", by.y = "name", all.x = TRUE)


missing_cols <- setdiff(names(africa_map_sf), names(mauritius))

for (col in missing_cols) {
  mauritius[[col]] <- NA  
}


mauritius <- mauritius[names(africa_map_sf)]



dataset <- dataset %>%
  mutate(name = case_when(
    name == "Burkina" ~ "Burkina Faso",
    name == "Central African Republic" ~ "Central African Rep.",
    name == "Ivory Coast" ~ "Côte d'Ivoire",
    name == "Democratic Republic of the Congo" ~ "Dem. Rep. Congo",
    name == "Equatorial Guinea" ~ "Eq. Guinea",
    name == "Swaziland" ~ "eSwatini",
    name == "The Gambia" ~ "Gambia",
    name == "Republic of South Africa" ~ "South Africa",
    TRUE ~ name
  ))


africa_map_sf <- merge(africa_map_sf, dataset, by.x = "name", by.y = "name", all.x = TRUE)



ggplot(data = africa_map_sf) +
  geom_sf(aes(fill = value), color = "white") +
  geom_sf_text(aes(label = name), size = 0.9, color = "black", check_overlap = TRUE) +  
  scale_fill_gradient(low = "lightgray", high = "black") +  
  theme_minimal() +
  labs(fill = "Change in Adult Literacy Rate (%)", title = "Change in Adult Literacy Rate in Africa") +
  theme(axis.text = element_blank(), 
        axis.title = element_blank(), 
        legend.position = "bottom")
