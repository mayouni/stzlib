# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #29.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([

	"How many roads must a man walk down",
	"Before you call him a man?",
	"How many seas must a white dove sail",
	"Before she sleeps in the sand?"
])

? o1.AlignedXT( :Width = :Max, :Char = "", :Direction = :Justified )
	? o1.Aligned( :To = :Right )
	? o1.AlignedTo( :Right )
	? o1.AlignedToRightXT( :Width = :Max, :Char = "" )
	? o1.RightAlignedXT( :Width = :Max, :Char = "" )
	? o1.AlignedToRight()
	? o1.RightAligned()

pf()
