### Juan Fernando Contreras Garcia
### Mariana Baquero Jara
### Codigo Uniandes: 202011873
### Codigo Uniandes: 202015009
### Update: 04/06/2024
### R version 4.3.2 (2023-10-31 ucrt)

#Limpiar el environment
rm(list=ls())

#Saber version de R.
R.version.string

#instalar/llamar pacman
require(pacman)


#uso la funcion p_load de pacman para instalar/llamar las librerias que se usaran en el problem set
p_load(rio, # funcion import/export: permite leer/escribir archivos desde diferentes formatos. 
       skimr, # funcion skim: describe un conjunto de datos
       janitor, # contiene conjuntos de datos
       tidyverse, # manipular/limpiar conjuntos de datos
       dplyr, #manipular dataframes
       data.table, # renombar variables
       sf,
       rvest,
       mapview,
       tmaptools,
       osmdata,
       ggplot2,
       viridis) 

#1.1 Obtener las URL

htmlprofe="https://eduard-martinez.github.io/pset-4.html"
pagina=read_html(htmlprofe)
url_full= pagina %>% html_nodes("a") %>% html_attr("href")

#1.2 Filtrar URL
url_subset=url_full[str_detect(url_full, pattern = "propiedad")]

#1.3 Extraer las tablas de los HTML
lista_tablas=list()

for (i in url_subset) {
  pagina=read_html(i)
  tabla=pagina %>% html_table(fill = TRUE)
  lista_tablas[[i]] =tabla[[1]]
}

db_house=rbindlist(lista_tablas)

db_house$geometry <- st_as_sfc(db_house$geometry, crs = 4326)

sf_house=st_as_sf(db_house, sf_column_name = "geometry")
class(sf_house)


bog <- opq(bbox = getbb("Bogota Colombia")) %>%
  add_osm_feature(key="boundary", value="administrative") %>% 
  osmdata_sf()
bog <- bog$osm_multipolygons %>% subset(admin_level==9 & !osm_id %in% 16011743:16011744)


mapa=ggplot() + geom_sf(data=bog) + geom_sf(data=sf_house, aes(color=price))+
  scale_fill_viridis(option = "A" , name = "Price")


ggsave("output/mapaps4.pdf", plot = mapa, width = 10, height = 6, device = "pdf")
