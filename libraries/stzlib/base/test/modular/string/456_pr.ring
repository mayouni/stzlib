# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #456.

load "../../../stzBase.ring"


? Q("Riiiiinngg").
	CharsQ().
	RemoveDuplicatesQ().
	ToStzListOfStrings().
	Concatenated()

#--> "Ring"

pf()
# Executed in 0.02 second(s).
