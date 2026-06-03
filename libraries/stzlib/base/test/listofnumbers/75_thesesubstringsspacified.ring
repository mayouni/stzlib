# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #75.

load "../../stzBase.ring"

pr()

o1 = new stzString("iloveringprogramminglanguage")
? o1.TheseSubStringsSpacified([ "php", "ruby" ]) # Nothing happens because these substrings
						 # do not exist in the main string
#--> iloveringprogramminglanguage

pf()
# Executed in 0.02 second(s)
