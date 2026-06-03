# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #31.

load "../../stzBase.ring"

pr()

	"How many roads must a man walk down",
	"Before you call him a man?",
	"How many seas must a white dove sail",
	"Before she sleeps in the sand?"
])

? o1.AlignedXT( :Width = :Max, :Char = "", :Direction = :Center )
	? o1.Aligned( :To = :Center )
	? o1.AlignedTo( :Center )
	? o1.AlignedToCenterXT( :Width = :Max, :Char = "" )
	? o1.CenterAlignedXT( :Width = :Max, :Char = "" )
	? o1.AlignedToCenter()
	? o1.CenterAligned()
	? o1.Centered()

pf()
