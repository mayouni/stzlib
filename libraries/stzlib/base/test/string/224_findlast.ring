# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #224.

load "../../stzBase.ring"

pr()

#		    1  456  901  
o1 = new stzString("___<<<__<<<__")

? o1.FindLast("<<<")
#--> 9

? @@( o1.FindLastAsSection("<<<") )
#--> [9, 11]

pf()
# Executed in 0.01 second(s) in Ring 1.21
