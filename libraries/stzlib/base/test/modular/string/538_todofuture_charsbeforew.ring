# Narrative
# --------
# TODO/FUTURE :CharsBeforeW
#
# Extracted from stzStringTest.ring, block #538.

load "../../../stzBase.ring"


pr()

o1 = new stzString("what a 123nice>>> day!")

? o1.Sit(
	:OnSection  = o1.FindFirstAsSection("nice"),
	:AndHarvest = [ :CharsBeforeW = 'Q(@char).IsANumber()', :NCharsAfter = 3 ]
)
#--> [ "123", ">>>" ]

pf()
