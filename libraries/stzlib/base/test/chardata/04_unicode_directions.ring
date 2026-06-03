# Narrative
# --------
# Tests UnicodeDirectionsXT() -- the extended view of bidi class names.
# Indexing [5][3] picks the 3rd field of the 5th direction row, which is
# the canonical lowercase name "europeannumberterminator" (Unicode class
# ET). The XT variant adds metadata columns over the base list returned
# by UnicodeDirections().

load "../../stzBase.ring"

pr()

? UnicodeDirectionsXT()[5][3]
#--> europeannumberterminator

pf()
# Reference timing:
# - ~0s in Ring 1.23
