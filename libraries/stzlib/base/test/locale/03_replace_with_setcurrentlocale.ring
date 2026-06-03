# Narrative
# --------
# #TODO Replace with SetCurrentLocale()
#
# Extracted from stzlocaletest.ring, block #3.
#ERR Error (R3) : Calling Function without definition: setdefaultlocale

load "../../stzBase.ring"


pr()

SetDefaultLocale("ar-TN")
? DefaultLocale() #--> ar-TN

pf()
