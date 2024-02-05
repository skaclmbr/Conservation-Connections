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