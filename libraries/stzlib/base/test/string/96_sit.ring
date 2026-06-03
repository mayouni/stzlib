# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #96.
#ERR Error (R14) : Calling Method without definition: sit

load "../../stzBase.ring"

pr()

o1 = new stzString("what a <<nice>>> day!")

? o1.Sit(
	:OnSection = [10, 13],
	:Harvest = [ :NCharsBefore = 2, :NCharsAfter = 3 ]
)

#--> [ "<<", ">>>" ]

pf()
# Executed in 0.05 second(s)
