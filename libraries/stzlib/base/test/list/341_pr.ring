# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #341.
#ERR Error (R11) : Error in class name, class not found: stztext

load "../../stzBase.ring"

pr()

? Stz(:Text, :Attributes)
#--> [
#	"@oobject",
#	"@cVarName",
#	"@oqstring",
#	"@@aconstraints",
#	"@clanguage"
# ]

pf()
# Executed in 0.03 second(s).
