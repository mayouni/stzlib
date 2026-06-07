# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #456.
#ERR Error (R14) : Calling Method without definition: removeduplicatesq

load "../../stzBase.ring"

pr()

? Q("Riiiiinngg").
	CharsQ().
	RemoveDuplicatesQ().
	ToStzListOfStrings().
	Concatenated()

#--> "Ring"

pf()
# Executed in 0.02 second(s).
