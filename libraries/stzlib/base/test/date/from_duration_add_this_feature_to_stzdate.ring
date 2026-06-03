# Narrative
# --------
# #TODO Add this feature to stzDate
#
# Extracted from stzdurationtest.ring, block #7.
#ERR Error (R3) : Calling Function without definition: todate

load "../../stzBase.ring"


pr()

ToDate("20250912")

o1 = new stzDate("20250912")
? o1.Content()

pf()
