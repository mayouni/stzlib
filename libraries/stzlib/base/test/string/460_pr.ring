# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #460.
#ERR Error (R14) : Calling Method without definition: removecharswxtq

load "../../stzBase.ring"

pr()

? Q("(9, 7, 8)").
	RemoveCharsWXTQ('Q(@Char).IsNumberInString()'). # becomes (, , )
	RemoveSpacesQ().			 	# becomes (,,)
	RemoveDuplicatedCharsQ().		 	# becomes (,)
	Content()

#--> (,)

pf()
# Executed in 0.17 second(s) in Ring 1.22
