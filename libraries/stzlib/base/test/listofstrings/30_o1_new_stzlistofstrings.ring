# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #30.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([

	"How many roads must a man walk down",
	"Before you call him a man?",
	"How many seas must a white dove sail",
	"Before she sleeps in the sand?"
])

? o1.AlignedXT( :Width = :Max, :Char = "", :Direction = :Left )
	? o1.Aligned( :To = :Left )
	? o1.AlignedTo( :Left )
	? o1.AlignedToLeftXT( :Width = :Max, :Char = "" )
	? o1.LeftAlignedXT( :Width = :Max, :Char = "" )
	? o1.AlignedToLeft()
	? o1.LeftAligned()

pf()
