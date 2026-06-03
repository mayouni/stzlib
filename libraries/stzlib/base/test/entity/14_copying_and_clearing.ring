# Narrative
# --------
# Copying and clearing
#
# Extracted from stzentitytest.ring, block #14.
#ERR Error (R24) : Using uninitialized variable: olist

load "../../stzBase.ring"

pr()

oListCopy = oList.Copy()
? oListCopy.NumberOfEntities()
#--> 4

oList.Clear()
? oList.IsEmpty()
#--> 1

? oListCopy.IsEmpty()
#--> 0

pf()
