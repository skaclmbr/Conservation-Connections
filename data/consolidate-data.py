# consolidate data from xml to JSON format
# Scott K Anderson
# skaclmbr
# Purpose: experimenting with building a conservaiton knowledge graph


import os
import csv
import json
import numbers

# import xml file
folder = os.path.dirname(os.path.abspath(__file__)) #retrieves the current file location as the base folder
csv_props = "/".join([folder, "properties.csv"])
csv_wikit = "/".join([folder, "wikitext.csv"])
csv_cats = "/".join([folder, "categories.csv"])
csv_nodes = "/".join([folder, "entities.csv"])
cc_json_out = "/".join([folder, "cc.json"])
cc_data = open(cc_json_out, "w", encoding="utf-8")

cc_json = {}


def cv(v):
    #test to convert value to correct format
    r = v
    if v in ["true", "false"]:
        if v == "true":
            r = 1
        else:
            r = 0
    else:
        try:
            r = int(v)
        except:
            try:
                r = float(v)
            except:
                r = v

    return r

# wthtml = {
#     "=" : "<h1>",
#     "==" : "<h2>",
#     "===" : "<h3>",
#     "====" : "<h4>"
# }
# def html_close(t):
#     t = t[:1] + "/" + t[1:]


# def wt_to_html (t):
#     #### DOES NOT WORK YET
#     # convert wikitext to html
#     html = ""
#     pos = 1

#     in_open = False
#     in_bracket = False
#     in_end = False
#     bracket = ""
#     pos_open = 0
#     bracket_html = ""

#     prev_char = ""
#     for s in t:

#         if s == "=":
#             if prev_char == s:
#                 #keep building
#                 bracket += s
#             else:
#                 if in_bracket:
#                     #close the bracket

#                 else:
#                     #open the bracket
#                     pos_open = len(html)
#                     html += wthtml(bracket) #add the opening bracket to html
#                     in_bracket = True
#         else:
#             html += s

#         prev_char = s
        
        

#         pos += 1
    

def main():
    # LOAD NODES
    with open(csv_nodes ) as csv_file:
        reader = csv.reader(csv_file, delimiter = ',', quotechar='"')
        count = 1
        for r in reader:
            if  count != 1: #skip first row
                cc_json[r[1]] = {}
                cc_json[r[1]]["name"] = r[1]
                cc_json[r[1]]["type"] = r[0]
                cc_json[r[1]]["properties"] = {}
                cc_json[r[1]]["categories"] = []
                cc_json[r[1]]["edges"] = []
                cc_json[r[1]]["description"] = ""

            count += 1
    csv_file.close()
    nodes = cc_json.keys()
    # LOAD PROPERTIES AND EDGES
    with open(csv_props, encoding="utf-8" ) as csv_file:
        reader = csv.reader(csv_file, delimiter = ',', quotechar='"')
        count = 1
        for r in reader:
            if count !=1:
                cn = r[0]
                #check to see if property or edge
                if (r[2] in nodes) & (r[2] != cn): # EDGE

                    cc_json[cn]["edges"].append(r[2])
                else: #PROPERTY
                    cc_json[cn]["properties"][r[1]] = cv(r[2])
            count +=1
    csv_file.close()

    # LOAD CATEGORIES
    with open(csv_cats, encoding="utf-8" ) as csv_file:
        reader = csv.reader(csv_file, delimiter = ',', quotechar='"')
        count = 1
        for r in reader:
            if count !=1:
                cn = r[0]
                #check to see if property or edge
                cc_json[cn]["categories"].append(r[1])
                
            count +=1
    csv_file.close()

    # LOAD wikitext
    with open(csv_wikit, encoding="utf-8" ) as csv_file:
        reader = csv.reader(csv_file, delimiter = ',', quotechar='"')
        count = 1
        for r in reader:
            if count !=1: #skip first row
                cn = r[0]
                #check to see if property or edge
                cc_json[cn]["description"] = r[1]
            count +=1
    csv_file.close()


    cc_json_array = []
    for v in cc_json.values():
        cc_json_array.append(v)

    json.dump(cc_json_array, cc_data)

if __name__ == '__main__':
	main()