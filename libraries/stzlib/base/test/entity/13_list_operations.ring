# Narrative
# --------
# List operations
#
# Extracted from stzentitytest.ring, block #13.
#ERR Error (R24) : Using uninitialized variable: olist

load "../../stzBase.ring"

pr()

? oList.IsEmpty()
#--> 0

? oList.UniqueTypes()
#--> ["device", "person", "vehicle"]

oList.Show()
#-->
# List of Entities (4 entities):
# ================================================
# 1. laptop (device)
# 2. alice (person)
# 3. bob (person)
# 4. truck (vehicle)

pf()
