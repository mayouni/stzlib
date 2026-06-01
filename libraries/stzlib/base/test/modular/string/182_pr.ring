# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #182.

load "../../../stzBase.ring"


# 		         6       4
o1 = new stzString("...<<*>>...<<*>>...")
? @@( o1.FindAsSectionsXT( "*", :Between = [ "<<", ">>" ]) )
#--> [ [ 6, 6 ], [ 14, 14 ] ]

pf()
# Executed in 0.01 second(s) in Ring 1.21
