# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #460.

load "../../stzBase.ring"


? Q("(9, 7, 8)").
	RemoveCharsWXTQ('Q(@Char).IsNumberInString()'). # becomes (, , )
	RemoveSpacesQ().			 	# becomes (,,)
	RemoveDuplicatedCharsQ().		 	# becomes (,)
	Content()

#--> (,)

pf()
# Executed in 0.17 second(s) in Ring 1.22
