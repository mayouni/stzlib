# Narrative
# --------
# Removing entities
#
# Extracted from stzentitytest.ring, block #11.

load "../../stzBase.ring"

pr()

oList.RemoveEntity("ferrari")
? oList.NumberOfEntities()
#--> 4

? oList.ContainsName("ferrari")
#--> 0

pf()
