if(!require(tidyverse)) install.packages(
  "tidyverse", repos = "http://cran.us.r-project.org")

if(!require(tidyjson)) install.packages(
  "tidyjson", repos = "http://cran.us.r-project.org")
  
if(!require(mongolite)) install.packages(
  "mongolite", repos = "http://cran.us.r-project.org")



node <- '{ "name": "American Oystercatcher", "type": "Species", "properties": { "Has AOS4 Code": "AMOY", "Has AOS59 Code": 446, "Has AOS6 Code": "HAEPAL", "Has AOS60 Code": 388, "Has Audubon Conservation Plan": 1, "Has Avibase Code": "981CE782575DD8E7", "Has Common Name": "American Oystercatcher", "Has eBird Code": "ameoys", "Has Family": "Haematopodidae", "Has Genus": "Haematopus", "Has Order": "Charadriiformes", "Has PIF Half Life": 0, "Has PIF Pop Est": 11000, "Has Plan": "South Atlantic Migratory Bird Initiative Implmentation Plan 2008", "Has Scientific Name": "Haematopus palliatus", "Has Species Taxonomy": "palliatus", "Has State Status": "special concern", "Has WAP15 ID": "ncwap15-spp-american-oystercatcher", "Is Audubon Priority": 1, "Is NC Present": "NC", "Is SGCN": 1, "Is WAP Management Concern": 1, "Present Breeding": 1, "Present Wintering": 1, "Was WAP Evaluated": 1 }, "categories": [ "Species", "Bird", "Charadriiformes", "Haematopodidae", "NC SGCN", "NC Management Concern" ], "edges": [ "Estuarine Wetland Communities", "Maritime Grasslands", "Sand, Shell, and Wrack Active Shoreline", "Atlantic Flyway Shorebird Business Strategy 2013", "Conservation Plan For The American Oystercatcher 2007", "American Oystercatcher Working Group", "South Atlantic Migratory Bird Initiative Implementation Plan 2008", "NCWAP 2015 Conservation Programs And Partnerships Priority 380", "NCWAP 2015 Surveys Priority 361" ] }'

node <- tidyjson::as.tbl_json(node)

props <- node %>% 
    enter_object("properties") %>% 
    gather_object("type") %>% 
    append_values_string("value") %>%
    select(c("type", "value")) %>%
    as_data_frame.tbl_json()
