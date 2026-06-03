# Narrative
# --------
# Filtering and sorting
#
# Extracted from stzentitytest.ring, block #12.

load "../../stzBase.ring"


oPersonsList = oList.FilterByType("person")
? oPersonsList.NumberOfEntities()
#--> 2

oList.SortByName()
? oList.Names()
#--> ["alice", "bob", "laptop", "truck"]

oList.SortByType()
? oList.Types()
#--> ["device", "person", "person", "vehicle"]
