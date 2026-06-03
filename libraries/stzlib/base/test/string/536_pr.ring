# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #536.

load "../../stzBase.ring"


o1 = new stzString("what a <<nice>>> day!")
? o1.Sit(
	:OnPosition = 11, # the letter "i"
	:AndHarvest = [ :NCharsBefore = 1, :NCharsAfter = 2 ]
)
#--> [ "n", "ce" ]

pf()
# Executed in 0.03 second(s) in Ring 1.22
