rm(list=ls())

library(rvest)
library(NLP)
library(openNLP)
library(ggmap)
library(rworldmap)


page = read_html('https://en.wikipedia.org/wiki/Coca-Cola')

text = html_text(html_nodes(page,'p'))
text = text[text != ""]
text = gsub("\\[[0-9]]|\\[[0-9][0-9]]|\\[[0-9][0-9][0-9]]","",text) # removing refrences [101] type

# Make one complete document
text = paste(text,collapse = " ") 

text = as.String(text)

sent_annot = Maxent_Sent_Token_Annotator()
word_annot = Maxent_Word_Token_Annotator()
loc_annot = Maxent_Entity_Annotator(kind = "location")

annot.l1 = NLP::annotate(text, list(sent_annot,word_annot,loc_annot))

k <- sapply(annot.l1$features, `[[`, "kind")
coke_locations = text[annot.l1[k == "location"]]


## +++ some downstream analysis with above data +++ ##
##

# We could do much with this info, e.g., improve lists by editing them with external domain knowledge, etc. 
# E.g., geocode the locations and create a map of the world of each article. 

all_places = unique(coke_locations) # view contents of this obj

all_places_geocoded <- geocode(all_places) #[1:10]
all_places_geocoded # view contents of this obj

newmap <- getMap(resolution = "high")
plot(newmap, 
     # xlim = c(-20, 59), ylim = c(35, 71),   # can select 'boxes' of lat-lon to focus on
     asp = 1)

points(all_places_geocoded$lon, 
       all_places_geocoded$lat, 
       col = "red", cex = 1.2, pch = 19)

