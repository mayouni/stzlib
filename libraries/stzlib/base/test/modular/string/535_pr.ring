# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #535.

load "../../../stzBase.ring"


o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection  = [10, 13], # or o1.FindAsSection("nice")
	:AndHarvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)
#--> [ "<<", ">>>" ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
