# Narrative
# --------
# Removing entities
#
# Extracted from stzentitytest.ring, block #11.

load "../../stzBase.ring"


oList.RemoveEntity("ferrari")
? oList.NumberOfEntities()
#--> 4

? oList.ContainsName("ferrari")
#--> 0
