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
p_load(rio, # funcion import/export: permite leer/escribir archivos desde diferentes formatos
       skimr, # funcion skim: describe un conjunto de datos
       janitor, # contiene conjuntos de datos
       tidyverse, # manipular/limpiar conjuntos de datos
       dplyr, #manipular dataframes
       data.table, # renombar variables
       sf, #Manipular datos espaciales
       rvest, #Manipular HTML
       mapview, #Visualizar datos espaciales interactivamente
       tmaptools, #Para mapas y manipulacion de datos espaciales
       osmdata, #Manipular y descargar datos
       ggplot2, #Creacion de graficos
       viridis) #para la paleta de colores

#1.1 Obtener las URL

#Se crea una variable a la que se le asigna la URL de la pagina
htmlprofe="https://eduard-martinez.github.io/pset-4.html"
#Leer el contenido de la pagina y asignarlo en una variable
pagina=read_html(htmlprofe)
#Almacenar el vector de URLs contenidos en la pagina
url_full= pagina %>% html_nodes("a") %>% html_attr("href")

#1.2 Filtrar URL
url_subset=url_full[str_detect(url_full, pattern = "propiedad")]

#1.3 Extraer las tablas de los HTML
lista_tablas=list()

#Se crea un bucle que itera cada i (elemento) en url_subset
for (i in url_subset) {
  #Se crea la variable pagina para almacenar el contenido de la pagina web de cada iteracion
  pagina = read_html(i)
  #Se crea una variable "tabla" que almacena las tablar de la pagina y se utiliza "fill=TRUE" para las celdas faltantes
  tabla = pagina %>% html_table(fill = TRUE)
  #Se crea una lista que se le asigna la primera tabla (1) segun cada iteracion
  lista_tablas[[i]] = tabla[[1]]
}

#Se unen todas las tablas en el dataframe "db_house"
db_house=rbindlist(lista_tablas)

#Se convierte una columna de "db_house" en un SimpleFeature
db_house$geometry <- st_as_sfc(db_house$geometry, crs = 4326)

#Se convierte el dataframe a un SimpleFeature
sf_house=st_as_sf(db_house, sf_column_name = "geometry")
#Comprobar que sea SimpleFeature
class(sf_house)

#Se halla los datos de Bogota Colombia
bog <- opq(bbox = getbb("Bogota Colombia")) %>%
  #Segun administrativo
  add_osm_feature(key="boundary", value="administrative") %>% 
  #Ejecuto en SimpleFeature
  osmdata_sf()

#Solo administrativos del nivel 9 y excluyendo ciertos IDs
bog <- bog$osm_multipolygons %>% subset(admin_level==9 & !osm_id %in% 16011743:16011744)

#Se crea el mapa al usar ggplot
mapa=ggplot() + geom_sf(data=bog) + geom_sf(data=sf_house, aes(color=price))+
  scale_fill_viridis(option = "A" , name = "Price")

#Se guarda en un Pdf
ggsave("output/mapaps4.pdf", plot = mapa, width = 10, height = 6, device = "pdf")
