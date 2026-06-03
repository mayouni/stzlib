# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #76.

load "../../stzBase.ring"


o1 = new stzString("iloveringprogramminglanguage")
? o1.TheseSubStringsSpacified([ "php", "ruby", "programming" ]) # Only "programming" is spacified
						 		# because "php" and "ruby" do no
								# exist in the main string
#--> ilovering programming language

pf()
# Executed in 0.05 second(s)
