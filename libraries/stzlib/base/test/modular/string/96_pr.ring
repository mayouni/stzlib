# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #96.

load "../../../stzBase.ring"


o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection = [10, 13],
	:Harvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)

#--> [ "<<", ">>>" ]

pf()
# Executed in 0.05 second(s)
