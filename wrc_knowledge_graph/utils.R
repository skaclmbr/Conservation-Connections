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

get_properties <- function(name){
  pipeline <- sprintf(
    paste0(
      '[',
      '{ "$match" : {"name" : "%s"}},',
      '{ "$project" : { "properties": 1}},',
      '{ "$unwind" : { "path": "$properties"}}',
      ']'
    ),
    name
  )

  props <- nodes$aggregate(pipeline) %>%
    jsonlite::flatten() %>%
    gather(key = "type_rem", value = "value") %>%
    mutate(type = sub("properties.","",type_rem)) %>%
    subset(select = c("type", "value")) %>%
    filter(type != "_id")
  
  return(props)
}

get_categories <- function(name){
  pipeline <- sprintf(
    paste0(
      '[',
      '{ "$match" : {"name" : "%s"}},',
      '{ "$project" : { "categories": 1}},',
      '{ "$unwind" : { "path": "$categories"}}',
      ']'
    ),
    name
  )

  cats <- nodes$aggregate(pipeline) %>%
    subset(select = c("categories"))
  
  return(cats)
}

get_description <- function(name) {
    filter <- sprintf(
    '{"name": "%s"}',
    name
  )

  desc <- nodes$find(
    filter,
    '{"description":1}'
  )
  return(markdown(desc$description))
}

get_node_data <- function(name) {
  if (length(name) != 0){
    all_props <- get_properties(name)

    all_cats <- get_categories(name)

    all_edges <- get_connections(name)

    desc <- get_description(name)
    
    results <- list(
      cats = all_cats,
      props = all_props,
      edges = all_edges,
      description = desc
    )
    print("gnd function completed")
    print(head(results$edges))
    return(results)
  } else {
    return("")
  }
}

get_connections <- function(name) {
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
    name
  )
  edges <- nodes$aggregate(pipeline) %>% 
    subset(select = c("node", "type"))
  print("connections retrieved")
  print(head(edges))
  return(edges)
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