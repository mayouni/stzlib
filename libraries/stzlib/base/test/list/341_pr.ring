# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #341.
#ERR Error (R14) : Calling Method without definition: isstzclassname

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
