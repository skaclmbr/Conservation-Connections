#############################################################################
# Functions for Connecting to Databases



#############################################################################
# MongoDB
# this is a read only account
HOST = "cluster0-shard-00-00.rzpx8.mongodb.net:27017"
source("config.r")

#############################################################################
## WILDLIFE ACTION PLAN

## Mongo Connection Parameters
WAP_URI = sprintf(
    paste0(
        "mongodb://%s:%s@%s/%s?authSource=admin&replicaSet=",
        "atlas-3olgg1-shard-0&readPreference=primary&ssl=true"
        ),
    USER,
    PASS,
    HOST,
    "conservation_connections")

nodes <- mongo(
    "nodes",
    url = WAP_URI,
    options = ssl_options(weak_cert_validation = T)
)


## Functions
get_all_list <- function() {
  pipeline <- paste0(
    '[',
    '{ "$project" : { "name": 1, "type": 1}}',
    ']'
  )
  r <- nodes$aggregate(pipeline)
  r[, 2:3]
}

get_types <- function() {
  pipeline <- paste0(
    '[',
    '{ "$group" : { "_id" : "$type",',
    '"count" : { "$sum" : 1}}}',
    ']'
  )
  nodes$aggregate(pipeline)
}

get_properties <- function(node){
  pipeline <- sprintf(
    paste0(
      '[',
      '{ "$match" : {"name" : "%s"}},',
      '{ "$project" : { "name" : 1, "properties": 1}}',
      # '{ "$unwind" : { "path": "$properties"}}',
      ']'
    ),
    node
  )
  print(pipeline)
  props <- nodes$aggregate(pipeline)
  print(props)
  props <- props %>%
    enter_object("properties") %>%
    gather_object("type") %>%
    append_values_string("value") %>%
    select(c("type", "value")) %>%
    as_data_frame.tbl_json()

  print(props)
}

get_node_data <- function(name) {
  #code to retrieve node information and store in this object
  filter <- sprintf('{ "name" : "%s"}', name)

  data <- nodes$find(filter, '{ "description" : 0}')
  data <- jsonlite::toJSON(data)[0]
  # data <- '{ "name": "American Oystercatcher", "type": "Species", "properties": { "Has AOS4 Code": "AMOY", "Has AOS59 Code": 446, "Has AOS6 Code": "HAEPAL", "Has AOS60 Code": 388, "Has Audubon Conservation Plan": 1, "Has Avibase Code": "981CE782575DD8E7", "Has Common Name": "American Oystercatcher", "Has eBird Code": "ameoys", "Has Family": "Haematopodidae", "Has Genus": "Haematopus", "Has Order": "Charadriiformes", "Has PIF Half Life": 0, "Has PIF Pop Est": 11000, "Has Plan": "South Atlantic Migratory Bird Initiative Implmentation Plan 2008", "Has Scientific Name": "Haematopus palliatus", "Has Species Taxonomy": "palliatus", "Has State Status": "special concern", "Has WAP15 ID": "ncwap15-spp-american-oystercatcher", "Is Audubon Priority": 1, "Is NC Present": "NC", "Is SGCN": 1, "Is WAP Management Concern": 1, "Present Breeding": 1, "Present Wintering": 1, "Was WAP Evaluated": 1 }, "categories": [ "Species", "Bird", "Charadriiformes", "Haematopodidae", "NC SGCN", "NC Management Concern" ], "edges": [ "Estuarine Wetland Communities", "Maritime Grasslands", "Sand, Shell, and Wrack Active Shoreline", "Atlantic Flyway Shorebird Business Strategy 2013", "Conservation Plan For The American Oystercatcher 2007", "American Oystercatcher Working Group", "South Atlantic Migratory Bird Initiative Implementation Plan 2008", "NCWAP 2015 Conservation Programs And Partnerships Priority 380", "NCWAP 2015 Surveys Priority 361" ] }'
  print(data)
  # props <- data
  props <- data %>%
    as.tbl_json() %>%
    enter_object("properties") %>%
    gather_object("type") %>%
    append_values_string("value") %>%
    select(c("type", "value")) #%>%
    # as_data_frame.tbl_json()

  print(props)
  cats <- data %>%
    as.tbl_json() %>%
    enter_object("categories") %>%
    gather_array("type") %>%
    as_data_frame.tbl_json()

  print(cats)
  edges <- ""

  description <- ""

  results <- list(
    name = name,
    cats = cats,
    props = props,
    edges = edges,
    description = description
  )
  return(results)
}

get_connections <- function(n) {
  pipeline <- sprintf(
    paste0(
      '[',
      '{ "$match" : { "name" : "%s"}},',
      #start graphLookup
      '{"$graphLookup" : {',
      '"from" : "nodes",',
      '"startWith" : "$edges",',
      '"connectFromField" : "edges",',
      '"connectToField" : "name",',
      '"as" : "connections",',
      '"maxDepth" : 1',
      '} },', #end graphLookup
      '{ "$project" : { "connections" : 1}}, ',
      '{ "$unwind" : {"path" : "$connections"}},',
      '{ "$project" : { ',
      '"node" : "$connections.name",',
      '"type" : "$connections.type"',
      '}}',
      ']'
    ),
    n
  )

  nodes$aggregate(pipeline)
}

get_dd_list <- function(type) {
  pipeline <- sprintf(
    paste0(
      '[{ "$match": { "type": "%s" }},',
      ' { "$project": { "name" : 1 }},',
      ' { "$sort": { "name" : 1 }}',
      ']'
    ),
    type
  )
  
  list <- nodes$aggregate(pipeline)
  
  list$title
}