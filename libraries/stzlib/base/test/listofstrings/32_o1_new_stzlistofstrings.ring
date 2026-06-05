# Narrative
# --------
# o1 = new stzListOfStrings([
#
# Extracted from stzlistofstringstest.ring, block #32.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([

	"How many roads must a man walk down",
	"Before you call him a man?",
	"How many seas must a white dove sail",
	"Before she sleeps in the sand?"
])

? o1.JustifiedXT( :Width = 50, :Char = " " )
#-->
# H o w   m a n y   r o a d s   must a man walk down
# B e f o r e   y o u   c a l l   h i m   a   m a n?
# H o w   m a n y   s e a s   must a white dove sail
# B e f o r e   s h e   s l e e p s   i n  the sand?

? o1.Justified()
#-->
# H ow many roads must a man walk down
# B e f o r e   y o u  call him a man?
# How many seas must a white dove sail
# B e f o r e  she sleeps in the sand?

//? o1.AlignedXT( :Max, ".", :Justify )

pf()
