# Narrative
# --------
# Removing entities
#
# Extracted from stzentitytest.ring, block #11.
#ERR Error (R24) : Using uninitialized variable: olist

load "../../stzBase.ring"

pr()

oList.RemoveEntity("ferrari")
? oList.NumberOfEntities()
#--> 4

? oList.ContainsName("ferrari")
#--> 0

pf()
