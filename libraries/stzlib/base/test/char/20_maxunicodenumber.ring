# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #20.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? MaxUnicodeNumber()
#--> 1114112

? UnicodeChar(1114113)
#--> ERR: Incorrect param type! p must be a number less then 1114112!

pf()
