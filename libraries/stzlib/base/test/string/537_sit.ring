# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #537.

load "../../stzBase.ring"

pr()

o1 = new stzString("what a <<nice>>> day!")

? @@( o1.Sit(
	:OnSection  = [10, 13], # or o1.FindAsSection("nice")
	:AndHarvestSections = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
) )
#--> [ [8, 9], [14, 16] ]

pf()
# Executed in 0.07 second(s) in Ring 1.22
