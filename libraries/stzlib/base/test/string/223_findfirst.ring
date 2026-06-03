# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #223.

load "../../stzBase.ring"

pr()

#		    1  456  901  
o1 = new stzString("___<<<__<<<__")

? o1.FindFirst("<<<")
#--> 4

? @@( o1.FindFirstAsSection("<<<") )
#--> [4, 6]

pf()
# Executed in 0.01 second(s) in Ring 1.21
