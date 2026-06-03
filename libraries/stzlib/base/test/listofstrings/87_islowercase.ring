# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #87.
#ERR Error (R14) : Calling Method without definition: islowercase

load "../../stzBase.ring"

pr()

o1 = new stzList([
	"tunis", "gafsa", "sfax", "beja", "gabes", "regueb"
])

? o1.IsLowercase()

pf()
# Executed in 0.06 second(s).
