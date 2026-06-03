# Narrative
# --------
# Filtering and sorting
#
# Extracted from stzentitytest.ring, block #12.
#ERR Error (R24) : Using uninitialized variable: olist

load "../../stzBase.ring"

pr()

oPersonsList = oList.FilterByType("person")
? oPersonsList.NumberOfEntities()
#--> 2

oList.SortByName()
? oList.Names()
#--> ["alice", "bob", "laptop", "truck"]

oList.SortByType()
? oList.Types()
#--> ["device", "person", "person", "vehicle"]

pf()
